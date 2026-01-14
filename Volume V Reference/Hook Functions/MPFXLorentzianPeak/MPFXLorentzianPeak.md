# MPFXLorentzianPeak

MPFXLorentzianPeak
V-670
Parameters
Details
This function is primarily intended to support the Multipeak Fitting package. To use MPFXGaussPeak as a 
fitting function, wrap it in an all-at-once user-defined fitting function:
Function FitGaussPeak(Wave cw, Wave yw, Wave xw) : FitFunc
Variable dummy = MPFXGaussPeak(cw, yw, xw)
End
The assignment to "dummy" is required because you must explicitly do something with the return value of 
a built-in function.
If the waves do not satisfy the number type requirements, the function returns NaN. A successful 
invocation returns zero.
See Also
All-At-Once Fitting Functions on page III-256
MPFXLorentzianPeak
MPFXLorentzianPeak(cw, yw, xw)
The MPFXLorentzianPeak function implements a single Lorentzian peak with no Y offset in the format of 
an all-at-once fitting function. It fills the wave yw with values defined by a Lorentzian peak as if this wave 
assignment statement was executed:
yw = 2*cw[2]/pi * cw[1]/(4*(xw-cw[0])^2 + cw[1]^2)
Parameters
Details
This function is primarily intended to support the Multipeak Fitting package. To use MPFXLorentzianPeak 
as a fitting function, wrap it in an all-at-once user-defined fitting function:
Function FitLorentzianPeak(Wave cw, Wave yw, Wave xw) : FitFunc
Variable dummy = MPFXLorentzianPeak(cw, yw, xw)
End
cw
yw
Y wave into which values are stored.
yw may be either double precision or single precision.
xw
X wave containing the X values at which the peak function is to be evaluated.
xw may be either double precision or single precision.
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
Peak width: sqrt(2) * (standard deviation).
cw[2]:
Amplitude.
Coefficient wave. The Lorentzian peak shape is defined by the coefficients as follows:
cw must be a double precision wave.
cw[0]:
Peak location.
cw[1]:
Peak width as full width at half maximum.
cw[2]:
Peak area.
