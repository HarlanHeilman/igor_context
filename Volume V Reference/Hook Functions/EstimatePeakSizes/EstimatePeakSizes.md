# EstimatePeakSizes

EstimatePeakSizes
V-203
// Y error bars only, constant error value = 4.3
ErrorBars wave1,Y const=4.3
// Error box, 10% in horizontal direction, 5% in vertical direction
ErrorBars wave1,BOX pct=10,pct=5
// Error box filled with blue color having 50% alpha (transparency)
// 10% in horizontal direction, 5% in vertical direction
ErrorBars wave1,BOX=(0,0,65535,32767) pct=10,pct=5
// Change the error box fill to red color having 50% alpha
// without changing the way the errors are computed.
ErrorBars wave1,BOX=(65535,0,0,32767) nochange, nochange
// Y error bars only, wave w1 has errors for Y+ bars
// wave w2 has errors for Y- bars
ErrorBars wave1,Y wave=(w1,w2)
// Y error bars only, same wave for both Y+ and Y-.
// Overrides the trace color to make the error bars black.
ErrorBars/RGB=(0,0,0) wave1,Y wave=(w1,w1)
// Y error bars only, no Y+ error bars, wave w2 has errors for Y- bars
ErrorBars wave1,Y wave=(,w2)
// Turns error bars for wave1 off
ErrorBars wave1,OFF
Error Ellipse Example
See Error Ellipse Example on page II-306.
See Also
Error Bars on page II-304, Trace Names on page II-282, Programming With Trace Names on page IV-87.
EstimatePeakSizes
EstimatePeakSizes [/B=baseWave] [/X=xWave] [/E=bothEdgesWave] edgePct, 
maxWidth, box, npks, peakCentersWave, peakWave, peakAmplitudesWave, 
peakWidthsWave
The EstimatePeakSizes operation estimates the amplitudes and widths of peaks whose estimated centers 
are given.
The EstimatePeakSizes operation is used primarily by the Igor Technical Note #20 and its variants.
Parameters
edgePct is the percentage of peak height at which the edge is detected, relative to the baseline. It must be 
between 1 and 99, and is usually 50.
maxWidth is the maximum width that will be returned in peakWidthsWave, in X coordinates.
box is the number of peak values included in the sliding average when smoothing peakWave and baseWave. 
If you specify an even number, the next-higher odd number is used.
npks is the number of peaks whose sizes are to be estimated. It must be at least 1.
peakCentersWave must contain the point numbers of the centers of the peaks and have a length of at least 
npks. The peak sizes are estimated by starting the search for the peak edges from these peak centers. The i-
th peak center must be stored in peakCentersWave[i] where i ranges from 0 to npks-1. The peak center values 
in peakCentersWave must be monotonically increasing or decreasing.
peakWave is the input wave containing the peaks.
peakAmplitudesWave is an output wave that will contain the baseline-corrected peak amplitudes of the 
peaks. It must have a length of at least npks. The i-th peak amplitude is stored in peakAmplitudesWave[i].
peakWidthsWave is an output wave that will contain the widths of the peaks in X coordinates. It must have 
a length of at least npks. The i-th peak width is stored in peakWidthsWave[i].
Flags
/B=baseWave
baseWave is subtracted from peakWave to compute the derived data which is 
searched for edges. It must be the same length as peakWave.
