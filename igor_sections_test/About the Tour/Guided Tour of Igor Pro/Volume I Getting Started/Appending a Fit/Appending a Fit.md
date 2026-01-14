# Appending a Fit

Chapter I-2 — Guided Tour of Igor Pro
I-51
1.
Choose the DataChange Wave Scaling menu item.
2.
If you see a button labeled More Options, click it.
3.
From the SetScale Mode pop-up menu, choose Start and End.
4.
Double-click “fit_fakeY” in the list.
This reads in the current X scaling values of fit_fakeY. The starting X value will be about 1.77 and the 
ending X will be about 4.53.
5.
Press Tab until the Start box is selected and enter 1.0.
6.
Tab to the End box and type “8.0”.
7.
Click Do It
The fit_fakeY trace is stretched out and now runs between 1 and 8.
Now we need to calculate new Y values for fit_fakeY using its new X values.
8.
In the history, find the line that starts “fit_fakeY=” and click it.
The entire line is selected. (The line in question is near the top of the curve fit report printed in the 
history.)
9.
Press Return or Enter once to copy the selection from the history to the command line and a second 
time to execute it.
The fit_fakeY wave now contains valid data between 1 and 8.
Appending a Fit
The fit trace added automatically when Igor does a curve fit uses a wave named by adding “fit_” to the start 
of the Y data wave’s name. If you do another fit to the same Y data, that fit curve will be overwritten. If you 
want to show the results of several fits to the same data, you will have to somehow protect the fit destination 
wave from being overwritten. This is done by simply renaming it.
1.
Choose the DataRename menu item.
2.
Double-click the wave named fit_fakeY to move it into the list on the right.
3.
Edit the name in the New Name box to change the name to “gaussFit_fakeY” and click Do It.

Chapter I-2 — Guided Tour of Igor Pro
I-52
4.
Position the A and B cursors to point numbers 35 and 61, respectively.
A quick way to do this is to enter the numbers 35 and 61 in the edit boxes to the right of the cursor 
position control.
5.
Choose AnalysisQuick Fitline.
Because there are two traces on the graph, Quick Fit doesn’t know which one to fit and puts up the 
Which Data Set to Quick Fit dialog.
6.
Select fakeY from the list and click OK.
The line fit is appended to the graph:
This concludes Guided Tour 2.
