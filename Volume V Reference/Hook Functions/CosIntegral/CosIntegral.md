# CosIntegral

cos
V-109
Another common application is using autocorrelation (where srcWaveName and destWaveName are the 
same) to determine Power Spectral Density. In this case it better to use the DSPPeriodogram operation 
which provides more options.
See Also
Convolution on page III-284 and Correlation on page III-286 for illustrated examples. See the Convolve 
operation for algorithm implementation details, which are identical except for the lack of source wave 
reversal, and the lack of the /A (acausal) flag.
The MatrixOp, StatsCorrelation, StatsCircularCorrelationTest, StatsLinearCorrelationTest, and 
DSPPeriodogram operations.
References
An explanation of autocorrelation and Power Spectral Density (PSD) can be found in Chapter 12 of Press, 
William H., et al., Numerical Recipes in C, 2nd ed., 994 pp., Cambridge University Press, New York, 1992.
WaveMetrics provides Igor Technical Note 006, “DSP Support Macros” that computes the PSD with options 
such as windowing and segmenting. See the Technical Notes folder. Some of the techniques discussed there 
are available as Igor procedure files in the “WaveMetrics Procedures:Analysis:” folder.
Wikipedia: http://en.wikipedia.org/wiki/Correlation
Wikipedia: http://en.wikipedia.org/wiki/Cross_covariance
Wikipedia: http://en.wikipedia.org/wiki/Autocorrelation_function
cos 
cos(angle)
The cos function returns the cosine of angle which is in radians.
In complex expressions, angle is complex, and cos(angle) returns a complex value:
See Also
acos, sin, tan, sec, csc, cot
cosh 
cosh(num)
The cosh function returns the hyperbolic cosine of num:
In complex expressions, num is complex, and cosh(num) returns a complex value.
See Also
sinh, tanh, coth
CosIntegral
CosIntegral(z)
The CosIntegral(z) function returns the cosine integral of z.
If z is real, a real value is returned. If z is complex then a complex value is returned.
The CosIntegral function was added in Igor Pro 7.00.
Details
The cosine integral is defined by
cos(x + iy) = cos(x)cosh(y) isin(x)sinh(y).
cosh(x) = ex + ex
2
.
