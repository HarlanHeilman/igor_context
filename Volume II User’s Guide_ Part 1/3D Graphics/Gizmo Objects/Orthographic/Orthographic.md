# Orthographic

Chapter II-17 — 3D Graphics
II-422
Gizmo Projections
A number of different projections can be used to control the display of 3D objects in a 2D Gizmo window.
By default Gizmo uses a built-in default orthographic projection which does not appear in the display list. 
The default orthographic projection is ideal for most applications.
Gizmo calculates the parameters to use with the default orthographic projection by scanning all objects in 
the display list and computing their largest extent. The default orthographic projection will be 2 units in all 
directions which allows full rotation of wave-based objects without clipping.
The automatic scanning of objects on the display list does not take into account optional translation, rota-
tion, or scaling operations. If you use any of these in the display list you should also provide a separate 
ortho operation with the appropriate definition of the projected space.
To add a projection operation, click the + icon under the display list. By default the only projection offered 
is Ortho and this is sufficient for nearly all purposes. In order to choose another type of projection you must 
check the Display Advanced Options Menus checkbox in the Gizmo section of the Miscellaneous Settings 
dialog which you can access via the Misc menu.
You can have any number of projection operations on the display list. When there is more than one projec-
tion Gizmo executes only the last one. 
When you are using a projection other than Ortho you must also specify the viewing angle. As a result, the 
standard mouse rotation and mouse wheel zoom do not apply.
Orthographic
The orthographic projection maintains the geometric orientations and scalings of 3D objects. This is the 
default projection for the Gizmo display window and is recommended for most purposes.
Unlike perspective projection, discussed in the next section, orthographic projection preserves object par-
allelism and there is no object foreshortening. Orthographic projection is analogous to an arrangement 
where dimensions of objects in the displayed scene are small compared to the viewing distance. Another 
way to think of it is that the image plane is perpendicular to one of the coordinate axes. Only objects con-
tained within the viewing volume are visible. This projection is also faster than perspective.
As shown in this diagram, the ortho projection depends on 6 parameters: left, right, bottom, top, zNear and 
zFar. The parameters are measured from the center of the display volume and are expressed in +/-1 display 
volume units.
