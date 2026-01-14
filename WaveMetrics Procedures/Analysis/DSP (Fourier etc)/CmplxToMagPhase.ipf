#include <BringDestToFront>
#pragma version=1.1
//
// FFTCmplxToMagPhase converts a complex wave, presumed to be the result of an FFT,
// to _Mag and _Phase waves.
//
// Version 1.1, 03/30/2001, JP - popup shows only complex waves,
//		linear magnitude now divided by FFT input N/2, not FFT output N/2.
//
Macro FFTCmplxToMagPhase(w,linlog,phase,phasetype)
	string w
	Prompt w,"Complex FFT output wave:",popup C2MP_ComplexWaves()
	variable linlog= 2
	Prompt linlog,"Magnitude mode:",popup "Linear;dB"
	Variable phase= 1
	Prompt phase,"Phase:",popup "No phase;Phase in radians;Phase in degrees"
	Variable phasetype=1
	Prompt phasetype,"Unwrap phase?",popup,"No;Yes"
;
	PauseUpdate; Silent 1
	
	string destw=w+"_Mag",phasew= w+"_Phase"
	Variable n= numpnts($w)		// of FFT wave
	Variable preFFTn= (n-1) * 2	// pre-transform data length
	
	Duplicate/O $w $destw
	$destw= r2polar($destw)	// If error here, $destw is probably not a complex wave
	// NOTE: depending on your application you may want to un-comment the next line
//	$destw[0] /= 2								// dc is special for single-sided FFT
	if( phase!=1 )
		Duplicate/O $destw $phasew
		Redimension/R $phasew
		$phasew= imag($destw)
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
		Variable FFTfactor= preFFTn/2
		$destw /= FFTfactor	// was /= n/2 before version 1.1
		SetScale y,0,0,"V",$destw
	endif
	BringDestFront(destw)
	if( phase!=1 )
		CheckDisplayed  $phasew
		if( !V_Flag )
			Append/R $phasew
		endif
	endif
	if( n <= 129 )
		Modify mode($destw)=4,marker($destw)=19,msize($destw)=1
	else
		Modify mode($destw)=0
	endif
end

// CmplxToMagPhase converts a complex wave into
// magnitude (_Mag) and phase (_Phase) waves.
//
Macro CmplxToMagPhase(w,linlog,phase,phasetype)
	string w
	Prompt w,"Complex wave:",popup C2MP_ComplexWaves()
	variable linlog= 2
	Prompt linlog,"Magnitude mode:",popup "Linear;dB"
	Variable phase= 1
	Prompt phase,"Phase:",popup "No phase;Phase in radians;Phase in degrees"
	Variable phasetype=1
	Prompt phasetype,"Unwrap phase?",popup,"No;Yes"
;
	PauseUpdate; Silent 1
	
	string destw=w+"_Mag",phasew= w+"_Phase"
	Variable n= numpnts($w)
	
	Duplicate/O $w $destw
	$destw= r2polar($destw)	// If error here, $w was probably not a complex wave
	if( phase!=1 )
		Duplicate/O $destw $phasew
		Redimension/R $phasew
		$phasew= imag($destw)
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
	endif
	BringDestFront(destw)
	if( phase!=1 )
		CheckDisplayed  $phasew
		if( !V_Flag )
			Append/R $phasew
		endif
	endif
	if( n <= 129 )
		Modify mode($destw)=4,marker($destw)=19,msize($destw)=1
	else
		Modify mode($destw)=0
	endif
end

Function/S C2MP_ComplexWaves()

	String list=""
	Variable index = 0
	do
		Wave/Z w= $GetIndexedObjName(":", 1, index)
		if( !WaveExists(w) )
			break
		endif
		if( WaveType(w) %& 0x1 )	// complex
			if( DimSize(w,1) < 2 )
				list += NameOfWave(w)+";"
			endif
		endif
		index += 1
	while(1)
	return list
End
