# Gizmo Coordinate System

Chapter II-17 — 3D Graphics
II-420
Prior to Igor7 Gizmo supported no internal attributes so you had to use global or embedded attributes. We 
now recommend that you use internal attributes if they are available in preference to global or embedded 
attributes.
Global Attributes
When you drag an attribute to the display list, it acts as a global attribute that affects all objects later in the 
display list.
If you place an attribute such as color in the display list, OpenGL draws all subsequent objects that do not 
have an internal color specification using this global color. You also need a color material operation in order 
to see the applied color.
Internal attributes and embedded attributes override global attributes.
Embedded Attributes
Embedded attributes are deprecated and are supported mainly for backward compatibility. We don't rec-
ommend their use in new projects because primitive obects now have their own internal attributes which 
should be used instead.
When you drag an attribute on top of an object in the object list, it becomes embedded in that object. You 
can embed a given attribute in any number of objects and you can embed any number of attributes in a 
given object.
For example, if you create a sphere object and you want it to appear in blue, you can create a blue color attri-
bute in the attribute list and drop it on top of the sphere object in the object list. The advantage of doing so, 
as opposed to directly setting the internal color attribute of the sphere object, is in allowing you to reuse the 
same color attribute with multiple objects. With this approach, by changing a single attribute you can 
change the color of all associated objects.
Internal attributes override embedded attributes and global attributes.
When an object with embedded attributes is drawn, Gizmo first stores the state of the drawing environ-
ment. It then executes the embedded attributes immediately before the object is drawn and finally it restores 
the state of the drawing environment. As a result, embedded attributes affect only the object in which they 
are embedded.
If you apply conflicting attributes to a given object, only the last attribute in the embedded list affects the 
object appearance. For example, if you have a sphere object with the following embedded attributes: red 
color, blue color and green color, the sphere is drawn in green.
Gizmo Display Environment
Gizmo constitutes an environment for displaying 3D graphics. This section discusses the main properties 
of that environment.
Gizmo Coordinate System
Gizmo uses a right-handed, 3D coordinate system. If the positive X axis points to the right and the positive 
Y axis points up then, by the right-hand rule, the positive Z axis points out of the screen towards you.
