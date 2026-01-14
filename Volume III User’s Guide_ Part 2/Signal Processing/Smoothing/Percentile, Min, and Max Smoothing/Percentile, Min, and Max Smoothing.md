# Percentile, Min, and Max Smoothing

Chapter III-9 — Signal Processing
III-296
Median Smoothing
Median smoothing does not use convolution with a set of coefficients. Instead, for each point it computes 
the median of the values over the specified range of neighboring values centered about the point. NaN 
values in the waveform data are allowed and are excluded from the median calculations.
For simple XY data median smoothing, include the Median.ipf procedure file:
#include <Median>
and use the AnalysisPackagesMedian XY Smoothing menu item. Currently this procedure file does not 
handle NaNs in the data and only implements method 1 as described below.
For image (2D matrix) median smoothing, use the MatrixFilter or ImageFilter operation with the median 
method. ImageFilter can smooth 3D matrix data.
There are several ways to use median smoothing (Smooth/M) on 1D waveform data:
1. Replace all values with the median of neighboring values.
2. Replace each value with the median if the value itself is NaN. See Replace Missing Data Using 
Median Smoothing on page III-114.
3. Replace each value with the median if the value differs from the median by a the specified threshold 
amount.
4. Instead of replacing the value with the computed median, replace it with a specified number, 
including 0, NaN, +inf, or -inf.
Median smoothing can be used to replace “outliers” in data. Outliers are data that seem “out of line” from 
the other data. One measure of this “out of line” is excessive deviation from the median of neighboring 
values. The Threshold parameter defines what is considered “excessive deviation”.
// Example uses integer wave to simplify checking the results
Make/O/N=20/I dataWithOutliers= 4*p+gnoise(1.5)
// simple line with noise
dataWithOutliers[7] *=2
// make an outlier at point 7
Display dataWithOutliers
Duplicate/O dataWithOutliers,dataWithOutliers_smth
Smooth/M=10 5, dataWithOutliers_smth
// threshold=10, 5 point median
AppendToGraph dataWithOutliers_smth
Percentile, Min, and Max Smoothing
Median smoothing is actually a specialization of Percentile smoothing, as are Min and Max.
50
40
30
20
10
0
10
9
8
7
6
5
4
 dataWithOutliers
 dataWithOutliers_smth
5-point median for point 7 includes
all 
 values within the box.
Median (middle value) is the
3rd largest value in the box
which is dataWithOutliers[8]=33
The difference at point 7
abs(value-median) = 19
exceeds the threshold of 10,
so the value is replaced
with the median = 33.
