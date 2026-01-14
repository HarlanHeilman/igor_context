# MPFXExpConvExpPeak

MPFXExpConvExpPeak
V-668
Parameters
Details
There is no analytic expression for peak parameters of common interest like the amplitude, location and 
width. The Multpeak Fitting package uses numerical techniques to get approximations.
This function is primarily intended to support the Multipeak Fitting package.
To use MPFXEMGPeak as a fitting function, wrap it in an all-at-once user-defined fitting function:
Function FitVoigtPeak(Wave cw, Wave yw, Wave xw) : FitFunc
Variable dummy = MPFXEMGPeak(cw, yw, xw)
End
The assignment to "dummy" is required because you must explicitly do something with the return value of 
a built-in function.
The implementation of this function involves the erfcx function.
If the waves do not satisfy the number type requirements, the function returns NaN. A successful 
invocation returns zero.
See Also
All-At-Once Fitting Functions on page III-256
MPFXExpConvExpPeak
MPFXExpConvExpPeak(cw, yw, xw)
The MPFXExpConvExpPeak function implements a single peak with no Y offset in the format of an all-at-
once fitting function. The peak shape is that of an exponential convolved with another exponential.
MPFXExpConvExpPeak is similar to the MPFXEMGPeak, but it has a sharp onset. It fills the wave yw with 
peak values as if a simple wave assignment was executed.
cw
yw
Y wave into which values are stored.
yw may be either double precision or single precision.
xw
X wave containing the X values at which the peak function is to be evaluated.
xw may be either double precision or single precision.
Coefficient wave, which must be a double-precision wave.
The Gaussian peak shape is defined by the coefficients as follows:
cw must be a double precision wave.
cw[0]:
Peak location. This is actually the location of the underlying Gaussian peak. 
There is no analytic expression for the actual peak location.
cw[1]:
Standard deviation of the Gaussian portion.
cw[2]:
Amplitude-related parameter.
cw[3]:
Decay constant of the exponential portion.
