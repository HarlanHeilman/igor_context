# Curve Fit of Histogram Data

Chapter I-2 — Guided Tour of Igor Pro
I-55
3.
Click the radio button labeled “Auto-set bins: 3.49*Sdev*N^-1/3”.
The information text at the bottom of the Destination Bins box tells you that the histogram will have 
48 bins.
This is a method by Sturges for selecting a “good” number of bins for a histogram. See the Histogram 
operation on page V-349 for a reference.
4.
Click the Bin-Centered X Values checkbox to check it.
By default, the Histogram operation sets the X scaling of the output wave such that the X values are at the 
left edge of each bin, and the right edge is given by the next X value. This makes a nice bar plot.
In the next section you will do a curve fit to the histogram. For curve fitting you need X values that 
represent the center of each bin.
5.
Click the Create Square Root(N) Wave checkbox to check it.
Counting data, such as a histogram, usually has Poisson-distributed values. The estimated mean of 
the Poisson distribution is simply the number of counts (N) and the estimated standard deviation is 
the square root of N.
The curve fit will be biased if this is not taken into account. You will use this extra wave for weighting 
when you do the curve fit.
6.
Click the Do It button.
Note that the histogram output as shown in Graph0 has a Gaussian shape, as you would expect since 
the histogram input was noise with a Gaussian distribution.
7.
Choose DataData Browser.
The Data Browser shows you the waves and variables in your experiment. You should see three 
waves now: fakeY, fakeY_Hist, and W_SqrtN. FakeY_Hist contains the output of the Histogram oper-
ation and W_SqrtN is the wave created by the Histogram operation to receive the square root of N 
data.
8.
Close the Data Browser.
9.
Click Graph0 and then double-click the trace to invoke the Modify Trace Appearance dialog.
10.
Select Markers from the Mode menu, then select the open circle marker.
11.
Click the Error Bars checkbox.
The Error Bars dialog appears.
12.
Select “+/- wave” from the Y Error Bars menu.
13.
Pop up the Y+ menu and select W_SqrtN.
Note that the Y- menu is set to Same as Y+. You could now select another wave from the Y- menu if 
you needed asymmetric error bars.
14.
Click OK, then Do It.
Saving Your Work - Tour 3B
1.
Choose the FileSave Experiment As menu item.
2.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
3.
Type “Tour 3B.pxp” in the name box and click Save.
Curve Fit of Histogram Data
The previous section produces all the pieces required to fit a Gaussian to the histogram data, with proper 
weighting to account for the variance of Poisson-distributed data.
1.
Click the graph to make sure it is the target window.

Chapter I-2 — Guided Tour of Igor Pro
I-56
2.
In the AnalysisQuick Fit menu make sure the Weight from Error Bar Wave item is checked. If it 
is not, select it to check it.
3.
Choose AnalysisQuick Fitgauss.
The graph now looks like this:
As shown in the history area, the fit results are:
Coefficient values ± one standard deviation
y0 
=-0.35284 ± 0.513
A 
=644.85 ± 7.99
x0 
=-0.0014111 ± 0.00997
width
=1.406 ± 0.0118
The original data was made with a standard deviation of 1. Why is the width 1.406? The way Igor 
defines its gauss fit function, width is sigma*21/2.
4.
Execute this command in the command line:
Print 1.406/sqrt(2)
The result, 0.994192, is pretty close to 1.0.
It is often useful to plot the residuals from a fit to check for various kinds of problems. For that you 
need to use the Curve Fitting dialog.
5.
Choose AnalysisCurve Fitting.
6.
Click the Function and Data tab and choose gauss from the Function menu.
7.
Choose fakeY_Hist (not fakeY) from the Y Data menu.
8.
Leave the X Data pop-up menu set to “_calculated_”.
9.
Click the Data Options tab. If there is text in the Start or End Range boxes, click the Clear button 
in the Range section.
10.
Choose W_SqrtN from the Weighting pop-up menu.
11.
Just under the Weighting pop-up menu there are two radio buttons. Click the top one which is 
labeled “Standard Dev”.
12.
Click the Output Options tab and choose “_auto_” from the Destination pop-up menu.
13.
Set the Residual pop-up menu to “_auto trace_”.
Residuals will be calculated automatically and added to the curve fit in our graph.
14.
Uncheck the X Range Full Width of Graph checkbox.
This is appropriate only when we are fitting to a subset of the source wave.
