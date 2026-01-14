# Data for Curve Fitting

Chapter III-8 — Curve Fitting
III-180
If the fit has gone far enough and you are satisfied, you can click the Quit button, which finishes the iteration 
currently under way and then puts the results in the history area as if the fit had completed on its own.
Sometimes you can see that the fit is not working, e.g., when chi-square is not decreasing or when some of 
the coefficients take on very large nonsense values. You can abort it by pressing the User Abort Key Com-
binations, which discards the results of the fit. You will need to adjust the fitting coefficients and try again.
Initial Guesses
The Levenberg-Marquardt algorithm is used to search for the minimum value of chi-square. Chi-square 
defines a surface in a multidimensional error space. The search process involves starting with an initial 
guess at the coefficient values. Starting from the initial guesses, the fit searches for the minimum value by 
travelling down hill from the starting point on the chi-square surface.
We want to find the deepest valley in the chi-square surface. This is a point on the surface where the coef-
ficient values of the fitting function minimize, in the least-squares sense, the difference between the exper-
imental data and fit data. Some fitting functions may have only one valley. In this case, when the bottom of 
the valley is found, the best fit has been found. Some functions, however, may have multiple valleys, places 
where the fit is better than surrounding values, but it may not be the best fit possible.
When the fit finds the bottom of a valley it concludes that the fit is complete even though there may be a 
deeper valley elsewhere on the surface. Which valley is found first depends on the initial guesses.
For built-in fitting functions, you can automatically set the initial guesses. If this produces unsatisfactory 
results, you can try manual guesses. For fitting to user-defined functions you must supply manual guesses.
Termination Criteria
A curve fit will terminate after 40 passes in searching for the best fit, but will quit if 9 passes in a row produce 
no decrease in chi-square. This can happen if the initial guesses are so good that the fit starts at the minimum 
chi-square. It can also happen if the initial guesses are way off or if the function does not fit the data at all.
You can change the 40-pass limit. See the discussion of V_FitMaxIters under Special Variables for Curve 
Fitting on page III-232. Usually needing more than 40 passes is a sign of trouble with the fit. See Identifiability 
Problems on page III-226.
Unless you know a great deal about the fitting function and the data, it is unwise to assume that a solution 
is a good one. In almost all cases you will want to see a graph of the solution to compare the solution with 
the data. You may also want to look at a graph of the residuals, the differences between the fitted model 
and the data. Igor makes it easy to do both in most cases.
Errors in Curve Fitting
In certain cases you may encounter a situation in which it is not possible to decide where to go next in searching 
for the minimum chi-square. This results in a “singular matrix” error. This is discussed under Singularities in 
Curve Fitting on page III-265. Curve Fitting Troubleshooting on page III-266 can help you find the solution 
to the problem.
Data for Curve Fitting
You must have measured values of both the dependent variable (usually called “y”) and the independent 
variables (usually called “x” especially if there is just one). These are sometimes called the “response vari-
able” and “explanatory variables.” You can do a curve fit to waveform data or to XY data. That is, you can 
fit data contained in a single wave, with the data values in the wave representing the Y data and the wave’s 
X scaling representing equally-spaced X data. Or you can fit data from two (or more) waves in which the 
data values in one wave represent the Y values and the data values in another wave represent the X data. 
In this case, the data do not need to be equally spaced. In fact, the X data can be in random order.
You can read more about waveform and XY data in Chapter II-5, Waves.
