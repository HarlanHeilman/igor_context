# Loess Smoothing

Chapter III-9 — Signal Processing
III-297
Percentile smoothing returns the smallest value in the smoothing window that is greater than the smallest 
percentile % of the values:
As an example, assume that percentile = 25, the number of points in the smoothing window is 7, and for one 
input point the values in the window after sorting are:
{0, 1, 8, 9, 10, 11, 30}
The 25th percentile is found by computing the rank R:
R = (percentile /100)*(num +1)
In this example, R evaluates to 2 so the second item in the sorted list, 1 in this example, is the percentile value 
for the input point.
The percentile algorithm uses an interpolated rank to compute the value of percentiles other than 0 and 100. 
See the Smooth operation for details.
Loess Smoothing
The Loess operation smooths data using locally-weighted regression smoothing. This algorithm is some-
times classified as a “nonparametric regression” procedure.
The regression can be constant, linear, or quadratic. A robust option that ignores outliers is available. In 
addition, for small data sets Loess can generate confidence intervals.
See the Loess operation on page V-515 help for a discussion of the basic and robust algorithms, examples, 
and references.
This implementation works with waveforms, XY pairs of waves, false-color images, matrix surfaces, and 
multivariate data (one dependent data wave with multiple independent variable data waves). Loess dis-
cards NaN input values.
The Smooth Dialog, however, provides an interface for only waveforms and XY pairs of waves (see XY Model 
of Data on page II-63), and does not provide an interface for confidence intervals or other less common options.
Here’s an example from the Loess operation help of interpolating (smoothing) an XY pair and creating an 
interpolated 1D waveform (Y vs. X scaling). Note: the Make commands below are wrapped to fit the page:
// 3. 1-D Y vs X wave data interpolated to waveform (Y vs X scaling)
// with 99% confidence interval outputs (cp and cm)
// NOx = f(EquivRatio)
// Y wave
Make/O/D NOx = {4.818, 2.849, 3.275, 4.691, 4.255, 5.064, 2.118, 4.602, 2.286, 0.97, 
3.965, 5.344, 3.834, 1.99, 5.199, 5.283, 3.752, 0.537, 1.64, 5.055, 4.937, 1.561};
// X wave (Note that the X wave is not sorted)
Make/O/D EquivRatio = {0.831, 1.045, 1.021, 0.97, 0.825, 0.891, 0.71, 0.801, 1.074, 
1.148, 1, 0.928, 0.767, 0.701, 0.807, 0.902, 0.997, 1.224, 1.089, 0.973, 0.98, 0.665};
// Graph the input data
Display NOx vs EquivRatio; ModifyGraph mode=3,marker=19
// Interpolate to dense waveform over X range
Make/O/D/N=100 fittedNOx
WaveStats/Q EquivRatio
Percentile
Type
Description
0
Min
The smoothed value is the minimum value in the smoothing window. 0 is the 
minimum value for percentile.
50
Median
The smoothed value is the median of the values in the smoothing window.
100
Max
The smoothed value is the maximum value in the smoothing window. 100 is the 
maximum value for percentile.
