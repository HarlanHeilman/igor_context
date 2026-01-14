# StatsRectangularPDF

StatsRayleighCDF
V-971
StatsLinearCorrelationTest, StatsCircularCorrelationTest, StatsKendallTauTest, 
StatsSpearmanRhoCDF, and StatsInvSpearmanCDF.
StatsRayleighCDF 
StatsRayleighCDF(x [, s [, m]])
The StatsRayleighCDF function returns the Rayleigh cumulative distribution function
with defaults s=1 and m=0. It returns NaN for s 0 and zero for x m.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRayleighPDF and 
StatsInvRayleighCDF functions.
StatsRayleighPDF 
StatsRayleighPDF(x [, s [, m]])
The StatsRayleighPDF function returns the Rayleigh probability distribution function
with defaults s=1 and m=0. It returns NaN for s 0 and zero for x m.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRayleighCDF and 
StatsInvRayleighCDF functions.
StatsRectangularCDF 
StatsRectangularCDF(x, a, b)
The StatsRectangularCDF function returns the rectangular (uniform) cumulative distribution function
where a< b.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRectangularPDF and 
StatsInvRectangularCDF functions.
StatsRectangularPDF 
StatsRectangularPDF(x, a, b)
The StatsRectangularPDF function returns the rectangular (uniform) probability distribution function
F(x;,μ) = 1 exp  x  μ
(
)
2
2 2



 ,
 > 0,x > μ.
f (x;,μ) = x  μ
 2
exp  x  μ
(
)
2
2 2



 ,
 > 0,x > μ.
F(x,a,b) =
0
x a
x  a
b  a
a x b
1
x  b






f (x;a,b) =
1
b  a
a x b
0
otherwise



