# Line Objects

Chapter II-17 — 3D Graphics
II-436
of the light in space. If you set w=0, your light source is infinitely far away and you effectively created a 
directional light source. 
We suggest that you set w=1, and set the direction using the next group of controls in the dialog, which 
describes the direction of the light as the three components of a vector pointing from the position of the light 
source to the point that you want the center of the specular spot to illuminate. The typical error here is enter-
ing the position of the illuminated spot instead of the direction vector.
The specified position of the light source is subject to the same transformations that apply to any other 
objects in the display list. In particular, as you rotate display objects, the lights will likewise rotate. If you 
want to keep the lights stationary so they illuminate different part of the rotating display, you must add a 
main transformation operation to the display list immediately after the last light object and before all the 
rotating objects. This will keep all objects listed above the main transformation stationary, and apply the 
rotation only to all subsequent display list items.
Using the main transformation operation allows you to have some things fixed and other things rotatable. 
The main transformation operation sets the point in the display list after which coordinate transformations 
are applied. Coordinate transformations affect translation and scaling in addition to rotation. No transfor-
mations are applied to everything above the main transformation in the display list and therefore those 
items are drawn in their default view, unless you insert explicit translate, rotate or scale operations.
By default, the spot cutoff angle (the light cone half-angle) is 180 degrees which means that the light pro-
vides uniform illumination in all directions. If you take the trouble to specify position and direction it will 
be useful to reduce the cutoff angle to something more realistic - less than 90-degrees.
The constant, linear and quadratic attenuations combine to attenuate positional lights (i.e., for which w is 
non-zero). The exponent value, in the range 0 to128, determines the intensity falloff from the center of the 
spot by multiplying the center intensity by the cosine of the angle between the direction of the light and the 
vertex in question, raised to the power of the exponent value. This can be used to make the light highly spec-
ular.
The Positional Light Demo experiment contains a control panel that you can use to explore the interplay 
between the various positional light parameters and how they affect the lighting on an object.
Gizmo Drawing Objects
Gizmo provides access to a number of drawing primitives. These include Line Objects, Triangle Objects, 
Quad Objects, Box Objects, Sphere Objects, Cylinder Objects, Disk Objects, Tetrahedron Objects and 
Pie Wedge Objects. You can use the dialogs associated with the different objects to set the various object 
properties.
As explained under Gizmo Dimensions on page II-421, the size of a drawing object is expressed in display 
volume units. The display volume extends from the origin to +/- 1 in each dimension. A box of size 1 cen-
tered at the origin extends halfway from the origin the edge of the display volume in each dimension.
Unlike drawing objects, wave-based objects such as scatter plots and surface plots are displayed against a 
separate coordinate system. If you combine drawing objects with wave-based objects, remember that 
drawing object positions and sizes are always expressed in terms of the +/-1 display volume. If you draw a 
2D wave as a surface and you would like to draw a box around it, just add a box whose length, width and 
height are two units.
Line Objects
A line object is a straight line that connects the two endpoint coordinates. You can add an arrowhead at the 
start or end of the line or at the mid point. This example shows a line from (1,1,1) to (0,0,0) created by the 
command
AppendToGizmo/D line={1,1,1,0,0,0}
