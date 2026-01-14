# StatsContingencyTable

StatsContingencyTable
V-924
StatsContingencyTable 
StatsContingencyTable [flags] srcWave
The StatsContingencyTable operation performs contingency table analysis on 2D and 3D tables. Output is to 
the W_ContingencyTableResults wave in the current data folder or optionally to a table or the history area.
Flags
Details
StatsContingencyTable supports 2D waves representing single contingency tables or 3D waves 
representing multiple 2D tables (where each table is a layer) or a single 3D table. Each entry in the wave 
must contain a frequency value and must be a positive number; it does not support 0’s, NaNs, or INFs. In 
the special case of 2x2 tables, use the /COR flag to compute the statistic using either the Yates or Haber 
corrections. Except for the heterogeneity option you can also compute the log likelihood statistic. In all the 
tests, H0 corresponds to independence between the tested variables.
For 3D tables StatsContingencyTable provides Chi-squared, degrees of freedom, the critical value, and 
optionally the log likelihood G statistic (/LLIK flag) for each of the following cases:
/ALPH = val
Sets the significance level (default val=0.05).
/COR=mode
Sets the correction type for 2x2 tables. By default there is no correction. Use mode=1 for 
Yates and mode=2 for Haber correction.
/FEXT={row, col}
Computes Fisher’s Exact P-value with 2x2 contingency tables. row and col are zero-
based indices of the table entry where it computes the probability of getting the 
results in the table or more extreme values. Without the /Q flag, it prints the 
probabilities of each individual table in the history.
Example 1: When you use /FEXT={0,0} the P-value represents the sum of the 
probabilities of the first group having in the Succeeded column 11 or more extreme 
values, i.e., 12, 13, 14, and 15. In each case the remaining table elements are adjusted 
so that row and column sums remain constant. 
Example 2: When you needed to evaluate the sum of the probabilities of Group2 
having 4 counts or less in the Succeeded column, then the appropriate flag is 
/FEXT={1,1}, which effectively computes the equivalent of having 9, 10, 11, 12, and 
13 Failed counts. In each case it computes the upper, the lower, and the two-tail 
probabilities.
/HTRG
Tests for heterogeneity between tables stored as layers of 3D wave.
/LLIK
Computes log likelihood statistic.
/Q
No results printed in the history area.
/T=k
The table is associated with the test and not with the data. If you repeat the test, it will 
update the table with the new results unless you moved the output wave to a different 
data folder. If the named table exists but it does not display the output wave from the 
current data folder, the table is renamed and a new table is created.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Given the contingency table:
Succeeded
Failed
Group1
11
8
Group2
4
9
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
