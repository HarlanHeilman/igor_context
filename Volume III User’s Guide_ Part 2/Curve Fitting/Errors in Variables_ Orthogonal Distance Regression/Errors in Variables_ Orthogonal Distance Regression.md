# Errors in Variables: Orthogonal Distance Regression

Chapter III-8 — Curve Fitting
III-236
try
CurveFit/N/Q line, test; AbortOnRTE
catch
if (V_AbortCode == -4)
Print "Error during curve fit:"
Variable cfError = GetRTError(1)
// 1 to clear the error
Print GetErrMessage(cfError,3)
endif
endtry
End
If you run this function, the output is:
 Error during curve fit:
 You must have at least as many data points as fit parameters.
No error alert is presented because of the call to GetRTError. The error is reported to the user by getting the 
error message using GetRTErrMessage and then printing the message to the history area.
V_FitIterStart
V_FitIterStart provides a way for a user-defined function to know when the fitting routines are about to 
start a new iteration. The original, obsolete purpose of this is to allow for possible efficient computation of 
user-defined fit functions that involve convolution. Such functions should now use all-at-once fit functions. 
See All-At-Once Fitting Functions on page III-256 for details.
S_Info
If you create a string variable in a function that calls CurveFit or Funcfit, Igor will fill it with keyword-value 
pairs giving information about the fit:
Use StringByKey to get the information from the string. You should set keySepStr to "=" and listSepStr to 
";".
Errors in Variables: Orthogonal Distance Regression
When you fit a model to data, it is usually assumed that all errors are in the dependent variable, and that 
independent variables are known perfectly (that is, X is set perfectly and Y is measured with error). This 
assumption is often not far from true, and as long as the errors in the dependent variable are much larger 
than those for the independent variable, it will not usually cause much difference to the curve fit.
When the errors are normally distributed with zero mean and constant variance, and the model is exact, 
then the standard least-squares fit gives the maximum-likelihood solution. This is the technique described 
earlier (see Overview of Curve Fitting on page III-179).
Keyword
Information Following Keyword
DATE
The date of the fit.
TIME
The time of day of the fit.
FUNCTION
The name of the fitting function.
AUTODESTWAVE
If you used the /D parameter flag to request an autodestination wave, this 
keyword gives the name of the wave.
YDATA
The name of the Y data wave.
XDATA
A comma-separated list of X data waves, or "_calculated_" if there were no 
X waves. In most cases there is just one X wave.
