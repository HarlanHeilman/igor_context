# StatsGammaCDF

StatsGammaCDF
V-932
Flags
Details
The F statistic is the ratio of the variance of wave1 to the variance of wave2. We assume the waves have equal 
wave variances and that H0 is sigma1=sigma2. For the upper one-tail test we reject H0 if F is greater than 
the upper critical value or if F is smaller than the lower critical value in the lower one-tail test. In the two-
tailed test we reject H0 if F is either greater than the upper critical value or smaller than the lower critical 
value. The critical values are computed by numerically solving for the argument at which the cumulative 
distribution function (CDF) equals the appropriate values for the tests. The CDF is given by
where the degrees of freedom n1 and n2 equal the number of valid (non-NaN) points in each wave -1, and 
betai is the incomplete beta function. To get the critical value for the upper one-tail test we solve F(x)=1-
alpha. For the lower one-tail test we solve F(x)=alpha. In the two-tailed test the lower critical value is a 
solution for F(x)=alpha/2 and the upper critical value is a solution for F(x)=1-alpha/2.
The F-test requires that the two samples are from normally distributed populations.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsVariancesTest, StatsFCDF, and betai.
StatsGammaCDF 
StatsGammaCDF(x, , , )
The StatsGammaCDF function returns the gamma cumulative distribution function
where  is the gamma function and inc is the incomplete gamma function gammaInc.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGammaPDF and 
StatsInvGammaCDF.
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
/TAIL=tc
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Specifies the tail tested.
tc=1:
Lower one-tail test with Ha: sigma1>sigma2.
tc=2:
Upper one-tail test with Ha: sigma1<sigma2.
tc=3:
Default; the null hypothesis H0:
sigma1=sigma2 with Ha: sigma1!=sigma2.
F(x,n1,n2) = 1 betai n2
2 , n1
2 ,
n2
n2 + n1x
 


 ,
F(x;μ,, ) =
inc  , x  μ



 


( )
.
x  μ
, > 0
