# Image Object Data Format

Chapter II-17 — 3D Graphics
II-452
If you are plotting a parametric surface then the data wave is 3D wave containing three layers. At each 
row/column position, layer 0 contains the X coordinate, layer 1 the Y coordinate, and layer 2 the Z coordi-
nate. The color wave for a parametric surface is a 3D RGBA wave that has the same number of elements in 
the X and Y dimensions as the data wave and where layer 0 contains the red component, layer 1 the green 
component, layer 2 the blue component and layer 3 the alpha component.
If you are plotting sequential quads (they could be the ImageTransform output of a Catmull-Clark B-
Spline), the data wave is a 3D wave with four rows and three layers. Each row contains stores the four ver-
tices of a quad and the three layers contain the X, Y, and Z coordinates.
If you are plotting disjoint quads the data wave is 2D with 12 columns corresponding to the X, Y, and Z 
values of the quad vertices taken in a counterclockwise direction.
The color wave for sequential quads and disjoint quads is a 4 column 2D wave in which the columns cor-
respond to RGBA values in the range [0,1].
Parametric Surface Data Formats
A parametric surface is defined by equations in which the X, Y, and Z coordinates are calculated for, usu-
ally, a pair of parameters. To define a parametric surface for Gizmo you need to have a 3D wave containing 
X, Y, and Z layers. The only restriction on the dimensions of this wave is that it must not have 4 columns. 
Gizmo constructs the parametric surface from quads. Each quad is defined by four neighboring vertices as 
shown in the diagram below.
You can find examples of parametric surfaces in these demo experiments:
Igor Pro Folder:Examples:Visualization:Mobius Demo
Igor Pro Folder:Examples:Visualization:Spherical Harmonics Demo
Igor Pro Folder:Examples:Visualization:Gizmo Sphere Demo
Image Object Data Format
The data wave for an image object can be in one of three formats:
•
A 2D matrix of Z values
•
A 3D RGB wave of type unsigned byte with 3 layers
•
A 3D RGBA wave of type unsigned byte with 4 layers
In the 3D formats, the red component is stored in layer 0, the green component in layer 1, and the blue com-
ponent in layer 2. The alpha component, if any, is stored in layer 3. Each component value ranges from 0 to 
255.
