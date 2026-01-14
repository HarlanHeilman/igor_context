# StatsSRTest

StatsSignTest
V-977
// Test uniform distribution
Make/O/N=(200) eee=enoise(5)
StatsShapiroWilkTest eee
W=0.959616 p=1.7979e-05
// p<alpha so reject normality
StatsSignTest 
StatsSignTest [flags] wave1, wave2
The StatsSignTest operation performs the sign test for paired-sample data contained in wave1 and wave2.
Flags
Details
The input waves must be the equal length, real numeric waves and must not contain any NaNs or INFs. 
Results are saved in the wave W_SignTest and are optionally displayed in a table. StatsSignTest computes 
the differences in each pair and counts the total number of entries with positive and negative differences, 
and tests the results using a binomial distribution. When the number of data pairs exceeds 1024 it uses a 
normal approximation to the binomials for calculating the probabilities and the power of the test.
References
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsWilcoxonRankTest
StatsSpearmanRhoCDF 
StatsSpearmanRhoCDF(r, N)
The StatsSpearmanRhoCDF function returns the cumulative distribution function for Spearman’s r, which 
is used in rank correlation test. It is valid for N>1 and -1 r 1. The distribution is mostly computed using 
the Edgeworth series expansion.
References
Algorithm AS 89, Appl. Statist., 24, 377, 1975.
van de Wiel, M.A., and A. Di Bucchianico, Fast computation of the exact null distribution of Spearman’s rho 
and Page’s L statistic for samples with and without ties, J. of Stat. Plan. and Inference, 92, 133-145, 2001.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRankCorrelationTest, 
StatsInvSpearmanCDF, and StatsKendallTauTest functions.
StatsSRTest 
StatsSRTest [flags] srcWave
The StatsSRTest operation performs a parametric or nonparametric serial randomness test on srcWave, 
which must contain finite numerical data. The null hypothesis of the test is that the data are randomly 
distributed. Output is to the W_StatsSRTest wave in the current data folder.
/ALPH=val
Sets the significance level (default 0.05).
/Q
No results printed in the history area. 
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

StatsSRTest
V-978
Flags
Details
The parametric test for serial randomness is according to Young. C is given by
where 
 is the mean and n is the number of points in srcWave. The critical value is obtained from mean 
square successive difference distribution StatsInvCMSSDCDF. For more than 150 points, StatsSRTest uses 
the normal approximation and provides the critical values from the normal distribution. For samples from 
a normal distribution, C is symmetrically distributed about 0 with positive values indicating positive 
correlation between successive entries and negative values corresponding to negative correlation.
The nonparametric test consists of counting the number of runs that are successive positive or successive 
negative differences between sequential data. If two sequential data are the same it computes two numbers 
of runs by considering the two possibilities where the equality is replaced with either a positive or a 
negative difference. The results of the operation include the number of runs up and down, the number of 
unchanged values (the number of places with no difference between consecutive entries), the size of the 
longest run and its associated probability, the number of converted equalities, and the probability that the 
number of runs is less than or equal to the reported number (StatsRunsCDF). When equalities are 
encountered the operation computes the probabilities that the computed number of runs or less can be 
found in an equivalent random sequence.
Converted equalities are those with the same sign on both sides so that when we replace the equality by the 
opposite sign we increase the number of runs. The equalities that are not converted are found between two 
different signs and therefore regardless of the sign that we give them they do not affect the total number of 
runs. We implicitly assume that the data does not contain more than one sequential equalities.
The longest run is determined without taking into account equalities or their conversions. The probability 
of the longest run is computed from Equation 6 of Olmstead, which is accurate within 0.001 when the 
/ALPH = val
Sets the significance level (default val=0.05).
/GCD
Tests the output of a random number generator (RNG). srcWave consists of values 
between 0 and 232 (converted to unsigned 32-bit integers). GCD computes the gcd for 
consecutive pairs of data in srcWave. The number of steps in the GCD and the 
distribution of the GCD’s are compared with ideal distributions and corresponding P 
values are reported. This test is part of Marsaglia’s Die-Hard battery of tests. P-values 
close to either 0 or 1 indicate a nonideal RNG. You should use the reported minimum 
and maximum values to check that the input is indeed in the proper range. Typically 
srcWave consists of at least1e6 entries.
/NAPR
Use the normal approximation even when the number of points is below 150.
/NP
Performs a nonparametric serial randomness test by counting the numbers of runs up 
and down and computing the probability that such a value is obtained by chance.
/P 
Performs a parametric serial randomness test.
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
C = 1
Xi  Xi+1
(
)
2
i=0
n2

2
Xi  X
(
)
2
i=0
n1

,
X
