# StatsBetaPDF

StatsBetaCDF
V-911
Ideally, the number of replicates must be equal for each factor and each level. StatsANOVA2Test supports 
both equal replication and proportional replication. Proportional replication allows for different number of 
data in each cell with missing data represented as NaN and the number of points in each cell is given by
Nij=(sum of data in row i)*(sum of data in column j)/number of samples.
If you have no replicates (a single datum per cell) use StatsANOVA2NRTest instead. If the number of 
replicates in your data does not satisfy these conditions you may be able to “estimate” additional replicates 
using various methods. In that case use the /FAKE flag so that the operation can account for the estimated 
data by reducing the total and error degrees of freedom. /FAKE only accounts for the number of estimates 
being used. You must provide an appropriate number of estimated values.
The contents of the M_ANOVA2Results output wave columns are: the first contains the sum of the squares 
(SS) values, the second the degrees of freedom (DF), the third contains the mean square (MS) values, the 
fourth contains the computed F value for this test, the fifth contains the critical Fc value for the specified 
alpha and degrees of freedom, and the last contains the conclusion with 0 to reject H0 or 1 to accept it. In 
each case H0 corresponds to the mean level, which is the same for all populations.
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsANOVA1Test and 
StatsANOVA2NRTest.
StatsBetaCDF 
StatsBetaCDF(x, p, q [, a, b])
The StatsBetaCDF function returns the beta cumulative distribution function
where B(p,q) is the beta function
The defaults (a=0 and b=1) correspond to the standard beta distribution were a is the location parameter, (b-
a) is the scale parameter, and p and q are shape parameters.
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsBetaPDF and StatsInvBetaCDF.
StatsBetaPDF 
StatsBetaPDF(x, p, q [, a, b])
The StatsBetaPDF function returns the beta probability distribution function
where B(p,q) is the beta function
F(x,p,q,a,b)=
1
B(p,q)
t p1(1 t)q1 dt
0
xa
ba

,
p,q > 0
a x b
B(p,q) =
t p1(1 t)q1 dt.
0
1
f (x; p,q,a,b) = x  a
(
)
p1 b  x
(
)
q1
B p,q
(
) b  a
(
)
p+q1 ,a x b
p,q > 0
B(p,q) =
t p1(1 t)q1dt
0
1
.
