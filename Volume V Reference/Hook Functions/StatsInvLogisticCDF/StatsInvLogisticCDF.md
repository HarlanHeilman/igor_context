# StatsInvLogisticCDF

StatsInvGammaCDF
V-939
References
Iman, R.L., and J.M. Davenport, Approximations of the critical region of the Friedman statistic, Comm. 
Statist., A9, 571-595, 1980.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFriedmanCDF and 
StatsFriedmanTest.
StatsInvGammaCDF 
StatsInvGammaCDF(cdf, , , )
The StatsInvGammaCDF function returns the inverse of the gamma cumulative distribution function. 
There is no closed form expression for the inverse gamma distribution; it is evaluated numerically.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGammaCDF and StatsGammaPDF.
StatsInvGeometricCDF 
StatsInvGeometricCDF(cdf, p)
The StatsInvGeometricCDF function returns the inverse of the geometric cumulative distribution function
where p is the probability of success in a single trial and x is the number of trials.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGeometricCDF and 
StatsGeometricPDF.
StatsInvKuiperCDF 
StatsInvKuiperCDF(cdf)
The StatsInvKuiperCDF function returns the inverse of Kuiper cumulative distribution function.
There is no closed form expression. It is mapped to the range of 0.4 to 4, with accuracy of 1e-10.
References
See in particular Section 14.3 of
Press, William H., et al., Numerical Recipes in C, 2nd ed., 994 pp., Cambridge University Press, New York, 1992.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsKuiperCDF.
StatsInvLogisticCDF 
StatsInvLogisticCDF(cdf, a, b)
The StatsInvLogisticCDF function returns the inverse of the logistic cumulative distribution function
6
2, 3, 4, 5
7
2, 3, 4
8
2, 3
9
2, 3
n
m
x = ln(1 cdf )
ln(1 p) 1.
