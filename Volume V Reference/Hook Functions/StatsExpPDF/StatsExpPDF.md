# StatsExpPDF

StatsEValueCDF
V-929
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsEValueCDF 
StatsEValueCDF(x, , )
The StatsEValueCDF function returns the extreme-value (type I, Gumbel) cumulative distribution function
where >0. This is also known as the “minimum” form or distribution of the smallest extreme. To obtain 
the distribution of the largest extreme reverse the sign of .
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsEValuePDF, StatsInvEValueCDF, StatsGEVCDF, StatsGEVPDF
StatsEValuePDF 
StatsEValuePDF(x, , )
The StatsEValuePDF function returns the extreme-value (type I, Gumbel) probability distribution function
where >0. This is also known as the “minimum” form or the distribution of the smallest extreme. To obtain 
the distribution of the largest extreme reverse the sign of .
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsEValueCDF, StatsInvEValueCDF, StatsGEVCDF, StatsGEVPDF
StatsExpCDF 
StatsExpCDF(x, , )
The StatsExpCDF function returns the exponential cumulative distribution function
where x  and > 0. It returns NaN for = 0.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsExpPDF and StatsInvExpCDF.
StatsExpPDF 
StatsExpPDF(x, , )
The StatsExpPDF function returns the exponential probability distribution function
where  is the location parameter and >0 is the scale parameter. Use =0 and =1 for the standard form of 
the exponential distribution. It returns NaN for =0.
F(x;μ,) = 1 exp exp x  μ




 



 ,
F(x;μ,) = 1 exp exp x  μ




 



 ,
F(x;μ,) = 1 exp  x  μ




 ,
f (x;μ,) = 1
 exp  x  μ




 ,
