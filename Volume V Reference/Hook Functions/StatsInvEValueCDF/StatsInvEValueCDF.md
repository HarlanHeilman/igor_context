# StatsInvEValueCDF

StatsInvCMSSDCDF
V-937
See Also
Chapter III-12, Statistics for a function and operation overview; StatsChiCDF and StatsChiPDF.
StatsInvCMSSDCDF 
StatsInvCMSSDCDF(cdf, n)
The StatsInvCMSSDCDF function returns the critical values of the C distribution (mean square successive 
difference distribution), which is given by
where
 
Critical values are computed from the integral of the probability distribution function.
References
Young, L.C., On randomness in ordered sequences, Annals of Mathematical Statistics, 12, 153-162, 1941.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCMSSDCDF and StatsSRTest.
StatsInvDExpCDF 
StatsInvDExpCDF(cdf, , )
The StatsInvDExpCDF function returns the inverse of the double-exponential cumulative distribution 
function
It returns NaN for cdf <0 or cdf > 1.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsDExpCDF and StatsDExpPDF.
StatsInvEValueCDF 
StatsInvEValueCDF(cdf, , )
The StatsInvEValueCDF function returns the inverse of the extreme-value (type I, Gumbel) cumulative 
distribution function
where >0. It returns NaN for cdf<0 or cdf>1. This inverse applies to the “minimum” form of the distribution. 
Reverse the sign of  to obtain the inverse distribution of the maximum form.
See Also
Chapter III-12, Statistics for a function and operation overview.
f (C,n) =
(2m + 2)
a22m+1 (m +1)
[
]
2 1 C 2
a2



 
m
,
a2 =
n2 + 2n 12
(
) n  2
(
)
n3 13n + 24
(
)
,
m =
n4  n3 13n2 + 37n  60
(
)
2 n3 13n + 24
(
)
.
x =
μ +  ln(2cdf )
when cdf < 0.5
μ   ln 2 1 cdf
(
)
 

when cdf  0.5


 
x = μ   ln 1 cdf
(
)
