# StatsUSquaredCDF

StatsUSquaredCDF
V-984
Details
Inputs to StatsTukeyTest are two or more 1D numeric waves (one wave for each group of samples) 
containing any numbers of points but with at least two or more valid entries.
The contents of the M_TukeyTestResults columns are: the first contains the difference between the group 
means 
, the second contains SE (supports unequal number of points), the third contains the q statistic 
for the pair, and the fourth contains the critical q value, the fifth contains the conclusion with 0 to reject H0 
(i == j) or 1 to accept H0, with /NK, the sixth contains the p values
the seventh contains the critical values, and the eighth contains the Newman-Keuls conclusion (with 0 to 
reject and 1 to accept H0). The order of the rows is such that all possible comparisons are computed 
sequentially starting with the comparison of the group having the largest mean with the group having the 
smallest mean.
 V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA1Test, StatsScheffeTest, and 
StatsDunnettTest.
StatsUSquaredCDF 
StatsUSquaredCDF(u2, n, m, method, useTable)
The StatsUSquaredCDF function returns the cumulative distribution function for Watson’s U2 with 
parameters u2 (U2 statistic) and integer sample sizes n and m. The calculation is computationally intensive, 
on the order of binomial(n+m, m). Use a nonzero value for useTable to search a built-in table of values. If n 
and m cannot be found in the table, it will proceed according to method:
For large n and m, consider using the Tiku approximation. To abort execution, press the User Abort Key 
Combinations.
Precomputed tables, using the algorithm described by Burr, contain these values:
/T=k
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors.
method
What It Does
0
Exact computation using Burr algorithm (could be slow).
1
Tiku approximation using chi-squared.
2
Use built-in table only and return a NaN if not in table.
n
m
4
4-30
5
5-30
6
6-30
7
7-30
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Xi
Xi
–
p = rank[Xi ] rank[X j ]+1,
