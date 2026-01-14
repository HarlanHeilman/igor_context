# StatsCircularCorrelationTest

StatsCircularCorrelationTest
V-914
Flags
Details
The source waves, srcWave1 and srcWave2, must have the same number of points and can be any real 
numeric data type. Any nonpositive values (including NaN) in either wave removes the entry in both 
waves from consideration and reduces the degrees of freedom by one. The number degrees of freedom is 
initially the number of points in srcWave1-1-nCon. By default it is assumed that srcWave1 and srcWave2 
represent two distributions of binned data.
When you specify /S, srcWave1 must consist of binned values of measured data and srcWave2 must contain 
the corresponding expected values. The calculation is: 
Here Yi is the sample point from srcWave1, Vi is the expected value of Yi based on an assumed distribution 
(srcWave2), and n is the number of points in the each wave. If you do not use /S, it calculates:
where Y1i and Y2i are taken from srcWave1 and srcWave2 respectively.
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsContingencyTable.
StatsCircularCorrelationTest 
StatsCircularCorrelationTest [flags] waveA, waveB
The StatsCircularTwoSampleTest operation peforms a number of tests for two samples of circular data. 
Using the appropriate flags you can choose between parametric or nonparametric, unordered or paired 
tests. The input consists of two waves that contain one or two columns. The first column contains angle data 
expressed in radians and an optional second column contains associated vector lengths. The waves must be 
either single or double precision floating point. Results are stored in the W_StatsCircularCorrelationTest 
wave in the current data folder and optionally displayed in a table. Some flags generate additional outputs, 
described below.
Flags
/ALZR
Allows zero entries in source waves. If you are using /S zero entries in srcWave2 are 
skipped.
/NCON=nCon
Specifies the number of constraints (0 by default), which reduces the number degrees 
of freedom and the critical value by nCon.
/S
Sets the calculation mode to a single distribution where srcWave1 represents an array 
of binned measurements and srcWave2 represents the corresponding expected values.
/T=k
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
/ALPH=val
Sets the significance level (default 0.05).
/NAA
Performs a nonparametric angular-angular correlation test.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
 2 =
Yi  Vi
(
)
2
Vi
.
i=0
n1

 2 =
Y1i  Y2i
(
)
2
Y1i + Y2i
,
i=0
n1


StatsCircularCorrelationTest
V-915
Details
The nonparametric test (/NAA) follows Fisher and Lee’s modification of Mardia’s statistic, which is an 
analogue of Spearman’s rank correlation. The test ranks the angles of each sample and computes the 
quantities r' and r'' as follows:
Here n is the number of data pairs and rai and rbi are the ranks of the ith member in the first and second 
samples respectively.
The test statistic is (n-1)(r'-r''), which is compared with the critical value (for one and two tails). The CDF of 
the statistic is a highly irregular function. The critical value is computed by a different methods according 
to n. For 3  n  8, a built-in table of CDF transitions gives a “conservative” estimate of the critical value. For 
9  n  30, the CDF is approximated by a 7th order polynomial in the region x > 0. For n  30, the CDF is 
from the asymptotic expression. For 3  n  30, CDF values are obtained by Monte-Carlo simulations using 
1e6 random samples for each n.
The parametric test for angular-angular correlation (/PAA) involves computation of a correlation coefficient 
raa and then evaluating the mean 
 and variance 
 of equivalent correlation coefficients computed 
from the same data but by deleting a different pair of angles each time. The mean and variance are then 
used to compute confidence limits L1 and L2:
where 
 is the normal distribution two-tail critical value at the a level of significance. H0 (corresponding 
to no correlation) is rejected if zero is not contained in the interval [L1,L2]. 
The parametric test for angular-linear correlation (/PAL) involves computation of the correlation coefficient ral 
which is then compared with a critical value from 
 for alpha significance and two degrees of freedom.
/PAA
Performs a parametric angular-angular correlation test.
/PAL
Performs a parametric angular-linear correlation test. In this case the angle wave is 
waveA and the linear data corresponds to waveB.
/Q
No results printed in the history area.
/T=k
/Z
Ignores errors.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
r' =
cos 2
n
rai  rbi
(
)



 
i=0
n1







2
+
sin 2
n
rai  rbi
(
)



 
i=0
n1







2
n2
,
r'' =
cos 2
n
rai + rbi
(
)



 
i=0
n1







2
+
sin 2
n
rai + rbi
(
)



 
i=0
n1







2
n2
.
raa
sraa
2
L1 = nraa  n 1
(
)raa  Z(2)
sraa
2
n ,
L2 = nraa  n 1
(
)raa + Z(2)
sraa
2
n
Z2

2
