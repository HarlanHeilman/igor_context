# StatsWatsonUSquaredTest

StatsWaldCDF
V-988
where I0(b) is the modified Bessel function of the first kind bessI, and
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsVonMisesCDF, 
StatsInvVonMisesCDF, and StatsVonMisesNoise functions.
StatsWaldCDF 
StatsWaldCDF(x, m, l)
The StatsWaldCDF function returns the numerically evaluated inverse Gaussian or Wald cumulative 
distribution function.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWaldPDF function.
StatsWaldPDF 
StatsWaldPDF(x, m, l)
The StatsWaldPDF function returns the inverse Gaussian or Wald probability distribution function
where x, m, l> 0.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsWaldCDF function.
StatsWatsonUSquaredTest 
StatsWatsonUSquaredTest [flags] srcWave1, srcWave2
The StatsWatsonUSquaredTest operation performs Watson’s nonparametric two-sample U2 test for samples 
of circular data. Output is to the W_WatsonUtest wave in the current data folder or optionally to a table.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/T=k
The table is associated with the test, not the data. If you repeat the test, it will update 
any existing table with the new results.
/Z
Ignores errors.
0 <  
 2
0 < a 
 2
b > 0.
f (x;μ,) =

2x3 exp   x  μ
(
)
2
2μ2x





 

Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
