# StatsScheffeTest

StatsScheffeTest
V-975
with the initial condition
References
Bradley, J.V., Distribution-Free Statistical Tests, Prentice Hall, Englewood Cliffs, New Jersey, 1968.
Olmstead, P.S., Distribution of sample arrangements for runs up and down, Annals of Mathematical 
Statistics, 17, 24-33, 1946.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsSRTest function.
StatsScheffeTest 
StatsScheffeTest [flags] [wave1, wave2,… wave100]
The StatsScheffeTest operation performs Scheffe’s test for the equality of the means. It supports two basic 
modes: the default tests all possible combinations of pairs of waves; the second tests a single combination 
where the precise form of H0 is determined by the coefficients of a contrast wave (see /CONT). Output is to 
the M_ScheffeTestResults wave in the current data folder.
Flags
/ALPH=val
Sets the significance level (default 0.05).
/CONW=cWave 
Performs a multiple contrasts test. cWave has one point for each input wave. The 
cWave value is 1 to include the corresponding (zero based) input wave in the first 
group, 2 to include the wave in the second group, or zero to exclude the wave.
The contrast is defined as the difference between the normalized sum of the ranks of 
the first group and that of the second group. If cWave={0,1,1,1,2}, then the contrast 
hypothesis H0 corresponds to:
For each pair of waves (i, j) with i ¦ j, it computes
the statistic
f (r,n) = rf (r,n 1) + 2 f (r 1,n 1) + (n  r) f (r  2,n 1)
n
,
f (1,n) = 2
n!.
X1 + X2 + X3
3
 X4 = 0.
SEij =
s2
1
nj
+ 1
ni



 ,
s2 =
X j
2 
j=0
nj 1

i=1
W

X j
j=0
nj 1




 
2
nj
,
i=1
W

S =
ci X i
i=0
n1

SE
,
