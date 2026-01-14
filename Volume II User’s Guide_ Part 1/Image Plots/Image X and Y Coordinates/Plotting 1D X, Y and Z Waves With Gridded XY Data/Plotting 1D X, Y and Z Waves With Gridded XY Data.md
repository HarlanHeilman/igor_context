# Plotting 1D X, Y and Z Waves With Gridded XY Data

Chapter II-16 — Image Plots
II-390
To do this, you must create new X and Y waves to specify the image rectangle edges. The new X wave must 
have one more point than the matrix wave has rows and the new Y wave must have one more point than 
the matrix wave has columns.
A set of image rectangle centers does not uniquely determine the rectangle edges. To see this, think of a 1x1 
image centered at (0,0). Where are the edges? They could be anywhere.
Without additional information, the best you can do is to generate a set of plausible edges, as we do with 
this function:
Function MakeEdgesWave(centers, edgesWave)
Wave centers
// Input
Wave edgesWave
// Receives output
Variable N=numpnts(centers)
Redimension/N=(N+1) edgesWave
edgesWave[0]=centers[0]-0.5*(centers[1]-centers[0])
edgesWave[N]=centers[N-1]+0.5*(centers[N-1]-centers[N-2])
edgesWave[1,N-1]=centers[p]-0.5*(centers[p]-centers[p-1])
End
This function demonstrates the use of MakeEdgesWave:
Function DemoPlotXYZAsImage()
Make/O mat={{0,1,2},{2,3,4},{3,4,5}}
// Matrix containing Z values
Make/O centersX = {1, 2.5, 5}
// X centers wave
Make/O centersY = {300, 400, 600}
// Y centers wave
Make/O edgesX; MakeEdgesWave(centersX, edgesX)
// Create X edges wave
Make/O edgesY; MakeEdgesWave(centersY, edgesY)
// Create Y edges wave
Display; AppendImage mat vs {edgesX,edgesY}
End
If you have additional information that allows you to create edge waves you should do so. Otherwise you 
can use the MakeEdgesWave function above to create plausible edge waves.
Plotting 1D X, Y and Z Waves With Gridded XY Data
In this case we have 1D X, Y and Z waves of equal length that define a set of points in XYZ space. The X and 
Y waves constitute an evenly-spaced sampling grid though the spacing in X may be different from the 
spacing in Y.
A good way to display such data is to create a scatter plot with color set as a function of the Z data. See 
Setting Trace Properties from an Auxiliary (Z) Wave on page II-298.
It is also possible to transform your data so it can be plotted as an image, as described under Plotting a 2D 
Z Wave With 1D X and Y Center Data. To do this you must convert your 1D Z wave into a 2D matrix wave 
and then convert your X and Y waves to contain the horizontal an vertical centers of your pixels.
For example, we start with this X, Y and Z data:
Make/O centersX = {1,2,3,1,2,3,1,2,3}
Make/O centersY = {5,5,5,7,7,7,9,9,9}
Make/O zData = {1,2,3,4,5,6,7,8,9}
If we display the X and Y data in a graph we can see that the X and Y waves exhibit repeating patterns:
