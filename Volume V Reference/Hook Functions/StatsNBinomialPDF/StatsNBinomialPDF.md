# StatsNBinomialPDF

StatsNBinomialCDF
V-959
where zi is the Fisher’s z transform of the correlation coefficients and ni is the corresponding sample size. It 
computes the common correlation coefficient rw and its transform zw.
These values are calculated even when not appropriate, such as when 2 exceeds the critical value and H0 
(all samples came from populations of identical correlation coefficients) is rejected.
The operation also computes ChiSquaredP (due to S.R. Paul), a different variant of 2 that is corrected for 
bias and should be compared with the same critical value. Output is to the W_StatsMultiCorrelationTest 
wave in the current data folder or optionally to a table.
References
See, in particular, Chapters 19 and 11 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsLinearCorrelationTest, StatsCircularCorrelationTest, StatsDunnettTest, StatsTukeyTest, 
StatsInvQCDF, and StatsScheffeTest.
StatsNBinomialCDF 
StatsNBinomialCDF(x, k, p)
The StatsNBinomialCDF function returns the negative binomial cumulative distribution function
where betai is the regularized incomplete beta function.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNBinomialPDF and 
StatsInvNBinomialCDF functions.
StatsNBinomialPDF 
StatsNBinomialPDF(x, k, p)
The StatsNBinomialPDF function returns the negative binomial probability distribution function
where 
 is the binomial function.
The binomial distribution expresses the probability of the kth success in the x+k trial for two mutually 
exclusive results (success and failure) and p the probability of success in a single trial.
 2 =
zi
2 ni  3
(
)
i=0
n1


zi ni  3
(
)
i=0
n1




 
2
ni  3
(
)
i=0
n1

,
zw =
zi ni  3
(
)
i=0
n1

ni  3
(
)
i=0
n1

F(x;k, p) = Betai(k,x +1; p),
f (x;k, p) =
x + k 1
k 1



 pk(1 p)x,
x = 0,1,2...
a
b


