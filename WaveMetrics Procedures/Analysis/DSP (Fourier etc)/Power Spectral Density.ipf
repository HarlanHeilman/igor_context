#pragma version= 1.9
#pragma rtGlobals=1		// Use modern global access method.

#include <DSP Window Functions>
#include <BringDestToFront>

// Given a long data wave create a short result wave containing the Power
// Spectral Density.  For the purposes of this macro, PSD is defined in
// terms of the power per frequency bin width. To get the total power you need
// to integrate. The signal is assumed to be a voltage measurement across a
// 1 ohm resistor ("Power" is the input value squared).
// The name of the new wave is the name of the source + _psd
//
// See the PSD Demo experiment for explanation of PSD Scaling.
//
// Version 1.1, LH 971028
// Changes since 1.0: changed normalization to give results as defined above.
//
// Version 1.2, JP 010427
// Changes since 1.1: corrected winNorm for Hanning to 3/8.
//
// Version 1.3, JP 020605
// Changes since 1.2: BIG CHANGE: Output is normalized so that A*cos(2*pi*f*t) results in
// a value of  A*A value in the bin associated with frequency f. Also, the Nyquist frequency is treated just like DC.
// The version 1.2 PSD macro is included as a Proc (you can still call it from your old code)
//
// Version 1.4, JP 020924
// PSD scaling corrected to average power / Hz.
// Renamed NormalizedPSD() to PowerSpectralDensity(), kept removeDC capability.
// Fixed Hanning winNorm to be actual, not theoretical value.
// Fixed off-by-one error in old PSD().
//
// Version 1.5, JP 020925
// Made the working part of PowerSpectralDensity() into a function: fPowerSpectralDensity().
//
// Version 1.6, JP 030225
// fixed broken WaveStats command in PSD when window == 2.
//
// Version 1.7, JP 040818
// Fixes for input waves that weren't single or double-precision floating point
// (such as all the integer types) resulting from the behavior of Igor 5's new FFT command.
//
// Version 1.8, JP 050120
// Fixed value of deltaF in fPowerSpectralDensity().
//
// Version 1.9 JP 131010
// fPowerSpectralDensity() sets Variable/G V_ENBW, the "Effective noise bandwidth" [1].
//
// 	 [1] Heinzel, Gerhard, et al. "Spectrum and spectral density estimation by the Discrete Fourier transform (DFT),
//	including a comprehensive list of window functions and some new flat-top windows."
//	Max Plank Institute 12 (2002): 122.
//
// This makes it possible to extract the linear spectrum = sqrt(w_psd * V_ENBW).
// The linear spectral density in V/sqrt(Hz) - if the input it is Volts - is simply sqrt(w_psd)
//
Macro PowerSpectralDensity(w,seglen,window,removeDC)
	string w
	Prompt w "data wave:",popup WaveList("*",";","")
	variable seglen=1
	Prompt seglen,"segment length:",popup "256;512;1024;2048;4096;8192;16384;32768;65536;131072;262144;524288;1048576;"	// version 1.9: more choices
	variable window=2
	Prompt window,"Window type:",popup "Square;Hann;Parzen;Welch;Hamming;BlackmanHarris3;KaiserBessel"
	variable removeDC=1	// 1 is yes, 2 is no (added for version 1.3)
	Prompt removeDC, "Remove DC component?", popup, "Yes;No;"

	PauseUpdate; Silent 1
	Variable npsd= 2^(7+seglen)				// number of points in group (resultant psd wave len= npsd/2+1)
	Variable nsrc= numpnts($w)

	if( npsd > nsrc/2 )
		DoAlert 0, "PowerSpectralDensity: source wave should be MUCH longer than the segment length."
		return
	endif

	String windowname= StringFromList(window-1,"Square;Hann;Parzen;Welch;Hamming;BlackmanHarris3;KaiserBessel;")
	Variable removeDCBoolean= SelectNumber(removeDC == 1, 0, 1)	// (condition, false val, true val)

	String psdName= fPowerSpectralDensity($w, npsd, windowname, removeDCBoolean)	

	BringDestFront(psdName)
	if( numpnts($psdName) <= 129 )
		ModifyGraph mode($psdName)=4,marker($psdName)=19,msize($psdName)=1
	else
		ModifyGraph mode($psdName)=0
	endif
