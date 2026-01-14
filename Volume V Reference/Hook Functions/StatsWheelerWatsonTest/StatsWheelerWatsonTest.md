# StatsWheelerWatsonTest

StatsWeibullCDF
V-990
References
See, in particular, Section 6.3 of:
Mardia, K.V., Statistics of Directional Data, Academic Press, New York, New York, 1972.
See, in particular, Chapter 27 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsWatsonUSquaredTest and 
StatsWheelerWatsonTest.
StatsWeibullCDF 
StatsWeibullCDF(x, m, s, g)
The StatsWeibullCDF function returns the Weibull cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWeibullPDF and 
StatsInvWeibullCDF functions.
StatsWeibullPDF 
StatsWeibullPDF(x, m, s, g)
The StatsWeibullPDF function returns the Weibull probability distribution function
where m is the location parameter, s is the scale parameter, and g is the shape parameter with x m and s, 
g > 0.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWeibullCDF and 
StatsInvWeibullCDF functions.
StatsWheelerWatsonTest 
StatsWheelerWatsonTest [flags] [srcWave1, srcWave2, srcWave3,…]
The StatsWheelerWatsonTest operation performs the nonparametric Wheeler-Watson test for two or more 
samples. Output is to the W_WheelerWatson wave in the current data folder or optionally to a table.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
Displays results in a table. k specifies the table behavior when it is closed.
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
F(x;μ,, ) = 1 exp  x  μ






 





,
x  μand, > 0.
f (x;μ,, ) = 

x  μ



-
./
 1
exp  x  μ



-
./



 



,
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
