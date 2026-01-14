# ODR Initial Guesses

Chapter III-8 — Curve Fitting
III-237
In some cases, however, the errors in both dependent and independent variables may be comparable. This 
situation has a variety of names including errors in variables, measurement error models or random regres-
sor models. An example of a model that can result in similar errors in dependent and independent variables 
is fitting the track of an object along a surface; the variables involved would be measurements of cartesian 
coordinates of the object’s location at various instants in time. Presumably the measurement errors would 
be similar because both involve spatial measurement.
Fitting such data using standard or ordinary least squares can lead to bias in the solution. To solve this prob-
lem, we offer Orthogonal Distance Regression (ODR). Rather than minimizing the sum of squared errors in 
the dependent variable, ODR minimizes the orthogonal distance from the data to the fitted curve by adjust-
ing both the model coefficients and an adjustment to the values of the independent variable. This is also 
sometimes called “total least squares” or “reduced major axis” (RMA) fitting
For ODR curve fitting, Igor Pro uses a modified version of the freely available ODRPACK95. The CurveFit, 
FuncFit, and FuncFitMD operations can all do ODR fitting using the /ODR flag (see the documentation for 
the CurveFit operation on page V-124 for details on the /ODR flag, and the Curve Fitting References on 
page III-267 for information about the ODRPACK95 implementation of ODR fitting). Our version of 
ODRPACK95 has been modified to make it threadsafe and to do some automatic multithreading during 
single fits.
ODR Fitting is Threadsafe
As of Igor Pro 8.00, ODR fitting is threadsafe. You can perform an ODR fit from a threadsafe user-defined 
function and you can do multiple ODR fits simultaneously using Igor’s preemptive threads.
Weighting Waves for ODR Fitting
Just as with ordinary least-squares fitting, you can provide a weighting wave to indicate the expected mag-
nitude of errors for ODR fitting. But in ODR fitting, there are errors in both the dependent and independent 
variables, so ODR fits accept weighting waves for both. You use the /XW flag to specify weighting waves 
for the independent variable.
If you do not supply a weighting wave, it is assumed the errors have a variance of 1.0. This may be accept-
able if the errors in the dependent and independent variables truly have similar magnitudes. But if the 
dependent and independent variables are of very different magnitudes, the chances are good that the errors 
are also of very different magnitudes, and weighting is essential for a proper fit. Unlike the case for ordinary 
least squares, where there is only a single weighting wave, ODR fitting depends on both the magnitude of 
the weights as well as the relative magnitudes of the X and Y weights.
ODR Initial Guesses
An ordinary least squares fit that is linear in the coefficients can be solved directly. No initial guess is 
required. The built-in line, poly, and poly2D curve fit functions are linear in the coefficients and do not 
require initial guesses.
An ordinary least-squares fit to a function that is nonlinear in the coefficients is an iterative process that 
requires a starting point. That means that you must provide an initial guess for the fit coefficients. The accu-
racy required of your initial guess depends greatly on the function you are fitting and the quality of your 
data. The built-in fit functions also attempt to calculate a good set of initial guesses, but for user-defined fits 
you must supply your own initial guesses.
An ODR fit introduces a nonlinearity into the fitting equations that requires iterative fitting and initial 
guesses even for fit functions that have linear fit coefficients. In the case of line, poly, and poly2D fit func-
tions, ODR fitting uses an ordinary least squares fit to get an initial guess. For nonlinear built-in fit func-
tions, the same initial guesses are used regardless of fitting method.
Because the independent variable is adjusted during the fit, an initial guess is also required for the adjust-
ments to the independent variable. The initial guess is transmitted via one or more waves (one for each 
independent variable) specified with the /XR flag. The X residual wave is also an output- see the ODR Fit 
Results on page III-238.
