# StatsTukeyTest

StatsTukeyTest
V-983
Tc is the critical value and  is the effective number of degrees of freedom (see /DFM flag).When accounting 
for possibly unequal variances,  is given by
The critical values (Tc) are computed by numerically by solving for the argument at which the cumulative 
distribution function (CDF) equals the appropriate values for the tests. The CDF is given by
To get the critical value for the upper one-tail test we solve F(x)=1-alpha. For the lower one-tail test we solve 
for x the equation F(x)=alpha. In the two-tailed test the lower critical value is a solution for F(x)=alpha/2 and 
the upper critical value is a solution for F(x)=1-alpha/2.
The T-test assumes both samples are randomly taken from normal population distributions.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsStudentCDF, StatsStudentPDF, and 
StatsInvStudentCDF.
References
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999. See in 
particular Section 8.1.
StatsTukeyTest 
StatsTukeyTest [flags] [wave1, wave2,… wave100]
The StatsTukeyTest operation performs multiple comparison Tukey (HSD) test and optionally the 
Newman-Keuls test. Output is to the M_TukeyTestResults wave in the current data folder. StatsTukeyTest 
usually follows StatsANOVA1Test.
Flags
H0 
Rejection Condition
1 = 2
|t|  Tc(alpha,)
1 > 2
 t  Tc(alpha, )
1 < 2
 t  Tc(alpha, )
/ALPH = val
Sets the significance level (default val=0.05).
/NK
Computes the Newman-Keuls test.
/Q
No results printed in the history area.
/SWN
Creates a text wave, T_TukeyDescriptors, containing wave names corresponding to 
each row of the comparison table (Save Wave Names). Use /T to append the text wave 
to the last column.
 =
s1
2
n1
+ s2
2
n2



 
2
s1
2
n1



 
2
n1 1 +
s2
2
n2



 
2
n2 1
.
F(x) =
1
2 betai 
2 , 1
2 ,

 + x2




x < 0
1 1
2 betai 
2 , 1
2 ,

 + x2




x  0.




