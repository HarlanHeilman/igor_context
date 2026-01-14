# StatsInvRayleighCDF

StatsInvQCDF
V-942
StatsInvQCDF 
StatsInvQCDF(cdf, r, c, df)
The StatsInvQCDF function returns the critical value of the Q cumulative distribution function for r the number 
of groups, c the number of treatments, and df the error degrees of freedom (df=r*c*(n-1) with sample size n).
Details
The Q distribution is the maximum of several Studentized range statistics. For a simple Tukey test, use r=1.
Examples
The critical value for a Tukey test comparing 5 treatments with 6 samples and 0.05 significance is:
Print StatsInvQCDF(1-0.05,1,5,5*(6-1))
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsTukeyTest function.
StatsInvQpCDF 
StatsInvQpCDF(ng, nt, df, alpha, side, sSizeWave)
The StatsInvQpCDF function returns the critical value of the Q' cumulative distribution function for ng the 
number of groups, nt the number of treatments, and df the error degrees of freedom. side=1 for upper-tail or 
side=2 for two-tailed critical values.
sSizeWave is an integer wave of ng columns and nt rows specifying the number of samples in each treatment. 
If sSizeWave is a null wave ($"") StatsInvQpCDF computes the number of samples from df=ng*nt*(n-1) with 
n truncated to an integer.
Details
StatsInvQpCDF is a modified Q distribution typically used with Dunnett’s test, which compares the various 
means with the mean of the control group or treatment.
StatsInvQpCDF differs from other StatsInvXXX functions in that you do not specify a cdf value for the 
inverse (usually 1-alpha for the critical value). Here alpha selects one- or two-tailed critical values.
It is computationally intensive, taking longer to execute for smaller alpha values.
Examples
The critical value for a Dunnett test comparing 4 treatments with 4 samples and (upper tail) 0.05 
significance is:
// n=4 because 12=1*4*(4-1).
Print StatsInvQpCDF(1,4,12,0.05,1,$"")
 2.28734
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsDunnettTest and StatsInvQCDF 
functions.
StatsInvRayleighCDF 
StatsInvRayleighCDF(cdf [, s [, m]])
The StatsInvRayleighCDF function returns the inverse of the Rayleigh cumulative distribution 
functiongiven by
with defaults s=1 and m=0. It returns NaN for s 0 and zero for x m.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRayleighCDF and 
StatsRayleighPDF functions.
x = μ + 
2ln 1 cdf
(
),
