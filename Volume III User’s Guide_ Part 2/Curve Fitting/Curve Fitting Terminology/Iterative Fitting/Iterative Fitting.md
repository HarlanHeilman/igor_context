# Iterative Fitting

Chapter III-8 — Curve Fitting
III-179
Fitting to an external function works the same as fitting to a user-defined function (with some caveats con-
cerning the Curve Fitting dialog — see Fitting to an External Function (XFUNC) on page III-194).
If you use the Curve Fitting dialog, you don’t really need to know much about the distinction between built-
in and user-defined functions. You may need to know a bit about the distinction between external functions 
and other types. This will be discussed later.
We use the term “coefficients” for the numbers that the curve fit is to find. We use the term “parameters” 
to talk about the values that you pass to operations and functions.
Overview of Curve Fitting
In curve fitting we have raw data and a function with unknown coefficients. We want to find values for the 
coefficients such that the function matches the raw data as well as possible. The “best” values of the coeffi-
cients are the ones that minimize the value of Chi-square. Chi-square is defined as:
where y is a fitted value for a given point, yi is the measured data value for the point and i is an estimate 
of the standard deviation for yi.
The simplest case is fitting to a straight line: 
. Suppose we have a theoretical reason to believe that 
our data should fall on a straight line. We want to find the coefficients a and b that best match our data.
For a straight line or polynomial function, we can find the best-fit coefficients in one step. This is nonitera-
tive curve fitting, which uses the singular value decomposition algorithm for polynomial fits.
Iterative Fitting
For the other built-in fitting functions and for user-defined functions, the operation is iterative as the fit tries 
various values for the unknown coefficients. For each try, it computes chi-square searching for the coeffi-
cient values that yield the minimum value of chi-square.
The Levenberg-Marquardt algorithm is used to search for the coefficient values that minimize chi-square. 
This is a form of nonlinear, least-squares fitting.
As the fit proceeds and better values are found, the chi-square value decreases. The fit is finished when the 
rate at which chi-square decreases is small enough.
During an iterative curve fit, you will see the Curve Fit progress window. This shows you the function 
being fit, the updated values of the coefficients, the value of chi-square, and the number of passes.
Normally you will let the fit proceed until completion when the Quit button is disabled and the OK button 
is enabled. When you click OK, the results of the fit are written in the history area.
y
yi
–
i
------------




2
i
y
ax
b
+
=
