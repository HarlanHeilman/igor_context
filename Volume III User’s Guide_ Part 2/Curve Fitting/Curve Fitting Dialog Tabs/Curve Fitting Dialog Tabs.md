# Curve Fitting Dialog Tabs

Chapter III-8 — Curve Fitting
III-213
descriptions are available in various places in this chapter. For a quick introduction, here is a table that lists 
the waves and variables used for fitting to a built-in function.
Curve Fitting Dialog Tabs
This section describes the controls on each tab and on the main pane of the Curve Fitting dialog.
Wave or Variable
Type
What It Is Used For
Dependent 
variable data 
wave
Input
Contains measured values of the dependent variable of the curve to 
fit. Often referred to as “Y data”.
Independent 
variable data wave
Input
Contains measured values of the independent variable of the curve to 
fit. Often referred to as “X data”.
Destination wave
Optional output
For graphical feedback during and after the fit. The destination 
wave continually updates during the fit to show the fit function 
evaluated with the current coefficients.
Residual wave
Optional output
Difference between the data and the model.
Weighting wave
Optional input
Used to control how much individual Y data points contribute to 
the search for the output coefficients.
System variables 
K0, K1, K2 …
Input and 
output 
Built-in fit functions only.
Optionally takes initial guesses from the system variables and 
updates them at the end of the fit.
Coefficients wave
By default, 
W_coef.
Input and 
Output
Takes initial guesses from the coefficients wave, updates it during 
the fit and leaves final coefficients in it.
See the reference for CurveFit and FuncFit for additional options.
Epsilon wave
Optional input 
User-defined fit functions only.
Used by the curve fitting algorithm to calculate partial derivatives 
with respect to the coefficients.
W_sigma
Output
Creates this wave and stores the estimates of error for the 
coefficients in it.
W_fitConstants
Output
Created when you do a fit using a built-in fit function containing a 
constant. Igor creates this wave and stores the values of any 
constants used by the fit equation. For details, see Fits with 
Constants on page III-189. For notes on constants used in specific fit 
functions, see Built-in Curve Fitting Functions on page III-206.
V_<xxx>
Input
There are a number of special variables, such as V_FitOptions, that 
you can set to tweak the behavior of the curve fitting algorithms.
V_<xxx>
Output
Creates and sets a number of variables such as V_chisq and 
V_npnts. These contain various statistics found by the curve fit.
M_Covar
Output
Optionally creates a matrix wave containing the “covariance 
matrix”. It can be used to generate advanced statistics.
Other waves
Optional input 
and output
User-supplied or automatically generated waves for displaying 
confidence and prediction bands, and for specifying constraints on 
coefficient values.
