# Gizmo 3D Scatter Plot Tour

Chapter II-17 — 3D Graphics
II-407
3D Waves
A 3D wave, sometimes called a "volume", is an M-row by N-column by L-layer wave where each element 
represents a scalar Z value. To be used in 3D graphics, 3D waves must contain at least two elements in each 
dimension.
3D waves can be displayed as 3D graphics in Surface Plots, Isosurface Plots, and Voxelgram Plots.
(3D waves can also be displayed as 2D graphics in Image Plots where a single layer of a 3D wave is dis-
played as an image.)
Gizmo Overview
Igor's 3D plotting tool is called "Gizmo".
Gizmo is based on OpenGL, an industry standard system for 3D graphics. Gizmo converts Igor data and 
commands into OpenGL data and instructions and displays the result in an Igor window called a "Gizmo 
window".
You create a Gizmo window by choosing WindowsNew3D Plot and then appending graphic objects 
using the Gizmo menu. You can do this without any knowledge of OpenGL. At this level you can create 
surface plots, scatter plots, path plots, voxelgrams, isosurface plots, 3D bar plots and 3D pie charts. Such 
objects are called "wave-based objects" or "data objects" to differentiate them from drawing objects, dis-
cussed next. After creating the basic plot you can modify various properties using Gizmo's "info" window.
Advanced users can also construct graphics using a set of 3D primitives including lines, triangles, quadran-
gles, cubes, spheres, cylinders, disks, tetrahedra and pie wedges. Such objects are called "drawing objects" 
to differentiate them from wave-based objects. If you apply proper scaling you can combine drawing 
objects and wave-based objects in the same Gizmo window.
Gizmo supports advanced OpenGL features such as lighting effects, shininess and textures. Advanced 
users who want to create sophisticated 3D graphics will benefit from some familiarity with 3D graphics in 
general and OpenGL in particular.
System Requirements
Much of Gizmo's operation depends on your computer's graphics hardware and its graphics driver soft-
ware. We suggest running Gizmo on hardware that includes a dedicated graphics card with at least 512MB 
of VRAM. Gizmo should also work on computers with onboard graphics and shared memory but you will 
experience slower performance and may encounter errors when exporting graphics.
Hardware Compatibility
Gizmo graphics may be affected by the version of OpenGL that you are running. This depends on your 
graphics hardware, graphics driver version and graphics acceleration settings.
Gizmo Guided Tour
The tutorials in the following sections will give you a sense of Gizmo's basic capabilities, how you create 
basic Gizmo plots, and the type of data that you need for a given type of plot.
At various points in the tour you are instructed to execute Igor commands. The easiest way to do this is to 
open the “3D Graphics” help file using the HelpHelp Windows submenu and do the tour from the help 
file rather than from this manual. Then you can execute the commands by selecting them in the help file 
and pressing Ctrl-Enter.
Gizmo 3D Scatter Plot Tour
In this tour we will create a triplet wave containing XYZ data which we will plot as a 3D scatter plot.

