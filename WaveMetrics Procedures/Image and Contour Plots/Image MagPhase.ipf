// This package performs 2D FFTs on matrix data and shows the results 
// as separate magnitude and phase images or as a combined mag/phase image.
// It adds ImageMagPhase to the Macros menu.
//
// In the dialog from ImageMagPhase:
// Normally, a magnitude only plot is approprate because phase is hard
// to interpret. The combined mag/phase image shows the magnitude as
// intensity and the phase as color (red-green)
// If you don't choose zero in center and your input data is real, the zero frequency
// in the rows dimension will be at the left edge of the image.


#include <Autosize Images>

#pragma rtGlobals= 1


Macro  ImageMagPhase(w,zeroInCenter,magScaleMode,resultMode)
	String w=  StrVarOrDefault("root:Packages:WMImagesMagPhase:wNameSav","")
	Prompt w,"matrix wave:", Popup WaveList("*",";","")
	Variable zeroInCenter=  NumVarOrDefault("root:Packages:WMImagesMagPhase:zicSav",0)+1
	Prompt zeroInCenter,"zero frequency in center:", Popup "No;Yes"
	Variable magScaleMode= NumVarOrDefault("root:Packages:WMImagesMagPhase:msmSav",2)+1
	Prompt magScaleMode,"Magnitude:", Popup "Linear;Sqrt;Log"
	Variable resultMode= NumVarOrDefault("root:Packages:WMImagesMagPhase:rmSav",2)+1
	Prompt resultMode,"Result Mode:", Popup "Magnitude;Mag and Phase;Combined MagPhase;All"
	
	 ImageMagPhaseCombined($w,zeroInCenter-1,magScaleMode-1,resultMode-1)
end

//	resultMode:
//	0 -> magnitude
//	1 -> magnitude and phase in different images
//	2 -> combinded mag and phase in one image where mag controls the intensity
//		and phase controls the color (red-green)
//	3 -> all of the above
//	Note: if you choose zeroInCenter, you may note the phase is not symmetrical. This is
//	because the negative frequencies are the complex conj of the positive frequencies
//	If your original data is complex, zero will automatically be in the center
//	Note: in all cases the dc component (zero freq in x and y) is zeroed so it does not
//	overwhelm the rest of the data.
Function ImageMagPhaseCombined(w,zeroInCenter,magScaleMode,resultMode)
	Wave w
	Variable zeroInCenter		// set true if you want zero frequence to be in center (uses more mem)
	Variable magScaleMode		// use zero for linear, 1 for sqrt(), 2 for log
	Variable resultMode			// see above comment


	// Remember input for next time
	String dfSav= GetDataFolder(1);
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMImagesMagPhase
	String/G wNameSav= NameOfWave(w)
	Variable/G zicSav= zeroInCenter
	Variable/G msmSav= magScaleMode
	Variable/G rmSav= resultMode
	SetDataFolder dfSav
	
	Variable wantMag=  (resultMode==0) %| (resultMode==1) %| (resultMode==3)
	Variable wantPhase= (resultMode==1) %| (resultMode==3)
	Variable wantCombined= (resultMode==2) %| (resultMode==3)
	
	String magName= NameOfWave(w)+"_Mag"
	if( wantMag )
		magName= "::"+magName		// make mag outside tmp data folder
	endif
	String PhaseName= NameOfWave(w)+"_Phase"
	if( wantPhase )
		PhaseName= "::"+PhaseName	// make phase outside tmp data folder
	endif
	NewDataFolder/O/S IMPtmp		// give tmp DF a unique name in case we need to leave it around for debug

	Duplicate/O w,$magName
	Wave rmag= $magName
	
	if( (DimSize(w,0) %& 1) )
		zeroInCenter= 1;				// force data to complex if num rows is odd. (requirement of fft)
	endif

	if( WaveType(w) %& 4 )			// original data doubles?
		if( zeroInCenter )
			Redimension/C rmag		// C to make complex for zero in cent
		endif
	else
		if( zeroInCenter )
			Redimension/S/C rmag		// S in case it was an integer, C to make complex for zero in cent
		else
			Redimension/S rmag		// S in case it was an integer
		endif
	endif
	FFT rmag							// rmag may or may not be real
	Wave/C cmag= rmag				// at times mag will be real and complex; pick one
	
	// the following creates separate real valued mag and phase waves
	cmag= r2polar(cmag)
	Duplicate/O cmag,$PhaseName
	Wave rPhase= $PhaseName
	Redimension/R rPhase
	rPhase= imag(cmag)
	Redimension/R cmag

	// this zeros the dc component of the mag
	Variable p0= x2pnt(rmag,0)
	Variable q0= (0 - DimOffset(rmag, 1))/DimDelta(rmag,1)	// equiv of y2pnt
	rmag[p0][q0]= 0

	if( magScaleMode==1 )
		rmag= sqrt(rmag)
	else
		if( magScaleMode==2 )
			rmag= log(rmag)
		endif
	endif
	
	if( wantCombined )
		String resultWave= NameOfWave(w)+"_MPC"
		String cindexWave= NameOfWave(w)+"_CIndex"
		
		Duplicate/O cmag,::$resultWave
		Wave rw= ::$resultWave
		Redimension/B/U rw
	
		Variable nmags= 20,nphases=8
		Make/N=(20*nphases,3)/W/U/O ::$cindexWave
		Wave mpColors= ::$cindexWave
		mpColors[][0]=65535*(mod(p,nphases)/(nphases-1))*floor(p/nphases)/(nmags-1)
		mpColors[][1]=65535*(((nphases-1)-mod(p,nphases))/(nphases-1))*floor(p/nphases)/(nmags-1)
		mpColors[][2]=0
		
		WaveStats/Q rmag
		rw= round(nmags*((rmag-V_min)/(V_max-V_min)))*nphases +   floor(0.001+(rPhase+pi)*(nphases-1)/(2*pi))
		CheckDisplayed/A rw
		if( V_Flag == 0 )
			Display as "Combined Mag/Phase";AppendImage rw;ModifyImage $resultWave cindex= mpColors
			DoAutoSizeImage(0,1)
			AutoPositionWindow/E
		endif
	endif
	if( wantMag )
		CheckDisplayed/A rmag
		if( V_Flag == 0 )
			Display as "Magnitude";AppendImage rmag;ModifyImage $NameOfWave(rmag)  ctab= {*,*,Grays}
			DoAutoSizeImage(0,1)
			AutoPositionWindow/E
		endif
	endif
	if( wantPhase )
		CheckDisplayed/A rPhase
		if( V_Flag == 0 )
			Display as "Phase";AppendImage rPhase;ModifyImage $NameOfWave(rPhase)  ctab= {*,*,RedWhiteBlue}
			DoAutoSizeImage(0,1)
			AutoPositionWindow/E
		endif
	endif
	KillDataFolder :
end


