# Gridded Data

Chapter II-15 — Contour Plots
II-366
Overview
A contour plot is a two-dimensional XY plot of a three-dimensional XYZ surface showing lines where the 
surface intersects planes of constant elevation (Z).
One common example is a contour map of geographical terrain showing lines of constant altitude, but 
contour plots are also used to show lines of constant density or brightness, such as in X-ray or CT images, 
or to show lines of constant gravity or electric potential.
Contour Data
The contour plot is appropriate for data sets of the form:
z= f(x,y)
meaning there is only one Z value for each XY pair. This rules out 3D shapes such as spheres, for example.
You can create contour plots from two kinds of data:
•
Gridded data stored in a matrix
•
XYZ triplets
Gridded Data
Gridded data is stored in a 2D wave, or “matrix wave”. By itself, the matrix wave defines a regular XY grid. 
The X and Y coordinates for the grid lines are set by the matrix wave’s row X scaling and column Y scaling.
You can also provide optional 1D waves that specify coordinates for the X or Y grid lines, producing a non-
linear rectangular grid like the one shown here. The dots mark XY coordinates specified by the 1D waves:
-1.0
-0.5
0.0
0.5
1.0
μm
-1.0
-0.5
0.0
0.5
1.0
μm
 14.5 
 14 
 14 
 13.5 
 13.5 
 13.25 
 13.25 
 13 
 12.75 
 12.75 
 12.75 
 12.5 
 12.5
