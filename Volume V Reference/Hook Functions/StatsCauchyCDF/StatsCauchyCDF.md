# StatsCauchyCDF

StatsBinomialCDF
V-912
The defaults (a=0 and b=1) correspond to the standard beta distribution were a is the location parameter, (b-
a) is the scale parameter, and p and q are shape parameters. When p<1, f(x=a) returns Inf.
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBetaCDF and StatsInvBetaCDF.
StatsBinomialCDF 
StatsBinomialCDF(x, p, N)
The StatsBinomialCDF function returns the binomial cumulative distribution function
where
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBinomialCDF and 
StatsBinomialPDF.
StatsBinomialPDF 
StatsBinomialPDF(x, p, N)
The StatsBinomialPDF function returns the binomial probability distribution function
where
is the probability of obtaining x good outcomes in N trials where the probability of a single successful 
outcome is p.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBinomialCDF and 
StatsInvBinomialCDF.
StatsCauchyCDF 
StatsCauchyCDF(x, )
The StatsCauchyCDF function returns the Cauchy-Lorentz cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCauchyCDF and StatsCauchyPDF.
F(x; p,N) =
N
i



 
i=1
x

pi(1 p)N i,
x = 1,2,...
N
i



 =
N!
i!(N  i)!.
f (x; p,N) =
N
x



 px(1 p)N  x,
x = 0,1,2,...
N
x



 =
N!
x!(N  x)!.
F(x;μ,) = 1
2 + 1
 tan1
x  μ




 
 .
