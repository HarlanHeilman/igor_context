# Axis Cue Objects

Chapter II-17 — 3D Graphics
II-448
Gizmo Axis and Axis Cue Objects
Gizmo axis objects are used mostly with wave-based data objects such as surface plots and scatter plots. 
They allow you to indicate the range of data values and to set the scale of data objects.
Axis cue objects show the orientation of the X, Y and Z directions. Axis objects show both orientation and 
numeric range.
Axis Cue Objects
Gizmo supports two axis cue objects: the default axis cue and the free axis cue. These objects indicate the 
orientation of the X, Y and Z axes.
The default axis cue is a triplet axis object that is centered at the display volume origin. The X, Y and Z cue 
lines extend in the positive X, Y and Z directions of the display volume respectively.
There is just one default axis cue. It is used only to provide an indication of which direction is which. It does 
not support tick marks, tick mark labels or axis labels. To display the default axis cue, right-click the Gizmo 
display window and select Show Axis Cue.
The default axis cue object is drawn with the X axis in red, the Y axis in green and the Z axis in blue. The 
characters labeling the three axes are all drawn in black. Internally, the axes are drawn with emission color 
material which helps differentiate the axis cue from the background.
A free axis cue object can be drawn at any offset from the origin and at any scale. By default it has the same 
orientation as the default axis cue. Use a rotate operation if you want to rotate it.
You can create multiple free axis cues and even use them as markers in scatter plots. To add a free axis cue, 
click the + icon in the object list of the Gizmo info window and choose Free Axis Cue.
