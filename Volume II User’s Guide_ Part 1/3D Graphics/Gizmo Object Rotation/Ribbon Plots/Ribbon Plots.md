# Ribbon Plots

Chapter II-17 — 3D Graphics
II-462
Apply the color wave to the surface:
ModifyGizmo modifyObject=surface0,objectType=surface,
property={ surfaceColorType,3}
ModifyGizmo modifyObject=surface0,objectType=surface,
property={ surfaceColorWave,root:sphereData_C}
Ribbon Plots
In a ribbon plot, data points are connected by a surface that defines the ribbon object. A ribbon is con-
structed from a list of triangles with alternating vertices as shown here:
To display the individual points or connections, you need to append a scatter plot or a path plot.
Data for a ribbon plot consist of a Nx3 matrix of values. Each row contains the X, Y, and Z values for the 
spatial coordinates of a point on the edge of the ribbon. The coordinates for each alternating edge of the 
ribbon follow in sequential order. The order of vertices for a ribbon is shown in the illustration above.
A ribbon must have at least four vertices and the total number of vertices must be even.
A ribbon plot can be colored using a constant color, a color taken from one of the built-in color tables, or a 
user-specified color wave. A color wave for a ribbon plot is a 2D wave in which each row specifies the color 
of the corresponding element in the data wave. The color wave has 4 columns which specify RGBA entries 
in the range of [0,1].
The full list of available options is given under ModifyGizmo.
This is an example of a simple ribbon plot:
