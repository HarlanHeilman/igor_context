# How to Use Contour Plot Preferences

Chapter II-15 — Contour Plots
II-381
Contour Axis Preferences
Only settings for axes used by the contour plot are captured. Axes used solely for an XY, category, or image 
plot are not captured when the Contour Plots category is selected.
The contour axis preferences are applied only when axes having the same name as the captured axis are 
created by AppendMatrixContour or AppendXYZContour commands. If the axes existed before those com-
mands are executed, they are not affected by the axis preferences. The names of captured contour axes are 
listed in the X Axis and Y Axis pop-up menus of the New Contour Plot and Append Contour Plot dialogs. 
This is similar to the way XY plot axis preferences work.
You can capture contour axis settings for the standard left and bottom axes, and Igor will save these sepa-
rately from left and bottom axis preferences captured for XY, category, and image plots. Igor will use the 
contour axis settings for AppendMatrixContour or AppendXYZContour commands only.
How to Use Contour Plot Preferences
Here is our recommended strategy for using contour preferences:
1.
Create a new graph containing a single contour plot. If you want to capture the triangulation and 
interpolation settings, you must make an XYZ contour plot. Use the axes you will want for a con-
tour plot.
2.
Use the Modify Contour Appearance dialog and the Modify Axis dialog to make the contour plot 
appear as you prefer.
3.
Choose GraphCapture Graph Prefs, select the Contour Plots category, and click Capture Prefs.
