# Absolute

Chapter III-3 — Drawing
III-66
the object and displays the Properties dialog. Use this to set the numeric coordinates for an object to bring 
it back onscreen. Or you can cancel out of the dialog and then press Delete to remove the object. Retrieve 
works on controls as well as drawing objects.
The Grid submenu provides options for controlling the grid. See Drawing Grid on page III-66 for details.
Drawing Grid
You can display a grid and force objects to snap to the grid, it is visible or not. You do this using the Mover 
pop-up menu Grid submenu.
The default grid is in inches with 8 subdivisions. The grid origin is the top-left corner of the window or sub-
window. Use the ToolsGrid to set grid properties. You can independently specify the X and Y grids and set 
the origin, major grid spacing, and number of subdivisions.
When grid snap is on, you can turn it off temporarily by engaging Caps Lock.
When dragging an object, the corner nearest to where you clicked to start dragging the object is the corner 
that will be snapped to the grid. You can also snap existing objects to the grid by selecting the Align to Grid 
from the Mover popup menu.
Set Grid from Selection
If a single object is selected, Set Grid from Selection will set the grid origin at the top left corner of the object. 
It two objects are selected, the origin will be set to the top left corner of the first object and the major grid 
spacing will be defined by the distance to the top left corner of the second object. If either the horizontal or 
vertical separation is small then a uniform (equal X and Y) grid is defined by the larger distance. Otherwise 
the horizontal and vertical grids are set from the corresponding distances.
Grid Style Function
The Style Function submenu allows you use to create a style function or to run one that you previously cre-
ated. Style functions are created in the main procedure window with names like MyGridStyle00. You can 
edit these to provide more meaningful names.
Drawing Coordinate Systems
A unique feature of Igor’s drawing tools is the ability to choose different coordinate systems. You can choose 
different systems on an object-by-object basis and for X and Y independently. This capability is mainly for use 
in graphs to allow your drawings to adjust to changes in window size or to changes in axis scaling.
You specify the coordinate system using pop-up menus found in the drawing Modify dialogs. The available 
coordinate systems are:
•
Absolute
•
Relative
•
Plot Relative
•
Axis Relative
•
Axis
Absolute
In absolute mode, coordinates are measured in points, or Control Panel Units for control panels, relative to the 
top-left corner of the window. Positive x is toward the right and positive y is toward the bottom. In this mode 
the position and size of objects are unaffected by changes in window size. This is the default and recommended 
mode in page layouts and control panels.
If you shrink a window, it is possible that some objects will be left behind and may find themselves outside 
of the window (offscreen). In addition, if you copy an object with absolute coordinates from one window
