# 3D Scatter Plots

Chapter II-17 — 3D Graphics
II-455
The Path Properties dialog looks like this:
The full list of available options is given under ModifyGizmo.
You can find an example of 3D tube segments where the tube segments are used to display chemical bonds 
by choosing FileExample ExperimentsVisualizationMolecule.
3D Scatter Plots
Each data point in a scatter plot is displayed as 3D marker.
If you want to connect the markers, you need to append a path plot object that uses the same triplet wave.
A scatter plot requires a triplet wave, which is a 2D wave of 3 columns for X, Y, Z coordinates, respectively, 
of each marker.
Each marker can be represented by a Gizmo object. You can select any one of the built-in drawing objects 
(e.g., box, sphere, cylinder or disk) or you can also select any object in the object list. This is useful when 
you have a very small number of points and you want to display each marker at high resolution. In that 
case you would add an object to the display list that has the required resolution and then choose this object 

Chapter II-17 — 3D Graphics
II-456
as your marker for the path plot. Choose FileExample ExperimentsVisualizationMolecule for an 
example.
You can specify the size of the scatter objects to be a constant size, or provide a wave that contains a size 
specification for each scatter point. The size is specified by a triplet wave where each row contains scale 
factors for the X, Y and Z dimensions of each marker.
You can also specify the rotation of each scatter point. The rotation is specified by a 2D wave containing 
four columns. The first column specifies the rotation angle in degrees and the remaining three columns 
specify the normalized rotation axis vector, just as in the rotate operation.
A scatter plot can be colored using a constant color, a color taken from one of the built-in color tables, or a 
user-specified color wave. A color wave for a scatter plot is a 2D wave in which each row specifies the color 
of the corresponding element in the data wave. The color wave has 4 columns which specify RGBA entries 
in the range of [0,1].
The Scatter Properties dialog allows you to set all properties of the object. If you use the dialog when the 
object is already in the display list then checking the Live Update box lets you to see all changes as you make 
them. 
One useful feature of scatter plots is the ability to draw a "drop line". Drop lines start at the center of each 
marker and extend to one of 14 possible points, lines or planes. You can choose any combination of drop 
lines from the Drop Lines tab of the Scatter Properties dialog.
