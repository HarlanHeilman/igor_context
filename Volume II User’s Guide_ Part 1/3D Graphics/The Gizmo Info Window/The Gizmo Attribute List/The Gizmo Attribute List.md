# The Gizmo Attribute List

Chapter II-17 — 3D Graphics
II-417
it in the display list of another info window, Igor also creates the corresponding entry in the object list of 
the receiving window.
It is not possible to drag and drop objects between info windows belonging to two instances of Igor.
The Gizmo Object List
The middle list in the info window is the object list. It lists all of the objects that you have created which are 
then available for use in the display list.
Gizmo supports many types of objects including wave-based objects such as surface plots and drawing 
primitives such as spheres. If you click the + icon under that object list you see a menu of the available object 
types. See Gizmo Objects on page II-418 for details.
For an object to appear in the Gizmo plot, you must drag it to the display list.
The Gizmo Display List
The display list controls what actually appears in the Gizmo display window. Gizmo processes the items 
in the display list in the order in which they appear.
In addition to objects that you drag in from the object list and attributes that you drag in from the attribute 
list, you can add the following operations to the display list:
ClearColor, ColorMaterial, Translate, Rotate, Scale, Main Transformation, Enable, Disable and Ortho.
Using the ColorMaterial, Enable and Disable operations requires some familiarity with OpenGL.
The Main Transformation item is used in conjunction with lighting. This is described under Gizmo Posi-
tional Lights on page II-434.
The Ortho operation controls the projection of the 3D space onto the 2D screen. This is described under 
Gizmo Projections on page II-422.
If you are familiar with OpenGL, you should note that Gizmo automatically generates a small number of 
OpenGL instructions e.g., viewing transformation, default lighting, etc., that are not visible on the list. If 
you provide your own alternatives the various defaults are simply not executed. For example, by default 
Gizmo provides a neutral ambient light to illuminate the scene. However, if you add one or more lights to 
the display list, the default ambient light is omitted. 
Item Ordering in the Gizmo Display List
You can reorder items in the display list by dragging and dropping them in the desired locations. The order 
of items in the display list is important because it determines the order of execution of OpenGL drawing 
instructions which govern the appearance of the plot. This becomes obvious when you use operations such 
as translation, rotation, or scaling.
There are a few items for which the exact position in the list does not make any difference, but in the major-
ity of cases a change in the order of items produces a visible change in the display. For example, if you 
switch the order of rotation and translation operations you will get a completely different result; see Gizmo 
Object Rotation on page II-424 for an example.
The Gizmo Attribute List
The attribute list appears on the right side of the info window.You create an attribute by clicking the + icon 
and selecting the type of attribute you want. You then drag that attribute into the display list as a global 
attribute or on top of an item in the object list as an embedded attribute.
The order of items in the attribute list is unimportant.
Attributes are discussed in detail under Gizmo Attributes on page II-419.
