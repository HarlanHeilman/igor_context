# Hazard and Survival Functions

Chapter III-12 — Statistics
III-392
General Purpose Statistics Operations and Functions
This group includes operations and functions that existed before IGOR Pro 6.0 and some general purpose 
operations and functions that do not belong to the main groups listed.
Hazard and Survival Functions
Igor does not provide built-in functions to calculate the Survival or Hazard functions. They can be calcu-
lated easily from the Probability Distribution Functions on page III-391 and Cumulative Distribution 
Functions on page III-390.
In the following, the cumulative distribution functions are denoted by F(x) and the probability distribution 
functions are denoted by p(x).
The Survival Function S(x) is given by
The Hazard function h(x) is given by
The cumulative hazard function H(x) is
Inverse Survival Function Z(a) is
where G() is the inverse CDF (see Inverse Cumulative Distribution Functions on page III-391).
StatsInvFriedmanCDF
StatsInvPoissonCDF
StatsInvWeibullCDF
StatsInvGammaCDF
StatsInvPowerCDF
StatsInvGeometricCDF
StatsInvQCDF
binomial
Sort
StatsTrimmedMean
binomialln
StatsCircularMoments
StudentA
erf
StatsCorrelation
StudentT
erfc
StatsMedian
WaveStats
inverseErf
StatsQuantiles
StatsPermute
inverseErfc
StatsResample
S(x) = 1−F(x).
h(x) = p(x)
S(x) =
p(x)
1−F(x).
H(x) =
h(u)du
−∞
x∫
,
H(x) = −ln 1−F(x)
[
].
Z(α) = G(1−α),
