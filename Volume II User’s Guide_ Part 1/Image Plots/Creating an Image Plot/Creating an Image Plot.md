# Creating an Image Plot

Chapter II-16 — Image Plots
II-386
Overview
You can display image data as an image plot in a graph window. The image data can be a 2D wave, a layer 
of a 3D or 4D wave, a set of three layers containing RGB values, or a set of four layers containing RGBA 
values where A is “alpha” which represents opacity.
When discussing image plots, we use the term pixel to refer to an element of the underlying image data and 
rectangle to refer to the representation of a data element in the image plot.
Each image data value defines a the color of a rectangle in the image plot. The size and position of the rect-
angles are determined by the range of the graph axes, the graph width and height, and the X and Y coordi-
nates of the pixel edges.
If your image data is a floating point type, you can use NaN to represent missing data. This allows the graph 
background color to show through.
Images are displayed behind all other objects in a graph except the ProgBack and UserBack drawing layers 
and the background color.
An image plot can be false color, indexed color or direct color.
False Color Images
In false color images, the data values in the 2D wave or layer of a 3D or 4D wave are mapped to colors using 
a color table. This is a powerful way to view image data and is often more effective than either surface plots 
or contour plots. You can superimpose a contour plot on top of a false color image of the same data.
Igor has many built-in color tables as described in Image Color Tables on page II-392. You can also define 
your own color tables using waves as described in Color Table Waves on page II-399. You can also create 
color index waves that define custom color tables as described in Indexed Color Details on page II-400.
Indexed Color Images
Indexed color images use the data values stored in a 2D wave or layer of a 3D or 4D wave as indices into 
an RGB or RGBA wave of color values that you supply. “True color” images, such as those that come from 
video cameras or scanners generally use indexed color. Indexed color images are more common than direct 
color because they consume less memory. See Indexed Color Details on page II-400.
Direct Color Images
Direct color images use a 3D RGB or RGBA wave. Each layer of the wave represents a color component - 
red, green, blue, or alpha. A set of component values for a given row and column specifies the color for the 
corresponding image rectangle. With direct color, you can have a unique color for every rectangle. See 
Direct Color Details on page II-401.
Loading an Image
You can load TIFF, JPEG, PNG, BMP, and Sun Raster image files into matrix waves using the ImageLoad 
or the Load Image dialog via the Data menu.
You can also load images fom plain text files, HDF5 files, GIS files, and from camera hardware.
For details, see Loading Image Files on page II-157.
Creating an Image Plot
Image plots are displayed in ordinary graph windows. All the features of graphs apply to image plots: axes, 
line styles, drawing tools, controls, etc. See Chapter II-13, Graphs.
