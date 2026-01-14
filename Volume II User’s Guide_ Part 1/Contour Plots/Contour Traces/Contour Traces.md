# Contour Traces

Chapter II-15 — Contour Plots
II-370
See The Color of Contour Traces on page II-371 for further discussion of contour colors.
Show Boundary Checkbox
Click this to generate a trace along the perimeter of the contour data in the XY plane. For a matrix contour plot, 
the perimeter is simply a rectangle enclosing the minimum and maximum X and Y. The perimeter of XYZ 
triplet contours connects the outermost XY points. This trace is updated at the same time as the contour level 
traces.
Show XY Markers Checkbox
Click this to generate a trace that shows the XY locations of the contour data. For a matrix contour plot, the 
locations are by default marked with dots. For XYZ triplet contours, they are shown using markers. As with 
any other contour trace, you can change the mode and marker of this trace with the Modify Trace Appear-
ance dialog. This trace is updated at the same time as the contour level traces.
Fill Contours Checkbox
Click this to fill between contour levels with solid colors. Click the Fill Colors button to adjust the colors in 
the same manner as described under Line Colors Button on page II-369.
Warning: Solid fills can sometimes fail.
You can set the fill and color for individual levels using the Modify Trace Appearance dialog even if the Fill 
Contours checkbox is off.
See Contour Fills on page II-373 for more information.
Show Triangulation Checkbox
Click this to generate a trace that shows the Delaunay triangulation of the contour data. This is available 
only for XYZ triplet contours. This trace is updated at the same time as the contour level traces.
Interpolation Pop-Up Menu
XYZ triplet contours can be interpolated to increase the apparent resolution, resulting in smoother contour 
lines. The interpolation uses the original Delaunay triangulation. Increasing the resolution requires more 
time and memory; settings higher than x16 are recommended only to the very patient.
Contour Traces
Igor creates XY pairs of double-precision waves to contain the contour trace data, and displays them as 
ordinary graph traces. Each trace draws all the curves for one Z level. If a single Z level generates more than 
one contour line, Igor uses a blank (NaN) at the end of each contour line to create a gap between it and the 
following line.
The same method is used to display markers at the data’s XY coordinates, the XY domain’s boundary, and, 
for XYZ triplet contours only, the Delaunay triangulation.
The names of these traces are fabricated from the name of the Z data wave or matrix. See Contour Trace 
Names on page II-371.
One important special property of these waves is that they are private to the graph. These waves do not 
appear in the Data Browser or in any other dialog, and are not accessible from commands. There is a trick 
you can use to copy these waves, however. See Extracting Contour Trace Data on page II-376.
The contour traces, which are the visible manifestation of these private waves, do show up in the Modify 
Trace Appearance dialog, and can be named in commands just like other traces.
There is often no need to bother with the individual traces of a contour plot because the Modify Contour Appear-
ance dialog provides adequate control over the traces for most purposes. However, if you want to distinguish 
one or more contour levels, to make them dashed lines, for example, you can do this by modifying the traces
