# The New Fit Function Dialog Adds Special Comments

Chapter III-8 — Curve Fitting
III-253
endif
return result
End
This function can be entered into the New Fit Function dialog. Here is what the dialog looked like when we 
created the function above:
The New Fit Function Dialog Adds Special Comments
In the example above of a piece-wise linear fit function, the New Fit Function dialog uses coefficient names 
instead of indexing a coefficient wave, but there isn’t any way to name coefficients in a fit function. The New 
Fit Function dialog adds special comments to a fit function that contain extra information. For instance, the 
PieceWiseLineFit function as created by the dialog looks like this:
Function PieceWiseLineFit(w,x) : FitFunc
WAVE w
Variable x
//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Alteri
//CurveFitDialog/ make the function less convenient to work with in the Curve Fit
//CurveFitDialog/ Equation:
//CurveFitDialog/ variable result
//CurveFitDialog/ if (x < breakX)
//CurveFitDialog/ result = a1+b1*x
//CurveFitDialog/ else
//CurveFitDialog/ result = a2+b2*x
//CurveFitDialog/ endif
//CurveFitDialog/ f(x) = result
//CurveFitDialog/ End of Equation
//CurveFitDialog/ Independent Variables 1
//CurveFitDialog/ x
//CurveFitDialog/ Coefficients 5
//CurveFitDialog/ w[0] = a1
//CurveFitDialog/ w[1] = b1
//CurveFitDialog/ w[2] = a2
//CurveFitDialog/ w[3] = b2
//CurveFitDialog/ w[4] = breakX
Special comments give the Curve Fitting dialog 
extra information about the fit function.
The function code as it appears in the text 
window of the New Fit Function dialog.
Independent variable name (or 
names, for a multivariate function).
Coefficient names.
This prefix in the comment identifies the comment 
as belonging to the curve fitting dialog.
