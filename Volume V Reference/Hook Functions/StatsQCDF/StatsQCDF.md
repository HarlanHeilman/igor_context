# StatsQCDF

StatsPowerNoise
V-967
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPowerPDF, StatsInvPowerCDF 
and StatsPowerNoise functions.
StatsPowerNoise 
StatsPowerNoise(b, c)
The StatsPowerNoise function returns a pseudorandom value from the power distribution function with 
probability distribution:
The random number generator initializes using the system clock when Igor Pro starts. This almost 
guarantees that you will never repeat a sequence. For repeatable “random” numbers, use SetRandomSeed. 
The algorithm uses the Mersenne Twister random number generator.
See Also
The SetRandomSeed operation.
The StatsPowerPDF StatsInvPowerCDF and StatsInvPowerCDF functions.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
StatsPowerPDF 
StatsPowerPDF(x, b, c)
The StatsPowerPDF function returns the Power Function probability distribution function
where b is a scale parameter and c is a shape parameter.
For b,c > 0, x is drawn from b >= x >= 0.
For b>0, c<0, x is drawn from x>b.
For b<0, c>0, x is drawn from -b <= x <= 0.
For b<0, c<0, x is drawn from x<-b.
Note that for -1<c<0 the average diverges and the magnitude of a mean calculated from N samples will in-
crease indefinitely with N.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPowerCDF, StatsInvPowerCDF 
and StatsPowerNoise functions.
StatsQCDF 
StatsQCDF(q, r, c, df)
The StatsQCDF function returns the value of the Q cumulative distribution function for r the number of 
groups, c the number of treatments, and df the error degrees of freedom (f=rc(n-1) with sample size n).
Details
The Q distribution is the maximum of several Studentized range statistics. For a simple Tukey test, use r=1.
References
Copenhaver, M.D., and B.S. Holland, Multiple comparisons of simple effects in the two-way analysis of 
variance with fixed effects, Journal of Statistical Computation and Simulation, 30, 1-15, 1988.
f (x;b,c) = c
x
x
b




c
.
f (x,b,c) = c
x
x
b




c
,
