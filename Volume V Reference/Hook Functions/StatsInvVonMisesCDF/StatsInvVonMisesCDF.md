# StatsInvVonMisesCDF

StatsInvUSquaredCDF
V-944
where a<c<b.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsTriangularCDF and 
StatsTriangularPDF functions.
StatsInvUSquaredCDF 
StatsInvUSquaredCDF(cdf, n, m, method, useTable)
The StatsInvUSquaredCDF function returns the inverse of Watson’s U2 cumulative distribution function 
integer sample sizes n and m. Use a nonzero value for useTable to search a built-in table of values. If n and 
m cannot be found in the table, it will proceed according to method:
For large n and m, consider using the Tiku approximation. To abort execution, press the User Abort Key 
Combinations. Because n and m are interchangeable, n should always be the smaller value. For n>8 the 
upper limit in the table matched the maximum that can be computed using the Burr algorithm. There is no 
point in using method 0 with m values exceeding these limits.
The inverse is obtained from precomputed tables of Watson’s U2 (see StatsUSquaredCDF).
References
Burr, E.J., Small sample distributions of the two sample Cramer-von Mises’ W2 and Watson’s U2, Ann. Mah. 
Stat. Assoc., 64, 1091-1098, 1964.
Tiku, M.L., Chi-square approximations for the distributions of goodness-of-fit statistics, Biometrica, 52, 630-
633, 1965.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWatsonUSquaredTest and 
StatsUSquaredCDF functions.
StatsInvVonMisesCDF 
StatsInvVonMisesCDF(cdf, a, b)
The StatsInvVonMisesCDF function returns the numerically evaluated inverse of the von Mises cumulative 
distribution function where the value of the integral of the distribution matches cdf. Parameters are as for 
StatsVonMisesCDF.
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
method
What It Does
0
Exact computation using Burr algorithm (could be slow).
1
Tiku approximation using chi-squared.
2
Use built-in table only and return a NaN if not in table.
Note:
Table values are different from computed values. These values use more conservative 
criteria than computed values. Table values are more consistent with published values 
because the U2 distribution is a highly irregular function with multiple steps of arbitrary 
sizes. The standard for published tables provides the X value of the next vertical transition 
to the one on which the specified P is found. See StatsInvFriedmanCDF.
x =
a +
cdf (b  a)(c  a)
0 cdf c  a
b  a
b 
(1 cdf )(b  a)(b  c)
c  a
b  a cdf 1






