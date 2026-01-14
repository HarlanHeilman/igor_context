# Frustum

Chapter II-17 — 3D Graphics
II-423
The zoom (using the mouse wheel) and pan tools are implemented by modifying the default ortho projec-
tion. If you add your own projection to the display list, the zoom tool is disabled.
Perspective
The perspective projection simulates the way your eye sees 3D objects. Although this is a realistic projec-
tion, it does not preserve the exact orientations or shapes of objects; for example, parallel lines may diverge 
or converge and there is foreshortening of objects. The viewing area is in the shape of a truncated pyramid 
in which the top has been cut off parallel to the base. Only objects within the viewing volume are visible. 
This is a symmetric perspective view of the viewing volume; a frustum, discussed in the next section, sup-
ports an asymmetric volume.
As shown in this diagram, the perspective projection depends on 4 parameters: fov, aspect, zNear and zFar.
Frustum
The frustum projection is essentially the same as the perspective projection, but in this case it has more flex-
ible settings, which means that it does not have to be symmetrical or aligned with the Z axis.
As shown in this diagram, the frustrum projection depends on 6 parameters: left, right, bottom, top, zNear 
and zFar.
