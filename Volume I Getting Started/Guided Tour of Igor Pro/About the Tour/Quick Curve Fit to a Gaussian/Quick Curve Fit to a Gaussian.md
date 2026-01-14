# Quick Curve Fit to a Gaussian

Chapter I-2 — Guided Tour of Igor Pro
I-47
12.
Click Do It.
Now the graph makes sense.
Quick Curve Fit to a Gaussian
Our synthetic data was generated using a Gaussian function so let’s try to extract the original parameters 
by fitting to a Gaussian of the form:
y = y0 + A*exp(-((x-x0)/width)^2)
Here y0, A, x0 and width are the parameters of the fit.
1.
Choose the AnalysisQuick Fitgauss menu item.
Igor generated and executed a CurveFit command which you can see if you scroll up a bit in the his-
tory area of the command window. The CurveFit command performed the fit, appended a fit result 
trace to the graph, and reported results in the history area.
At the bottom of the reported results we see the values found for the fit parameters. The amplitude 
parameter (A) should be 1.0 and the position parameter (x0) should be 4.0. We got 0.99222 ± 0.0299 for 
the amplitude and 3.9997 ± 0.023 for the position.
Let’s add this information to the graph.
2.
Choose AnalysisQuick FitTextbox Preferences.
The Curve Fit Textbox Preferences dialog appears.
You can add a textbox containing curve fit results to your graph. The Curve Fit Textbox Preference 
dialog has a checkbox for each component of information that can be included in the textbox.
3.
Click the Display Curve Fit Info Textbox checkbox to check it and then click OK.
You have specified that you want an info textbox. This will affect future Quick Fit operations.
4.
Choose AnalysisQuick Fitgauss again.
This time, Igor displays a textbox with the curve fit results. Once the textbox is made, it is just a textbox 
and you can double-click it and change it. But if you redo the fit, your changes will be lost unless you 
rename the textbox.
That textbox is nice, but it’s too big. Let’s get rid of it.
You could just double-click the textbox and click Delete in the Modify Annotation dialog. The next time 
you do a Quick Fit you would still get the textbox unless you turn the textbox feature off.
5.
Choose AnalysisQuick FitTextbox Preferences again. Click the Display Curve Fit Info Textbox 
checkbox to uncheck it. Click OK.
6.
Choose AnalysisQuick Fitgauss again.
The textbox is removed from the graph.
