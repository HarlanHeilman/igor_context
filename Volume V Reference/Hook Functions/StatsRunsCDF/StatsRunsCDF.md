# StatsRunsCDF

StatsSample
V-974
If you use /SQ the operation sets V_Median, V_Q25, V_Q75, V_IQR, V_min, and V_max.
If you use /WS the operation sets V_min, V_max, V_numNaNs, V_numINFs, V_avg, V_sdev, V_rms, 
V_adev, V_skew, V_kurt, and V_Sum.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsSample, WaveStats and 
StatsQuantiles.
StatsSample
StatsSample /N=numPoints [flags] srcWave
StatsSample creates a random, non-repeating sample from srcWave.
It samples srcWave by drawing without replacement numPoints values from srcWave and storing them in 
the output wave W_Sampled or M_Sampled if /MC or /MR are used.
The /N flag is required.
Flags
Details
If you omit /MC and /MR, the output is a 1D wave named W_Sampled where the samples are chosen from 
srcWave without regard to its dimensionality.
If you use either /MC or /MR the output is a 2D wave named M_Sampled which will have either the same 
number of columns (/MC) as srcWave or the same number of rows (/MR) as srcWave. 
See Also
Chapter III-12, Statistics, StatsResample
StatsRunsCDF 
StatsRunsCDF(n, r)
The StatsRunsCDF function returns the cumulative distribution function for the up and down runs 
distribution for total number of runs r in a random linear arrangement of n unequal elements. There is no 
closed form expression. It is computed numerically from the recursion of the probability density
/ACMB
Creates a wave containing all unique combinations of numPoints values from 
srcWave. It is assumed that srcWave is a 1D numeric wave containing more than 
numPoints elements. The results are stored in the wave M_Combinations in the 
current data folder. Each row in the result wave corresponds to a unique combination 
of samples.
Added in Igor Pro 7.00.
/CMPL
Stores all data elements from srcWave that were excluded from the random sample 
in the wave W_CompWave or M_CompWave in the current data folder. /CMPL was 
added in Igor Pro 8.00.
/N=numPoints
Specifies the number of points sampled from srcWave. When combined with /MC, 
numPoints is the number of sampled rows and when combined with /MR, it is the 
number of sampled columns.
/MC
Use /MC (multi-column) to randomly sample full rows from srcWave, i.e., the output 
consists of all columns of each selected row. /MC and /MR are mutually exclusive 
flags.
/MR
Use /MR (multi-row) to randomly sample full columns from srcWave, i.e., the output 
consists of all rows of each of the selected columns. /MC and /MR are mutually 
exclusive flags.
/Z
Ignores errors.
