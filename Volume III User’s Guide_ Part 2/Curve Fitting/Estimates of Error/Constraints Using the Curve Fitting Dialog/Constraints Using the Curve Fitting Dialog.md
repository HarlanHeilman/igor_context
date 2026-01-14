# Constraints Using the Curve Fitting Dialog

Chapter III-8 — Curve Fitting
III-227
When the correlation is too strong, the fitting algorithm doesn't know where to go and therefore wanders 
around in a coefficient space in which a broad range of values all seem about as good. That is, broad regions 
in chi-square space provide very little variation in chi-square. The usual result is apparent convergence but 
with large estimated values in W_sigma, or a singular matrix error. 
The error estimates are based on the curvature of the chi-square surface around the solution point. A flat-
bottomed chi-square surface, such as results from having many solutions that are nearly as good, results in 
large errors. The flat bottom of the chi-square surface also results in small derivatives with respect to the 
coefficients that don't give a good indication of where the fit should go next, so iterations wander around, 
giving rise to fits that require many iterations to converge.
If you see a fit with unreasonably large error estimates, or that take many iterations to converge, compute 
the correlation matrix and look for off-diagonal values near 1 or -1. In our experience, values about 0.9 are 
probably OK. Values near 0.99 are suspicious but can be acceptable. Values around 0.999 are almost cer-
tainly an indication of problems.
Unfortunately, there is little you can do about identifiability problems. It is a mathematical characteristic of 
your fitting function. Sometimes a model has regions in coefficient space where two coefficients have 
similar effects on a fit, and expanding the range of the independent variable can alleviate the problem. Occa-
sionally some feature controlled by a coefficient might be very narrow and you can fix the problem with 
higher sampling density.
Fitting with Constraints
It is sometimes desirable to restrict values of the coefficients to a fitting function. Sometimes fitting func-
tions may allow coefficient values that, while fine mathematically, are not physically reasonable. At other 
times, some ranges of coefficient values may cause mathematical problems such as singularities in the func-
tion values, or function values that are so large that they overflow the computer representation. In such 
cases it is often desirable to apply constraints to keep the solution out of the problem areas. It could be that 
the final solution doesn’t involve any active constraints, but the constraints prevent termination of the fit 
on an error caused by wandering into bad regions on the way to the solution.
Curve fitting supports constraints on the values of any linear combination of the fit coefficients. The Curve 
Fitting dialog supports constraints on the value of individual coefficients.
The algorithm used to apply constraints is quite forgiving. Your initial guesses do not have to be within the 
constraint region (that is, initial guesses can violate the constraints). In most cases, it will simply move the 
parameters onto a boundary of the constraint region and proceed with the fit. Constraints can even be contra-
dictory (“infeasible” in curve fitting jargon) so long as the violations aren’t too severe, and the fit will simply 
“split the difference” to give you coefficients that are a compromise amongst the infeasible constraints.
Constraints are not available for the built-in line, poly and poly2D fit functions. To apply constraints to 
these fit functions you must create a user-defined fit function.
Constraints Using the Curve Fitting Dialog
The Coefficients Tab of the Curve Fitting dialog includes a menu to enable fitting with constraints. When 
you select the checkbox, the constraints section of the Coefficients list becomes available:
