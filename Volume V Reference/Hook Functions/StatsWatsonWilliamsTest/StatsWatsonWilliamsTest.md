# StatsWatsonWilliamsTest

StatsWatsonWilliamsTest
V-989
Details
The input waves, srcWave1 and srcWave2, each must contain at least two angles in radians (mod 2), can have 
any number of dimensions, and can be single or double precision. They must not contain any NaNs or INFs.
The Watson U2 H0 postulates that the two samples came from the same population against the different 
populations alternative. In the calculation, StatsWatsonUSquaredTest ranks the two inputs, accounts for 
possible ties, computes the test statistic U2, and compares it with the critical value. Because of the difficulty 
of computing the critical values, it always computes first the approximation due to Tiku and if possible it 
computes the exact critical value using the method outlined by Burr. You can evaluate the U2 CDF to get 
more information about the critical region.
V_flag will be set to -1 for any error and to zero otherwise.
References
We have found that this method leads to slightly different results depending on the compiler and the 
system on which it is implemented:
Burr, E.J., Small sample distributions of the two sample Cramer-von Mises’ W2 and Watson’s U2, Ann. Mah. 
Stat. Assoc., 64, 1091-1098, 1964.
Tiku, M.L., Chi-square approximations for the distributions of goodness-of-fit statistics, Biometrica, 52, 630-
633, 1965.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsWatsonWilliamsTest, 
StatsWheelerWatsonTest, StatsUSquaredCDF, and StatsInvUSquaredCDF.
StatsWatsonWilliamsTest 
StatsWatsonWilliamsTest [flags] [srcWave1, srcWave2, srcWave3,…]
The StatsWatsonWilliamsTest operation performs the Watson-Williams test for two or more sample means. 
Output is to the W_WatsonWilliams wave in the current data folder or optionally to a table.
Flags
Details
The StatsWatsonWilliamsTest must have at least two input waves, which contain angles in radians, can be 
single or double precision, and can be of any dimensionality; the waves must not contain any NaNs or INFs.
The Watson-Williams H0 postulates the equality of the means from all samples against the simple 
inequality alternative. The test computes the sums of the sines and cosines from which it obtains a weighted 
r value (rw). According to Mardia, you should use different statistics depending on the size of rw: for 
rw>0.95 use the simple F statistic, but for 0.95>rw>0.7 you should use the F-statistic with the K correction 
factor. Otherwise you should use the t-statistic. StatsWatsonWilliamsTest computes both the (corrected) F-
statistic and the t-statistic as well as their corresponding critical values.
 V_flag will be set to -1 for any error and to zero otherwise.
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
