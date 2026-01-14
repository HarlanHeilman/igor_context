# StatsCircularMeans

StatsCircularMeans
V-916
where:
References
Fisher, N.I., and A.J. Lee, Nonparametric measures of angular-angular association, Biometrica, 69, 315-321, 
1982.
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsInvChiCDF, StatsInvNormalCDF, 
and StatsKendallTauTest.
StatsCircularMeans 
StatsCircularMeans [flags] srcWave
The StatsCircularMeans operation calculates the mean of a number of circular means, returning the mean 
angle (grand mean), the length of the mean vector, and optionally confidence interval around the mean 
angle. Output is to the history area and to the W_CircularMeans wave in the current data folder.
Flags
/ALPH=val
Sets the significance level (default 0.05).
/CI 
Calculates the confidence interval (labeled CI_t1 and CI_t2) around the mean angle.
/NSOA
Performs nonparametric second order analysis according to Moore’s version of 
Rayleigh’s test where H0 corresponds to uniform distribution around the circle. 
Moore’s test ranks entries by the lengths of the mean radii (second column of the 
input) from smallest (rank 1) to largest (rank n) and then computes the statistic:
ral =
rxc
2 + rxs
2  2rxcrxsrcs
1 rcs
2
,
rxc =
Xi cos(ai)  1
n
Xi
i=0
n1

cos(ai)
i=0
n1

i=0
n1

Xi
2  1
n
Xi
i=0
n1





2
i=0
n1







cos2(ai)  1
n
cos(ai)
i=0
n1





2
i=0
n1







,
rxs =
Xi sin(ai)  1
n
Xi
i=0
n1

sin(ai)
i=0
n1

i=0
n1

Xi
2  1
n
Xi
i=0
n1





2
i=0
n1







sin2(ai)  1
n
sin(ai)
i=0
n1





2
i=0
n1







,
rcs =
cos(ai)sin(ai)  1
n
sin(ai)
i=0
n1

cos(ai)
i=0
n1

i=0
n1

sin2(ai)  1
n
sin(ai)
i=0
n1





2
i=0
n1







cos2(ai)  1
n
cos(ai)
i=0
n1





2
i=0
n1







.

StatsCircularMeans
V-917
Details
The srcWave input to StatsCircularMeans must be a single or double precision two column wave containing 
in each row a mean angle (radians) and the length of a mean radius (the first column contains mean angles 
and the second column contains mean vector lengths). srcWave must not contain any NaNs or INFs. The 
confidence interval calculation follows the procedure outlined by Batschelet.
V_flag will be set to -1 for any error and to zero otherwise.
where ai are the mean angle entries (from column 1) corresponding to vector length 
rank (i+1). The critical value is obtained from Moore’s distribution 
StatsInvMooreCDF.
/PSOA
Perform parametric second order analysis where H0 corresponds to no mean 
population direction. It assumes that the second order quantities are from a bivariate 
normal distribution. If this is not the case, use /NSOA above. The test statistic is:
where
Here n is the number of means in srcWave and the critical value is computed from the 
F distribution, equivalent to executing:
Print StatsInvFCDF(1-alpha,2,n-2)
/Q
No results printed in the history area.
/T=k
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
R' =
1
n
i +1
(
)cos ai
( )
i=0
n1





2
+
1
n
i +1
(
)sin ai
( )
i=0
n1





2
n
,
F = k(k  2)
2
X 2Sy2  2XYSxy +Y 2Sx2
Sx2Sy2  Sxy
2




X = 1
n
Xi
i=0
n1

= 1
n
ri
i=0
n1
 cos ai
( ),
Y = 1
n
Yi
i=0
n1

= 1
n
ri
i=0
n1
 sin ai
( ),
Sx2 =
Xi
2
i=0
n1

 1
n
Xi
i=0
n1





2
,
Sy2 =
Yi
2
i=0
n1

 1
n
Yi
i=0
n1





2
,
Sxy =
XiYi
i=0
n1

 1
n
Xi
i=0
n1

Yi
i=0
n1

.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
