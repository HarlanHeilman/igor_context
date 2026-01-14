# Fitting to a Multivariate Function

Chapter III-8 — Curve Fitting
III-200
Prepare a weighting wave that has weights proportional to X, but are not equal to the true measurement 
errors:
Duplicate data, data_wt
data_wt = x+1
// Right proportionality with X, but 1000 times too big
The fit has pretty meaningless coefficient errors because the weights provided were proportional to the true 
measurement errors, but 1000 times too big:
CurveFit/NTHR=0 exp data /W=data_wt /I=1 /D 
Fit converged properly
fit_data= W_coef[0]+W_coef[1]*exp(-W_coef[2]*x)
W_coef={0.0044805,0.99578,0.10063}
V_chisq= 0.000117533;V_npnts= 128;V_numNaNs= 0;V_numINFs= 0;
V_startRow= 0;V_endRow= 127;
W_sigma={5.78,5.74,1.15}
Coefficient values ± one standard deviation
y0 =0.0044805 ± 5.78
A =0.99578 ± 5.74
invTau=0.10063 ± 1.15
So now we compute reduced errors based on reduced chi-square:
Variable reducedChiSquare = V_chisq/(V_npnts - numpnts(W_coef))
Duplicate W_sigma, reducedSigma
reducedSigma = W_sigma*sqrt(reducedChiSquare)
The resulting errors are more reasonable:
Print reducedSigma
reducedSigma[0]= {0.00560293,0.0055649,0.00111907}
Note that, as with any non-linear fitting, Gaussian statistics like this are not really applicable. The results 
should be used with caution.
Fitting to a Multivariate Function
A multivariate function is a function having more than one independent variable. This might arise if you 
have measured data over some two-dimensional area. You might measure surface temperature at a variety 
of locations, resulting in temperature as a function of both X and Y. It might also arise if you are trying to 
find dependencies of a process output on the various inputs, perhaps initial concentrations of reagents, plus 
temperature and pressure. Such a case might have a large number of independent variables.
Fitting a multivariate function is pretty much like fitting to a function with a single independent variable. 
This discussion assumes that you have already read the instructions above for fitting a univariate function.
You can create a new multivariate user-defined function by clicking the New Fit Function button. In the 
Independent Variables list, you would enter more than one variable name. You can use as many indepen-
dent variables as you wish (within generous limits set by the length of a line in the procedure window).
A univariate function usually is written as y = f(x), and the Curve Fitting dialog reflects this in using “Y 
Data” and “X Data” to label the menus where you select the input data.
Multivariate data isn’t so convenient. Functions intended to fit spatial data are often written as z = f(x,y); 
volumetric data may be g = f(x,y,z). Functions of a large number of independent variables are often written 
as y = f(x1,x2,…). To avoid confusion, we just keep the Y Data and X Data labels and use them to mean depen-
dent variable and independent variables.
The principle difference between univariate and multivariate functions is in the selection of input data. If you 
have four or fewer independent variables, you can use a multidimensional wave to hold the Y values. This 
would be appropriate for data measured on a spatial grid, or any other data measured at regularly-spaced 
intervals in each of the independent variables. We refer to data in a multidimensional wave as “gridded data.”

Chapter III-8 — Curve Fitting
III-201
Alternately, you can use a 1D wave to hold the Y values. The independent variables can then be in N 1D 
waves, one wave for each independent variable, or a single N-column matrix wave. The X wave or waves 
must have the same number of rows as the Y wave.
Selecting a Multivariate Function
When the Curve Fitting dialog is first used, multivariate functions are not listed in the Function menu. The 
first thing you must do is to turn on the listing of multivariate functions. You do this by choosing Show Mul-
tivariate Functions from the Function menu. This makes two built-in multivariate functions, poly2D and 
Gauss2D, as well as suitable user-defined functions, appear in the menu.
The Show Multivariate Functions setting is saved in the preferences. Unless you turn it off again, you never 
need select it again.
Now you can select your multivariate function from the menu.
Selecting Fit Data for a Multivariate Function
When you have selected a multivariate function, the Y Data menu is filled with 1D waves and any multidi-
mensional waves that match the number of independent variables required by the fit function.
Selecting X Data for a 1D Y Data Wave
If your Y data are in a 1D wave, you must select an X wave for each independent variable. There is no way to 
store X scaling data in the Y wave for more than one independent variable, so there is no _calculated_ item.
With a 1D wave selected in the Y Data menu, the X Data menu lists both 1D waves and 2D waves with N 
columns for a function with N independent variables.
As you select X waves, the wave names are transferred to a list below the menu. When you have selected 
the right number of waves the X Data menu is disabled. The order in which you select the X waves is 
important. The first selected wave gives values for the first independent variable, etc.
If you need to remove an X Data wave from the list, simply click the wave name and press Backspace (Win-
dows) or Delete (Macintosh). To change the order of X Data waves, select one or more waves in the list and 
drag them into the proper order.
Selecting X Data for Gridded Y Data
When you select a multidimensional Y wave, the independent variable values can come from the dimen-
sion scaling of the Y wave or from 1D waves containing values for the associated dimensions of the Y wave. 
That is, if you have a 2D matrix Y wave, you could select a wave to give values for the X dimension and a 
wave to give values for the Y dimension. The Independent Variable menus list only waves that match the 
given dimension of the Y wave.s
Fitting a Subrange of the Data for a Multivariate Function
Selecting a subrange of data for a 1D Y wave is just like selecting a subrange for a univariate function. 
Simply enter point numbers in the Start and End range boxes in the Data Options tab.
If you are fitting gridded Y data, the Data Options tab displays eight boxes to set start and end ranges for 
each dimension of a multidimensional wave. Enter row, column, layer or chunk numbers in these boxes:
If your Y wave is a matrix wave displayed in a graph as an image, you can use the cursors to select a subset 
of the data. With the graph as the target window, clicking the Cursors button will enter text in the range 
boxes to do this.
Using cursors with a contour plot is not straightforward, and the dialog does not support it.
You can also select data subranges using a data mask wave (see Using a Mask Wave on page III-198). The 
data mask wave must have the same number of points and dimensions as the Y Data wave.
