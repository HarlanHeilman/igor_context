# StatsLinearCorrelationTest

StatsLinearCorrelationTest
V-950
V_flag will be set to -1 for any error and to zero otherwise.
References
Klotz, J.H., Computational Approach to Statistics.
Klotz, J., and Teng, J., One-way layout for counts and the exact enumeration of the Kruskal-Wallis H 
distribution with ties, J. Am. Stat. Assoc, 72, 165-169, 1977.
Wallace, D.L., Simplified Beta-Approximation to the Kruskal-Wallis H Test, J. Am. Stat. Assoc., 54, 225-230, 1959.
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsWilcoxonRankTest, StatsNPMCTest, 
and StatsAngularDistanceTest.
StatsLinearCorrelationTest 
StatsLinearCorrelationTest [flags] waveA, waveB
The StatsLinearCorrelationTest operation performs correlation tests on waveA and waveB, which must be 
real valued numeric waves and must have the same number of points. Output is to the 
W_StatsLinearCorrelationTest wave in the current data folder or optionally to a table.
Flags
Details
The linear correlation tests start by computing the linear correlation coefficient for the n elements of both 
waves:
Row
Data
0
Number of groups
1
Number of valid data points (excludes NaNs)
2
Alpha
3
Kruskal-Wallis Statistic H
4
Chi-squared approximation for the critical value Hc
5
Chi-squared approximation for the P value
6
Wallace approximation for the critical value Hc
7
Wallace approximation for the P value
8
Exact P value (requires /E)
/ALPH = val
Sets the significance level (default val=0.05).
/CI
Computes confidence intervals for the correlation coefficient.
/Q
No results printed in the history area.
/RHO=rhoValue
Tests hypothesis that the correlation has a nonzero value |r| 1.
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

StatsLinearCorrelationTest
V-951
Next it computes the standard error of the correlation coefficient
The basic test is for hypothesis H0: the correlation coefficient is zero, in which case t and F statistics are 
applicable. It computes the statistics:
and
and then the critical values for one and two tailed hypotheses (designated by tc1, tc2, Fc1, and Fc2 
respectively). Critical value for r are computed using
where i takes the values 1 or 2 for one and two tailed hypotheses. Finally, it computes the power of the test 
at the alpha significance level for both one and two tails (Power1 and Power2).
If you use /RHO it uses the Fisher transformation to compute
the standard error approximation
and the critical values from the normal distribution Zci.
r =
XiYi
i=1
n

 1
n
Xi
i=1
n

Yi
i=1
n

Xi
2
i=1
n

 1
n
Xi
i=1
n




 
2





 
Yi
2
i=1
n

 1
n
Yi
i=1
n




 
2





 
sr =
1 r2
n  2
t = r / sr
F = 1+ r
1 r ,
rci =
tc
2
tc
2 + n
FisherZ= 1
2 ln 1+r
1-r




zeta= 1
2 ln 1+
1-




sigmaZ=
1
n  3,
Zstatistic= FisherZ  zeta
sigmaZ
,
