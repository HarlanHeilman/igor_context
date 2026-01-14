# MPFXGaussPeak

MPFXGaussPeak
V-669
Parameters
Details
The following equations and discussion use these definitions:
c0 = cw[0], c1 = cw[1], c2 = cw[2], c3 = cw[3]
The peak location given by c0 is not the actual peak location; it is simply a parameter that offsets the peak 
in the X direction. The actual location is given by
The actual peak height is given by
The peak area is given by c1/c3.
We are not aware of an analytic expression for the full width at half maximum (FWHM).
This function is primarily intended to support the Multi-peak Fitting package.
To use MPFXExpConvExpPeak as a fitting function, wrap it in an all-at-once user-defined fitting function:
Function FitVoigtPeak(Wave cw, Wave yw, Wave xw) : FitFunc
Variable dummy = MPFXExpConvExpPeak(cw, yw, xw)
End
The assignment to "dummy" is required because you must explicitly do something with the return value of 
a built-in function.
If the waves do not satisfy the number type requirements, the function returns NaN. A successful 
invocation returns zero.
See Also
All-At-Once Fitting Functions on page III-256
MPFXGaussPeak
MPFXGaussPeak(cw, yw, xw)
The MPFXGaussPeak function implements a single Gaussian peak with no Y offset in the format of an all-
at-once fitting function. It fills the wave yw with values defined by a Gaussian peak as if this wave 
assignment statement was executed:
yw = cw[2] * exp( -((xw - cw[0])/cw[1])^2 )
cw
yw
Y wave into which values are stored.
yw may be either double precision or single precision.
xw
X wave containing the X values at which the peak function is to be evaluated.
xw may be either double precision or single precision.
Coefficient wave. The Gaussian peak shape is defined by the coefficients as follows:
cw must be a double precision wave.
cw[0]:
Peak location.
cw[1]:
Peak height.
cw[2]:
Inverse of the decay constant of one exponential.
cw[3]:
Inverse of the decay constant of the other exponential.
loc = ln(c2
c3)
c2 −c3 + c0
h =
c1 · c2
c2
c3
−
c2
c2−c3 −
c2
c3
−
c3
c2−c3
c3 −c2
