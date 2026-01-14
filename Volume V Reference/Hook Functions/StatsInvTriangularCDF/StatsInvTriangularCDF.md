# StatsInvTriangularCDF

StatsInvRectangularCDF
V-943
StatsInvRectangularCDF 
StatsInvRectangularCDF(cdf, a, b)
The StatsInvRectangularCDF function returns the inverse of the rectangular (uniform) cumulative 
distribution function
where a< b.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRectangularCDF and 
StatsRectangularPDF functions.
StatsInvSpearmanCDF 
StatsInvSpearmanCDF(cdf, N)
The StatsInvSpearmanCDF function returns the inverse cumulative distribution function for Spearman’s r, 
which is used as a critical value in rank correlation tests.
The inverse distribution is computed by finding the value of r for which it attains the cdf value. The result 
is usually lower than in published tables, which are more conservative when the first derivative of the 
distribution is discontinuous.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRankCorrelationTest, 
StatsSpearmanRhoCDF, and StatsKendallTauTest functions.
StatsInvStudentCDF 
StatsInvStudentCDF(cdf, n)
The StatsInvStudentCDF function returns the numerically evaluated inverse of Student cumulative 
distribution function. There is no closed form expression.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsStudentCDF and 
StatsStudentPDF functions.
StatsInvTopDownCDF 
StatsInvTopDownCDF(cdf, N)
The StatsInvTopDownCDF function returns the inverse cumulative distribution function for the top-down 
distribution. For 3 N 7 it uses a lookup table CDF and returns the next higher value of r for which the 
distribution value is larger than cdf. For 8 N 50 it returns the nearest value for which the built-in 
distribution returns cdf. For N>50 it returns the scaled normal approximation.
Tabulated values are from Iman and Conover who pick as the critical value the very first transition of the 
distribution following the specified cdf value. These tabulated values tend to be slightly higher than 
calculated values for 7<N<15.
References
Iman, R.L., and W.J. Conover, A measure of top-down correlation, Technometrics, 29, 351-357, 1987.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRankCorrelationTest and 
StatsTopDownCDF functions.
StatsInvTriangularCDF 
StatsInvTriangularCDF(cdf, a, b, c)
The StatsInvTriangularCDF function returns the inverse of the triangular cumulative distribution function
x = a + cdf (b  a),
a < b.
