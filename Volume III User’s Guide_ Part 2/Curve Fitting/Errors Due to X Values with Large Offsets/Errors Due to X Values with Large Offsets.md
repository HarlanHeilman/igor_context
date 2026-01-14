# Errors Due to X Values with Large Offsets

Chapter III-8 — Curve Fitting
III-265
while(1)
End
This function is very limited. It simply does fits to a number of waves in a list. Igor includes a package that 
adds a great deal of sophistication to batch fitting, and provides a user interface. For a demonstration, 
choose FileExample ExperimentsCurve FittingBatch Curve Fitting Demo.
Curve Fitting Examples
The Igor Pro Folder includes a number of example experiments that demonstrate the capabilities of curve 
fitting. These examples cover fitting with constraints, multivariate fitting, multipeak fitting, global fitting, 
fitting a line between cursors, and fitting to a user-defined function. All of these experiments can be found 
in Igor Pro Folder/Examples/Curve Fitting.
Singularities in Curve Fitting
You may occasionally run across a situation where you see a “singular matrix” error. This means that the 
system of equations being solved to perform the fit has no unique solution. This generally happens when 
the fitted curve contains degeneracies, such as if all Y values are equal.
In a fit to a user-defined function, a singular matrix results if one or more of the coefficients has no effect on 
the function’s return value. Your coefficients wave must have the exact same number of points as the number 
of coefficients that you actually use in your function or else you must hold constant unused coefficients.
Certain functions may have combinations of coefficients that result in one or more of the coefficients having 
no effect on the fit. Consider the Gaussian function:
If K1 is set to zero, then the following exponential has no effect on the function value. The fit will report 
which coefficients have no effect. In this example, it will report that K2 and K3 have no effect on the fit. How-
ever, as this example shows, it is often not the reported coefficients that are at fault.
Special Considerations for Polynomial Fits
Polynomial fits use the singular value decomposition technique. If you encounter singular values and some 
of the coefficients of the fit have been zeroed, you are probably asking for more terms than can be supported 
by your data. You should use the smallest number of terms that gives a “reasonable” fit. If your data does 
not support higher-order terms then you can actually get a poorer fit by including them.
If you really think your data should fit with the number of terms you specified, you can try adjusting the 
singular value threshold. You do this by creating a special variable called V_tol and setting it to a value 
smaller than the default value of 1e-10. You might try 1e-15.
Another way to run into trouble during polynomial fitting is to use a range of X values that are very much 
offset from zero. The solution is to temporarily offset your X values, do the fit and then restore the original 
X values. This is done for you by the poly_XOffset fit function; see Built-in Curve Fitting Functions on page 
III-206 for details.
Errors Due to X Values with Large Offsets
The single and double exponential fits can be thrown off if you try to fit to a range of X values that are very 
much offset from zero. In general, any function, which, when extrapolated to zero, returns huge or infinite 
values, can create problems. The solution is to temporarily offset your x values, perform the fit and then 
restore the original x values. You may need to perform a bit of algebra to fix up the coefficients.
K0
K1
x
K2
–

K3


2
exp
+
