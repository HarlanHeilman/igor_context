# Plotting a 2D Z Wave With 1D X and Y Center Data

Chapter II-16 — Image Plots
II-389
Image X and Y Coordinates - Evenly Spaced
When your data consists of evenly-spaced pixels, you use the image wave's dimension scaling to specify 
the image rectangle coordinates. You can set the scaling using the Change Wave Scaling dialog (Data menu) 
or using the SetScale operation.
The scaled dimension value for a given pixel specifies the center of the corresponding image rectangle.
Here is an example that uses a 2x2 matrix to exaggerate the effect:
Make/O small={{0,1},{2,3}}
// Set X dimension scaling
SetScale/I x 0.1,0.12,"", small
SetScale/P y 0.0,1.0,"", small
// Set Y dimension scaling
Display
AppendImage small
// _calculated_ X & Y
ModifyImage small ctab={-0.5,3.5,Grays}
Note that on the X axis the rectangles are centered on 0.10 and 0.12, the matrix wave's X (row) indices as 
defined by its X scaling. On the Y axis the rectangles are centered on 0.0 and 1.0, the matrix wave's Y (col-
umn) indices as defined by its Y scaling. In both cases, the rectangle edges are one half-pixel width from the 
corresponding index value.
Image X and Y Coordinates - Unevenly Spaced
If your pixel data is unevenly-spaced in the X and/or Y dimension, you must supply X and/or Y waves to 
define the coordinates of the image rectangle edges. These waves must contain one more data point than the X 
(row) or Y (column) dimension of the image wave in order to define the edges of each rectangle.
In this example, the matrix wave is evenly-spaced in the Y dimension but unevenly-spaced in the X dimen-
sion:
Make/O small={{0,1},{2,3}}
SetScale/P y 0.0,1.0,"", small
// Set Y dimension scaling
Make smallx={1,3,4}
// Define X edges with smallx
Display
AppendImage small vs {smallx,*}
ModifyImage small ctab={-0.5,3.5,Grays,0}
The X coordinate wave (smallx) now controls the vertical edges of each image rect-
angle. smallx consists of three data points which are necessary to define the vertical 
edges of the two rectangles in the image plot. The values of smallx are interpreted as follows:
The 1D edge wave must be either strictly increasing or strictly decreasing.
If you have X and/or Y waves that specify edges but they do not have an extra point, you may be able to 
proceed by simply adding an extra point. You can do this by editing the waves in a table or using the Insert-
Points operation. If this is not appropriate, see the next section for another approach.
Plotting a 2D Z Wave With 1D X and Y Center Data
In an image, each pixel has a well-defined width and height. If your data is sampled at specific X and Y 
points and there is no well-defined pixel width and height, or if you don't know the width and height of 
each pixel, you don't really have a proper image.
However, because this kind of data is often stored in a matrix wave with associated X and Y waves, it is 
sometimes convenient to display it as an image, treating the X and Y waves as containing the center coor-
dinates of the pixels.
Point 0: 1.0
Sets left edge of first rectangle
Point 1: 2.75
Sets right edge of first rectangle and left edge of second rectangle
Point 2: 4.0
Sets right edge of last rectangle
1.5
1.0
0.5
0.0
-0.5
0.13
0.12
0.11
0.10
0.09
1.5
1.0
0.5
0.0
-0.5
4.0
3.5
3.0
2.5
2.0
1.5
1.0
