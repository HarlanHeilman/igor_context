# Curve Fitting Terminology

Chapter III-8 — Curve Fitting
III-178
Overview
Igor Pro’s curve fitting capability is one of its strongest analysis features. Here are some of the highlights:
•
Linear and general nonlinear curve fitting.
•
Fit by ordinary least squares, or by least orthogonal distance for errors-in-variables models.
•
Fit to implicit models.
•
Built-in functions for common fits.
•
Automatic initial guesses for built-in functions.
•
Fitting to user-defined functions of any complexity.
•
Fitting to functions of any number of independent variables, either gridded data or multicolumn data.
•
Fitting to a sum of fit functions.
•
Fitting to a subset of a waveform or XY pair.
•
Produces estimates of error.
•
Supports weighting.
The idea of curve fitting is to find a mathematical model that fits your data. We assume that you have the-
oretical reasons for picking a function of a certain form. The curve fit finds the specific coefficients which 
make that function match your data as closely as possible.
You cannot use curve fitting to find which of thousands of functions fit a data set.
People also use curve fitting to merely show a smooth curve through their data. This sometimes works but 
you should also consider using smoothing or interpolation, which are described in Chapter III-7, Analysis.
You can fit to three kinds of functions:
•
Built-in functions.
•
User-defined functions.
•
External functions (XFUNCs).
The built-in fitting functions are line, polynomial, sine, exponential, double-exponential, Gaussian, Lorent-
zian, Hill equation, sigmoid, lognormal, log, Gauss2D (two-dimensional Gaussian peak) and Poly2D (two-
dimensional polynomial).
You create a user-defined function by entering the function in the New Fit Function dialog. Very compli-
cated functions may have to be entered in the Procedure window.
External functions, XFUNCs, are written in C or C++. To create an XFUNC, you need the optional Igor XOP 
Toolkit and a C/C++ compiler. You don’t need the toolkit to use an XFUNC that you get from WaveMetrics 
or from another user.
Curve fitting works with equations of the form 
; although you can fit functions of any 
number of independent variables (the xn’s) most cases involve just one. For more details on multivariate 
fitting, see Fitting to a Multivariate Function on page III-200.
You can also fit to implicit functions; these have the form
. See Fitting Implicit Functions 
on page III-242.
You can do curve fits with linear constraints (see Fitting with Constraints on page III-227).
Curve Fitting Terminology
Built-in fits are performed by the CurveFit operation. User-defined fits are performed by the FuncFit or 
FuncFitMD operation. We use the term “curve fit operation” to stand for CurveFit, FuncFit, or FuncFitMD, 
whichever is appropriate.
y
f x1 x2 xn





=
f x1 x2 xn





0
=
