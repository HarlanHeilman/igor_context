# StatsInvChiCDF

StatsInvBetaCDF
V-936
where 
 is the binomial function. All parameters must be positive integers and must have m>n and x<k.
References
Klotz, J.H., Computational Approach to Statistics.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsHyperGCDF.
StatsInvBetaCDF 
StatsInvBetaCDF(cdf, p, q [, a, b])
The StatsInvBetaCDF function returns the inverse of the beta cumulative distribution function. There is no 
closed form expression for the inverse beta CDF; it is evaluated numerically.
The defaults (a=0 and b=1) correspond to the standard beta distribution.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBetaCDF and StatsBetaPDF.
StatsInvBinomialCDF 
StatsInvBinomialCDF(cdf, p, N)
The StatsInvBinomialCDF function returns the inverse of the binomial cumulative distribution function. 
The inverse function returns the value at which the binomial CDF with probability p and total elements N, 
has the value 0.95. There is no closed form expression for the inverse binomial CDF; it is evaluated 
numerically.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBinomialCDF and 
StatsBinomialPDF.
StatsInvCauchyCDF 
StatsInvCauchyCDF(cdf, )
The StatsInvCauchyCDF function returns the inverse of the Cauchy-Lorentz cumulative distribution 
function
It returns NaN for cdf <0 or cdf> 1.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCauchyCDF and StatsCauchyPDF.
StatsInvChiCDF 
StatsInvChiCDF(x, n)
The StatsInvChiCDF function returns the inverse of the chi-squared distribution of x and shape parameter 
n. The inverse of the distribution is also known as the percent point function.
f (x;m,n,k) =
n
x
 



m  n
k  x
 



m
k
 



,
a
b


x = μ +  tan  cdf  1
2


-
./


 

.
