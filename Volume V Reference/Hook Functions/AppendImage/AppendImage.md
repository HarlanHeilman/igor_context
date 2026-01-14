# AppendImage

AppendImage
V-32
AppendImage 
AppendImage [/G=g/W=winName][axisFlags] matrix [vs {xWaveName, yWaveName}]
The AppendImage operation appends the matrix as an image to the target or named graph. By default the 
image is plotted versus the left and bottom axes.
Parameters
matrix is either an NxM 2D wave for false color or indexed color images, or it can be a 3D NxMx3 wave 
containing a layer of data for red, a layer for green and a layer for blue. It can also be a 3D NxMx4 wave 
with the fourth plane containing alpha values.
If matrix contains multiple planes other than three or four or if it contains three or four and multiple chunks, 
the ModifyImage plane keyword can be used to specify the desired subset to display.
If you provide xWaveName and yWaveName, xWaveName provides X coordinate values, and yWaveName 
provides Y coordinate values. This makes an image with uneven pixel sizes. In both cases, you can use * to 
specify calculated values based on the dimension scaling of matrix. See Details if you use xWaveName or 
yWaveName.
Flags
Details
When appending an image to a graph each image data point is displayed as a rectangle. You can supply 
optional X and Y waves to define the coordinates of the rectangle edges. These waves need to contain one more 
data point than the X (row) or Y (column) dimension of the matrix. The waves must also be either strictly 
increasing or strictly decreasing. See Image X and Y Coordinates on page II-388 for details.
For false color, the values in the matrix are linearly mapped into a color table. See the ModifyImage ctab 
keyword. For indexed color, the values in the matrix are interpreted as Z values to be looked up in a user-
supplied 3 column matrix of colors. See the ModifyImage cindex keyword. Direct color NxMx3 waves 
contain the actual red, green, and blue values for each pixel. NxMx4 waves add an alpha channel. If the 
number type is unsigned bytes, then the range of intensity ranges from 0 to 255. For all other number types, 
the intensity ranges from 0 to 65535.
By default, nondirect color matrices are initially displayed as false color using the Grays color table and 
autoscale mode.
If the matrix is complex, the image is displayed in terms of the magnitude of the Z value, that is, 
sqrt(real2 + imag2).
See Also
Image X and Y Coordinates on page II-388, Color Blending on page III-498.
The NewImage, ModifyImage, and RemoveImage operations. For general information on image plots see 
Chapter II-16, Image Plots.
axisFlags
Flags /L, /R, /B, and /T are the same as used by AppendToGraph.
/G=g
/W=winName
Appends to the named graph window or subwindow. When omitted, action will 
affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
Controls the interpretation of three-plane images as direct RGB.
g=1
Suppresses the auto-detection of three or four plane images as direct (RGB) 
color.
g=0
Same as no /G flag (default).
