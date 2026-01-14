# StatsErrorPDF

StatsErlangCDF
V-928
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsTukeyTest, StatsANOVA1Test, 
StatsScheffeTest, and StatsNPMCTest.
StatsErlangCDF 
StatsErlangCDF(x, b, c)
The StatsErlangCDF function returns the Erlang cumulative distribution function
where b>0 (also as =1/b) is the scale parameter, c> 0 the shape parameter, (x) the gamma function, and 
(a,x) the incomplete gamma function gammaInc.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsErlangPDF.
StatsErlangPDF 
StatsErlangPDF(x, b, c)
The StatsErlangPDF function returns the Erlang probability distribution function
where b>0 (also as =1/b) is the scale parameter and c> 0 the shape parameter.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsErlangCDF.
StatsErrorPDF 
StatsErrorPDF(x, a, b, c)
The StatsErrorPDF function returns the error probability distribution function or the exponential power 
distribution
where a is the location parameter, b> 0 is the scale parameter, c> 0 is the shape parameter, and (x) is the 
gamma function.
Fourth
The critical q' value
Fifth
0 if the conclusion is to reject H0 or 1 to accept H0
Sixth
The P-value
F(x;b,c) = 1
 c, x
b



 
(c)
.
f (x;b,c) =
x
b
 



c1
exp  x
b
 



b(c 1)!
.
f (x;a,b,c) =
exp  1
2
x  a
b




2
c

 






b2
c
2 +1 1+ c
2




.
