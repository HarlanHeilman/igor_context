# StatsGEVPDF

StatsGEVCDF
V-934
Details
The input srcWave must contain angles in radians, can be any number of dimensions, can be single or double 
precision, and should not contain NaNs or INFs.
StatsHodgesAjneTest performs the standard Hodges-Ajne test, which simply tests for uniformity against 
the hypothesis that the population is not uniformly distributed around the circle. This test finds a diameter 
that divides the circle into two halves such that one contains the least number of data m, the test statistic.
Use /SA to perform the modified (Batschelet) test, which tests against the alternative that the population is 
concentrated somehow about the specified angle. The modified test counts the number of points m' in 90-
degree neighborhoods around the specified angle. The test statistic is given by C=n-m' where n is the 
number of points in the wave. The critical value is computed from the binomial probability density.
In both cases H0 is rejected if the statistic is smaller than the critical value.
V_flag will be set to -1 for any error and to zero otherwise.
References
Ajne, B., A simple test for uniformity of a circular distribution, Biometrica, 55, 343-354, 1968.
See, in particular, Chapter 27 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsCircularMeans, StatsCircularMoments, StatsWatsonUSquaredTest, StatsWatsonWilliamsTest, and 
StatsWheelerWatsonTest.
StatsGEVCDF
StatsGEVCDF(x, , , )
The StatsGEVCDF function returns the generalized extreme value cumulative distribution function.
where 
and >0.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsGEVPDF, StatsEValuePDF, StatsEValueCDF, StatsInvEValueCDF
StatsGEVPDF
StatsGEVPDF(x, , , )
The StatsGEVPDF function returns the generalized extreme value probability distribution function.
/T=k
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
F(x,μ,σ,ξ) = exp −1+ ξ x −μ
σ
⎛
⎝⎜
⎞
⎠⎟
−1/ξ
⎡
⎣
⎢
⎢
⎤
⎦
⎥
⎥
⎧
⎨⎪
⎩⎪
⎫
⎬⎪
⎭⎪
,
1+ ξ x −μ
σ
⎛
⎝⎜
⎞
⎠⎟> 0,
