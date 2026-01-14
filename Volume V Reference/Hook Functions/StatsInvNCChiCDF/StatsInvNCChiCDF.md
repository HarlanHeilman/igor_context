# StatsInvNCChiCDF

StatsInvLogNormalCDF
V-940
where the scale parameter b>0 and the shape parameter is a.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogisticCDF and 
StatsLogisticPDF functions.
StatsInvLogNormalCDF 
StatsInvLogNormalCDF(cdf, sigma, theta, mu)
The StatsInvLogNormalCDF function returns the numerically evaluated inverse of the lognormal 
cumulative distribution function.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogNormalCDF and 
StatsLogNormalPDF functions.
StatsInvMaxwellCDF 
StatsInvMaxwellCDF(cdf, k)
The StatsInvMaxwellCDF function returns the evaluated numerically inverse of the Maxwell cumulative 
distribution function. There is no closed form expression. 
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsMaxwellCDF and 
StatsMaxwellPDF functions.
StatsInvMooreCDF 
StatsInvMooreCDF(cdf, N)
The StatsInvMooreCDF function returns the inverse cumulative distribution function for Moore’s R*, 
which is used as a critical value in nonparametric version of the Rayleigh test for uniform distribution 
around the circle. It supports the range 3 N120 and does not change appreciably for N > 120.
The inverse distribution is computed from polynomial approximations derived from simulations and 
should be accurate to approximately three significant digits.
References
Moore, B.R., A modification of the Rayleigh test for vector data, Biometrica, 67, 175-180, 1980.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsCircularMeans function.
StatsInvNBinomialCDF 
StatsInvNBinomialCDF(cdf, k, p)
The StatsInvNBinomialCDF function returns the numerically evaluated inverse of the negative binomial 
cumulative distribution function. There is no closed form expression.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNBinomialCDF and 
StatsNBinomialPDF functions.
StatsInvNCChiCDF 
StatsInvNCChiCDF(cdf, n, d)
The StatsInvNCChiCDF function returns the inverse of the noncenteral chi-squared cumulative 
distribution function. It is computationally intensive because the inverse is computed numerically and 
involves multiple evaluations of the noncentral distribution, which is evaluated from a series expansion.
x = a + blog
cdf
1 cdf
 


 .
