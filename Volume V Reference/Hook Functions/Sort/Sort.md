# Sort

SmoothCustom
V-883
See Also
See the Loess, MatrixConvolve, and MatrixFilter operations for true 2D smoothing.
FilterFIR, FilterIIR, Loess, Interpolate2
Also see the “Smooth Operation Responses” example experiment.
SmoothCustom 
SmoothCustom [/E=endEffect] coefsWaveName, waveName [, waveName]…
The SmoothCustom operation smooths waves by convolving them with coefsWaveName.
Parameters
coefsWaveName must be single or double floating point, must not be one of the destination waveNames, must 
not be complex.
waveName is a numeric destination wave that is overwritten by the convolution of itself and coefsWaveName.
Flags
Details
The convolution is in the time domain. That is, the FFT is not employed. For this reason the length of 
coefsWaveName should be small or small in comparison to the destination waves.
SmoothCustom presumes that the middle point of coefsWaveName corresponds to the delay = 0 point. The 
“middle” point number = trunc(numpnts(coefsWaveName-1)/2). coefsWaveName usually contains the two-
sided impulse response of a filter, and contains an odd number of points. This is the type of wave created 
by FilterFIR.
SmoothCustom ignores the X scaling of all the waves.
The SmoothCustom operation is not multidimensional aware. See Analysis on Multidimensional Waves 
on page II-95 for details.
Sort 
Sort [ /A /DIML /C /R ] sortKeyWaves, sortedWaveName [, sortedWaveName]…
The Sort operation sorts the sortedWaveNames by rearranging their Y values to put the data values of 
sortKeyWaves in order.
Parameters
sortKeyWaves is either the name of a single wave, to use a single sort key, or the name of multiple waves in 
braces, to use multiple sort keys.
All waves must be of the same length.
The sortKeyWaves must not be complex.
Flags
Note:
SmoothCustom is obsolete. Use the FilterFIR operation instead. For multidimensional 
data use the MatrixConvolve or MatrixFilter operations.
/E=endEffect
End effect method, a value between 0 and 3. See the Smooth operation for a 
description of the /E flag.
/A[=a]
Alphanumeric sort. When sortKeyWaves includes text waves, the normal sorting places 
“wave1” and “wave10” before “wave9”.
The optional a parameter requires Igor Pro 7.00 or later.
Use /A or /A=1 to sort the number portion numerically, so that “wave9” is sorted before 
“wave10”.
Use /A=2 to ignore + and - characters in the text so that “Text-09” sorts before “Text-10”.
