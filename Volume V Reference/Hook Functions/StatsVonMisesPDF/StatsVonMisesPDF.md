# StatsVonMisesPDF

StatsVonMisesCDF
V-987
References
NIST/SEMATECH, Bartlett’s Test, in NIST/SEMATECH e-Handbook of Statistical Methods, 
<http://www.itl.nist.gov/div898/handbook/eda/section3/eda357.htm>, 2005.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsVonMisesCDF 
StatsVonMisesCDF(x, a, b)
The StatsVonMisesCDF function returns the von Mises cumulative distribution function
where I0(b) is the modified Bessel function of the first kind (bessI), and
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsVonMisesPDF, 
StatsInvVonMisesCDF, and StatsVonMisesNoise functions.
StatsVonMisesNoise 
StatsVonMisesNoise(a, b)
The StatsVonMisesNoise function returns a pseudo-random number from a von Mises distribution whose 
probability density is
where I0 is the zeroth order modified Bessel function of the first kind.
References
Best, D.J., and N. I. Fisher, Efficient simulation of von Mises distribution, Appl. Statist., 28, 152-157, 1979.
See Also
StatsVonMisesCDF, StatsVonMisesPDF, and StatsInvVonMisesCDF.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview
StatsVonMisesPDF 
StatsVonMisesPDF(q, a, b)
The StatsVonMisesPDF function returns the von Mises probability distribution function
F(;a,b) =
1
2I0(b)
exp bcos(x  a)
(
)dx
0

.
0 <  
 2
0 < a 
 2
b > 0.
f (;a,b) = exp bcos(  a)
[
]
2I0(b)
,
f (;a,b) = exp bcos   a
(
)
(
)
2I0(b)
.
