# StatsMultiCorrelationTest

StatsMaxwellPDF
V-957
StatsMaxwellPDF 
StatsMaxwellPDF(x, k)
The StatsMaxwellPDF function returns Maxwell’s probability distribution function
The Maxwell distribution describes, for example, the speed distribution of molecules in an ideal gas.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsMaxwellCDF and 
StatsInvMaxwellCDF functions.
StatsMedian 
StatsMedian(waveName)
The StatsMedian function returns the median value of a numeric wave waveName, which must not contain NaNs.
Example
Make/N=5 sample1={1,2,3,4,5}
Print StatsMedian(sample1)
3
Make/N=6 sample2={1,2,3,4,5,6}
Print StatsMedian(sample2)
3.5
See Also
Chapter III-12, Statistics for a function and operation overview
median, WaveStats, StatsQuantiles
StatsMooreCDF 
StatsMooreCDF(x, N)
The StatsMooreCDF function returns the cumulative distribution function for Moore’s R*, which is used in 
a nonparametric version of the Rayleigh test for uniform distribution around the circle. It supports the 
range 3 N 120 and does not change appreciably for N>120.
The distribution is computed from polynomial approximations derived from simulations and should be 
accurate to approximately three significant digits.
References
Moore, B.R., A modification of the Rayleigh test for vector data, Biometrica, 67, 175-180, 1980.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsCircularMeans function.
StatsMultiCorrelationTest 
StatsMultiCorrelationTest [flags] corrWave, sizeWave
The StatsMultiCorrelationTest operation performs various tests on multiple correlation coefficients. Inputs 
are two 1D waves: corrWave, containing correlation coefficients, and sizeWave, containing the size (number 
of elements) of the corresponding samples. Although you can do all the tests at the same time, it rarely 
makes sense to do so.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/CON={controlRow,tails}
f (x;k) =
2
 k 3/2x2 exp  kx2
2



 ,
x > 0.

StatsMultiCorrelationTest
V-958
Details
Without any flags, StatsMultiCorrelationTest computes 2 for the correlation coefficients and compares it 
with the critical value.
Performs a multiple comparison test using the controlRow element of corrWave as a 
control. It is one- or two-tailed test according to the tails parameter. Output is to the 
M_ControlCorrTestResults wave in the current data folder.
/CONT=cWave
Performs a multiple contrasts test on the correlation coefficients. The contrasts wave, 
cWave, contains the contrast factor, ci, entry for each of the n correlation coefficients ri 
in corrWave, and satisfying the condition that the sum of the entries in cWave is zero. 
H0 corresponds to
The test statistic S is
where zi is the Fisher z transform of the correlation coefficient ri:
It produces the SE value, the contrast statistic S, and the critical value, which are 
labeled ContrastSE, ContrastS, and Contrast_Critical, respectively, in the 
W_StatsMultiCorrelationTest wave.
/Q
No results printed in the history area.
/T=k
/TUK
Performs a Tukey-type multi comparison testing between the correlation coefficients 
by comparing every possible combination of pairs of correlation coefficients, 
computing the difference in their z-transforms, the SE, and the q statistic:
The critical value is computed from the q CDF (StatsInvQCDF) with degrees of 
freedom numWaves and infinity. Output is to the M_TukeyCorrTestResults wave in 
the current data folder or optionally to a table.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
ci
i=0
n1
 ri = 0.
S =
1
ci
2
ni  3
cizi
i=0
n1

,
zi = 1
2 ln 1+ ri
1 ri



 .
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
q =
zj  zi
1
2
1
ni  3 +
1
nj  3




.
