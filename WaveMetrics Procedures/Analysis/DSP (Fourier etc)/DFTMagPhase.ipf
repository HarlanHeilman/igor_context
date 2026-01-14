#include <BringDestToFront>

// Given an input wave (which doesn't require a length that is a power of two),
// create a new wave with the suffix "_dMag" that contains the normalized frequency response
// and optionally create a wave with the suffix "_dPhase".
// The frequency range, and number of output points are specified.
// Options include windowing (Hann) vs no windowing, linear vs dB, phase vs no phase.
// If phase then option of radians or degrees,wrapped or unwrapped.
// You may want to modify the code at the end of this macro.
// It sets the display style and that is a matter of taste.
//
Macro DFTMagPhase(w,window,fMin,fMax,numout,linlog,phase,phasetype)
	string w
	Prompt w,"Input data:",popup WaveList("*",";","")
	variable window=1
	Prompt window,"Windowing:",popup "None;Hann"
	variable fMin=0
	Prompt fMin,"Minimum frequency"
	variable fMax=0
	Prompt fMax,"Maximum frequency, or 0 for Nyquist"
	variable numout=65	// small value recommended.  Remember, we're using the DFT, not the FFT
	Prompt numout,"Number of output points:"
	variable linlog= 2
	Prompt linlog,"Magnitude mode:",popup "Linear;dB"
	Variable phase= 0.5
	Prompt phase,"Phase:",popup "No phase;Phase in radians;Phase in degrees"
	Variable phasetype=1
	Prompt phasetype,"Unwrap phase?",popup,"No;Yes"
;
	PauseUpdate; silent 1
	
	string destw=w+"_dMag",phasew= w+"_dPhase"
	Variable n= numpnts($w)
	
	if( fMax == 0)
		fMax= 0.5/(pnt2x($w,1)-pnt2x($w,0))
	endif
	if( fMin >= fMax )
		Abort "Min frequency must be less than Max frequency"
	endif
	if( fMax > 1/(pnt2x($w,1)-pnt2x($w,0)) )
		Abort "Maximum frequency too big"
	endif
	if( fMin < 0 )
		Abort "Minimum frequency too small"
	endif

	Duplicate/O $w $phasew,$destw
	if(window==2)
		Hanning $phasew; $phasew *= 2			// *= 2 assumes continuous rather than pulsed data
	endif
	Redimension/C $phasew							//DFT requires complex data
	Redimension/C/N=(numout) $destw
	K0=DFTVarRes($phasew,$destw,fMin,fMax,1)		// Do Forward transform between fMin and fMax
	Setscale/I x,fMin,fMax, $destw
	$destw= r2polar($destw)
	if( phase!=1 )
		Duplicate/O $destw $phasew
		Redimension/R $phasew
		$phasew= imag($destw)
		if( phasetype==2 )
			if( fMin==0)
				$phasew[0]= $phasew[1]			// try to avoid glitch at dc
			endif
			UnWrap 2*Pi,$phasew
			if( fMin==0)
				$phasew[0]= 0
			endif
		endif
		if(phase==3)
			$phasew *= 180/Pi
			SetScale y,0,0,"deg",$phasew
		else
			SetScale y,0,0,"rad",$phasew
		endif
	else
		KillWaves $phasew
	endif
	Redimension/R $destw
	if( linlog==2 )
		WaveStats/Q $destw
		$destw= 20*log($destw/V_max)
		SetScale y,0,0,"dB",$destw
	else
		$destw /= n/2
		SetScale y,0,0,"V",$destw
	endif
	BringDestFront(destw)
	if( phase!=1 )
		CheckDisplayed  $phasew
		if( !V_Flag )
			Append/R $phasew
		endif
	endif
	if( numpnts($destw) <= 129 )
		Modify mode($destw)=4,marker($destw)=19,msize($destw)=1
	else
		Modify mode($destw)=0
	endif
end


// Given an input wave ( doesn't have to be a power of two), compute the real,complex values
// and the magnitude and phase values at the given frequency.
// phase options are radians or degrees
// The results are printed, and are stored in global variables V_real, V_imag, V_mag, and V_phase.
//
// REQUIRES: DFT1()
//
Macro DFTAtOneFrequency(w,freq,phase,printit)
	string w
	Prompt w,"Input data:",popup WaveList("*",";","")
	Variable freq
	Prompt freq,"DFT at frequency (Hz):"
	Variable phase= 1
	Prompt phase,"Phase:",popup "Phase in radians;Phase in degrees"
	Variable printit= 1
	Prompt printit,"Results:",popup "Printed to History;Not Printed"
