# StatsLogisticPDF

StatsLogisticCDF
V-955
Here W is the number of Y-waves and 
 is the total number of data points in all Y-waves.
The test statistic F for equality of slopes is given by:
Fc is the corresponding critical value.
Output is to the W_LinearRegressionMC wave in the current data folder.
V_flag is set to -1 for any error and to zero otherwise.
S_waveNames is set to a semicolon-separated list of the names of the waves created by the operation.
References
See, in particular, Chapter 18 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; curvefit.
StatsLogisticCDF 
StatsLogisticCDF(x, a, b)
The StatsLogisticCDF function returns the logistic cumulative distribution function
where the scale parameter b>0 and the shape parameter is a.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogisticPDF and 
StatsInvLogisticCDF functions.
StatsLogisticPDF 
StatsLogisticPDF(x, a, b)
The StatsLogisticPDF function returns the logistic probability distribution function
DFp =
ni  2
(
)
j=1
W

DFt =
ni  2
j=1
W

N =
nj
j=1
W

F =
SSc  SSp
numWaves 1




SSp
DFp .
F(x;a,b) =
1
1+ exp  x  a
b




.
f (x;a,b) =
exp  x  a
b


 

b 1+ exp  x  a
b


 





2 ,