end

// fPowerSpectralDensity() returns the  name of the created PSD wave.
//
// Version 1.9: the global variable V_ENBW can be used to compute the linear spectrum:
//	WAVE w_psd = $fPowerSpectralDensity(w, npsd, windowname, removeDC)
//	NVAR V_ENBW = V_ENBW
//
//	Duplicate/O w_psd, w_linearSpectrum
//	w_linearSpectrum = sqrt(w_psd * V_ENBW).
//
// Note: The linear spectral density, in V/sqrt(Hz)  if the input it is Volts, is simply sqrt(w_psd)
//
Function/S fPowerSpectralDensity(w, npsd, windowname, removeDC)
	Wave w
	Variable npsd			// SegLen - the number of input points in each segment, must be even
	String windowName		// one of "Square;Hann;Parzen;Welch;Hamming;BlackmanHarris3;KaiserBessel"
	Variable removeDC		// 0 to leave the DC component in the PSD result, 1 to remove it.
	
	Variable nsrc= numpnts(w)
	if( npsd > nsrc )
		npsd= nsrc
	endif
	String destw=NameOfWave(w)+"_psd"
	String srctmp=NameOfWave(w)+"_tmp"
	String winw=NameOfWave(w)+"_psdWin"
	
	Make/O/N=(npsd/2+1) $destw= 0
	WAVE psd= $destw
	
	Make/O/N=(npsd) $srctmp,$winw
	WAVE tmp= $srctmp
	WAVE win= $winw
	win= 1
	
	Variable winNorm
	strswitch( windowName )	// one of "Square;Hann;Parzen;Welch;Hamming;BlackmanHarris3;KaiserBessel"
		default:
		case "Square":
			winNorm= 1
			break
		case "Hann":
			Hanning win
			// winNorm=0.375		//  theoretical avg squared value
			WaveStats/Q win
			winNorm= V_rms*V_rms	// actual value is more accurate than a theoretical value.
			break
		case "Parzen":
			winNorm= Parzen(win)
			break
		case "Welch":
			winNorm= Welch(win)
			break
		case "Hamming":
			winNorm= Hamming(win)
			break
		case "BlackmanHarris3":
			winNorm= BlackmanHarris3(win)
			break
		case "KaiserBessel":
			winNorm= KaiserBessel(win)
			break
	endswitch

	// Compute Equivalent noise bandwidth as per [1], equation 22.
	WaveStats/Q/M=0 win
	Variable s1 	= V_sum
	Variable s2 = winNorm * npsd	// s2 is the sum of the squares of the window values
	Variable fs= 1/deltax(w)
	Variable/G V_ENBW= fs * s2 / (s1*s1) // Output via global variable!				

	// Optionally remove DC component from the entire wave.
	// This perhaps should be done for each segment, instead.
	Variable dc= 0
	if( removeDC )	// boolean
		WaveStats/Q/M=0 w
		dc= V_Avg
	endif

	Variable psdFirst= 0
	Variable psdOffset= npsd/2
	Variable nsegs
	for( nsegs= 0; psdFirst+npsd <= nsrc; nsegs += 1, psdFirst += psdOffset)
		Duplicate/O/R=[psdFirst,psdFirst+npsd-1] w, tmp
		tmp = (tmp-dc) * win
		FFT/DEST=ctmp tmp	// result is a one-sided spectrum of complex values
		psd += magsqr(ctmp)	// summed Fourier power of one-sided spectrum
								// (we're missing all negative frequency powers except for the Nyquist frequency)
	endfor
	CopyScales/P ctmp, psd
	KillWaves/Z ctmp
	// transform seconds in to Hz, etc, just like the FFT else remove units
	String newUnits=WaveUnits(psd,0)
	String oldUnits=WaveUnits(w, 0)
	if( CmpStr(oldUnits,newUnits )== 0 )	// FFT didn't modify the units, we try a little harder
		strswitch( oldUnits )
			case "s":
			case "sec":
			case "secs":
				newUnits= "Hz"
				break
			case "seconds":
				newUnits= "Hertz"
			case "m":
				newUnits= "1/m"
			case "cm":
				newUnits= "1/cm"
				break	
			default:
				newUnits=""
				break	
		endswitch
	endif
	SetScale x, leftx(psd), rightx(psd), newUnits, psd
	// normalize the sum of PSDs
	Variable deltaF= deltax(psd)			// deltaF is the frequency bin width
	Variable norm= 2 / (npsd * npsd * nsegs * winNorm * deltaF)
	psd *= norm
	// Explanation of norm values:
	//	* 2				 		total power = magnitude^2(-f) + magnitude^2(f), and we've only accumulated magnitude^2(f)
	//  / (npsd * npsd * nsegs)	converts to average power
	//	/ winNorm				compensates for power lost by windowing the time data.
	//	/ deltaF					converts power to power density (per Hertz)

	psd[0] /= 2			// we're not missing 1/2 the power of DC bin from the two-sided FFT, restore original value
	psd[npsd/2] /= 2	// there aren't two Nyquist bins, either.

	// Parseval's theorem (power in time-domain = power in frequency domain)
	// is satisfied if you compare:
	// time-domain average power ("mean squared amplitude" in Numerical Recipies) = 1/N * sum(t=0...N-1) w[t]^2
	// frequency-domain average power= deltaf * sum(f=0...npsd/2) destw[f]^2
	
	KillWaves/Z tmp, win
	
	return NameOfWave(psd)	// in the current data folder
