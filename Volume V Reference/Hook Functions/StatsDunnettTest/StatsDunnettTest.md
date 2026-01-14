# StatsDunnettTest

StatsDunnettTest
V-927
References
Hartigan, P. M., Computation of the Dip Statistic to Test for Unimodality, Applied Statistics, 34, 320-325, 1985.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsDunnettTest 
StatsDunnettTest [flags] [wave1, wave2,… wave100]
The StatsDunnettTest operation performs the Dunnett test by comparing multiple groups to a control 
group. Output is to the M_DunnettTestResults wave in the current data folder or optionally to a table. 
StatsDunnettTest usually follows StatsANOVA1Test.
Flags
Details
StatsDunnettTest inputs are two or more 1D numeric waves (one wave for each group of samples). The input 
waves may contain different number of points, but they must contain two or more valid entries per wave.
For output to a table (using /T), each labelled row represents the results of the test for comparing the means of 
one group to the control group, and rows are ordered so that all comparisons are computed sequentially starting 
with the group having the smallest mean. The contents of the labeled columns are:
/ALPH = val
Sets the significance level (default val=0.05).
/CIDX=cIndex
Specifies the (zero based) index of the input wave corresponding to the control group. 
The default is zero (the first wave corresponds to the control group).
/Q
No results printed in the history area.
/SWN
Creates a text wave, T_DunnettDescriptors, containing wave names corresponding to 
each row of the comparison table (Save Wave Names). Use /T to append the text wave 
to the last column.
/T=k
/TAIL=tc 
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
First
The difference between the group means
Second
SE (which is computed for possibly unequal number of points)
Third
The q statistic for the pair which may be positive or negative
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Specifies H0.
Code combinations are not allowed.
tc=1:
One tailed test (c  a)
tc=2:
One tailed test (c  a)
tc=4:
Two tailed test (c = a) (default)
