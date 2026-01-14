# StatsANOVA2RMTest

StatsANOVA2RMTest
V-909
Details
Input to StatsANOVA2NRTest is a 2D wave in which the Factor A corresponds to rows and Factor B 
corresponds to columns. H0 provides that there is no difference in the means of the respective populations, 
i.e., if H0 is rejected for Factor A but accepted for Factor B that means that there is no difference in the means 
of the columns but the means of the rows are different.
NaN and INF entries are not supported although you may use a single NaN value in combination with the 
/FOMD flag. If srcWave contains dimension labels they will be used to designate the two factors in the 
output.
The contents of the M_ANOVA2NRResults output wave columns are as follows:
The variable V_flag is set to zero if the operation succeeds or to -1 otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA1Test and 
StatsANOVA2Test.
StatsANOVA2RMTest 
StatsANOVA2RMTest [flags] srcWave
The StatsANOVA2RMTest operation performs analysis of variance (ANOVA) on srcWave where replicates 
consist of multiple measurements on the same subject (repeated measures). srcWave is a 2D wave of any 
numeric type. Output is to the M_ANOVA2RMResults wave in the current data folder or optionally to a table.
Flags
As indicated in the table, factor B is not tested for significant interaction under Model 
3 and neither factor A nor factor B are tested for Model 1. If you are willing to accept 
an increase in Type II error you can obtain the relevant values by specifying Model 2. 
None of the models support a test for interaction A x B.
/MODL=m
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Column 0
Sum of the squares (SS) values
Column 1
Degrees of freedom (DF)
Column 2
Mean square (MS) values
Column 3
Computed F value for this test
Column 4
Critical F value (Fc) for the specified alpha
Column 5
Conclusion with 0 to reject H0 or 1 to accept it
/ALPH=val
Sets the significance level (default 0.05).
/Q
No results printed in the history area.
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
