# Gizmo Directional Lights

Chapter II-17 — 3D Graphics
II-433
object has alpha=0. The final steps required for translucency are the addition of the blending function attri-
bute and the enable operation. Select GizmoEnable Transparency Blend menu to create the blending 
function and the enable operation and add both to the display list.
The isosurface is a special case because by construction it consists of non-intersecting triangles. In most 
applications it is sufficient to sort the triangles in the order of the distance of the viewing point from the 
centroid of the triangle. You can obtain the triangles corresponding to an isosurface object using Modify-
Gizmo with the saveToWave keyword and establish a sample viewing point. The standard orthographic 
projection implies infinite distance to viewing point. An example of this type of sorting can be found in the 
Depth Sorting demo experiment.
Gizmo Lights
Gizmo supports both directional and positional light sources. The type and color of the lights that you add 
to the display affect the appearance of objects in the display window.
You create lights like any other object by selecting Light from the object list pop-up menu. Using the Light 
Properties dialog, shown below, you can specify the light type and various light parameters. For the light 
to have any effect, you must add it to the display list above any object that you want to illuminate.
Lighting effects are defined in terms of their ambient, diffuse, and specular components. The distribution 
of light intensity is described by the location of the light source, direction, cone angle, and attenuation. The 
final appearance of an object depends on the combination of the properties of the light and the properties 
of the object material.
Lighting effects are computed in hardware on a per pixel basis. Therefore, when you want smooth shading, 
you must describe the object using a sufficiently large number of vertices. For simple objects, such as a 
single quad (4 vertices), you will likely not see much variation in lighting across the quad. Shading is com-
puted using the dot product between the normal to the surface at each vertex and the direction of the light 
source. There is no accounting for objects obscuring other objects from the light source or for multiple reflec-
tions of light.
If you add no lights to the display list, Gizmo uses default, color-neutral ambient light. If you add a light to 
the display list, Gizmo removes the default lighting.
Gizmo Directional Lights
You can think of a directional light as a light positioned very far away from the scene so that its rays are 
essentially parallel within the display volume. The sun is a good example of a directional light. New light 
objects are directional by default.
The Light Properties dialog contains the controls you need to specify the light's position, color properties 
and distribution. When editing a light object that is already in the display list, you can click the Live Update 
checkbox to see how your changes affect the Gizmo Display.
