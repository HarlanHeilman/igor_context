# Internal Attributes

Chapter II-17 — 3D Graphics
II-419
Gizmo Attributes
A Gizmo attribute encapsulates a setting which you can then apply to the Gizmo display list as a global 
attribute or to a specific Gizmo object as an embedded attribute.
Gizmo supports the following types of attributes:
•
Color
•
Ambient
•
Diffuse
•
Specular
•
Shininess
•
Emission
•
Blending
•
Point size
•
Line width
•
Alpha test function
You create an attribute using the attribute list in the info window. You can then drag the attribute to the 
display list as a global attribute or into an object in the object list as an embedded attribute.
In addition to global and embedded attributes, Igor7 added internal attributes, described in the next sec-
tion.
Internal Attributes
Internal attributes are built into objects. For example, the New Sphere dialog looks like this:
The draw style, normals, orientation and color settings are internal attributes of the sphere object.
The Use Global Attributes checkbox disables the controls under it and enables the use of the respective 
global attributes for the object in question. It does not affect the use of other global attributes.
The Specify Color checkbox does the same for color. If unchecked, the object has no intrinsic color. In this 
case you must add a color material operation and a color attribute to the display list before the object. If 
Specify Color is checked, Gizmo creates a default color material for the object and uses the specified internal 
color attribute.
