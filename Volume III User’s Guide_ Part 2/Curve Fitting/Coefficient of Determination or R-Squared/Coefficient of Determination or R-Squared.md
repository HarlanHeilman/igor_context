# Coefficient of Determination or R-Squared

Chapter III-8 — Curve Fitting
III-221
Duplicate yData, residuals_exp
residuals_exp = yData - fit_yData_exp(xData)
// Do polynomial fit with auto-trace
CurveFit poly 3, yData /X=xData /D
Rename fit_yData fit_yData_poly3
// Find polynomial residuals
Duplicate yData, residuals_poly3
residuals_poly3 = yData - fit_yData_poly3(xData)
Calculating model values by interpolating in the auto trace wave may not be sufficiently accurate. Instead, 
you can calculate the exact value using the actual fitting expression. When the fit finishes, it prints the equa-
tion for the fit in the history. With a little bit of editing you can create a wave assignment for calculating 
residuals. Here are the assignments from the history for the above fits:
fit_yData= poly(W_coef,x)
fit_yData= W_coef[0]+W_coef[1]*exp(-W_coef[2]*x)
We can convert these into residuals calculations like this:
residuals_poly3 = yData - poly(W_coef,xData)
residuals_exp = yData - (W_coef[0]+W_coef[1]*exp(-W_coef[2]*xData))
Note that we replaced “x” with “xData” because we have tabulated x values. If we had been fitting equally 
spaced data then we would not have had a wave of tabulated x values and would have left the “x” alone.
This technique for calculating residuals can also be used if you create and use an explicit destination wave. 
In this case the residuals are simply the difference between the data and the destination wave. For example, 
we could have done the exp fit and residual calculations as follows:
Duplicate yData, yDataExpFit,residuals_exp
// explicit destination wave using /D=wave
CurveFit exp yData /X=xData /D=yDataExpFit
residuals_exp = yData - yDataExpFit
Coefficient of Determination or R-Squared
When you do a line fit, y = a + bx, Igor prints a variety of statistics, including "r-squared", also known as the 
"coefficient of determination". The value of r-squared is stored in the automatically-created variable V_r2.
The literature on regression shows differences of opinion on the interpretation of r-squared. Because it is 
commonly reported, Igor provides the value.
There are two ways to compute r-squared that reflect slightly different interpretations:
(1)
(2)
where
 
(3 - total sum of squares)
r 2 = 1−SSres
SStot
r 2 =
SSreg
SStot
SStot =
(yi −y)2
i=1
n
∑
