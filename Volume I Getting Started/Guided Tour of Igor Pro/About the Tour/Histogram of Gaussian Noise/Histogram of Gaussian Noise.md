# Histogram of Gaussian Noise

Chapter I-2 — Guided Tour of Igor Pro
I-54
10.
Click the Do It button.
A graph is created showing the histogram results. Next we will touch it up a bit.
11.
Double-click the trace in the graph.
The Modify Trace Appearance dialog appears.
"Left" is selected in the Axis pop-up menu in the top/left corner of the dialog indicating that changes 
made in the dialog will affect the left axis.
12.
Choose “Sticks to zero” from the Mode pop-up menu and click Do It.
The graph is redrawn using the new display mode.
13.
Double-click one of the tick mark labels (e.g., “100) of the left axis.
The Modify Axis dialog appears, showing the Axis Range tab.
14.
From the two pop-up menus in the Autoscale Settings area, choose “Round to nice values” and 
“Autoscale from zero”.
15.
Choose Bottom from the Axis pop-up menu.
16.
From the two pop-up menus in the Autoscale Settings area, choose “Round to nice values” and 
“Symmetric about zero”.
17.
Click the Do It button.
The graph should now look like this:
Saving Your Work - Tour 3A
1.
Choose the FileSave Experiment As menu item.
2.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
3.
Type “Tour 3A.pxp” in the name box and click Save.
Histogram of Gaussian Noise
Now we'll do another histogram, this time with Gaussian noise.
1.
Type the following in the command line and then press Return or Enter:
fakeY = gnoise(1)
2.
Choose the AnalysisHistogram menu item.
The dialog should still be correctly set up from the last time.
