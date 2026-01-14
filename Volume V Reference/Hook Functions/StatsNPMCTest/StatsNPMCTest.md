# StatsNPMCTest

StatsNormalPDF
V-962
where erf is the error function.
See Also
Chapter III-12, Statistics for a function and operation overview; the erf, StatsNormalPDF and 
StatsInvNormalCDF functions.
StatsNormalPDF 
StatsNormalPDF(x, m, s)
The StatsNormalPDF function returns the normal probability distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNormalCDF and 
StatsInvNormalCDF functions.
StatsNPMCTest 
StatsNPMCTest [flags] [wave1, wave2,… wave100]
The StatsNPMCTest operation performs a number of nonparametric multiple comparison tests. Output 
waves are saved in the current data folder according to the test(s) performed. Some tests are only 
appropriate when you have the same number of samples in all groups. StatsNPMCTest usually follows 
StatsANOVA1Test or StatsKWTest.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/CIDX=controlIndex Performs nonparametric multiple comparisons on a control group specified by the 
zero-based controlIndex wave in the input list. Output is to the M_NPCCResults wave 
in the current data folder or optionally to a table. The output column contents are: the 
first contains the difference between the rank sums of the control and each of the other 
waves; the second contains the standard error (SE); the third contains the statistic q, 
defined as the ratio of the difference in rank sums to SE; the fourth contains the critical 
value which also depends on the tails specification (see /TAIL); and the fifth contains 
the conclusion with 0 to reject H0 and 1 to accept it. One version of this test applies 
when all inputs contain the same number of samples. When that is not the case, it uses 
the Dunn-Hollander-Wolfe approach to compute an appropriate SE and to handle 
possible ties.
/CONW=cWave
Performs a nonparametric multiple contrasts tests. cWave has one point for each input 
wave. The cWave value is 1 to include the corresponding (zero based) input wave in 
the first group, 2 to include the wave in the second group, or zero to exclude the wave.
The contrast is defined as the difference between the normalized sum of the ranks of 
the first group and that of the second group. If cWave={0,1,1,1,2}, then the contrast is 
computed as
where Rni is the normalized rank sum of the samples from the corresponding input 
wave. Note the significance of allowing zeros in the contrast wave because the actual 
ranking is performed on the pool of all the samples.
f (x,μ,) =
1

2
exp  (x  μ)2
2 2




 .

StatsNPMCTest
V-963
Output is to the M_NPMConResults wave in the current data folder or optionally to 
a table. The output column contents are: the first is the contrast value; the second is 
the standard error (SE); the third is the statistic S, which is the ratio of the absolute 
value of the contrast to SE; the fourth is the critical value (from 2 the approximation); 
and the fifth is the conclusion with 0 to reject H0 and 1 indicating acceptance.
This test supports input waves with different number of samples and can also handle 
tied ranks. Note that the contrast wave used here is structured differently than for 
StatsMultiCorrelationTest.
/DHW
Performs the Dunn-Holland-Wolfe test, which supports unequal number of samples 
and accounts for ties in the rank sums. Output is to the M_NPMCDHWResults wave 
in the current data folder or optionally to a table. The output column contents are: the 
first contains the difference between the means of the rank sums (rank sums divided 
by the number of samples in the group), the second contains the standard error (SE), 
the third contains the DHW statistic Q, the fourth contains the critical value, and the 
fifth contains the conclusion (0 to reject H0 and 1 to accept). 
/Q
No results printed in the history area.
/SWN
Creates a text wave containing wave names corresponding to each row of the 
comparison table. Depending on your choice of tests, the following wave names are 
created:
/CIDX test: T_NPCCResultsDescriptors
/DHW test: T_NPMCDHWDescriptors
/SNK test: T_NPMCSNKResultsDescriptors
/TUK test: T_NPMCTukeyDescriptors
/T=k
The table is associated with the test and not with the data. If you repeat the test, it will 
update the table with the new results.
/TAIL=tc 
Code combinations are not allowed.
/SNK
Performs a nonparametric variation on the Student-Newman-Keuls test where the 
standard error SE is a function of p (the rank difference). This test requires equal 
numbers of samples in all groups; use /DHW for unequal sizes.
Output is to the M_NPMCSNKResults wave in the current data folder. The output 
column contents are: the first contains the difference between rank sums, the second 
contains the standard error (SE), the third contains the p value (rank difference), the 
fourth the statistic, the fifth contains the critical value, and the sixth contains the 
conclusion (0 to reject H0 and 1 to accept). This test is more sensitive to differences 
than the Tukey test (/TUK).
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Specifies H0 with /CIDX.
tc=1:
One tailed test (c  a).
tc=2:
One tailed test (c  a).
tc=4:
Default; two tailed test (c = a).
