# StatsJBTest

StatsInvWeibullCDF
V-945
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsVonMisesPDF and 
StatsVonMisesNoise functions.
StatsInvWeibullCDF 
StatsInvWeibullCDF(cdf, m, s, g)
The StatsInvWeibullCDF function returns the inverse of the Weibull cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWeibullCDF and 
StatsWeibullPDF functions.
StatsJBTest 
StatsJBTest [flags] srcWave
The StatsJBTest operation performs the Jarque-Bera test on srcWave. Output is to the W_JBResults wave in 
the current data folder.
Flags
Details
StatsJBTest computes the Jarque-Bera statistic
where S is the skewness, K is the kurtosis, and n is the number of points in the input wave. We can express 
S and K terms of the jth moment of the distribution for n samples Xi
as
and
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
x = μ +  ln 1 cdf
(
)
 

1/ .
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
JB = n
6 S2 + K 2
4



 ,
μ j = 1
n
(Xi  X) j
i=1
n

S =
μ3
μ2
(
)
3/2 ,
