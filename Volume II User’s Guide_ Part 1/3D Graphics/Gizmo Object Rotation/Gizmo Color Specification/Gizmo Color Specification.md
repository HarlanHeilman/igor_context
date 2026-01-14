# Gizmo Color Specification

Chapter II-17 — 3D Graphics
II-428
Assume you want to set the Gizmo orientation to the rotation produced by the preceding example (X axis 
points to the right, Y axis points away from you, and the Z axis points up) followed by a 90-degree rotation 
about the Z axis, producing the orientation where the X axis points to toward you, the Y axis points to the 
right, and the Z axis points up. You could execute this:
Make/O/N=4 q1={sin(pi/4),0,0,cos(pi/4)}
// Z up, X right, Y away
Make/O/N=4 q2={0,0,sin(pi/4),cos(pi/4)}
// 90 degree rotation about Z
Make/O/N=4 qr// Resultant orientation
MultiplyQuaternions(q2,q1,qr)
// Compute resultant orientation
Print qr
 qr[0]= {0.5,0.5,0.5,0.5}
ModifyGizmo setQuaternion={0.5,0.5,0.5,0.5}
Another way to do this is to use the ModifyGizmo appendRotation command which does the quaternion 
multiplication for you:
ModifyGizmo setQuaternion={sin(pi/4),0,0,cos(pi/4)}
// Z up, X right, Y away
ModifyGizmo appendRotation={0,0,sin(pi/4),cos(pi/4)}
The last command rotates 90 degrees about the Z axis starting from the current orientation.
Locking Rotation
In some situations you want to prohibit rotation of the Gizmo plot. You can do this by executing:
ModifyGizmo lockMouseRotation = 1
This locks the rotation without providing any visible clue that it is locked.
A more complicated approach is to set a fixed viewing transformation on the display list, then add all the 
objects to be drawn, and end with a MainTransformation operation. All objects in the display list above the 
main transformation will be drawn with fixed rotation and scaling.
Gizmo Colors, Material and Lights
The rendered color of a Gizmo object depends on its internal color, color attributes, material as specified by 
a color material operation and lighting. The following sections discuss these topics.
Gizmo Color Specification
Colors of objects and lights are specified using four floating point numbers: RGBA. 
The first three are the primary colors red, green, and blue which combine additively to give the final color. 
The intensity of each component is a number in the range [0.0 to 1.0].
The fourth component is alpha, which determines the opacity of an object. Values are between 1.0, a com-
pletely opaque color, and 0.0, a completely transparent or colorless object.
To conserve graphics resources, alpha blending for a Gizmo window is turned off by default. To create 
objects that have some degree of transparency, in addition to setting the alpha component of their color, 
you must enable transparency blending by choosing Gizmo MenuEnable Transparency Blend.
By default the blendFunc0 and enableBlend items are inserted at the top of the display list and therefore 
affect the drawing of all items that follow them. You may be able to improve drawing speed by moving this 
pair of entries immediately above the items that require transparency blending. You would then also add 
a disable operation to disable the blending right after the last entry that uses transparency. For details see 
Transparency and Translucency on page II-432. 
Here is an example showing color specification with transparency:
// Create a new Gizmo with axis cue and set rotation
NewGizmo
