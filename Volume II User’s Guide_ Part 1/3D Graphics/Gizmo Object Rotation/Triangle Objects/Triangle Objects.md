# Triangle Objects

Chapter II-17 — 3D Graphics
II-437
You can make the line into a 3D cylinder using: 
ModifyGizmo modifyObject=line0,objectType=line,property={arrowMode,16}
ModifyGizmo modifyObject=line0,objectType=line,property={cylinderStartRadius,0.05}
ModifyGizmo modifyObject=line0,objectType=line,property={cylinderEndRadius,0.05}
Triangle Objects
A triangle is a planar object bounded by a simple polygon connecting its three vertices. A triangle object is 
always drawn filled. The fill color is determined by the internal color attribute, an embedded color attribute, 
or a global color attribute, in that order of precedence. All lighting attributes also apply.
In some situations, it may be more straightforward to create the triangle in a simple orientation and then 
use translate and rotate operations to position the triangle in its final orientation.
You can set the color of the triangle on a vertex by vertex basis and OpenGL will interpolate the colors 
between the vertices. Here is an example:
AppendToGizmo/D triangle={0,0,0,1,1,1,1,-1,-1}
ModifyGizmo modifyobject=triangle0, objectType=triangle, 
property={colorType,2}
ModifyGizmo modifyobject=triangle0, objectType=triangle, 
property={colorValue,0,1,0,0,1}
ModifyGizmo modifyobject=triangle0, objectType=triangle, 
property={colorValue,1,0,1,0,1}
ModifyGizmo modifyobject=triangle0, objectType=triangle, 
property={colorValue,2,0,0,1,1}
