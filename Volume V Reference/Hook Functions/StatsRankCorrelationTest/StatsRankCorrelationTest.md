# StatsRankCorrelationTest

StatsRankCorrelationTest
V-970
median of the data and the edges of the array. The Moore and McCabe method is similar to Tukey’s method 
except you do not include the median itself in computing the quartiles. Mendenhall and Sincich compute 
the quartiles using 1/4 and 3/4 of (numDataPoints+1) and round to the nearest integer (if the fraction part 
is exactly 0.5 they round up for the lower quartile and down for the upper quartile). Minitab uses the same 
expressions but instead of rounding it uses linear interpolation.
StatsQuantiles uses a stable index sorting routine so that
IndexSort W_QuantilesIndex,srcWave
is a monotonically increasing wave.
References
Tukey, J. W., Exploratory Data Analysis, 688 pp., Addison-Wesley, Reading, Massachusetts, 1977.
Mendenhall, W., and T. Sincich, Statistics for Engineering and the Sciences, 4th ed., 1008 pp., Prentice Hall, 
Englewood Cliffs, New Jersey, 1995.
See Also
Chapter III-12, Statistics for a function and operation overview; WaveStats, StatsMedian, Sort, and 
MakeIndex.
StatsRankCorrelationTest 
StatsRankCorrelationTest [flags] waveA, waveB
The StatsRankCorrelationTest operation performs Spearman’s rank correlation test on waveA and waveB, 
1D waves containing the same number of points. Output is to the W_StatsRankCorrelationTest wave in the 
current data folder.
Flags
Details
StatsRankCorrelationTest ranks waveA and waveB and then computes the sum of the squared differences of 
ranks for all rows. Ties are assigned an average rank and the corrected Spearman rank correlation 
coefficient is computed with ties. It reports the sum of the squared ranks (sumDi2), the sums of the ties 
coefficients (sumTx and sumTy respectively), the Spearman rank correlation coefficient (in the range [-1,1]), 
and the critical value. H0 corresponds to zero correlation against the alternative of nonzero correlation. The 
critical value is usually lower than the one in published tables. When the first derivative of the CDF is 
discontinuous, tables tend to use a more conservative value by choosing the next transition of the CDF as 
the critical value. StatsRankCorrelationTest is not as powerful as StatsLinearCorrelationTest.
See Also
Chapter III-12, Statistics for a function and operation overview.
/ALPH = val
Sets the significance level (default val=0.05).
/P=method
/Q
No results printed in the history area.
/T=k
/Z
Ignores errors.
Controls the computation of the P-value.
The /P flag was added in Igor Pro 9.00.
method=0:
If the number of data points is less than or equal to 6 then an exact 
calculation is made. This is the default if /P is omitted.
method=1:
The P-value is computed using the Edgeworth approximation. 
The P-value reported corresponds to a two tails calculation.
method=2:
The P-value is computed using the Student-T approximation. 
This is appropriate when the number of data points is large.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
