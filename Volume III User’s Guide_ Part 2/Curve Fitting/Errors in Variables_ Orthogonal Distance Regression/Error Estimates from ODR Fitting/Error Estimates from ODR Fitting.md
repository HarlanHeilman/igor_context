# Error Estimates from ODR Fitting

Chapter III-8 — Curve Fitting
III-238
In the absence of the /XR flag, initial guesses for the adjustments to the independent variable values are set 
to zero. This is usually appropriate; in areas where the fitting function is largely vertical, you may need 
nonzero guesses to fit successfully. One example of such a situation would be the region near a singularity.
Holding Independent Variable Adjustments
In some cases you may have reason to believe that you know some input values of the independent vari-
ables are exact (or nearly so) and should not be adjusted. To specify which values should not be adjusted, 
you supply X hold waves, one for each independent variable, via the /XHLD flag. These waves should be 
filled with zeroes corresponding to values that should be adjusted, or ones for values that should be held.
This is similar to the /H flag to hold fit coefficients at a set value during fitting. However, in the case of ODR 
fitting and the independent variable values, holds are specified by a wave instead of a string of ones and 
zeroes. This was done because of the potential for huge numbers of ones and zeroes being required. To save 
memory, you can use a byte wave for the holds. In the Make Waves dialog, you select Byte 8 Bit from the 
Type menu. Use the /B flag with the Make operation on page V-526.
ODR Fit Results
An ordinary least-squares fit adjusts the fit coefficients and calculates model values for the dependent vari-
able. You can optionally have the fit calculate the residuals — the differences between the model and the 
dependent variable data.
ODR fitting adjusts both the fit coefficients and the independent variable values when seeking the least 
orthogonal distance fit. In addition to the residuals in the dependent variable, it can calculate and return to 
you a wave or waves containing the residuals in the independent variables, as well as a wave containing 
the adjusted values of the independent variable.
Residuals in the independent variable are returned via waves specified by the /XR flag. Note that the con-
tents of these waves are inputs for initial guesses at the adjustments to the independent variables, so you 
must be careful — in most cases you will want to set the waves to zero before fitting.
The adjusted independent variable values are placed into waves you specify via the /XD flag.
Note that if you ask for an auto-destination wave (/D flag; seeThe Destination Wave on page III-196) the 
result is a wave containing model values at a set of evenly-spaced values of the independent variables. This 
wave will also be generated in response to the /D flag for ODR fitting.
You can also specify a specific wave to receive the model values (/D=wave). The values are calculated at the 
values of the independent variables that you supply as input to the fit. In the case of ODR fitting, to make a 
graph of the model, the appropriate X wave would be the output from the /XD flag, not the input X values.
Constraints and ODR Fitting
When fitting with the ordinary least-squares method (/ODR=0) you can provide a text wave containing con-
straint expressions that will keep the fit coefficients within bounds. These expressions can be used to apply 
simple bound constraints (keeping the value of a fit coefficient greater than or less than some value) or to 
apply bounds on linear combinations of the fit coefficients (constrain a+b>1, for instance).
When fitting using ODR (/ODR=1 or more) only simple bound constraints are supported.
Error Estimates from ODR Fitting
In a curve fit, the output includes an estimate of the errors in the fit coefficients. These estimates are com-
puted from the linearized quadratic approximation to the chi-square surface at the solution. For a linear fit 
(line, poly, and poly2D fit functions) done by ordinary least squares, the chi-square surface is actually qua-
dratic and the estimates are exact if the measurement errors are normally distributed with zero mean and 
constant variance. If the fitting function is nonlinear in the fit coefficients, then the error estimates are an 
approximation. The quality of the approximation will depend on the nature of the nonlinearity.
