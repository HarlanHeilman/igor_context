# Creating a Contour Plot

Chapter II-15 — Contour Plots
II-367
Contouring gridded data is computationally much easier than XYZ triplets and consequently much faster.
XYZ Data
XYZ triplets can be stored in a matrix wave of three columns, or in three separate 1D waves each supplying 
X, Y, or Z values. You must use this format if your Z data does not fall on a rectangular grid. For example, 
you can use the XYZ format for data on a circular grid or for Z values at random X and Y locations.
XYZ contouring involves the generation of a Delaunay triangulation of your data, which takes more time 
than is needed for gridded contouring. You can view the triangulation by selecting the Show Triangulation 
checkbox in the Modify Contour Appearance dialog.
For best results, you should avoid having multiple XYZ triplets with the same X and Y values. If the contour 
data is stored in separate waves, the waves should be the same length.
If your data is in XYZ form and you want to convert it to gridded data, you can use the ContourZ function 
on an XYZ contour plot of your data to produce a matrix wave. The AppendImageToContour procedure in 
the WaveMetrics Procedures folder produces such a matrix wave, and appends it to the top graph as an 
image. Also see the Voronoi parameter of the ImageInterpolate operation on page V-382 for generating an 
interpolated matrix.
Creating a Contour Plot
Contour plots are appended to ordinary graph windows. All the features of graphs apply to contour plots: 
axes, line styles, drawing tools, controls, etc. See Chapter II-13, Graphs.
You can create a contour plot in a new graph window by choosing WindowsNewContour Plot. This 
displays the New Contour Plot dialog. This dialog creates a blank graph to which the plot is appended.
To add a contour plot to an existing graph, choose GraphAppend To GraphContour plot. This displays 
the Append Contour Plot dialog.
You can also use the AppendMatrixContour or AppendXYZContour operations.
You can add a sense of depth to a gridded contour plot by adding an image plot to the same graph. To do 
this, choose Graph-Append To Graph-Image Plot. This displays the Append Image Plot dialog. If your data 
is in XYZ form, use the AppendImageToContour WaveMetrics procedure to create and append an image.
These commands generate a gridded contour plot with an image plot:
Make/O/D/N=(50,50) mat2d
// Make some data to plot
SetScale x,-3,3,mat2d
SetScale y,-3,3,mat2d
mat2d = 3*(1-y)^2 * exp(-((x*(x>0))^2.5) - (y+0.5)^2)
mat2d -= 8*(x/5 - x^3 - y^5) * exp(-x^2-y^2) 
mat2d -= 1/4 * exp(-(x+.5)^2 - y^2)
Display;AppendMatrixContour mat2d
//This creates the contour plot
AppendImage mat2d
