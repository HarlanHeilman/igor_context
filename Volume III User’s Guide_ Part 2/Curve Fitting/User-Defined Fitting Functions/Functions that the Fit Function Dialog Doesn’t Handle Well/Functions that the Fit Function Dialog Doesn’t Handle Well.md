# Functions that the Fit Function Dialog Doesn’t Handle Well

Chapter III-8 — Curve Fitting
III-254
variable result
if (x < w[4])
 result = w[0]+w[1]*x
else
 result = w[2]+w[3]*x
endif
return result
End
If you click the Edit Fit Function button, the function code is analyzed to determine the number of coeffi-
cients. If the comments that name the coefficients are present, the dialog uses those names. If they are not 
present, the coefficient wave name is used with the index number appended to it as the coefficient name.
Having mnemonic names for the fit coefficients is very helpful when you look at the curve fit report in the 
history area. The minimum set of comments required to have names appear in the dialog and in the history 
is a lead-in comment line, plus the Coefficients comment lines. For instance, the following version of the 
function above will allow the Curve Fitting dialog and history report to use coefficient names:
Function PieceWiseLineFit(w,x) : FitFunc
WAVE w
Variable x
//CurveFitDialog/
//CurveFitDialog/ Coefficients 5
//CurveFitDialog/ w[0] = a1
//CurveFitDialog/ w[1] = b1
//CurveFitDialog/ w[2] = a2
//CurveFitDialog/ w[3] = b2
//CurveFitDialog/ w[4] = breakX
Variable result
if (x < w[4])
 result = w[0]+w[1]*x
else
 result = w[2]+w[3]*x
endif
return result
End
The blank comment before the line with the number of coefficients on it is required- the parser that looks at 
these comments needs one lead-in line to throw away. That line can contain anything as long as it includes 
the lead-in “//CurveFitDialog/”.
Functions that the Fit Function Dialog Doesn’t Handle Well
In the example functions it is quite clear by looking at the function code how many fit coefficients a function 
requires, because the coefficient wave is indexed with a literal number. The number of coefficients is simply 
one more than the largest index used in the function.
Occasionally a fit function uses constructions other than a literal number for indexing the coefficient wave. 
This will make it impossible for the Curve Fitting dialog to figure out how many coefficients are required. In 
this case, the Coefficients tab can’t be constructed until you specify how many coefficients are needed. You do 
this by choosing a coefficient wave having the right number of points from the Coefficient Wave menu.
You cannot edit such a function by clicking the Edit Fit Function button. You must write and edit the func-
tion in the Procedure window.
Here is an example function that can fit an arbitrary number of Gaussian peaks. It uses the length of the 
coefficient wave to determine how many peaks are to be fit. Consequently, it uses a variable (cfi) rather 
than a literal number to access the coefficients:
Function FitManyGaussian(w, x) : FitFunc
WAVE w
Variable x
Variable returnValue = w[0]
The actual function code.
The first coefficient is a baseline offset.
