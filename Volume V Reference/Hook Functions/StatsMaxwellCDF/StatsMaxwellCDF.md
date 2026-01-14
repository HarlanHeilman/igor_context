# StatsMaxwellCDF

StatsLogNormalCDF
V-956
where the scale parameter b>0 and the shape parameter is a.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogisticCDF and 
StatsInvLogisticCDF functions.
StatsLogNormalCDF 
StatsLogNormalCDF(x,  [, , ])
The StatsLogNormalCDF function returns the lognormal cumulative distribution function
for x > and , >0. The standard lognormal distribution is for =0 and =1, which are the optional 
parameter defaults.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogNormalPDF and 
StatsInvLogNormalCDF functions.
StatsLogNormalPDF 
StatsLogNormalPDF(x,  [, , ])
The StatsLogNormalPDF function returns the lognormal probability distribution function
for x > and , > 0, where  is the location parameter,  is the scale parameter and,  is the shape 
parameter. The standard lognormal distribution is for =0 and =1, which are the optional parameter 
defaults.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsLogNormalCDF and 
StatsInvLogNormalCDF functions.
Reference
The expression for the PDF follows the NIST definition at: 
https://www.itl.nist.gov/div898/handbook/eda/section3/eda3669.htm. Note that alternate definitions use μ 
differently.
StatsMaxwellCDF 
StatsMaxwellCDF(x, k)
The StatsMaxwellCDF function returns the Maxwell cumulative distribution function
where gammp is the regularized incomplete gamma function.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsMaxwellPDF and 
StatsInvMaxwellCDF functions.
F(x;,,μ) =
1

2
1
t  exp  ln t 
μ




 

J
KL
2
2 2



M
N
O
0
x
dt,
f (x;,,μ) =
1

2
1
x  exp  ln x 
μ




 



2
2 2






,
F(x;k) = gammp 3
2 , kx2
2



 ,
x > 0.
