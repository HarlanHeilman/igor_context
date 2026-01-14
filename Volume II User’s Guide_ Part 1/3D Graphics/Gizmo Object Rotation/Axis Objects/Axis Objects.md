# Axis Objects

Chapter II-17 — 3D Graphics
II-449
The free axis cue is colored the same as the default axis cue unless you disable its color by checking the No 
Color checkbox in the Free Axis Cue dialog. In this case it takes on the current color of the drawing envi-
ronment as set by the previous color attribute in the display list. You also need a color material operation 
in the display list to apply a color to a free axis.
Axis Objects
As explained under Gizmo Dimensions on page II-421, a Gizmo display has an axis coordinate system that 
is superimposed on the +/-1 display volume. You set the range of this axis coordinate system using the Axis 
Range dialog, accessible via the Gizmo menu. Wave-based objects, such as scatter plots and surface plots, 
are displayed against this axis coordinate system. An axis object is a visual representation of it.
Gizmo supports three types of axis objects: box, triplet, and custom. Gizmo treats axis objects just like other 
objects that you add to the Gizmo display window with one exception: you must have at least one data 
object or drawing object on the display list for an axis object to be meaningful.
The corners of the box axis object correspond to the corners of the display volume. Thus the location of each 
corner in display volume space is -1 or +1 in each dimension. In this diagram the coordinates shown are the 
display volume coordinates of the corners of the box axes.
Box axes consist of 12 axes named X0, X1, X2, X3, Y0, Y1, Y2, Y3, Z0, Z1, Z2 and Z3. You can control each 
axis individually, assign it a color, range, tick marks, and tick mark labels. You can also add grid lines or 
paint any of the six sides of the box.

Chapter II-17 — 3D Graphics
II-450
Triplet axes are a system of three orthogonal axes that intersect at the origin and span the +/-1 display 
volume. You can control each axis individually, assign its tick marks, tick mark labels and color. The origin 
of the axes is the center of the -/+1 display cube.
Each triplet axis is identified by name, X0, Y0, and Z0. This diagram shows display volume coordinates for 
triplet axes and the name of each axis:
A custom axis is a single line in space connecting your chosen start and end points as specified in -1/+1 
display volume coordinates. Unlike box and triplet axes which reflect the global axis range as set by 
GizmoAxis Range, a custom axis has its own, independent axis range. You can add tick marks and tick 
mark labels to the custom axis as to any other axis.
By default, Gizmo attempts to find an appropriate position for tick mark labels. Using the manual position 
mode, you can take control over their position and orientation.
In most cases you will control the various axis settings using the Axes Properties dialog. When using the 
dialog it is important to keep track of the different axes that you can select with the checkboxes. To help you 
identify the various axes in your plot, the Axis tab of the dialog displays an outline of the axes in the same 
orientation as they appear in the Gizmo window. You can toggle the display of axes by double-clicking 
them.
