# StatsNPNominalSRTest

StatsNPNominalSRTest
V-964
Details
Inputs to StatsNPMCTest are two or more 1D numerical waves (one wave for each group of samples) 
containing two or more valid entries. The waves must have the same number of points for the use /SNK and 
/TUK tests, otherwise, for waves of differing lengths you must use the Dunn-Hollander-Wolfe test (/DHW).
V_flag will be set to zero for no execution errors. Individual tests may fail if, for example, there are different 
number of samples in the input waves for a test that requires an equal number of points. StatsNPMCTest 
skips failed tests and V_flag will be a binary combination identifying the failed test(s):
V_flag will be set to -1 for any other errors.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA1Test and StatsKWTest.
For multiple comparisons in parametric tests see: StatsDunnettTest and StatsScheffeTest.
StatsNPNominalSRTest 
StatsNPNominalSRTest [flags] [srcWave]
The StatsNPNominalSRTest operation performs a nonparametric serial randomness test for nominal data 
consisting of two types. The null hypothesis is that the data are randomly distributed. Output is to the 
W_StatsNPSRTest wave in the current data folder.
Flags
/TUK
Perform a Tukey-type (Nemenyi) multiple comparison test using the difference 
between the rank sums. This is the default that is performed if you do not specify any 
of the test flags. This test requires equal numbers of points in all waves; use /DHW for 
unequal sizes.
Output is to the M_NPMCTukeyResults wave in the current data folder. The output 
column contents are: the first contains the difference between the rank sums, the 
second contains the SE values, the third contains the statistic q, the fourth contains the 
critical value for this specific alpha and the number of groups; and the last contains a 
conclusion flag with 0 indicating a rejection of H0 and 1 indicating acceptance. H0 
postulates that the paired means are the same.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors.
V_flag & 1
Tukey method failed (/TUK).
V_flag & 2
Student-Newman-Keuls failed (/SNK).
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/P={m,n,u}
Provides a summary of the data instead of providing the nominal series. m is the 
number of elements of the first type, n is the number of elements of the second type, 
and u is the number of runs or contiguous sequences of each type. Do not use srcWave 
with /P.
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
