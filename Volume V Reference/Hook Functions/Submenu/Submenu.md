# Submenu

StudentA
V-1006
NewDataFolder/O/S mypack
Variable/G nvalSav= nval
String/G svalSav= sval
SetDataFolder dfSav
End
StudentA 
StudentA(t, DegFree)
The StudentA function returns the area from -t to t under the Student’s T distribution having DegFree degrees 
of freedom. That is, it returns the probability that a random sample from Student’s T is between -t and t.
Note that this is the bi-tail result. That is, it gives the area from -t to t, rather than the cumulative area from 
- to t. It is this latter number that is commonly tabulated- StudentA returns the probability 1- where the 
area from - to t is the probability 1-/2.
StudentA tests whether a normally-distributed statistic is significantly different from a certain value. You 
could use it to test whether an intercept from a line fit is significantly different from zero:
Make/O/N=20 Data=0.5*x+2+gnoise(1)
// line with Gaussian noise
Display Data
CurveFit line Data /D
Print "Prob = ", StudentA(W_coef[0]/W_sigma[0], V_npnts-2)
Because the noise is random, the results will differ slightly each time this is tried. When we did it, the result was:
Prob = 0.999898
which indicates that the intercept of the line fit was different from zero with 99.99 per cent probability.
See Also
StatsStudentCDF, StatsStudentPDF, StatsInvStudentCDF
StudentT 
StudentT(Prob, DegFree)
The StudentT function returns the t value corresponding to an area Prob under the Student’s T distribution 
from -t to t for DegFree degrees of freedom.
Note that this is a bi-tail result, which is what is usually desired. Tabulated values of the Student’s T 
distribution are commonly the one-sided result.
StudentT calculates confidence intervals from standard deviations for normally-distributed statistics. For 
instance, you can use it to calculate a confidence interval for the coefficients from a curve fit:
Make/O/N=20 Data=0.5*x+2+gnoise(1)
// line with Gaussian noise
Display Data
CurveFit line Data /D
print "intercept = ", W_coef[0], "±", W_sigma[0]*StudentT(0.95, V_npnts-2)
print "slope = ", W_coef[1], "±", W_sigma[1]*StudentT(0.95, V_npnts-2)
See Also
StatsStudentCDF, StatsStudentPDF, StatsInvStudentCDF
Submenu 
Submenu menuNameStr
The Submenu keyword introduces a submenu definition. It is used inside a Menu definition. See Chapter 
IV-5, User-Defined Menus for further information.
Note:
This function is deprecated. New code should use the more accurate StatsStudentCDF.
Note:
This function is deprecated. New code should use the more accurate 
StatsInvStudentCDF.
