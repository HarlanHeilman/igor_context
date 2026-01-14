# StatsKWTest

StatsKuiperCDF
V-949
See Also
Chapter III-12, Statistics for a function and operation overview; StatsJBTest, WaveStats, and 
StatsCircularMoments.
StatsKuiperCDF 
StatsKuiperCDF(V)
The StatsKuiperCDF function returns the Kuiper cumulative distribution function
Accuracy is on the order of 1e-15. It returns 0 for values of V<0.4 or 1 for V>3.1.
References
See in particular Section 14.3 of
Press, William H., et al., Numerical Recipes in C, 2nd ed., 994 pp., Cambridge University Press, New York, 1992.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsInvKuiperCDF.
StatsKWTest 
StatsKWTest [flags] [wave1, wave2,… wave100]
The StatsKWTest operation performs the nonparametric Kruskal-Wallis test which tests variances using the 
ranks of the data. Output is to the W_KWTestResults wave in the current data folder.
Flags
Details
Inputs are two or more 1D numerical waves (one for each group of samples). Use NaNs for missing data or 
use waves with different number of points.
StatsKWTest always computes the critical values using both the Chi-squared and Wallace approximations. 
If appropriate (small enough data set) you can also use /E to obtain the exact P value. When the calculation 
involves many waves or many data points the calculation of the exact critical value can be very lengthy. All 
the results are saved in the wave W_KWTestResults in the current data folder and are optionally displayed 
in a table (/T). The wave contains the following information:
H0 for the Kruskal-Wallis test is that all input waves are the same. If the test fails and the input consisted of 
more than two waves, there is no indication for possible agreement between some of the waves. See 
StatsNPMCTest for further analysis.
/ALPH = val
Sets the significance level (default val=0.05).
/E
Computes the exact P-value using the Klotz and Teng algorithm, which may require 
long computation times for large data sets. You can stop the calculation by pressing 
the User Abort Key Combinations after which all remaining results remain valid and 
the exact P-value is set to NaN.
/Q
No results printed in the history area.
/T=k
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
F(V) = 1 2
4 j2V 2 1
(
)exp 2 j2V 2
(
).
j=1


Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