;
	PauseUpdate; silent 1
	
	Variable n= numpnts($w)
	String units
	String tmpw=w+"Tmp"
	Duplicate/O $w,$tmpw							// this could be avoided if we knew whether w was complex
	Redimension/C $tmpw								// DFT requires complex data
	Variable/C dftCmplx = DFT1($tmpw,1,freq)/(n/2)	// Forward Discrete Fourier Transform
	KillWaves $tmpw

	Variable/G V_real= real(dftCmplx)
	Variable/G V_imag= imag(dftCmplx)
	dftCmplx= r2polar(dftCmplx)
	Variable/G V_mag= real(dftCmplx)
	Variable/G V_phase= imag(dftCmplx)
	if(phase==2)
		V_phase *= 180/Pi	
		units= "degrees"
	else
		units= "radians"
	endif
	if(printit==1)
		Print "frequency = ",freq," Hz"
		Print "(magnitude,phase) = (",V_mag,",",V_phase,units,")"
		Print "(real,imaginary)= (",V_real,",",V_imag,")"
	endif
end

// Given a complex input wave and a same size output wave, calculate the
// Discrete Fourier Transform using the direct (slow) method.
// parameter dir should be +1 for forward transform or -1 for reverse.
// input wave is not changed
//
// The x scaling of the output wave should be changed by the caller
// with a statement such as
// Setscale/p x,0,1/numpnts(inw)/(pnt2x(inw,1)-pnt2x(inw,0)), outw  
//
// Requires: DFT1()
//
Function DFT(inw,outw,dir)
	wave/c inw,outw
	variable dir
	
	variable n=numpnts(inw)
	variable nn
	variable dx= pnt2x(inw,1)-pnt2x(inw,0)
	
	nn=0
	do
		outw[nn]= DFT1(inw,dir,nn/(n*dx))
		nn+=1
	while(nn<n)
	
	return 0
end


// Given a complex input wave and a complex output wave (probably of different size),
// calculate the Discrete Fourier Transform using the direct (slow) method for the frequencies
// in the range of fMin to fMax, inclusive.  outw[0] will contain the value for fMin, and outw[n-1]
// will contain the value for fMax.
// parameter dir should be +1 for forward transform or -1 for reverse.
// input wave is not changed.
//
// The x scaling of the output wave should be changed by the caller
// with a statement such as
// Setscale/I x, fMin,fMax, outw
// The values of the output wave have the normal multiplication factor of inPts=numpnts(inw);
//	if the input wave is a record of repetitive data, divide outwave by inPts.  
//
// Requires: DFT1()
//
Function DFTVarRes(inw,outw,fMin,fMax,dir)		// Do transform between fMin and fMax
	wave/c inw,outw
	variable fMin,fMax,dir
	
	variable n=numpnts(outw)
	variable freq
	variable nn
	
	nn=0
	do
		freq= fMin+nn/(n-1)*(fMax-fMin)
		outw[nn]= DFT1(inw,dir,freq)
		nn+=1
	while(nn<n)
		
	return 0
end


// Given a complex input wave and a same size output wave, calculate the
// Descrete Fourier Transform using the direct (slow) method.
// parameter dir should be +1 for forward transform or -1 for reverse.
// input wave is not changed  
// parameter freq is the frequency at which  the forward DFT will be computed,
// it is the time at which the inverse DFT is computed.
// Returns complex value of Discrete Fourier Transform at given frequency (forward)
// or time (backward)
//
Function/C DFT1(inw,dir,freq)
	wave/c inw
	variable dir,freq
	
	variable n=numpnts(inw)
	variable/c w,wrot
	variable kk
	variable dx=  pnt2x(inw,1)-pnt2x(inw,0)
	variable pointFreq= freq*dx 	//pointFreq varies from 0 to 1.  0 for Constant Term, 1 for max frequency term (it plays role of nn/n in DFT Function)
	
	Variable/C out=0
	
	kk=0
	w= cmplx(1,0)
	wrot= cmplx(cos(2*pi*pointFreq),sin(2*pi*pointFreq))	// was 	wrot= cmplx(cos(2*pi*nn/n),sin(2*pi*nn/n)) in DFT()
	if(dir== -1)
		wrot= conj(wrot)
	endif
	do
		out += inw[kk]*w
		w *= wrot
		kk+=1
	while(kk<n)
	
	if(dir== -1)
		out /= n
	endif
	
	return out
end
