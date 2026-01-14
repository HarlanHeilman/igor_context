# Gizmo Surface Using Voronoi Interpolation Tour

Chapter II-17 — 3D Graphics
II-412
Make/O/N=(20,3) data = gnoise(5)
data[][2] = 2*data[p][0] - 3*data[p][1] + data[p][0]^2 + gnoise(0.05)
This scatter data represents random locations in the XY plane with Z values that are approxi-
mately equal to a polynomial function in X and Y.
3.
Choose DataData Browser.
The quickest way to display this data in Gizmo is by right-click selecting "Gizmo Plot" in the Data 
Browser.
4.
Right-click the data wave icon and choose New Gizmo Plot.
Igor created a Gizmo 3D scatter plot from the data wave in a new window named Gizmo0.
5.
In the command line, execute:
CurveFit/Q poly2d 2, data[][2]/X=data[][0,1] /D
Igor performs a 2D polynomial curve fit and produces output waves and variables. The main out-
put is in the wave fit_data.
6.
Close the Data Browser window.
This is just to reduce clutter on your screen.
Next we will now add a surface to the Gizmo plot.
7.
Click the + icon at the bottom of the object list in the Gizmo0 Info window and choose Surface.
Igor displays the Surface Properties dialog.
8.
Choose Matrix from the Source Wave Type pop-up menu and fit_data from the Surface Wave 
pop-up menu.
There are several additional options but we will leave them in their default states for now.
9.
Click Do It.
Igor created a surface object named surface0 and added it to the object list in the info window. It 
is not yet visible in the Gizmo0 window because we have not yet added it to the display list.
10.
Drag the surface0 object from the object list to the display list.
The surface appears in the Gizmo0 window and appears to fit the scatter objects pretty well.
11.
Using the mouse, rotate the contents of the Gizmo plot to inspect the fit from various angles.
12.
Choose FileSave Experiment and save the experiment as "Gizmo 3D Scatter Plot and Fitted 
Surface Tour.pxp".
This is just in case you want to revisit the tour later and is not strictly necessary.
Gizmo Surface Using Voronoi Interpolation Tour
We have already seen how to create a surface plot from a 2D matrix of Z values. In this tour we illustrate 
the how to plot a 3D surface representation of XYZ scatter data. The process involves triangulation of the 
XYZ data using Voronoi interpolation.
1.
Start a new experiment by choosing FileNew Experiment.
2.
To create a triplet wave containing XYZ scatter data, execute:
Make/O/N=(20,3) data = enoise(5)
data[][2] = 2*data[p][0] - 3*data[p][1] + data[p][0]^2 + gnoise(0.05)
3.
Choose DataData Browser.
4.
Right-click the data wave icon and choose New Gizmo Plot.
Igor created a Gizmo 3D scatter plot from the data wave in a new window named Gizmo0.
Next we will triangulate the scatter data using Voronoi interpolation.
