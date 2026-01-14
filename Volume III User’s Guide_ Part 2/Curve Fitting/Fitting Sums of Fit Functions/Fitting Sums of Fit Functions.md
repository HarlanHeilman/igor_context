# Fitting Sums of Fit Functions

Chapter III-8 — Curve Fitting
III-244
It is difficult to compute the model representing the solution, as it requires finding roots of the implicit func-
tion. A quick way to add a smooth model curve to a graph is to fill a matrix with values of the fit function 
at a range of X and Y and then add a contour plot of the matrix to your graph. Then modify the contour plot 
to show only the zero contour.
Here are commands to add a contour of the example function to the graph above:
Make/N=(100,100) ellipseContour
SetScale/I x -3,4.5,ellipseContour
SetScale/I y -.2, 5, ellipseContour
ellipseContour = FitEllipse(ellipseCoefs, x, y)
AppendMatrixContour ellipseContour
ModifyContour ellipseContour labels=0,autoLevels={*,*,0},moreLevels=0,moreLevels={0}
ModifyContour ellipseContour rgbLines=(0,0,0)
Fitting Sums of Fit Functions
Sometimes the appropriate model is a combination, typically a sum, of simpler models. It might be a sum 
of exponential decay functions, or a sum of several different peaks at various locations. Peak fitting can 
3
2
1
0
4
3
2
1
0
-1
-2
3
2
1
0
4
3
2
1
0
-1
-2
