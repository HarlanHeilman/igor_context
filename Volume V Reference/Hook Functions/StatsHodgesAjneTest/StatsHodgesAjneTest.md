# StatsHodgesAjneTest

StatsGammaPDF
V-933
StatsGammaPDF 
StatsGammaPDF(x, , , )
The StatsGammaPDF function returns the gamma probability distribution function
where  is the location parameter,  is the scale parameter,  is the shape parameter, and  is the gamma 
function.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGammaCDF and 
StatsInvGammaCDF.
StatsGeometricCDF 
StatsGeometricCDF(x, p)
The StatsGeometricCDF function returns the geometric cumulative distribution function
where p is the probability of success in a single trial and x is the number of trials for x 0.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGeometricPDF and 
StatsInvGeometricCDF.
StatsGeometricPDF 
StatsGeometricPDF(x, p)
The StatsGeometricPDF function returns the geometric probability distribution function
where the p is the probability of success in a single trial and x is the number of trials x  0.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsGeometricCDF and 
StatsInvGeometricCDF.
StatsHodgesAjneTest 
StatsHodgesAjneTest [flags] srcWave
The StatsHodgesAjneTest operation performs the Hodges-Ajne nonparametric test for uniform distribution 
around a circle. Output is to the W_HodgesAjne wave in the current data folder or optionally to a table.
Flags
/ALPH = val
Sets the significance level (default val=0.05).
/Q
No results printed in the history area.
/SA=specAngle
Uses the Batschelet modification of the Hodges-Ajne test to test for uniformity against 
the alternative of concentration around the specified angle. specAngle must be 
expressed in radians modulus 2.
f (x;μ,, ) =
x  μ



 


 1
exp  x  μ



 


( )
.
x  μ
, > 0
F(x, p) = 1 (1 p)x+1.
f (x, p) = p(1 p)x,
