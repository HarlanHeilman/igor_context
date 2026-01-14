# StatsCircularTwoSampleTest

StatsCircularTwoSampleTest
V-921
where
and
References
Fisher, N.I., Statistical Analysis of Circular Data, 295pp., Cambridge University Press, New York, 1995.
Press, William H., et al., Numerical Recipes in C, 2nd ed., 994 pp., Cambridge University Press, New York, 
1992.
Durand, D., and J.A. Greenwood, Modifications of the Rayleigh test for uniformity in analysis of two-
dimensional orientation data, J. Geol., 66, 229-238, 1958.
See Also
Chapter III-12, Statistics for a function and operation overview.
WaveStats, StatsAngularDistanceTest, StatsCircularCorrelationTest, StatsCircularMeans, 
StatsHodgesAjneTest, StatsWatsonUSquaredTest, StatsWatsonWilliamsTest, and 
StatsWheelerWatsonTest.
StatsCircularTwoSampleTest 
StatsCircularTwoSampleTest [flags] waveA, waveB
The StatsCircularTwoSampleTest operation performs second order analysis of angles. Using the appropriate 
flags you can choose between parametric or nonparametric, unordered or paired tests. The input consists of 
two waves that contain one or two columns. The first column contains angle data (mean angles) expressed in 
radians and an optional second column that contains associated vector lengths. The waves must be either 
single or double precision. Results are stored in the W_StatsCircularTwoSamples wave in the current data 
folder and optionally displayed in a table. Some of the tests may have additional outputs.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/NPR
Performs nonparametric paired-sample test (Moore). The input waves must contain 
paired angular data so both must have single column and the same number of points.
/NSOA
Perform nonparametric second order two-sample test. Input waves must each contain 
two columns.
/PPR
Performs parametric paired-sample test. Input waves must contain paired data and 
must have the same number of points.
 
skewness =
2sin
ˆμ2  2
(
)
1 R
(
)
32
kurtosis =
2 cos
ˆμ2  2
(
)  R
4
1 R
(
)
2
ˆμp =
atan Sp Cp
(
)
Sp > 0,Cp > 0
atan Sp Cp
(
) + 
Cp < 0
atan Sp Cp
(
) + 2
Sp < 0,Cp > 0






Cp = 1
n
cos p i
i=1
n

,
Sp = 1
n
sin p i
i=1
n

.
