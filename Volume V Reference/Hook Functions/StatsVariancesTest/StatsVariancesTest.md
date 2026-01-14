# StatsVariancesTest

StatsVariancesTest
V-985
Because n and m are interchangeable, n should always be the smaller value. For n>8 the upper limit in the 
table matched the maximum that can be computed using the Burr algorithm. There is no point in using 
method 0 with m values exceeding these limits.
References
Burr, E.J., Small sample distributions of the two sample Cramer-von Mises’ W2 and Watson’s U2, Ann. Mah. 
Stat. Assoc., 64, 1091-1098, 1964.
Tiku, M.L., Chi-square approximations for the distributions of goodness-of-fit statistics, Biometrica, 52, 630-
633, 1965.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWatsonUSquaredTest and 
StatsInvUSquaredCDF functions.
StatsVariancesTest 
StatsVariancesTest [flags] [wave1, wave2,… wave100]
The StatsVariancesTest operation performs Bartlett’s or Levene’s test to determine if wave variances are 
equal. Output is to the W_StatsVariancesTest wave in the current data folder or optionally to a table.
Flags
Details
All tests define the null hypothesis by
8
8-26
9
9-22
10
10-18
11
11-16
12
12-14
13
13
/ALPH = val
Sets the significance level (default val=0.05).
/METH=m
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
n
m
Specifies the test type.
m=0:
Bartlett test (default).
m=1:
Levene’s test using the mean.
m=2:
Modified Levene’s test using the median.
m=3:
Modified Levene’s test using the 10% trimmed mean.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.

StatsVariancesTest
V-986
against the alternative
Bartlett’s test computes:
Here 
 is the variance of the ith wave, N is the sum of the points of all the waves, ni is the number of points 
in wave i, and k is the number of waves. The weighted variance is given by
H0 is rejected if T is greater than the critical value taken from the 2 distribution computed by solving for x:
Levene’s test computes:
where
 depends on /METH.
H0 is rejected if W is greater than the critical value from the F distribution computed by solving for x:
H 0 :
1
2 =  2
2 = ... =  k
2,
H a :
 i
2   j
2  foratleastonei  j.
T =
n  k
(
)ln  w
2
(
) 
ni 1
(
)ln  i
2
(
)
i=1
k

1+
1
3 k 1
(
)
1
ni 1 
1
N  k
i=1
k




 
.
2
i
 w
2 =
ni 1
(
) i
2
N  k
i=1
k

.
1 alpha = 1 gammq k 1
2
, x
2



 .
W =
N  k
(
)
ni Z i  Z
(
)
i=1
k

2
k 1
(
)
Zij  Z i
(
)
2
j=1
k

i=1
k

,
Zij = Yij  Y i ,
Z i = 1
ni
Zij
j=1
k

,
Z = 1
N
Zij
j=1
k

i=1
k

.
Yi
1 alpha = 1 betai 2
2 ,1
2 ,
2
2 + 1x



 .
