# StatsQuantiles

StatsQpCDF
V-968
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsTukeyTest function.
StatsQpCDF 
StatsQpCDF(q, nr, nt, dt, side, sSizeWave)
The StatsQpCDF function returns the Q' cumulative distribution function associated with Dunnett's test.
Here nr is the number of groups (should be set to 1), nt is the number of treatments, df is the error degrees 
of freedom.
Set side=1 for upper-tail or side=2 for two-tailed CDF.
sSizeWave is an integer wave of nt rows specifying the number of samples in each treatment. 
Details
StatsQpCDF is a modified Q distribution typically used with Dunnett's test, which compares the various 
means with the mean of the control group or treatment
References
"Algorithm AS 251: Multivariate Normal Probability Integrals with Product Correlations Structure", C. W. 
Dunnett, Appl. Stat., 38 (1989) 564-579.
A short correction for the algorithm was published in: Appl. Stat., 42 (1993) 709.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsDunnettTest, StatsInvQpCDF, 
and StatsInvQCDF functions.
StatsQuantiles 
StatsQuantiles [flags] srcWave
The StatsQuantiles operation computes quantiles and elementary univariate statistics for a set of data in srcWave.
Flags
/ALL
Invokes all flags except /Q, /QM, and /Z.
/BOX
Computes parameters necessary to construct a box plot.
/iNaN
Ignores NaNs, which are sorted to the end of the array by default.
/IW
Creates an index wave W_QuantilesIndex. W_QuantilesIndex[i] corresponds to the 
position of srcWave[i] when sorted from minimum to maximum.
/Q
No information printed in the history area.
/QM=qMethod
/QW
Creates a single precision wave W_QuantileValues containing the quantile value 
corresponding to each entry in srcWave.
/STBL
Uses a stable sort, which may require significant computation time for multiple 
entries with the same value.
Specifies the method for computing quartiles. qMethod has one of these values:
See Details for more information.
0:
Tukey (default).
1:
Minitab.
2:
Moore and McCabe.
3:
Mendenhall and Sincich.

StatsQuantiles
V-969
Details
StatsQuantiles produces quick five-number summaries or more detailed results for univariate data. Values 
are returned in the wave W_StatsQuantiles and in the variables:
Entries in the wave W_StatsQuantiles depend on your choice of flags. Each row has a row label explicitly 
defining its value. If you use the /ALL flag, W_StatsQuantiles will contain the following row labels:
Otherwise, W_StatsQuantiles will contain the first five entries and any additionally requested value. You 
should always access values using the dimension labels (see Dimension Labels on page II-93).
There is frequently some confusion in comparing statistical results computed by different programs 
because each may use a different definition of quartiles. You can specify the method of computing the 
quartiles as you prefer with the /QM flag. If you neglect to choose a method, StatsQuantiles uses Tukey’s 
method, which computes quartiles (also called hinges) as the lower and upper median values between the 
/T=k
/TM
Computes the tri-mean: 0.25*(V_Q25+2*median+V_Q75).
/TRIM=tVal
Computes the trimmed mean which is the mean value of the entries between the 
quantiles tVal (in %) and 100-tVal. By default tVal=25 and the trimmed mean 
corresponds to the midmean.
/Z
Ignores any errors.
V_min
Minimum value.
V_max
Maximum value.
V_Median
Median value.
V_Q25
Lower quartile.
V_Q75
Upper quartile.
V_IQR
Inter-quartile range V_Q75-VQ25, which is also known as the H-spread.
V_MAD
Median absolute deviation.
V_mode
The most frequent value.
If there is a tie and several values have the highest frequency then the lowest value 
among them is returned as the mode.
If all values in srcWave are unique or if the number of points in srcWave is less than 
3, V_mode is set to NaN.
This output was added in Igor Pro 7.00.
minValue
lowerInnerFence
maxValue
lowerOuterFence
Median
upperInnerFence
Q25
upperOuterFence
Q75
triMean
IQR
trimmedMean
MedianAbsoluteDeviation
Displays the result wave W_StatsQuantiles in a table and specifies window 
behavior when the user attempts to close the table.
If you use /K=2 you can still kill the window using the KillWindow operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
