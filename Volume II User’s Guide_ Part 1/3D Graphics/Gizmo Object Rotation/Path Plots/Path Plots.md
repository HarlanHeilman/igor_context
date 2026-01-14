# Path Plots

Chapter II-17 — 3D Graphics
II-454
If we now change the range of the data, the data axes remain unchanged and the data no longer fills the 
axes:
// Change the X and Y range of the data
SetScale x, 0, 5, "", data2D; SetScale y, 0, 5, "", data2D
To recap, X, Y and Z data axes always exist, whether they are displayed or not. They always fill the +/-1 
display volume. Data objects are displayed against the data axes which, by default, are autoscaled. Conse-
quently, by default, data objects fill the display volume. If you change the data axes to manual scaling and 
change their range or change the range of the data, the data axes still fill the +/-1 display volume but the 
data objects no longer exactly fit.
Path Plots
Each data point in a path plot is connected in sequential order by a straight line to each adjacent point.
To draw markers at the individual points, you need to append a scatter plot based on the same data wave.
A path plot requires a triplet wave, which is a 2D wave of 3 columns for X, Y, Z coordinates, respectively, 
of each vertex. A color wave for a path plot is a 2D wave in which each row specifies the color of the corre-
sponding vertex in the data wave. The color wave has 4 columns which specify RGBA entries in the range 
of [0,1].
