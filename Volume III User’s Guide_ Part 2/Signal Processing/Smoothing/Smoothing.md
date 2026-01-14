# Smoothing

Chapter III-9 — Signal Processing
III-292
To find multiple peaks, write a procedure that calls FindPeak from within a loop. After a peak is found, 
restrict the range of the search with /R so that the just-found peak is excluded, and search again. Exit the 
loop when V_Flag indicates a peak wasn’t found.
The FindPeak operation does not work on an XY pair. See Converting XY Data to a Waveform on page III-109.
Smoothing
Smoothing is a specialized filtering operation used to reduce the variability of data. It is sometimes used to 
reduce noise.
This section discusses smoothing 1-dimensional waveform data with the Smooth, FilterFIR, and Loess 
operations. Also see the FilterIIR and Resample operations.
Smoothing XY data can also be handled by the Loess operation and the Median.ipf procedure file (see 
Median Smoothing on page III-296).
The MatrixFilter, MatrixConvolve, and ImageFilter operations smooth image and 3D data.
Igor has several built-in 1D smoothing algorithms. In addition, you can supply your own smoothing coefficients.
1.0
0.5
0.0
0.7
0.6
0.5
0.4
0.3
0.2
0.1
0.0
minLevel
V_PeakLoc
Negative peak example
using FindPeak /N with /M=minLevel
4
3
2
1
0
60
40
20
0
 data
 smoothed data (binomial 5 passes)
