# StatsANOVA1Test

StatsANOVA1Test
V-907
Details
The inputs for StatsAngularDistanceTest are two or more waves each corresponding to individual sample. 
The waves must be single or double precision expressing the angles in radians. There is no restriction on 
the number of points or dimensionality of the waves but the data should not contain NaNs or INFs. We 
recommend that you use double precision waves, especially if there are ties in the data. The reference 
directions should also be in radians. For two samples, StatsAngularDistanceTest computes the angular 
distances between the input data and the reference directions and then uses the Mann-Whitney-Wilcoxon 
test (StatsWilcoxonRankTest). Results are stored in the W_WilcoxonTest wave and in the corresponding 
table. For more than two samples, StatsAngularDistanceTest uses the Kruskal-Wallis test, storing results in 
the wave W_KWTestResults wave in the current data folder.
V_flag will be set to -1 for any error and to zero otherwise.
References
See, in particular, Chapter 27 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsWilcoxonRankTest and 
StatsKWTest.
Examples:Statistics:Circular Statistics:AngularDistanceTest.pxp.
StatsANOVA1Test 
StatsANOVA1Test [flags] [wave1, wave2,… wave100]
The StatsANOVA1Test operation performs a one-way ANOVA test (fixed-effect model). The standard 
ANOVA test results are stored in the M_ANOVA1 wave in the current data folder.
Flags
/TAIL=tail
See Setting Bit Parameters on page IV-12 for details about bit settings.
The P value corresponding to the last tail calculated will be entered in the table.
/WSTR=waveListString
Specifies a string containing a semicolon-separated list of waves that contain sample 
data. Use waveListString instead of listing each wave after the flags.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
/ALPH=val
Sets the significance level (default 0.05).
/BF
Performs the Brown and Forsythe test computing F'' and degrees of freedom. The 
W_ANOVA1BnF wave in the current data folder contains the output.
/Q
No results printed in the history area.
/T=k
Displays results in a table; additional tables are created with /BF and /W.
/W
Performs the Welch test F' and computes degrees of freedom. The W_ANOVA1Welch 
wave in the current data folder contains the output.
tail is a bitwise parameter that specifies the tails tested.
Bit 0:
Lower tail.
Bit 1:
Upper tail (default).
Bit 2:
Two tail.
k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
