# V_FitOptions

Chapter III-8 — Curve Fitting
III-234
V_FitOptions
There are a number of options that you can invoke for the fitting process by creating a variable named V_Fi-
tOptions and setting various bits in it. Set V_FitOptions to 1 to set Bit 0, to 2 to set Bit 1, etc.
Bit 0: Controls X Scaling of Auto-Trace Wave
If V_FitOptions exists and has bit 0 set (Variable V_fitOptions=1) and if the Y data wave is on the top 
graph then the X scaling of the auto-trace destination wave is set to match the appropriate x axis on the 
graph. This is useful when you want to extrapolate the curve outside the range of x data being fit.
A better way to do this is with the /X flag (not parameter- this flag goes immediately after the CurveFit or 
FuncFit operation and before the fit function name). See CurveFit for details.
Bit 1: Robust Fitting
You can get a form of robust fitting where the sum of the absolute deviations is minimized rather than the 
squares of the deviations, which tends to deemphasize outlier values. To do this, create V_FitOptions and 
set bit 1 (Variable V_fitOptions=2).
Warning 1: No attempt to adjust the results returned for the estimated errors or for the correlation matrix 
has been made. You are on your own.
Warning 2: Don’t set this bit and then forget about it.
Warning 3: Setting Bit 1 has no effect on line, poly or poly2D fits.
Bit 2: Suppresses Curve Fit Window
Normally, an iterative fit puts up an informative window while the fit is in progress. If you don’t want this 
window to appear, create V_FitOptions and set bit 2 (Variable V_fitOptions=4). This may speed 
things up a bit if you are performing batch fitting on a large number of data sets.
A better way to do this is via the /W=2 flag. See CurveFit for details.
Bit 3: Save Iterates
It is sometimes useful to know the path taken by a curve fit getting to a solution (or failing to). To save his 
information, create V_FitOptions and set bit 3 (Variable V_FitOptions=8). This creates a matrix wave 
called M_iterates, which contains the values of the fit coefficients at each iteration. The matrix has a row for 
each iteration and a column for each fit coefficient. The last column contains the value of chi square for each 
iteration.
Bit 4: Suppress Screen Updates
Works just like setting the /N=1 flag. See CurveFit for details.
Added in Igor Pro 7.00.
V_FitMaxIters
Input
Controls the maximum number of passes without convergence before 
stopping the fit. By default this is 40. You can set V_FitMaxIters to any 
value greater than 0. If V_FitMaxIters is less than 1 the default value of 40 
is used.
V_FitNumIters
Output
Number of iterations.
You must create this variable; it is not automatically created.
S_Info
Output
Keyword-value pairs giving certain kinds of information about the fit.
You must create this variable; it is not automatically created.
Variable
I/O
Meaning
