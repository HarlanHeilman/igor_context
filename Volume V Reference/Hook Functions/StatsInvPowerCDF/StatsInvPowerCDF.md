# StatsInvPowerCDF

StatsInvNCFCDF
V-941
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNCChiCDF, StatsNCChiPDF, 
StatsChiCDF, and StatsChiPDF functions.
StatsInvNCFCDF 
StatsInvNCFCDF(cdf, n1, n2, d)
The StatsInvNCFCDF function returns the numerically evaluated inverse of the cumulative distribution 
function of the noncentral F distribution. n1 and n2 are the shape parameters and d is the noncentrality 
measure. There is no closed form expression for the inverse.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNCFCDF and StatsNCFPDF 
functions.
StatsInvNormalCDF 
StatsInvNormalCDF(cdf, m, s)
The StatsInvNormalCDF function returns the numerically computed inverse of the normal cumulative 
distribution function. There is no closed form expression.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNormalCDF and 
StatsNormalPDF functions.
StatsInvParetoCDF 
StatsInvParetoCDF(cdf, a, c)
The StatsInvParetoCDF function returns the inverse of the Pareto cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsParetoCDF and StatsParetoPDF 
functions.
StatsInvPoissonCDF 
StatsInvPoissonCDF(cdf, )
The StatsInvPoissonCDF function returns the numerically evaluated inverse of the Poisson cumulative 
distribution function. There is no closed form expression for the inverse Poisson distribution.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPoissonCDF and 
StatsPoissonPDF functions.
StatsInvPowerCDF 
StatsInvPowerCDF(cdf, b, c)
The StatsInvPowerCDF function returns the inverse of the Power Function cumulative distribution 
function
where the scale parameter b and the shape parameter c satisfy b,c>0.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPowerCDF, StatsPowerPDF and 
StatsPowerNoise functions.
x =
a
1 cdf
(
)
(1/c)
x = b / cdf (1/c).
