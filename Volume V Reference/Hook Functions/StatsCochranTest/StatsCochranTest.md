# StatsCochranTest

StatsCochranTest
V-923
where 2F1 is the hypergeometric function hyperG2F1.
References
Young, L.C., On randomness in ordered sequences, Annals of Mathematical Statistics, 12, 153-162, 1941.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCMSSDCDF and StatsSRTest.
StatsCochranTest 
StatsCochranTest [flags] [wave1, wave2,… wave100]
The StatsCochranTest operation performs Cochran’s (Q) test on a randomized block or repeated measures 
dichotomous data. Output is to the M_CochranTestResults wave in the current data folder or optionally to 
a table.
Flags
Details
StatsCochranTest computes Cochran's statistic and compares it to a critical value from a Chi-squared 
distribution, which depends only of the significance level and the number of groups (columns). The null 
hypothesis for the test is that all columns represent the same proportion of the effect represented by a non-
zero data. 
The Chi-square distribution is appropriate when there are at least 4 columns and at least 24 total data 
points.
Dichotomous data are presumed to consist of two values 0 and 1, thus StatsCochranTest distinguishes only 
between zero and any nonzero value, which is considered to be 1; it does not allow NaNs or INFs. Input 
waves can be a single 2D wave or a list of 1D numeric waves, which can also be specified in a string list with 
/WSTR. In the standard terminology, data rows represent blocks and data columns represent groups. H0 
corresponds to the assumption that all groups have the same proportion of 1’s.
With the /T flag, it displays the results in a table that contains the number of rows, the number of columns, 
the Cochran statistic, the critical value, and the conclusion (1 to accept H0 and 0 to reject it).
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFriedmanTest.
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
The table is associated with the test and not with the data. If you repeat the test, it will 
update the table with the new results unless you moved the output wave to a different 
data folder. If the named table exists but it does not display the output wave from the 
current data folder, the table is renamed and a new table is created.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
F(C,n) =
(2m + 2)
a22m+1 (m +1)
[
]
2 C 2F1
1
2 ,m, 3
2 , C 2
a2



 ,
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
