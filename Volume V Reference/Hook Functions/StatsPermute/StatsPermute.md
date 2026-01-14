# StatsPermute

StatsParetoCDF
V-965
Details
The input wave to StatsNPNominalSRTest is specified with srcWave or /P. The wave must contain exactly two 
values. If srcWave is a text wave, then each type can be designated by a letter or by a short string (less than 200 
bytes). If srcWave is numeric, you should avoid the usual floating point waves, which can give rise to internal 
representations of more than two distinct values. Output to W_StatsNPSRTest includes the total number of 
points (N), the number of occurrences (m) of the first variable, the number of occurrences (n) of the second 
variable, and the number of runs (u). When both m and n are less than 300, it computes the P value 
(probability P(u'<u)) and the critical values using the Swed and Eisenhart algorithm. When m or n are larger 
than 300, it computes the mean and standard deviation of an equivalent normal distribution with the 
corresponding critical value.
References
Swed, F.S., and C. Eisenhart, Tables for testing randomness of grouping in a sequence of alternatives, Ann. 
Math. Statist., 14, 66-87, 1943.
See, in particular, Chapter 25 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsSRTest.
StatsParetoCDF 
StatsParetoCDF(x, a, c)
The StatsParetoCDF function returns the Pareto cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsParetoPDF and 
StatsInvParetoCDF functions.
StatsParetoPDF 
StatsParetoPDF(x, a, c)
The StatsParetoPDF function returns the Pareto probability distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsParetoCDF and 
StatsInvParetoCDF functions.
StatsPermute 
StatsPermute(waveA, waveB, dir)
The StatsPermute function permutes elements in waveA based on the lexicographic order of waveB and the 
direction dir. It returns 1 if a permutation is possible and returns 0 otherwise. Use dir=1 for the next 
permutation and dir=-1 for a previous permutation.
Details
Both waveA and waveB must be numeric. The lexicographic order of elements in the index wave is set so that 
permutations start with the index wave waveB in ascending order and end in descending order. Elements of 
waveA are permuted in place according to the order of the indices in waveB which are clipped (after permutation) 
to the valid range of entries in waveA. waveB is also permuted in place in order to allow you to obtain sequential 
permutations. If waveA consists of real numbers you can permute them using the lexicographic value of the 
entries directly. To do so pass $"" for waveB. Whenever it returns 0, neither waveA and waveB are changed.
F(x;a,c) = 1
a
x




c
.
f(x;a,c)= c
x
a
x




c
,
a,c > 0
x  a.
