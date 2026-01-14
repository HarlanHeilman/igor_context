# Format of a Multivariate Fitting Function

Chapter III-8 — Curve Fitting
III-255
Variable i
Variable numPeaks = floor((numpnts(w)-1)/3)
Variable cfi
for (i = 0; i < numPeaks; i += 1)
cfi = 3*i+1
returnValue += w[cfi]*exp(-((x-w[cfi+1])/w[cfi+2])^2)
endfor
return returnValue
End
Format of a Multivariate Fitting Function
A multivariate fitting function has the same form as a univariate function, but has more than one indepen-
dent variable:
Function F(w, x1, x2, ...) : FitFunc
WAVE w;
Variable x1
Variable x2
Variable ...
<body of function>
<return statement>
End
A function to fit a planar trend to a data set could look like this:
Function Plane(w, x1, x2) : FitFunc
WAVE w
Variable x1, x2
return w[0] + w[1]*x1 + w[2]*x2
End
There is no limit on the number of independent variables, with the exception that the entire Function dec-
laration line must fit within a single command line of 2500 bytes.
The New Fit Function dialog will add the same comments to a multivariate fit function as it does to a basic 
fit function. The Plane() function above might look like this (we have truncated the first two special 
comment lines to make them fit):
Function Plane(w,x1,x2) : FitFunc
WAVE w
Variable x1
Variable x2
//CurveFitDialog/ These comments were created by the Curve...
//CurveFitDialog/ make the function less convenient to work...
//CurveFitDialog/ Equation:
//CurveFitDialog/ f(x1,x2) = A + B*x1 + C*x2
//CurveFitDialog/ End of Equation
//CurveFitDialog/ Independent Variables 2
//CurveFitDialog/ x1
//CurveFitDialog/ x2
//CurveFitDialog/ Coefficients 3
//CurveFitDialog/ w[0] = A
//CurveFitDialog/ w[1] = B
//CurveFitDialog/ w[2] = C
return w[0] + w[1]*x1 + w[2]*x2
End
Each peak takes three coefficients: 
amplitude, x position and width.
Loop over the peaks, 
calculating them one at a time.
Calculate index of amplitude for this peak.
Expression of a single Gaussian peak.
Each peak is added to the result.
