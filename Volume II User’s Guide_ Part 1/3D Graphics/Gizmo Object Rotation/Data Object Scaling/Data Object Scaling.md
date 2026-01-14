# Data Object Scaling

Chapter II-17 — 3D Graphics
II-453
Isosurface and Voxelgram Object Data Formats
The data for an isosurface or a voxelgram object is a 3D volumetric wave.
Isosurfaces and voxelgrams do not use color waves.
NaN Values in Waves
In general, you should avoid using NaNs in data waves plotted in Gizmo. NaNs appears as holes in sur-
faces or as discontinuities in path plots. A surface object whose data wave contains one or more NaN values 
is drawn in the usual way except that all constituent triangles for which at least one vertex is a NaN are not 
drawn. When possible, it is best to display missing data in Gizmo using transparency (see Transparency 
and Translucency on page II-432).
Gizmo Data Objects
Data objects, also called "wave-based objects", are display objects representing data in Igor waves. They 
include 3D Scatter Plots, Path Plots, Surface Plots, Ribbon Plots, Isosurface Plots, Voxelgram Plots and 
3D Bar Plots.
Data Object Scaling
Data objects are displayed against a set of X, Y and Z data axes. These data axes exist whether or not you 
add an axis object to the plot. The data axes fill the +/-1 display volume.
By default, the data axes are autoscaled to the range of data in all data objects in the plot. You can change 
the range of the data axes using GizmoSet Axis Range.
The following commands illustrate these points. Execute them in a new experiment to follow along:
// Create a Gizmo plot with a surface object
NewGizmo
ModifyGizmo showAxisCue=1
Make/O/N=(100,100) data2D = Gauss(x,50,10,y,50,15)
AppendToGizmo/D surface=data2D, name=surface0
ModifyGizmo setQuaternion={0.206113,0.518613,0.772600,0.302713}
If you now choose GizmoSet Axis Range, you can see that all data axes, which are now invisible, are in 
autoscale mode (Manual checkboxes are unchecked) and that the X and Y axes range from 0 to 99. These 
values come from the fact that the default X and Y values of the data2D wave range from 0 to 99 (default 
wave scaling). The Z axis range is based on the range of Z values in data2D. (If you opened the Axis Range 
dialog, click Cancel to dismiss it now.)
To help us visualize these data axes we add a box axis object with tick marks and tick mark labels:
// Add box axes with tick marks and tick mark labels
AppendToGizmo/D Axes=BoxAxes, name=axes0
ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4,ticks,3}
ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8,ticks,3}
ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9,ticks,3}
If we change the values in the data, since the data axes are in autoscaling mode, the data still fills the axes 
(which always fill the display volume) after the change:
// Change the X and Y range of the data
SetScale x, 0, 10, "", data2D; SetScale y, 0, 10, "", data2D
Now we set the X and Y data axes to manual scaling mode but leave their ranges unchanged:
// Set the X and Y axes to manual scaling mode
ModifyGizmo setOuterBox={0,9.9,0,9.9,1.5286241e-11,0.001061033}
ModifyGizmo scalingOption=48
