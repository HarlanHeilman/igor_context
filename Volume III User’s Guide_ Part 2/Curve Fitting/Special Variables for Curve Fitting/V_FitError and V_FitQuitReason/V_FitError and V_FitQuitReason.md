# V_FitError and V_FitQuitReason

Chapter III-8 — Curve Fitting
III-235
Bit 5: Errors Only
When set, just like setting /O flag (Guess only) but for FuncFit also computes the W_sigma wave and option-
ally the covariance matrix (/M flag) for your set of coefficients. There is the possibility that setting this bit 
can generate a singular matrix error.
Added in Igor Pro 7.00.
V_chisq
V_chisq is a measure of the goodness of fit. It has absolute meaning only if you’ve specified a weighting 
wave. See the discussion in the section Weighting on page III-199.
V_q
V_q (straight-line fit only) is a measure of the believability of chi-square. It is valid only if you specified a 
weighting wave. It represents the quantity q which is computed as follows:
q = gammq((N-2)/2, chisq/2)
where gammq is the incomplete gamma function 1-P(a,x) and N is number of points. A q of 0.1 or higher indi-
cates that the goodness of fit is believable. A q of 0.001 indicates that the goodness of fit may be believable. A 
q of less than 0.001 indicates systematic errors in your data or that you are fitting to the wrong function.
V_FitError and V_FitQuitReason
When an error occurs during a curve fit, it normally causes any running user-defined procedure to abort.
This makes it impossible for you to write a procedure that attempts to recover from errors. However, you 
can prevent an abort in the case of certain types of errors that arise from unpredictable mathematical cir-
cumstances. Do this creating a variable named V_FitError and setting it to zero before performing a fit. If 
an error occurs during the fit, it will set bit 0 of V_FitError. Certain errors will also cause other bits to be set 
in V_FitError:
Reentrant curve fitting means that somehow a second curve fit started execution when there was already 
one running. That could happen if your user-defined fit function tried to do a curve fit, or if a button action 
procedure that does a fit responded too soon to another click.
There is more than one reason for a fit to stop iterating without an error. To obtain more information about 
the reason that a nonlinear fit stopped iterating, create a variable named V_FitQuitReason. After the fit, 
V_FitQuitReason is zero if the fit terminated normally, 1 if the iteration limit was reached, 2 if the user 
stopped the fit, or 3 if the limit of passes without decreasing chi-square was reached.
Other types of errors, such as missing waves or too few data points for the fit, are likely to be programmer 
errors. V_FitError does not catch those errors, but you can still prevent an abort if you wish, using the 
special function AbortOnRTE and Igor's try-catch-endtry construct. Here is an example function that 
attempts to do a curve fit to a data set that may contain nothing but NaNs:
Function PreventCurveFitAbort()
Make/O test = NaN
Error
Bit Set
Any error
0
Singular matrix
1
Out of memory
2
Function returned NaN or INF
3
Fit function requested stop
4
Reentrant curve fitting
5
