# Smoothing Demo

Chapter III-9 — Signal Processing
III-293
Choose AnalysisSmooth to see the Smoothing dialog.
Depending on the smoothing algorithm chosen, there may be additional parameters to specify in the dialog.
Built-in Smoothing Algorithms
Igor has numerous built-in smoothing algorithms for 1-dimensional waveforms, and one that works with 
the XY Model of Data on page II-63:
The first four algorithms precompute or apply one set of smoothing coefficients according to the smoothing 
parameters, and then replaces each data wave with the convolution of the wave with the coefficients.
You can determine what coefficients have been computed by smoothing a wave containing an impulse. For 
instance:
Make/O/N=32 wave0=0; wave0[15]=1; Smooth 5,wave0
// Smooth an impulse
Display wave0; ModifyGraph mode=8,marker=8
// Observe coefficients
Compute the FFT of the coefficients with magnitude output to view the frequency response. See Finding 
Magnitude and Phase on page III-274.
The last two algorithms (the Smooth/M and Loess operations) are not based on creating a fixed set of 
smoothing coefficients and convolution, so this technique is not applicable.
Smoothing Demo
For a demo of various smoothing techniques, choose FilesExample ExperimentsFeature 
DemosSmooth Curve Through Noise.
Algorithm
Operation
Data
Binomial
Smooth
1D waveform
Savitzky-Golay
Smooth/S
1D waveform
Box (Average)
Smooth/B
1D waveform
Custom Smoothing
FilterFIR
1D waveform
Median
Smooth/M
1D waveform
Percentile, Min, Max
Smooth/M/MPCT
1D waveform
Loess
Loess
1D waveform, XY 1D waves, false-color images*, matrix 
surfaces*, and multivariate data*.
* The Loess operation supports these data formats, but the Smooth dialog does not provide an interface to
select them.
0.20
0.15
0.10
0.05
0.00
30
25
20
15
10
5
0
