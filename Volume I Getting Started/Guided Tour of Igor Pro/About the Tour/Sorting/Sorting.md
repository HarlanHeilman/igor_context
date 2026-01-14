# Sorting

Chapter I-2 — Guided Tour of Igor Pro
I-48
More Curve Fitting to a Gaussian
The Quick Fit menu provides easy access to curve fitting using the built-in fit functions, with a limited set of 
options, to fit data displayed in a graph. You may want more options. For that you must use the Curve Fitting 
dialog.
1.
Choose the AnalysisCurve Fitting menu item.
The Curve Fitting dialog appears.
2.
Click the Function and Data tab.
3.
From the Function pop-up menu, choose gauss.
4.
From the Y Data pop-up menu, choose fakeY.
5.
From the X Data pop-up menu, choose fakeX.
6.
Click the Data Options tab.
The Weighting and Data Mask pop-up menus should read “_none_”.
7.
Click the Output Options tab.
The Destination pop-up menu should read “_auto_” and Residual should read “_none_”.
8.
Click Do It.
During the fit a Curve Fit progress window appears. After a few passes the fit is finished and Igor waits 
for you to click OK in the progress window.
9.
Click OK.
The curve fit results are printed in the history. They are the same as in the previous section.
Sorting
In the next section we will do a curve fit to a subrange of the data. For this to work, the data must be sorted 
by X values.
1.
Double-click one of the open circle markers in the graph.
The Modify Traces Appearance dialog appears with fakeY selected. If fakeY is not selected, click it.
2.
From the Mode pop-up choose Lines between points and click Do It.
The fakeY trace reverts to a rat’s nest of lines.
3.
Choose the AnalysisSort menu item.
The Sorting dialog appears.
4.
If necessary choose Sort from the Operation pop-up menu.
5.
Select “fakeX” in the Key Wave list and both “fakeX” and “fakeY” in the Waves to Sort list.
This will sort both fakeX and fakeY using fakeX as the sort key.
6.
Uncheck any checkboxes in the dialog that are checked, including the Display Output In checkbox.
7.
Click Do It.
The rat’s nest is untangled. Since we were using the lines between points mode just to show the results of 
the sort, we now switch back to open circles.
8.
Press Control and click (Macintosh) or right-click (Windows) on the fakeY trace (the jagged one).
A pop-up menu appears with the name of the trace at the top. If it is not “Browse fakeY” try again.
9.
Choose Markers from the Mode submenu.
