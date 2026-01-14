# Extrapolating a Fit After the Fit is Done

Chapter I-2 — Guided Tour of Igor Pro
I-50
7.
Choose AnalysisQuick Fitgauss.
Note that the fit curve is evaluated only over the subrange identified by the cursors.
We would like the fit trace to extend over the entire X range, while fitting only to the data between 
the cursors. This is one of the options available only in the Curve Fitting dialog.
8.
Choose AnalysisCurve Fitting and then click the Function and Data tab.
The curve fitting dialog appears and the settings should be as you left them. Check that the function 
type is gauss, the X data is fakeY, the X data is fakeX.
9.
Click the Data Options tab.
10.
Click the Cursors button in the Range area.
This puts the text “pcsr(A)” and “pcsr(B)” in the range entry boxes.
pcsr is a function that returns the wave point number at the cursor position.
11.
Select the Output Options tab and click the X Range Full Width of Graph checkbox to check it.
12.
Click Do It.
The curve fit starts, does a few passes and waits for you to click OK.
13.
Click OK.
The fit was done using only the data between the cursors, but the fit trace extends over the entire X 
range.
In the next section, we need the short version of the fit curve, so we will simply do the fit again:
14.
Choose AnalysisQuick Fitgauss.
Extrapolating a Fit After the Fit is Done
When you used the Quick Fit menu, and when you chose “_auto_” from the Destination pop-up menu in the 
Curve Fitting dialog, Igor created a wave named fit_fakeY to show the fit results. This is called the "fit desti-
nation wave." It is just an ordinary wave whose X scaling is set to the extent of the X values used in the fit.
In the preceding sections you learned how to make the curve fit operation extrapolate the fit curve beyond 
the subrange. Here we show you how to do this manually to illustrate some important wave concepts.
To extrapolate, we simply change the X scaling of fit_fakeY and re-execute the fit destination wave assign-
ment statement which the CurveFit operation put in the history area.
