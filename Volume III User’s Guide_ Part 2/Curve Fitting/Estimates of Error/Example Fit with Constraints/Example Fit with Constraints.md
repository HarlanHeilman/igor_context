# Example Fit with Constraints

Chapter III-8 — Curve Fitting
III-229
K0*K1 > 5
// K0*K1 is nonlinear
1/K1 < 4
// This is nonlinear: division by K1
ln(K0) < 1
// K0 not allowed as parameter to a function
When constraint expressions are parsed, the factors that multiply or divide the Kn’s are extracted as literal 
strings and evaluated separately. Thus, if you have <expression>*K0 or K0/<expression>, <expression> must 
be executable on its own.
You cannot use a text wave with constraint expressions for fitting from a threadsafe function. You must use 
the method described in Constraint Matrix and Vector on page III-230.
Equality Constraint
You may wish to constrain the value of a fit coefficient to be equal to a particular value. The constraint algo-
rithm does not have a provision for equality constraints. One way to fake this is to use two constraints that 
require a coefficient to be both greater than and less than a value. For instance, “K1 > 5” and “K1 < 5” will 
require K1 to be equal to 5.
If it is a single parameter that is to be held equal to a value, this isn’t the best method. You are much better off 
holding a parameter. In the Curve Fitting dialog, simply select the Hold box in the Coefficients list on the Coef-
ficients tab and enter a value in the Initial Guess column. If you are using a command line to do the fit,
FuncFit/H="01"…
will hold K1 at a particular value. Note that you have to set that value before starting the fit.
Example Fit with Constraints
The examples here are available in the Curve Fitting help file where they can be conveniently executed 
directly from the help window.
This example fits to a sum of two exponentials, while constraining the sum of the exponential amplitudes 
to be less than some limit that might be imposed by theoretical knowledge. We use the command line 
because the constraint is too complicated to enter into the Curve Fitting dialog.
First, make the data and graph it:
Make/O/N=50 expData= 3*exp(-0.2*x) + 3*exp(-0.03*x) + gnoise(.1)
Display expData
ModifyGraph mode=3,marker=8
Do a fit without constraints:
CurveFit dblExp expData /D/R
The following command makes a text wave with a single element containing the string “K1 + K3 < 5” which 
implements a restriction on the sum of the individual exponential amplitudes.
Make/O/T CTextWave={"K1 + K3 < 5"}
The wave is made using commands so that it could be written into this help file. It may be easier to use the 
Make Waves item from the Data menu to make the wave, and then display the wave in a table to edit the 
expressions. Make sure you make Text wave. Do not leave any blank lines in the wave.
Now do the fit again with constraints:
CurveFit dblExp expData /D/R/C=CTextWave
In this case, the difference is slight; in the graph of the fit with constraints, notice that the fit line is slightly 
lower at the left end and slightly higher at the right end than in the standard curve fit, and that difference 
is reflected in the residual values at the ends:
