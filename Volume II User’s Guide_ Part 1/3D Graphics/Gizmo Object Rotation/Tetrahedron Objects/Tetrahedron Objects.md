# Tetrahedron Objects

Chapter II-17 — 3D Graphics
II-445
from the Annotation pop-up menu. For backward compatibility, Gizmo still supports string objects and 
they are useful if you want 3D graphics. Annotations are preferrable for general labeling.
For further discussion of annotations versus string objects, see Changes to Gizmo Text on page II-471. The 
rest of this section describes the original Gizmo string object feature.
String objects can be used for short text labels or annotations. You can create a string object using a 
command such as:
AppendToGizmo string="Hello", strFont="Geneva", name=string0
Like the primitive objects described above, string objects are 3D objects that are drawn in +/-1 display 
volume coordinates. You can use translate and rotate operations in order to place the string at the appro-
priate part of the graph and in the desired orientation.
The key to orienting strings correctly is understanding that they originate at the origin, character advance 
is in the X direction and text height is in the Y direction.
Multiple lines are not supported so a given string object results in a single line of text only.
ColorScale Objects
Gizmo colorscale objects were used in Igor Pro 6 and before to create 3D color scale graphics. You can now 
use standard Igor annotations as you do in graphs.
Annotations are 2D graphics that lie flat in a plane in front of all 3D graphics. They are well suited for 
general labeling purposes. To create a color scale as an annotation choose GizmoAdd Annotation and 
choose ColorScale from the Annotation pop-up menu. For backward compatibility, Gizmo still supports 
colorscale objects and they are useful if you want 3D graphics. Annotations are preferrable for general label-
ing.
The rest of this section describes the original Gizmo ColorScale object.
Color scale objects are designed to provide an association between a sequence of colors and a numeric scale. 
You can create a color scale object using a command such as:
AppendToGizmo colorScale=colorScale0
You would typically following this with ModifyGizmo commands.
Color scales are also drawn in +/-1 display volume coordinates and by default appear planar though you 
can assign to them a positive depth value to make the color scale into a full 3D object.
You can choose the sequence of colors to be based on a built-in color table or provide your own sequence 
using a color wave.
A color scale can be tied to a wave-based data object such as a surface plot but can also be independent on 
all objects in the plot. You can create multiple color scale objects in the same plot.
Tetrahedron Objects
A tetrahedron is defined by 4 vertices. These commands generate a tetrahedron and set its drawing style to 
lines:
AppendToGizmo/D tetrahedron=tetrahedron0
ModifyGizmo ModifyObject=tetrahedron0, objectType=tetrahedron, 
property={vertex0,-1,-1,-1}
ModifyGizmo ModifyObject=tetrahedron0, objectType=tetrahedron, 
property={vertex1,1,-1,-1}
ModifyGizmo ModifyObject=tetrahedron0, objectType=tetrahedron, 
property={vertex2,0,1,-1}
ModifyGizmo ModifyObject=tetrahedron0, objectType=tetrahedron, 
property={vertex3,0,0,1}

Chapter II-17 — 3D Graphics
II-446
You can turn on filling and specify a color for each vertex to produce a tetrahedron like this:
You can also specify that a sphere is to be drawn at each tetrahedron vertex:
