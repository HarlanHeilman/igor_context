# StatsNormalCDF

StatsNCTCDF
V-961
where B() is the beta function and 1F1() is the hypergeometric function hyperG1F1.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsNCFCDF and StatsInvNCFCDF 
functions.
StatsNCTCDF 
StatsNCTCDF(x, df, d)
The StatsNCTCDF function returns the cumulative distribution function of the noncentral Student-T 
distribution. df is the degrees of freedom (positive integer) and d is the noncentrality measure. There is no 
closed form expression for the distribution.
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsStudentCDF, StatsStudentPDF, 
and StatsNCTPDF functions.
StatsNCTPDF 
StatsNCTPDF(x, df, d)
The StatsNCTPDF function returns the probability distribution function of the noncentral Student-T 
distribution. df is the degrees of freedom (positive integer) and d is the noncentrality measure.
References
Evans, M., N. Hastings, and B. Peacock, Statistical Distributions, 3rd ed., Wiley, New York, 2000.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsStudentPDF, StatsStudentCDF, 
and StatsNCTCDF functions.
StatsNormalCDF 
StatsNormalCDF(x, m, s)
The StatsNormalCDF function returns the normal cumulative distribution function
f (x;n1,n2,d) = exp d / 2
(
)
B n1
2 , n2
2




xn1 /21(xn1 + n2)(n1 +n2 )/2n1
n1 /2n2
n2 /2
1F1
n1 + n2
2
, n1
2 ,
xdn1
2 xn1 + n2
(
)



 ,
f (x;n,) =
nn 2n!
2ne 2 2(n + x2)n 2 n
2


-
./
2x 1F1
n
2 +1; 3
2;
 2x2
2(n + x2)


-
./
(n + x2) n +1
2


-
./
+
1F1
n +1
2 ; 1
2;
 2x2
2(n + x2)


-
./
(n + x2) n
2 +1


-
./


 

 
 


 

 
 
F(x,μ,) = 1
2 + 1
2 erf
x  μ

2



 ,
