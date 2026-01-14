# StatsKDE

StatsKDE
V-946
The Jarque-Bera statistic is asymptotically distributed as a Chi-squared with two degrees of freedom. For 
values of n in the range [7,2000] the operation provides critical values obtained from Monte-Carlo 
simulations. For further details or if you would like to run your own simulation to obtain critical values for 
other values of n, use the JarqueBeraSimulation example experiment.
StatsJBTest reports the number of finite data points, skewness, kurtosis, Jarque-Bera statistic, asymptotic critical 
value, and the critical value obtained from Monte-Carlo calculations as appropriate; it ignores NaNs and INFs.
References
Jarque, C., and A. Bera, A test of normality of observations and regression residuals, International Statistical 
Review, 55, 163-172, 1987.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsKSTest, WaveStats, and 
StatsCircularMoments.
StatsKDE
StatsKDE [flags] srcWave
StatsKDE can be used to estimate a PDF from original data distribution. Unlike histograms, this method 
produces a smooth result as it constructs the PDF from a normalized superposition of kernel functions.
The StatsKDE operation was added in Igor Pro 7.00.
Flags
/BWM=m
/DEST=destWave
Specifies the output destination. Creates a real wave reference for the destination 
wave in a user function. See Automatic Creation of WAVE References on page IV-72 
for details.
/FREE
Makes the destination wave (specified by /DEST) a free wave.
/H=bw
Specifies a fixed user-defined bandwidth.
/KT=kernel
/Q
No results printed in the history area. In the case of univariate KDE this flags 
suppresses the printing of the bandwidth value.
/S={x0,dx,xn}
Specifies the range of the output starting from x=x0 to x=xn in increments of dx.
K =
μ4
μ2
(
)
2  3.
Sets the bandwidth selection method.
m=0:
User-specified via /H flag
m=1:
Silverman
m=2:
Scott
m=3:
Bowmann and Azzalini
Specifies the kernel type.
kernel=1:
Epanechnikov
kernel=2:
Bi-weight
kernel=3:
Tri-weight
kernel=4:
Triangular
kernel=5:
Gaussian
kernel=6:
Rectangular
