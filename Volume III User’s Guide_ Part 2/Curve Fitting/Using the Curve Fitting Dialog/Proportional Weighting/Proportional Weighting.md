# Proportional Weighting

Chapter III-8 — Curve Fitting
III-199
Weighting
You may provide a weighting wave if you want to assign greater or lesser importance to certain data points. 
You would do so for one of two reasons:
•
To get a better, more accurate fit.
•
To get more accurate error estimates for the fit coefficients.
The weighting wave is used in the calculation of chi-square. chi-square is defined as
where y is a fitted value for a given point, yi is the original data value for the point and wi is the standard 
error for the point. The weighting wave provides the wi values. The values in the weighting wave can be 
either 1/i or simply i, where i is the standard deviation for each data value. If necessary, Igor takes the 
inverse of the weighting value before using it to perform the weighting.
You specify the wave containing your weighting values by choosing it from the Weighting menu in the 
Data Options tab. In addition you must specify whether your wave has standard deviations or inverse stan-
dard deviations in it. You do this by selecting one of the buttons below the menu:
•
Standard Deviations
•
1/Standard Deviations
Usually you would use standard deviations. Inverse standard deviations are permitted for historical reasons.
There are several ways in which you might obtain values for i. For example, you might have a priori knowl-
edge about the measurement process. If your data points are average values derived from repeated mea-
surements, then the appropriate weight value is the standard error. That is the standard deviation of the 
repeated measurements divided by N1/2. This assumes that your measurement errors are normally distrib-
uted with zero mean.
If your data are the result of counting, such as a histogram or a multichannel detector, the appropriate 
weighting is 
. This formula, however, makes infinite weighting for zero values, which isn’t correct and 
will eliminate those points from the fit. It is common to substitute a value of 1 for the weights for zero points.
You can use a value of zero to completely exclude a given point from the fit process, but it is better to use a 
data mask wave for this purpose.
If you do not provide a weighting wave, then unity weights are used in the fit and the covariance matrix is 
normalized based on the assumption that the fit function is a good description of the data. The reported 
errors for the coefficients are calculated as the square root of the diagonal elements of the covariance matrix 
and therefore the normalization process will provide valid error estimates only if all the data points have 
roughly equal errors and if the fit function is, in fact, appropriate to the data.
If you do provide a weighting wave then the covariance matrix is not normalized and the accuracy of the 
reported coefficient errors rests on the accuracy of your weighting values. For this reason you should not 
use arbitrary values for the weights.
Proportional Weighting
In some cases, it is desirable to use weighting but you know only proportional weights, not absolute mea-
surement errors. In this case, you can use weighting and after the fit is done, calculate reduced chi-square. 
The reduced chi-square can be used to adjust the reported error estimates for the fit coefficients. When you 
do this, the resulting reduced chi-square cannot be used to test goodness of fit.
For example, a data set having Gaussian errors that are proportional to X:
Make data = exp(-x/10) + gnoise((x+1)/1000)
Display data
y
yi
–
wi
------------




2
i
y


