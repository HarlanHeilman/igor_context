# StatsShapiroWilkTest

StatsShapiroWilkTest
V-976
Details
The default of StatsScheffeTest (also known as the S test) tests the hypotheses of equality of means for each 
possible pair of samples. It is not as powerful as Tukey’s test (StatsTukeyTest) and is more useful for 
hypotheses formulated as multiple contrasts (see /CONT).
References
See, in particular, Chapter 11 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA1Test, StatsDunnettTest and 
StatsTukeyTest.
StatsShapiroWilkTest
StatsShapiroWilkTest [flags] srcWave
The StatsShapiroWilkTest computes Shapiro-Wilk statistic W and its associated P-value and stores them in 
V_statistic and V_prob respectively.
Flags
Details
The Shapiro-Wilk tests the null hypothesis that the population is normally distributed. If the P-value is less 
than the selected alpha then the null hypothesis, normality, is rejected.
The test is valid only for waves containing 3 to 5000 data points. The operation ignores any NaNs or INFs 
in srcWave.
Example
// Test normally distributed data
Make/O/N=(200) ggg=gnoise(5)
StatsShapiroWilkTest ggg
W=0.995697 p=0.846139
// p>alpha so accept normality
the critical value, and a result field which is set to 1 if H0 should be accepted or 0 if it 
should be rejected. W is the total number of waves, ni and 
 are respectively the 
number of data points and the average of wave i.
/Q
No results printed in the history area.
/SWN
Creates a text wave, T_ScheffeDescriptors, containing wave names corresponding to 
each row of the comparison table (Save Wave Names). Use /T to append the text wave 
to the last column.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
/Q
No results printed in the history area. 
/Z
Ignores errors.
Xi
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
