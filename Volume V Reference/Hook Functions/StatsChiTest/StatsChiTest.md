# StatsChiTest

StatsCauchyPDF
V-913
StatsCauchyPDF 
StatsCauchyPDF(x)
The StatsCauchyPDF function returns the Cauchy-Lorentz probability distribution function
where  is the location parameter and  is the scale parameter. Use =0 and =1 for the standard form of 
the Cauchy-Lorentz distribution.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCauchyCDF and StatsInvCauchyCDF.
StatsChiCDF 
StatsChiCDF(x, n)
The StatsChiCDF function returns the chi-squared cumulative distribution function for the specified value 
and degrees of freedom n.
where is (a,b) the incomplete gamma function. The distribution can also be expressed as
See Also
Chapter III-12, Statistics for a function and operation overview; StatsChiPDF, StatsInvChiCDF, and 
gammq.
StatsChiPDF 
StatsChiPDF(x, n)
The StatsChiPDF function returns the chi-squared probability distribution function for the specified value 
and degrees of freedom as
See Also
Chapter III-12, Statistics for a function and operation overview; StatsChiCDF and StatsChiPDF.
StatsChiTest 
StatsChiTest [flags] srcWave1, srcWave2
The StatsChiTest operation computes a 2 statistic for comparing two distributions or a 2 statistic for 
comparing a sample distribution with its expected values. In both cases the comparison is made on a bin-
by-bin basis. Output is to the W_StatsChiTest wave in the current data folder or optionally to a table.
f (x;μ,) = 1

1
1+
x  μ




 
2 ,
F(x;n) =

n
2 , x
2



 
 n
2




.
F(x;n) = 1 gammq n
2 , x
2
 


 .
f (x;n) =
exp  x
2



 x
n
2 1
2
n
2  n
2




.
