# Gizmo Clipping

Chapter II-17 — 3D Graphics
II-421
Gizmo Dimensions
The default Gizmo viewing volume is a space that is 4 units wide in all three dimensions. The actual display 
volume is two units in each dimension, centered in the middle of the viewing volume. Each dimension of 
the display volume extends from -1 to +1 about the origin. The display volume is smaller than the viewing 
volume to avoid clipping at the corners when the plot is rotated.
All drawing objects, such as spheres and cylinders, are sized in units of the +/-1 display volume. So, for 
example, if you create a box that is 2 units on a side, it completely fills the display volume. If you create a 
cylinder that is 3 units high, then the top of the cylinder is clipped because it extends outside the viewing 
volume boundary.
Superimposed on the display volume and precisely filling it is an axis coordinate system against which 
wave-based data objects such as scatter and surface plots are plotted. You can set the axis coordinate range 
for each dimension by choosing GizmoAxis Range. The axis coordinate system exists even though, by 
default, no axes are visible.
The axis coordinate system is autoscaled by default. Consequently, when you initially display a wave-based 
object, it fills the range of each axis. Since the axis coordinate system fills the display volume, the displayed 
wave-based object also fills the display volume.
When you display two or more wave-based objects at the same time while the axes are set to autoscale, 
Gizmo sets the range of each axis based on the minimum and maximum in the respective dimension of all 
data objects combined.
Once you turn autoscaling off, the axis range that you set determines the extent to which wave-based 
objects fill the display volume.
When you combine drawing objects and wave-based objects, the dimensions and positions of the drawing 
objects remain in +/-1 display volume units whereas the wave-based objects are displayed against the axis 
coordinate system.
Gizmo Clipping
When you set the range of any axis, you may use values that do not include the full range of the data. To 
display the results correctly in this case, Gizmo creates clipping planes on the relevant sides of the display 
volume. Once created, these clipping planes affect both wave-based data objects and drawing objects. The 
clipping planes are not created unless a data object extends beyond the range of the axes.
If you want to do your own clipping, this automatic Gizmo clipping may intefere. To disable automatic clip-
ping, for example for a surface object named surface0, you can execute:
ModifyGizmo modifyObject=surface0, objectType=surface, property={Clipped,0}
If you are working in advanced mode (see Advanced Gizmo Techniques on page II-466), you can create 
custom clipping planes to create special effects such as gaps in a surface plot. To use clipping planes, make 
sure that you are not using an axis range that is smaller than the span of the data in any dimension. Current 
graphics hardware support 6 to 8 clipping planes and axis-range clipping planes have a priority. For an 
example, open the Clipping Demo experiment.
