# Special Variables for Curve Fitting

Chapter III-8 — Curve Fitting
III-232
Severe Constraint Conflict
Although the method used for applying the constraints can find a solution even when constraints conflict 
with each other (are infeasible), it is possible to have a conflict that is so bad that the method fails. This will 
result in a singular matrix error.
Constraint Region is a Poor Fit
It is possible that the region of coefficient space allowed by the constraints is such a bad fit to the data that 
a singular matrix error results.
Initial Guesses Far Outside the Constraint Region
Usually if the initial guesses for a fit lie outside the region allowed by the constraints, the fit coefficients will 
shift into the constraint region on the first iteration. It is possible, however, for initial guesses to be so far from 
the constraint region that the solution to the constraints fails. This will cause the usual singular matrix error.
Constraints Conflict with a Held Parameter
You cannot hold a parameter and apply a constraint to the same parameter. Thus, this is not allowed:
Make/T CWave="K1 > 5"
FuncFit/H="01" myFunc, myCoefs, myData /C=CWave 
NaNs and INFs in Curve Fits
Curve fits ignore NaNs and INFs in the input data. This is a convenient way to eliminate individual data 
values from a fit. A better way is to use a data mask wave (see Using a Mask Wave on page III-198).
Special Variables for Curve Fitting
There are a number of special variables used for curve fitting input (to provide additional control of the fit) 
and for output (to provide additional statistics). Knowledgeable users can use the input variables to tweak 
the fitting process. However, this is usually not needed. Some output variables help users knowledgeable 
in statistics to evaluate the quality of a curve fit.
To use an input variable interactively, create it from the command line using the Variable operation before 
performing the fit.
Most of the output variables are automatically created by the CurveFit or FuncFit operations. Some, as indi-
cated below, are not automatically created; you must create them yourself if you want the information they 
provide.
If you are fitting using a procedure, both the input and output variables can be local or global. It is best to 
make them local. See Accessing Variables Used by Igor Operations on page IV-123 for information on how 
to use local variables. In procedures, output-only variables are always as local variables.
If you perform a curve fit interactively via the command line or via the Curve Fitting dialog, the variables 
will be global. If you use multiple data folders (described in Chapter II-8, Data Folders), you need to 
remember that input and output variables are searched for or created in the current data folder.

Chapter III-8 — Curve Fitting
III-233
The following table lists all of the input and output special variables. Some variables are discussed in more 
detail in sections following the table.
Variable
I/O
Meaning
V_FitOptions
Input
Miscellaneous options for curve fit.
V_FitTol
Input
Normally, an iterative fit terminates when the fractional decrease of chi-
square from one iteration to the next is less than 0.001. If you create a 
global variable named V_FitTol and set it to a value between 1E-10 and 
0.1 then that value will be used as the termination tolerance. Values 
outside that range will have no effect.
V_tol
Input
(poly fit only) The “singular value threshold”. See Special Considerations 
for Polynomial Fits on page III-265.
V_chisq
Output
A measure of the goodness of fit. It has absolute meaning only if you’ve 
specified a weighting wave containing the reciprocal of the standard error 
for each data point.
V_q
Output 
(line fit only) A measure of the believability of chi-square. Valid only if 
you specified a weighting wave.
V_siga, V_sigb
Output 
(line fit only) The probable uncertainties of the intercept (K0 = a) and slope 
(K1 = b) coefficients for a straight-line fit (to y = a + bx).
V_Rab
Output 
(line fit only) The coefficient of correlation between the uncertainty in a 
(the intercept, K0) and the uncertainty in b (the slope, K1).
V_Pr
Output 
(line fit only) The linear correlation coefficient r (also called Pearson’s r). 
Values of +1 or -1 indicate complete correlation while values near zero 
indicate no correlation.
V_r2
Output
(line fit only) The coefficient of determination, usually called simply "r-
squared". See Coefficient of Determination or R-Squared on page III-221 
for details.
V_npnts
Output
The number of points that were fitted. If you specified a weighting wave 
then points whose weighting was zero are not included in this count. Also 
not included are points whose values are NaN or INF.
V_nterms
Output
The number of coefficients in the fit.
V_nheld
Output
The number of coefficients held constant during the fit.
V_numNaNs
Output
The number of NaN values in the fit data. NaNs are ignored during a 
curve fit.
V_numINFs
Output
The number of INF values in the fit data. INFs are ignored during a curve 
fit.
V_FitError
Input/
Output
Used from a procedure to attempt to recover from errors during the fit.
V_FitQuitReason
Output
Provides additional information about why a nonlinear fit stopped 
iterating.
You must create this variable; it is not automatically created.
V_FitIterStart
Output
Use of V_FitIterStart is obsolete; use all-at-once fit functions instead. See 
All-At-Once Fitting Functions on page III-256 for details.
Set to 1 when an iteration starts. Identifies when the user-defined fitting 
function is called for the first time for a particular iteration.
You must create this variable; it is not automatically created.
