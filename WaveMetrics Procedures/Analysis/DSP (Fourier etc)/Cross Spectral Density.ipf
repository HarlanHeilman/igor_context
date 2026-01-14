#pragma rtGlobals=1		// Use modern global access method.

// 12APR00 
// The following functions have been converted from the original PSD macros.
// They take two waves U and V (assumed to be the same length), break them down into smaller segments Ui and Vi.
// Each segment is FFT'ed and then the two transforms are multiplied as in
// FT{Ui} * conj( FT{Vi}).   
// The sum of the contributions from all segments is normalized at for an output.
// Additional details: the FT{} involves using a Hanning window function, and the normalization
// also takes into account the associated x values for the segments.
// The normalization results in what is sometimes refered to as the degree of correlation or degree of coherence.
// LH041108: made code use tmp and output waves of the same numeric type as the input. Previously would
// give an error if used double precision waves.
// LH050624: fixed goof from  LH041108. (W_NCSD and W_CSD need to be complex.)

Menu "Macros"
"Calc_Cross_Spectral_Density", CDSGUI();
End

// this is just used as a prototype for the FuncRef
Function theFunc(wx,wy,seglen)
	Wave wx,wy
	variable seglen
End

Function CDSGUI()
	String strWave1=""
	String strWave2=""
	Variable segmentLength=256
	Variable normalize=1					// normalization off
		
	Prompt strWave1 "First wave:",popup WaveList("*",";","")
	Prompt strWave2 "Second wave:",popup WaveList("*",";","")
	Prompt normalize "Normalization:",popup "OFF;ON"
	Prompt segmentLength,"Segment length:"
	DoPrompt "Cross-Spectral Density Parameters:", strWave1,strWave2,segmentLength,normalize

	if(segmentLength<10)
		Abort  "Segment length must be greater than 10."
	endif
	
	FUNCREF theFunc f=CSD
	
	if(normalize==2)
		FUNCREF theFunc f=NCSD
	endif
	
	Wave/Z w1=$strWave1
	Wave/Z w2=$strWave2
	if((WaveExists(w1)!=0) && (WaveExists(w2)!=0))
		f(w1,w2,segmentLength)
	else
		Print "Bad wave specification.\r"
	endif
End


// calculates the cross-spectral density of two waves wx, wy by breaking each into smaller segments that are FFT'ed
// multiplied and averaged.

Function CSD(wx,wy,seglen)
	Wave wx,wy
	variable seglen
	        
	Variable i
	Variable numPoints=DimSize(wx,0)
	
	if(DimSize(wy,0)!=numPoints)
		DoAlert 0, "The two waves must have the same number of points."
		return 0
	endif
	
	if(seglen<4)
		DoAlert 0, "Segment length must be greater than 4."
		return 0
	endif
	
	variable npsd=seglen    			 
	variable psdOffset=npsd/2     	 
	variable psdFirst=0           
	variable nsrc=numpnts(wx)                
	
	variable delta=(rightx(wx)-leftx(wx))/nsrc   
	variable numSegments=numPoints/seglen     
	  
	if( npsd > nsrc/2 )
		Abort "CSD : the signal must be MUCH longer than the segments"
		return 0
	endif

	make/o/c/n=(npsd/2+1)/Y=(WaveType(wx)|1) W_CSD=0
	
	NewDataFolder/S  wm_tmp
	Make/o/n=(npsd)/Y=(WaveType(wx)) srctmpx,srctmpy,winw=1
	
	Hanning winw
	Variable winNorm=3/8                
	Variable npsdm1=npsd-1
	
        for(i=0;i<numSegments;i+=1)
		Duplicate/O/R=[psdFirst,psdFirst+npsdm1] wx srctmpx; 
		FastOp srctmpx=srctmpx*winw
		Duplicate/O/R=[psdFirst,psdFirst+npsdm1] wy srctmpy; 
		FastOp srctmpy=srctmpy*winw
		fft srctmpx;   
		fft srctmpy;   
		W_CSD +=srctmpx*conj(srctmpy);  
		psdFirst +=psdOffset;
	endfor

	CopyScales/P srctmpx,W_CSD
	winNorm=2*delta/(winNorm*numSegments*npsd); 
	W_CSD *=winNorm
 	KillDataFolder :													// cleanup
End


// calculates the normalized cross-spectral density of two waves wx, wy 
// or the degree of coherence/correlation. 

Function NCSD(wx,wy,seglen)
	Wave wx,wy
	variable seglen
	        
	Variable i
	Variable numPoints=DimSize(wx,0)
	
	if(DimSize(wy,0)!=numPoints)
		DoAlert 0, "The two waves must have the same number of points."
		return 0
	endif
	
	if(seglen<2)
		DoAlert 0, "Segment length must be greater than 2."
		return 0
	endif
	
	variable npsd=seglen    			 
	variable psdOffset=npsd/2     	 
	variable psdFirst=0           
	variable nsrc=numpnts(wx)                
	
	variable delta=(rightx(wx)-leftx(wx))/nsrc   
	variable numSegments=numPoints/seglen     
	  
	if( npsd > nsrc/2 )
		Abort "PSD2 : the signal must be MUCH longer than the segments"
		return 0
	endif

	make/o/c/n=(npsd/2+1)/Y=(WaveType(wx)|1) W_NCSD=0
	
	NewDataFolder/S  wm_tmp
	Make/o/n=(npsd)/Y=(WaveType(wx)) srctmpx,srctmpy,winw=1
	Make/o/n=(npsd)/Y=(WaveType(wx)) ssx=0,ssy=0
	
	Hanning winw
	Variable winNorm=3/8                
	Variable npsdm1=npsd-1
	
        for(i=0;i<numSegments;i+=1)
		Duplicate/O/R=[psdFirst,psdFirst+npsdm1] wx srctmpx; 
		FastOp srctmpx=srctmpx*winw								// Hanning window
		Duplicate/O/R=[psdFirst,psdFirst+npsdm1] wy srctmpy; 
		FastOp srctmpy=srctmpy*winw								// Hanning window
		fft srctmpx;   
		fft srctmpy;   
		W_NCSD +=srctmpx*conj(srctmpy);  						// < VU*> 
		ssx+=magsqr(srctmpx)
		ssy+=magsqr(srctmpy)
		psdFirst +=psdOffset;
	endfor

	CopyScales/P srctmpx,W_NCSD
	// The result here should be a normalized quantity whose real and imaginary parts
	// should be between -1 and 1 (Schwartz inequality).  Since the scaling of all
	// 3 waves is the same, there is no need here to correct for the window's normalization.
	W_NCSD /= sqrt(ssx*ssy)
 	KillDataFolder :													// cleanup
End
