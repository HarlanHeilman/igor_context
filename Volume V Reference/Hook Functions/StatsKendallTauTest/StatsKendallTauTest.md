# StatsKendallTauTest

StatsKendallTauTest
V-947
Details
StatsKDE estimates the PDF of a distribution of values using a smoothing kernel and a bandwidth 
parameter which affects the degree of smoothing.
Theory suggests that the Epanechnikov kernel is the most efficient but many expressions for the optimal 
bandwidth are derived for the Gaussian kernel. If srcWave contains N points and the requested output (/S 
flag) has M points then the computational complexity is O(NM). For large problems it may be beneficial to 
use the Gaussian kernel via the FastGaussTransform operation.
References
Wand M.P. and Jones M.C. (1995) Monographs on Statistics and Applied Probability, London: Chapman 
and Hall
Bowman, A.W., and Azzalini, A. (1997), Applied Smoothing Techniques for Data Analysis, London: Oxford 
University Press.
See Also
Statistics on page III-383, Histogram, FastGaussTransform
StatsKendallTauTest 
StatsKendallTauTest [flags] wave1 [, wave2]
The StatsKendallTauTest operation performs the nonparametric Mann-Kendall test, which computes a 
correlation coefficient  (similar to Spearman’s correlation) from the relative order of the ranks of the data. 
Output is to the W_StatsKendallTauTest wave in the current data folder.
Flags
Details
Inputs may be a pair of XY (1D) waves of any real numeric type or a single 1D wave, which is equivalent to 
using a pair of XY waves where the X wave is monotonically increasing function of the point number. 
StatsKendallTauTest ignores wave scaling.
Kendall’s  is 1 for a monotonically increasing input and -1 for monotonically decreasing input. The 
significance of the test is computed from the normal approximation
where n is the number of data points in each wave. The significance is expressed as a P-value for the null 
hypothesis of no correlation.
References
Kendall, M.G., Rank Correlation Methods, 3rd ed., Griffin, London, 1962.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsRankCorrelationTest.
For small values of n you can compute the exact probability using the procedure 
WM_KendallSProbability().
/Z
Ignores errors. V_flag is set to zero if there are no errors.
/Q
No results printed in the history area.
/T=k
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
Var() = 4n +10
9n(n 1),
