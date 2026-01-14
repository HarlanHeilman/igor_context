# StatsWilcoxonRankTest

StatsWilcoxonRankTest
V-991
Details
The StatsWatsonWilliamsTest must have at least two input waves, which contain angles in radians (mod 
2), can be single or double precision, and can be of any dimensionality; the waves must not contain any 
NaNs or INFs.
The Wheeler-Watson H0 postulates that the samples came from the same population. The extension of the 
test to more than two samples is due to Mardia. The Wheeler-Watson test is not valid for data with ties, in 
which case you should use Watson’s U2 test.
 V_flag will be set to -1 for any error and to zero otherwise.
References
Mardia, K.V., Statistics of Directional Data, Academic Press, New York, New York, 1972.
See, in particular, Chapter 27 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsWatsonUSquaredTest and 
StatsWheelerWatsonTest.
StatsWilcoxonRankTest 
StatsWilcoxonRankTest [flags] waveA, waveB
The StatsWilcoxonRankTest operation performs the nonparametric Wilcoxon-Mann-Whitney two-sample 
rank test or the Wilcoxon Signed Rank test (for paired data) on waveA and waveB. Output is to the 
W_WilcoxonTest wave in the current data folder or optionally to a table.
waveA and waveB must not contain NaNs or INFs.
Flags
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors.
/ALPH = val
Sets the significance level (default val=0.05).
/APRX=m
Approximations may be appropriate for large sample sizes when computation may 
take a long time.
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/TAIL=tail
Sets the approximation method. It computes an exact critical value by default.
m=1:
Standard normal approximation with ties (Zar P. 151).
m=2:
Improved normal approximation (Zar P. 152).
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
tail is a bitwise parameter that specifies the tails tested.
Bit 0:
Lower tail.
Bit 1:
Upper tail (default).
Bit 2:
Two tail.

StatsWilcoxonRankTest
V-992
Details
The Wilcoxon-Mann-Whitney test combines the two samples and ranks them to compute the statistic U. If 
waveA has m points and waveB has n points, then U is given by
with the corresponding statistic U' given by 
where Ri is the ranks of data in the ith wave (ranked in ascending order). 
The distribution of U is difficult to compute, requiring the number of possible permutations of m elements 
of waveA and n elements of waveB that give rise to U values that do not exceed the one computed. The 
distribution is computed according to the algorithm developed by Klotz. With increasing sample size one 
can avoid the time consuming distribution computation and use a normal approximation instead. Klotz 
recommends this approximation for N=m+n~100.
Use /APRX=2 for the best approximation. The two approximations are discussed by Zar. 
The Wilcoxon Signed Rank Test, or Wilcoxon Paired-Sample Test, ranks the difference between pairs of 
values and computes the sums of the positive ranks (Tp) and the negative ranks (Tm). It calculates Tp and 
Tm and P-values for all tail combinations. The P-values are:
P_lower_tail 
P(Wp<=Tp)
P_upper_tail
P(Wp>=Tp)
P_two_tail
2*Min(P_lower_tail,P_upper_tail)
Wp is the generic symbol for the sum of positive ranks for the given number of pairs.
 V_flag will be set to -1 for any error and to zero otherwise.
In both Wilcoxon-Mann-Whitney two-sample rank test and the Wilcoxon Signed Rank test H0 is that the 
data in the two input waves are statistically the same.
References
Cheung, Y.K., and J.H. Klotz, The Mann Whitney Wilcoxon distribution using linked lists, Statistica Sinica, 
7, 805-813, 1997.
See in particular Chapter 15 of:
Klotz, J.H., Computational Approach to Statistics.
Streitberg, B., and J. Rohmel, Exact distributions for permutations and rank tests: An introduction to some 
recently published algorithms, Statistical Software Newsletter, 12, 10-17, 1986.
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview.
See Setting Bit Parameters on page IV-12 for details about bit settings.
You can perform any combination of tests by adding their corresponding tail values 
(/TAIL=7 tests all tail possiblities). Note that H0 changes according to the selected tail.
/WSRT
Performs the Wilcoxon Signed Rank Test for paired data. The test computes statistics 
Tp and Tm, lower-tail, upper-tail, and two-tail P-values. If the number of samples is 
less than 200 it computes exact P-values, otherwise they are computed using the 
normal approximation. Do not use /ALPH, /APRX, and /TAIL with this flag.
/Z
Ignores errors.
U = mn + m m +1
(
)
2
 R1,
U ' = nm + n n +1
(
)
2
 R2.
