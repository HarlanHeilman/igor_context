# VoigtFunc

version
V-1068
version 
#pragma version = versNum
In the File Information dialog, #pragma version=versNum provides file version information that is 
displayed next to the file name in the dialog. This line must not be indented and must appear in the first 
fifty lines of the file. See Procedure File Version Information on page IV-166.
See Also
The The version Pragma on page IV-54, Procedure File Version Information on page IV-166, the IgorInfo 
function, and #pragma.
VoigtFunc
VoigtFunc(X,Y)
The VoigtFunc function computes the Voigt function using an approximation that has, as described by the 
author, "accuracy is typically at at least 13 significant digits".
VoigtFunc returns values from a normalized Voigt peak centered at X=0 for the given value of X. The X 
input is a normalized distance from the peak center:
where 
 is the Gaussian component half-width, and 
 is the distance from the peak center.
The parameter Y is the shape parameter: when Y is zero, the peak is pure Gaussian. When Y approaches 
infinity, the shape becomes pure Lorentzian. When Y is sqrt(ln(2)), the mix is half-and-half.
VoigtFunc was added in Igor Pro 7.00. The approximation used to compute it was changed Igor 8.00 for 
greater accuracy.
Details
The VoigtFunc function returns values from a normalized peak that can be used as the basis for user-
defined fitting functions. The function is used as the basis for the built-in Voigt fitting function and the 
VoigtPeak function.
VoigtFunc Curve Fitting Example
Here is an example of a user-defined fitting function built on VoigtFunc:
Constant sqrtln2=0.832554611157698
// sqrt(ln(2))
Constant sqrtln2pi=0.469718639349826
// sqrt(ln(2)/pi)
Function MyVoigtFit(w,xx) : FitFunc
Wave w
Variable xx
//CurveFitDialog/ These comments were created by the Curve Fitting dialog.
//CurveFitDialog/ Equation:
//CurveFitDialog/ Variable ratio = sqrtln2/gw
//CurveFitDialog/ Variable xprime = ratio*(xx-x0)
//CurveFitDialog/ Variable voigtY = ratio*shape
//CurveFitDialog/ f(xx) = y0 + area*sqrtln2pi*VoigtFunc(xprime, voigtY)
//CurveFitDialog/ End of Equation
//CurveFitDialog/ Independent Variables 1
//CurveFitDialog/ xx
//CurveFitDialog/ Coefficients 5
//CurveFitDialog/ w[0] = y0
//CurveFitDialog/ w[1] = area
//CurveFitDialog/ w[2] = x0
//CurveFitDialog/ w[3] = gw (FWHM)
//CurveFitDialog/ w[4] = shape (Lw/Gw)
Variable voigtX = 2*sqrtln2*(xx-w[2])/w[3]
Variable voigtY = sqrtln2*w[4]
return w[0] + (w[1]/w[3])*2*sqrtln2pi*VoigtFunc(voigtX, voigtY)
End
X =
ln(2)ν −ν0
γ g
γ g
ν −ν0
