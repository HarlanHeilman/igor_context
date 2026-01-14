# Gizmo Surface Plot Tour

Chapter II-17 — 3D Graphics
II-410
Gizmo Surface Plot Tour
In this tour we will create a 2D wave containing Z values which we will plot as a surface plot.
1.
Start a new experiment by choosing FileNew Experiment.
2.
To create a 2D matrix of Z values, execute:
Make/O/N=(100,100) data2D = Gauss(x,50,10,y,50,15)
This matrix data represents Z values on a regular grid.
As you saw in the first tour, the quickest way to display this data in Gizmo is by right-clicking an 
appropriate wave in the Data Browser and selecting Gizmo Plot. The same shortcut works with 
a matrix of Z values. But we will do it the hard way as this will give you a better understanding 
of Gizmo.
3.
Choose WindowsNew3D Plot.
Notice from the history area of the command window that Igor has executed:
NewGizmo
Igor also created an empty Gizmo0 window and the Gizmo0 Info window.
4.
Click the + icon at the bottom of the object list in the Gizmo0 Info window and choose Surface.
Igor displays the Surface Properties dialog.
5.
Choose Matrix from the Source Wave Type pop-up menu and data2D from the Surface Wave 
pop-up menu.
There are several additional options but we will leave them in their default states for now.
6.
Click Do It.
Igor created a surface object named surface0 and added it to the object list in the info window. It 
is not yet visible in the Gizmo0 window because we have not yet added it to the display list.
7.
Drag the surface0 object from the object list to the display list.
The surface appears in the Gizmo0 window. You are now looking at it from the top.
8.
Using the mouse, rotate the surface in the Gizmo0 window to reorient it so you can see the side 
view of the Gaussian peak.
9.
In the Gizmo info window, click the "+" icon at the bottom of the object list and choose Axes.
The Axes Properties dialog appears. Click the Axis tab if it is not already selected.
10.
Click the Axis tab if it is not already selected.
The Axis Type pop-up menu should be set to Box and all of the axis checkboxes (X0, X1...Z2, Z3) 
should be checked.
11.
1Click Do It.
Igor created an axis object named axes0 and added it to the object list in the info window. It is not 
yet visible in the Gizmo0 window because we have not yet added it to the display list.
12.
Drag the axes0 object from the object list to the display list.
You now have box axes around the surface plot.
13.
Double-click the axes0 object in the display list. Using the resulting Axes Properties dialog, 
turn on tick marks and tick mark labels for the X0, Y0 and Z0 axes.
This is the same as what we did in the preceding tour.
Now we will add a colorscale annotation.
14.
Choose GizmoAdd Annotation.
The Add Annotation dialog appears.
15.
From the Annotation pop-up menu in the top/left corner of the dialog, choose ColorScale.
16.
Click the Position tab and set the Anchor pop-up menu to Right Center.