Chapter II-17 — 3D Graphics
II-408
1.
Start a new experiment by choosing FileNew Experiment.
2.
To create a triplet wave containing XYX scatter data, execute:
Make/O/N=(20,3) data = gnoise(5)
data[][2] = 2*data[p][0] - 3*data[p][1] + data[p][0]^2 + gnoise(0.05)
This scatter data represents random locations in the XY plane with Z values that are approxi-
mately equal to a polynomial function in X and Y.
As we see next, the quickest way to display this data in Gizmo is by right-click selecting "Gizmo 
Plot" in the Data Browser.
3.
Choose DataData Browser.
The Data Browser window appears.
4.
Right-click the data wave icon and choose New Gizmo Plot.
Igor created a Gizmo 3D scatter plot from the data wave in a new window named Gizmo0.
It also created the Gizmo info window entitled "Gizmo0 Info".
(If you don't see the "Gizmo0 Info" window, choose GizmoShow Info.)
You can rotate the Gizmo scatter plot by dragging the contents of the Gizmo0 window and using 
the arrow keys. Feel free to play.
...
That was entirely too easy and not very instructive so we will redo it without using the Data 
Browser shortcut.
5.
Start a new experiment by choosing FileNew Experiment.
6.
To create a triplet wave containing XYX scatter data, execute:
Make/O/N=(20,3) data = gnoise(5)
data[][2] = 2*data[p][0] - 3*data[p][1] + data[p][0]^2 + gnoise(0.05)
7.
Choose WindowsNew3D Plot.
Notice from the history area of the command window that Igor has executed:
NewGizmo
Igor also created an empty Gizmo0 window and the Gizmo0 Info window.
(If you don't see the "Gizmo0 Info" window, choose GizmoShow Info.)
8.
Click the + icon at the bottom of the object list in the Gizmo0 Info window and choose Scatter.
Igor displays the Scatter Properties dialog.
9.
Choose data from the Scatter Wave menu.
This menu displays only triplet waves. If you want to create a 3D scatter plot, you must have a 
triplet wave.
There are several additional options but we will leave them in their default states for now.
10.
Click Do It.
Igor created a 3D scatter object named scatter0 and added it to the object list in the info window. 
It is not yet visible in the Gizmo0 window because we have not yet added it to the display list.
11.
Drag the scatter0 object from the object list to the display list.
Spheres representing the XYZ data appear in the Gizmo0 window. Although the plot is by no 
means complete, you can click and drag the body of the Gizmo0 window to rotate the display.
12.
In the Gizmo0 Info window, click the "+" icon at the bottom of the object list and choose Axes.
The Axes Properties dialog appears.
13.
Click the Axis tab if it is not already selected.
The Axis Type pop-up menu should be set to Box and all of the axis checkboxes (X0, X1...Z2, Z3) 
should be checked.

Chapter II-17 — 3D Graphics
II-409
14.
Click Do It.
Igor created an axes object named axes0 and added it to the object list in the info window. It is 
not yet visible in the Gizmo0 window because we have not yet added it to the display list.
15.
Drag the axes0 object from the object list to the display list.
You now have box axes around the scatter spheres.
16.
Double-click the axes0 object in either the object list or the display list.
The Axes Properties dialog reopens.
17.
Click the Ticks and Labels tab.
18.
Select X0 from the Axis pop-up menu and check the Show Tick Marks and Show Numerical 
Labels checkboxes.
19.
Select Y0 from the Axis pop-up menu and check the Show Tick Marks and Show Numerical 
Labels checkboxes.
20.
Select Z0 from the Axis pop-up menu and check the Show Tick Marks and Show Numerical 
Labels checkboxes.
21.
Click Do It.
You now have labeled tick marks for the X0, Y0 and Z0 axes.
But which axis is which?
22.
Right-click the body of the Gizmo0 window and select Show Axis Cue.
Igor adds an axis cue that shows you which dimension is which.
Rotate the display a bit to get a sense of the axis cue.
You can also double click the axes0 object and select the Axis tab. The properties dialog displays 
the box axes. If you now hover with the mouse cursor over any axis you see a tooltip that identi-
fies the axis.
23.
Click the close box of the Gizmo0 Info window.
The Gizmo0 Info window is hidden. It is usually of interest while you are constructing or tweak-
ing a 3D plot and can be hidden when you just want to view the plot. You can make it visible at 
any time by choosing GizmoShow Info or by right-clicking the Gizmo0 window and choosing 
Show Info Window.
24.
Click the close box of the Gizmo0 window.
Igor displays the Close Window dialog asking if you want to save the window as a window rec-
reation macro. This works the same as a graph recreation macro.
25.
Click the Save button to save the window recreation macro.
The recreation macro is saved in the main procedure window.
26.
Choose WindowsProcedure WindowsProcedure Window.
This displays the main procedure window containing the Gizmo0 recreation macro. You may 
need to scroll up to see the beginning of it which starts with:
Window Gizmo0() : GizmoPlot
27.
Close the procedure window by clicking its close box.
28.
Choose WindowsOther MacrosGizmo0.
Igor executes the Gizmo0 recreation macro which recreates the Gizmo0 window.
29.
Choose FileSave Experiment and save the experiment as "Gizmo 3D Scatter Plot Tour.pxp".
This is just in case you want to revisit the tour later and is not strictly necessary.
At this point, you have completed the construction of a 3D scatter plot. As you may have noticed, there are 
many scatter plot and axis options that we did not explore. You can do that now, by double-clicking the 
scatter0 and axes0 icons in the Gizmo Info window, or you can leave that for later and continue with the 
next section of the tutorial.
