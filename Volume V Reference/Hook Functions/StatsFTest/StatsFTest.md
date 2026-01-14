# StatsFTest

StatsFriedmanTest
V-931
StatsFriedmanTest 
StatsFriedmanTest [flags] [wave1, wave2,… wave100]
The StatsFriedmanTest operation performs Friedman’s test on a randomized block of data. It is a 
nonparametric analysis of data contained in either individual 1D waves or in a single 2D wave. Output is 
to the M_FriedmanTestResults wave in the current data folder or optionally to a table.
Flags
Details
The Friedman test ranks the input data on a row-by-row basis, sums the ranks for each column, and 
computes the Friedman statistic, which is proportional to the sum of the squares of the ranks.
Input waves can be a single 2D wave or a list of 1D numeric waves, which can also be specified in a string list 
with /WSTR. All 1D waves must have the same number of points. A 2D wave must not contain any NaNs.
The critical value for the Friedman distribution is fairly difficult to compute when the number of rows and 
columns is large because it requires a number of permutations on the order of (numColumns!)^numRows. A 
certain range of these critical values are supported by precomputed tables. When the exact critical value is not 
available you can use one of the two approximations that are always computed: the Chi-squared approximation 
or the Iman and Davenport approximation, which converts the Friedman statistic is converted to a new value Ff 
then compares it with critical values from the F distribution using weighted degrees of freedom.
With the /T flag, it displays the results in a table that contains the number of rows, the number of columns, 
the Friedman statistic, the exact critical value (if available), the Chi-squared approximation, the Iman and 
Davenport approximation, and the conclusion (1 to accept H0 and 0 to reject it).
V_flag will be set to -1 for any error and to zero otherwise.
References
Iman, R.L., and J.M. Davenport, Approximations of the critical region of the Friedman statistic, Comm. 
Statist. A9, 571-595, 1980.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFriedmanCDF and 
StatsInvFriedmanCDF.
StatsFTest 
StatsFTest [flags] wave1, wave2
The StatsFTest operation performs the F-test on the two distributions in wave1 and wave2, which can be any 
real numeric type, must contain at least two data points each, and can have an arbitrary number of 
dimensions. Output is to the W_StatsFTest wave in the current data folder or optionally to a table.
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/RW
Saves the ranking wave M_FriedmanRanks, which contains the rank values 
corresponding to each input datum.
/T=k
The table is associated with the test and not with the data. If you repeat the test, it will 
update the table with the new results.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
