# Color Waves

Chapter II-17 — 3D Graphics
II-430
For an example, open this demo experiment: Material Attributes.
Color Waves
Wave-based objects can be drawn in fixed colors or using the built-in Igor color tables. You can also use 
your own color waves to specify the colors of the objects in the Gizmo display window. The format of a 
color wave is similar to that of the corresponding data wave except that each data node (vertex) has red, 
green, blue and alpha color components associated with it.
One situation where a color wave is useful is when you want to display a set of scalar values (e.g., tempera-
ture measurements) corresponding to points on a 3D surface. In this case you have one wave that describes 
the shape of the surface and another wave containing the scalar measurements. The application of a color 
wave gives you complete freedom to represent the scalar data distributed on the surface. In most cases you 
can create an appropriate color wave using the ModifyGizmo makeColorWave and makeTripletColor-
Wave keywords to create a color wave for the data based on one of the built-in tables and then specifying 
an appropriate alpha in the color wave.
