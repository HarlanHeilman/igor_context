# StatsTTest

StatsTrimmedMean
V-981
StatsTrimmedMean 
StatsTrimmedMean(waveName, trimValue)
The StatsTrimmedMean function returns the mean of the wave waveName after removing trimValue fraction 
of the values from both tails of the distribution. trimValue is a number in the range [0, 0.5]. waveName can be 
any real numeric type.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsQuantiles and mean.
StatsTTest 
StatsTTest [flags] wave1 [, wave2]
The StatsTTest operation performs two kinds of T-tests: the first compares the mean of a distribution with a 
specified mean value (/MEAN) and the second compares the means of the two distributions contained in wave1 
and wave2, which must contain at least two data points, can be any real numeric type, and can have an arbitrary 
number of dimensions. Output is to the W_StatsTTest wave in the current data folder or optionally to a table.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/CI
Computes the confidence intervals for the mean(s).
/DFM=m
/MEAN=meanV
Compares meanV with the mean of the distribution in wave1. Outputs are the number 
of points in the wave, the degrees of freedom (accounting for any NaNs), the average, 
standard deviation (),
the statistic
and the critical value, which depends on /TAIL.
/PAIR
Specifies that the input waves are pairs and computes the difference of each pair of 
data to get the average difference and the standard error of the difference 
. The t 
statistic is the ratio of the two
In this case H0 is that the difference is zero.
This mode does not support /CI and /DFM.
/Q
No results printed in the history area.
Specifies method for calculating the degrees of freedom.
m=0:
Default; computes equivalent degrees of freedom accounting for 
possibly different variances.
m=1:
Computes equivalent degrees of freedom but truncates to a smaller 
integer.
m=2:
Computes degrees of freedom by DF=n1+n2-2, where n is the sum of 
points in the wave. Appropriate when variances are equal.
sX =

DF +1
,
t = X  meanV
sX
d
Sd
t = d
sd
.
d

StatsTTest
V-982
Details
When comparing the mean of a single distribution with a hypothesized mean value, you should use 
/MEAN and only one wave (wave1). If you use two waves StatsTTest performs the T-test for the means of 
the corresponding distributions (which is incompatible with /MEAN).
When comparing the means of two distributions, the default t-statistic is computed from Welch's 
approximate t:
where 
 are variances, ni the number of samples, and 
 the averages of the respective waves. This expres-
sion is appropriate when the number of points and the variances of the two waves are different. If you want 
to compute the t-statistic using pooled variance you can use the /AEVR flag. In this case the pooled variance 
is given by
and the t-statistic is
The different test are:
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/TAIL=tailCode 
Here d is the mean of the difference population.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Specifies H0.
tailCode=1:
One tailed test (1  2).
tailCode=2:
One tailed test (1  2).
tailCode=4:
Default; two tailed test (1 = 2).
When performing paired tests using /PAIR:
tailCode=1:
One tailed test (d ).
tailCode=2:
One tailed test (d  ).
tailCode=4:
Default; two tailed test (d = ).
t ' =
x1  x2
s1
2
n1
+ s2
2
n2
,
si
2
Xi
sp
2 = n1 1
(
)s1
2 + n2 1
(
)s2
2
n1 + n2  2
,
t =
x1  x2
sp
1
n1
+ 1
n2
.
