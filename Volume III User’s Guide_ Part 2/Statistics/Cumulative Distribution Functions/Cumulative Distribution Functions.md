# Cumulative Distribution Functions

Chapter III-12 — Statistics
III-390
Noise Functions
The following functions return numbers from a pseudo-random distribution of the specified shapes and 
parameters. Except for enoise and gnoise where you have an option to select a random number generator, 
the remaining noise functions use a Mersenne Twister algorithm for the initial uniform pseudo-random dis-
tribution. Note that whenever you need repeatable results you should use SetRandomSeed prior to execut-
ing any of the noise functions.
The following noise generation functions are available:
Cumulative Distribution Functions
A cumulative distribution function (CDF) is the integral of its respective probability distribution function 
(PDF). CDFs are usually well behaved functions with values in the range [0,1]. CDFs are important in com-
puting critical values, P values and power of statistical tests.
Many CDFs are computed directly from closed form expressions. Others can be difficult to compute 
because they involve evaluating a very large number of states, e.g., Friedman or USquared distributions. In 
these cases you have the following options:
1. Use a built-in table that consists of exact, precomputed values.
2. Compute an approximate CDF based on the prevailing approximation method or using a Monte-
Carlo approach.
3. Compute the exact CDF.
Built-in tables are ideal if they cover the range of the parameters that you need. Monte-Carlo methods can 
be tricky in the sense that repeated application may return small variations in values. Computing the exact 
CDF may be desirable, but it is often impractical. In most situations the range of parameters that is practical 
to compute on a desktop machine is already covered in the built-in tables. Larger parameters have not been 
considered because they take days to compute or because they require 64 bit processors. In addition, most 
of the approximations tend to improve with increasing size of the parameters. 
The functions to calculate values from CDFs are as follows:
binomialNoise
logNormalNoise
enoise
lorentzianNoise
expNoise
poissonNoise
gammaNoise
StatsPowerNoise
gnoise
StatsVonMisesNoise
hyperGNoise
wnoise
StatsBetaCDF
StatsHyperGCDF
StatsQCDF
StatsBinomialCDF
StatsKuiperCDF
StatsRayleighCDF
StatsCauchyCDF
StatsLogisticCDF
StatsRectangularCDF
StatsChiCDF
StatsLogNormalCDF
StatsRunsCDF
StatsCMSSDCDF
StatsMaxwellCDF
StatsSpearmanRhoCDF
StatsDExpCDF
StatsInvMooreCDF
StatsStudentCDF
StatsErlangCDF
StatsNBinomialCDF
StatsTopDownCDF
StatsEValueCDF
StatsNCFCDF
StatsTriangularCDF
StatsExpCDF
StatsNCTCDF
StatsUSquaredCDF
