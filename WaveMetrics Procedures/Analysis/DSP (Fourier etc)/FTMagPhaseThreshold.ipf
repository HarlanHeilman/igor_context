#include <BringDestToFront>
#include <Math Utility Functions>

// Given an input wave ( doesn't have to be a power of two), create a new wave
// with the suffix "_Mag" that contains the normalized frequency response and
// optionally a wave with the suffix "_Phase".
// Several levels of resolution enhancement (really just sin x/x interpolation) are provided.
// Options include windowing (Hann) vs no windowing, linear vs dB, phase vs no phase
// If phase then option of radians or degrees,wrapped or unwrapped
// The thresholdPct parameter suppresses phase
// values where the magnitude is less than some percentage of the maximum magnitude.
//
// You may want to modify the code at the end of this macro.  It sets the display
// style and that is a matter of taste.
//
Macro FFTMagPhaseThreshold(w,window,resolution,linlog,phase,phasetype,thresholdPct)
	string w
	Prompt w,"Input data:",popup WaveList("*",";","")
	variable window=1
	Prompt window,"Windowing:",popup "None;Hann"
	variable resolution=1
	Prompt resolution,"Resolution enhancement:",popup "none;2;4;8;16;32"
	variable linlog= 2
	Prompt linlog,"Magnitude Mode:",popup "Linear;dB"
	Variable phase= 1
	Prompt phase,"Phase:",popup "No phase;Phase in radians;Phase in degrees"
	Variable phasetype=1
	Prompt phasetype,"Unwrap phase?",popup,"No;Yes"
	Variable thresholdPct=5
	Prompt thresholdPct,"Suppress phase if below % max magnitude"
;
	PauseUpdate; silent 1
	
	string destw=w+"_Mag",phasew= w+"_Phase"
	Variable n= numpnts($w)
	
	if( (resolution<1) %| (resolution>6) )
		Abort "resolution out of range"
	endif
	resolution -= 1
	Duplicate/O $w $destw
	if(window==2)
		Hanning $destw; $destw *= 2			// assumes continuous rather than pulsed data
	endif
	Redimension/N=(CeilPwr2(n)*2^resolution) $destw		// pad with zeros to power of 2
	fft $destw
	$destw= r2polar($destw)
	// NOTE: depending on your application you may want to un-comment the next line
//	$destw[0] /= 2								// dc is special
	if( phase!=1 )
		Duplicate/O $destw $phasew
		Redimension/R $phasew
		$phasew= imag($destw)
		// remove phase values where corresponding amplitude is small	| FLORIN
		if( thresholdPct > 0 )
			WaveStats/Q $destw
			Variable threshold = V_max * thresholdPct/100
			$phasew*= ($destw[p] > threshold )
		endif
		if( phasetype==2 )
			$phasew[0]= $phasew[1]			// try to avoid glitch at dc
			UnWrap 2*Pi,$phasew
			$phasew[0]= 0
		endif
		if(phase==3)
			$phasew *= 180/Pi
			SetScale y,0,0,"deg",$phasew
		else
			SetScale y,0,0,"rad",$phasew
		endif
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
