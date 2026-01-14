# Gizmo Windows

Chapter II-17 — 3D Graphics
II-413
5.
Execute this in the command line:
ImageInterpolate/S={-5,0.1,5,-5,0.1,5}/CMSH Voronoi data
The Voronoi interpolation created two waves: M_ScatterMesh and M_InterpolatedImage. M_S-
catterMesh consists of a series of XYZ coordinates that define polygons in 3D space which fit the 
scatter data. We will use M_ScatterMesh to append a surface to the 3D plot.
6.
Click the + icon at the bottom of the object list in the Gizmo0 Info window and choose Surface.
Igor displays the Surface Properties dialog.
7.
Choose Triangles from the Source Wave Type pop-up menu and M_ScatterMesh from the Sur-
face Wave pop-up menu.
There are several additional options but we will leave them in their default states for now.
8.
Click Do It.
Igor created a surface object named surface0 and added it to the object list in the info window. It 
is not yet visible in the Gizmo0 window because we have not yet added it to the display list.
9.
Drag the surface0 object from the object list to the display list.
The surface appears in the Gizmo0 window.
10.
Using the mouse, rotate the contents of the Gizmo plot to inspect the fit from various angles.
The surface fits the scatter objects pretty well.
11.
Double-click the surface0 object in the display list, click the Grid Lines and Points tab, check 
the Draw Grid Lines checkbox, and click Do It.
This shows the polygons created by Voronoi interpolation and represented by the M_Scatter-
Mesh wave.
12.
Clean up by executing:
KillWaves M_InterpolatedImage
Rename M_ScatterMesh, VoronoiMesh
It's a good idea to rename waves that Igor creates with default wave names so that, if you later 
execute another command that uses the same default wave name, you will not inadvertently 
overwrite data. Also we don't need the M_InterpolatedImage wave.
13.
Choose FileSave Experiment and save the experiment as "Gizmo Surface Using Voronoi 
Interpolation Tour.pxp".
This is just in case you want to revisit the tour later and is not strictly necessary.
That concludes the Gizmo guided tour. There are more examples below. Also choose FileExample Exper-
imentsVisualization for sample experiments.
Gizmo Windows
For each 3D plot, Gizmo creates a display window and its associated info window. The display window 
presents a rotatable representation of your 3D objects. You use the info window to control which objects are 
displayed, the order in which they are drawn, and their properties. You can hide both windows to reduce 
clutter when you do not need them. You can also kill and recreate Gizmo windows like you kill and recreate 
graphs.
You can create any number of Gizmo display windows. Keeping multiple Gizmo display windows open 
has some drawbacks. Even inactive and hidden Gizmo display windows consume graphics resources that 
could otherwise be used for the active Gizmo display window. Also, in some laptop computers you may be 
able to reduce power consumption by closing Gizmo display windows that include rotating objects. 
Depending on your hardware, saving unused Gizmo display windows as recreation macros may be bene-
ficial.
For brevity, we sometimes use the term "Gizmo window" to refer to the Gizmo display window. We use 
"Gizmo info window" or "info window" to refer to the Gizmo info window.
