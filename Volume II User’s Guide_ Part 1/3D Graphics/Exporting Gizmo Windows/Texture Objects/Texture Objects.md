# Texture Objects

Chapter II-17 — 3D Graphics
II-467
The resulting graph should look something like this:
A similar example of scatter objects can be found in the Scatter Arrows demo experiment where the marker 
object is a line that has a cylindrical body and cone head.
Texture Objects
Textures are used extensively in OpenGL so most graphics hardware are optimized to use them. An in-
depth discussion of texture is beyond the scope of this document so we will focus on the use of textures in 
Gizmo. To work with texture objects you must enable the advanced Gizmo menus in Miscellaneous Set-
tings.
A Gizmo texture object represents an OpenGL object that allows you to apply image information to surfaces 
of arbitrary shape. Textures in Gizmo are 1D or 2D. They can be applied to quad objects, quadric objects 
(spheres, cylinders and disks) and parametric surfaces. If you intend to use a texture on a simple quad you 
should use an image plot instead; see Gizmo Image Plots on page II-458.
You usually create a texture from an image that was loaded using ImageLoad and is in the form of an 
unsigned byte 3D RGB wave where the color for each pixel is stored in sequential layers. Before you create 
a Gizmo texture you need to convert the standard image format into a 1D wave where the color entries for 
each pixel are stored sequentially as RGB or RGBA. This conversion can be accomplished by ImageTrans-
form with the keyword imageToTexture.
The Texture Properties dialog determines how the texture wave is converted into a texture object and how 
the texture is applied in a drawing.

Chapter II-17 — 3D Graphics
II-468
Before invoking the dialog it is useful to know the dimensions of the texture wave, its packing format and 
the original image size. ImageTransform stores this information in the wave note of the texture wave. The 
dialog loads the texture information from the wave note if you click the From Texture Wave button.
Once you create a texture object you can apply it to other objects. For example, to apply texture0 to cylinder0 
your display list should contain the following sequence:
where cylinder0 is preceeded by texture0 and followed by clearTexture0. You must check the Uniform 
Texture Coordinates checkbox in the Cylinder Properties dialog. The texture object is placed just before the 
cylinder and the clear texture operation follows so that subsequent drawings are free of textures.
The Gizmo Earth demo experiment illustrates the use of textures. In this case a high-resolution rectangular 
texture is added to a parametric surface representing the sphere. The parametric surface consists of 61x61 
vertices.
