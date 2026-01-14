# Gizmo Positional Lights

Chapter II-17 — 3D Graphics
II-434
The position of the light is specified via two angles: azimuth and elevation. Elevation is also called "alti-
tude", especially in astronomy. The meaning of these angles is described at http://en.wikipe-
dia.org/wiki/Azimuth. When the elevation is +90 or -90 degrees, the azimuth is undefined.
Ambient, diffuse and specular lighting are described at http://en.wikipedia.org/wiki/Phong_reflection_-
model. Ambient light illuminates all parts of all objects equally regardless of their orientation and of the 
position of the light. Diffuse light is reflected off a surface in all directions, as when light hits a rough sur-
face. Specular light is reflected in a specific direction, as when light hits a shiny surface. The illumination 
created by diffuse and specular light at a given point on an object depends on the angle of the light ray rel-
ative to the normal to the surface of that point.
Gizmo Positional Lights
A positional light is a light source that originates at a finite distance from the illuminated scene. A desk lamp 
is a typical example of a positional light. It can be placed somewhere above the desk and it produces non-
uniform illumination as its intensity falls off as a function of distance from the center of the illumination 
spot.
When you create a light object, it is initialized as a directional light. You can click click the Convert to Posi-
tional button in the dialog to get the corresponding positional light settings which you can then adjust as 
desired.

Chapter II-17 — 3D Graphics
II-435
The parameters for specifying positional lights are illustrated here:
The top three controls in the directional light dialog specify the RGBA values of each of the ambient, diffuse 
and specular light components. You should provide some ambient component in at least one of the lights 
in the display list. This requirement holds even if you are trying to create a predominantly diffuse or spec-
ular effect.
When you create a Gizmo object you have the option to specify a color or to leave it unspecified. If you 
specify a color, Gizmo creates a default color material for the object. The default color material has the GL_-
FRONT_AND_BACK and GL_AMBIENT_AND_DIFFUSE settings. If you are interested in specular effects 
you must add specular and shininess attributes (see Gizmo Colors, Material and Lights on page II-428).
The Position and Direction controls in the dialog describe the position and direction of the light source. The 
position is expressed in homogeneous coordinates where the last element (w) is used to normalize the X, Y 
and Z components. Therefore, if you set w=1, then the X, Y, and Z components specify the absolute position
