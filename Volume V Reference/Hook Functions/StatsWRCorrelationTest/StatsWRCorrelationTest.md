# StatsWRCorrelationTest

StatsWRCorrelationTest
V-993
StatsAngularDistanceTest, StatsKWTest, StatsWilcoxonRankTest
StatsWRCorrelationTest 
StatsWRCorrelationTest [flags] waveA, waveB
The StatsWRCorrelationTest operation performs a Weighted Rank Correlation test on waveA and waveB, 
which contain the ranks of sequential factors. The waves are 1-based, integer ranks of factors in the range 
1-2^31.
StatsWRCorrelationTest computes a top-down correlation coefficient using Savage sums as well as the 
critical and P-values. Output is to the W_StatsWRCorrelationTest wave in the current data folder or 
optionally to a table.
Flags
Details
The StatsWRCorrelationTest input waves must be one-dimensional and have the same length. The waves are 1-
based, integer ranks of factors corresponding to the point number. Ranks may have ties in which case you should 
repeat the rank value. For example, if the second and third entries have the same rank you should enter {1,2,2,4}. 
H0 stipulates that the same factors are most important in both groups represented by waveA and waveB.
The top-down correlation is the sum of the product of Savage sums for each row:
where n is the number of rows and the Savage sum Si is
and SiA corresponds to the Si value of the rank of the data in row (i-1) of waveA.
References
Iman, R.L., and W.J. Conover, A measure of top-down correlation, Technometrics, 29, 351-357, 1987.
See, in particular, Chapter 19 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsLinearCorrelationTest, 
StatsRankCorrelationTest, StatsTopDownCDF, and StatsInvTopDownCDF.
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/Z
Ignores errors.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
rTD =
SiASiB  n
i=1
n

n  S1
,
Si =
1
j
j=i
n
 ,