End


// Version 1.2 PSD, in case you prefer it.
Proc PSD(w,seglen,window)
	string w
	Prompt w "data wave:",popup WaveList("*",";","")
	variable seglen=1
	Prompt seglen,"segment length:",popup "256;512;1024;2048;4096;8192"
	variable window=2
	Prompt window,"Window type:",popup "Square;Hann;Parzen;Welch;Hamming;"
						"BlackmanHarris3;KaiserBessel"
;
	PauseUpdate; silent 1
	
	variable npsd= 2^(7+seglen)				// number of points in group (resultant psd wave len= npsd/2+1)
	variable psdOffset= npsd/2					// offset each group by this amount
	variable psdFirst=0							// start of current group
	variable nsrc= numpnts($w)
	variable nsegs,winNorm						// count of number of segements and window normalization factor
	string destw=w+"_psd",srctmp=w+"_tmp"
	string winw=w+"_psdWin"					// window goes here
	
	if( npsd > nsrc/2 )
		Abort "psd: source wave should be MUCH longer than the segment length"
	endif
	make/o/n=(npsd/2+1) $destw
	make/o/n=(npsd) $srctmp,$winw; $winw= 1
	if( window==1 )
		winNorm= 1
	else
		if( window==2 )
			Hanning $winw
			// winNorm=0.375		//  theoretical avg squared value
			WaveStats/Q $winw
			winNorm= V_rms*V_rms	// actual value is better than a theoretical value.
		else
			if( window==3 )
				winNorm= Parzen($winw)
			else
				if( window==4 )
					winNorm= Welch($winw)
				else
					if( window==5 )
						winNorm= Hamming($winw)
					else
						if( window==6 )
							winNorm= BlackmanHarris3($winw)
						else
							if( window==7 )
								winNorm= KaiserBessel($winw)
							else
								Abort "unknown window index"
							endif
						endif
					endif
				endif
			endif
		endif
	endif	// (kinda makes you wish we had elseif or switch constructs, huh? - well we do but only in functions)

	Duplicate/O/R=[0,npsd-1] $w $srctmp; $srctmp *= $winw; fft $srctmp
	CopyScales/P $srctmp, $destw
	$destw= magsqr($srctmp)
	psdFirst= psdOffset
	nsegs=1
	do
		Duplicate/O/R=[psdFirst,psdFirst+npsd-1] $w $srctmp;   $srctmp *= $winw
		fft $srctmp;   $destw += magsqr($srctmp);   psdFirst += psdOffset; nsegs+=1
	while( psdFirst+npsd <= nsrc )
	winNorm= 2*deltax($w)/(winNorm*nsegs*npsd)
	$destw *= winNorm
	$destw[0] /= 2

	KillWaves $srctmp,$winw
	BringDestFront(destw)
	if( numpnts($destw) <= 129 )
		Modify mode($destw)=4,marker($destw)=19,msize($destw)=1
	else
		Modify mode($destw)=0
	endif
end

