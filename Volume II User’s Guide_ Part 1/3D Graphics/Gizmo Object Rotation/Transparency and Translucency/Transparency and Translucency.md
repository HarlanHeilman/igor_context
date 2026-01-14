# Transparency and Translucency

Chapter II-17 — 3D Graphics
II-432
value is mapped to the last color in the color table and any scatter element whose data value is greater than 
the entered value is displayed using the color selected from the color pop-up menu below.
Reflection
Gizmo supports four types of surface object interactions with lights: ambient, diffuse, specular, and shini-
ness.
Lights have ambient, diffuse and specular components.
Materials have ambient, diffuse, specular and shininess attributes.
Ambient
Ambient reflectance determines the overall color of the object. Ambient reflectance is most noticeable in 
object shadows. The total ambient reflectance is determined by the global ambient light and ambient light 
from individual light sources. It is unaffected by the viewpoint position.
Diffuse
A diffuse surface reflection scatters light evenly in all directions. This is the most important factor determin-
ing the color of an object. It is affected by the incident diffuse light color and by the angle of the incident 
light relative to the normal direction. It is most intense where the incident light falls perpendicular to the 
surface. It is unaffected by the viewpoint position.
Specular
Specular reflection governs the appearance of highlights on an object. The amount of specular reflection 
depends on the location of the viewpoint, being brightest along the direct angle of reflection.
Shininess
Shininess controls the size and brightness of a specular highlight. The shinier the object, the smaller and 
brighter (more focused) the highlight.
Normals, Lighting and Shading
When you display a scene with lighting effects, make sure to enable the calculation of normals for all objects 
in the display list. You can do this in the properties dialog for each object. Depending on the type of object, 
check the Calculate Normals checkbox or choose from the Normals pop-up menu. These settings are off by 
default to conserve graphics processing resources.
Normals are required because the shading of every pixel depends on the angle between the normal to the 
surface and the direction of the light source. In the special case of quadric objects (sphere, cylinder and disk) 
there are internal settings that let you choose between flat, smooth and no normals. All objects draw much 
slower when normals are calculated.
Transparency and Translucency
Proper implementation of transparency in OpenGL requires that objects be drawn from the back to the front 
of the scene, starting with the object that is farthest from the viewer and ending with the nearest object. For 
any fixed viewing transformation it is possible to sort the displayed objects as long as they consist of prim-
itive non-intersecting elements. If you are drawing compound objects such as quadrics you have no control 
over the order of their constituent segments. Most wave-based objects are transformed into triangle arrays 
which can be distance-sorted as long as there are no intersecting triangles.
Distance sorting is computationally expensive so most applications avoid it using various tricks. The "poor 
man's" solution is to use alpha blending. This type of translucency can provide the desired effect for a 
restricted range of viewing angles and may require re-ordering the objects on the display list.
To use alpha blending, assign colors to two distinct objects on the display list. The translucent object should 
have an alpha value that corresponds to its opacity. An opaque object has alpha=1, whereas a transparent
