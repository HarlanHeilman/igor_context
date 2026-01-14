# StatsANOVA2NRTest

StatsANOVA2NRTest
V-908
Details
Inputs to StatsANOVA1Test are two or more 1D numerical waves containing (one wave for each group of 
samples). Use NaN for missing entries or use waves with different numbers of points. The standard 
ANOVA results are in the M_ANOVA1 wave with corresponding row and column labels. Use /T to display 
the results in a table. In each case you will get the two degrees of freedom values, the F value, the critical 
value Fc for the choice of alpha and the degrees of freedom, and the P-value for the result. V_flag will be 
set to -1 for any error and to zero otherwise.
In some cases the ANOVA test may not be appropriate. For example, if groups do not exhibit sufficient 
homogeneity of variances. Although this may not be fatal for the ANOVA test, you may get more insight 
by performing the variances test in StatsVariancesTest.
If there are only two groups this test should be equivalent to StatsTTest. 
You can evaluate the power of an ANOVA test for a given set of degrees of freedom and noncentrality 
parameter using:
power=1-StatsNCFCDF(StatsInvFCDF((1-alpha),n1,n2),n1,n2,delta)
Here n1 is the Groups’ degrees of freedom, n2 is the Error degrees of freedom, and delta is the noncentrality 
parameter. For more information see ANOVA Power Calculations Panel and the associated example experiment.
References
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsVariancesTest, StatsTTest, 
StatsNCFCDF, and StatsInvFCDF.
StatsANOVA2NRTest 
StatsANOVA2NRTest [flags] srcWave
The StatsANOVA2NRTest operation performs a two-factor analysis of variance (ANOVA) on the data that 
has no replication where there is only a single datum for every factor level. srcWave is a 2D wave of any 
numeric type. Output is to the M_ANOVA2NRResults wave in the current data folder or optionally to a table.
Flags
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
/ALPH=val
Sets the significance level (default 0.05).
/FOMD
Estimates one missing value. You will also have to use a single or double precision 
wave for srcWave and designate the single missing value as NaN. The estimated value 
is printed to the history as well as the bias used to correct the sum of the squares of 
factor A.
/INT=val
Sets the degree of interactivity.
Sets the degree of interactivity.
val=0:
No interaction between the factors (default).
val=1:
Significant interaction effect between factors.
Combination with /MODL determines which factors to test:
val
Model 1
Model 2
Model 3
1
A&B
A
0
A&B
A&B
A&B
