# StatsANOVA2Test

StatsANOVA2Test
V-910
Details
Input to StatsANOVA2RMTest is the 2D srcWave in which the factor A (Groups) are columns and the 
different subjects are rows. It does not support NaNs or INFs.
The contents of the M_ANOVA2RMResults output wave columns are: the first contains the sum of the 
squares (SS) values, the second contains the degrees of freedom (DF), the third contains the mean square 
(MS) values, the fourth contains the single F value for this test, the fifth contains the critical F value for the 
specified alpha and degrees of freedom, and the last column contains the conclusion with 0 to reject H0 or 
1 to accept it. In each case H0 corresponds to the mean level, which is the same for all subjects.
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA2NRTest and 
StatsANOVA2Test.
StatsANOVA2Test 
StatsANOVA2Test [flags] srcWave
The StatsANOVA2Test operation performs a two-factor analysis of variance (ANOVA) on srcWave. Output 
is to the M_ANOVA2Results wave in the current data folder or optionally to a table.
Flags
Details
Input to StatsANOVA2Test is the single or double precision 3D srcWave in which the factor A levels are 
columns, the factor B levels are rows, and the replicates are layers. If srcWave contains dimension labels they 
will be used to designate the factors in the output.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
/ALPH=val
Sets the significance level (default 0.05).
/FAKE=num
Specifies the number of points in srcWave obtained by “estimation”. num is subtracted 
from the total and error degrees of freedom.
/MODL=m
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Sets the model number.
m=1:
Factor A and factor B are fixed.
m=2:
Both factors are random.
m=3:
Factor A is fixed and factor B is random (default).
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
