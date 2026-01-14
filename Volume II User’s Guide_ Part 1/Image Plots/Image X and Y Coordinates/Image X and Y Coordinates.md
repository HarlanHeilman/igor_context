# Image X and Y Coordinates

Chapter II-16 — Image Plots
II-388
for images made with floating-point data; it is intended for integer data. It is almost impossible to enter 
exact matches for floating-point data.
When you select Explicit Mode for the first time, two entries are made for you assigning white to 0 and black 
to 255. A third blank line is added for you to enter a new value. If you put something into the blank line, 
another blank line is added.
To remove an entry, click in the blank areas of a line in the list to select it and press Delete (Macintosh) or 
Backspace (Windows).
Image X and Y Coordinates
Images display wave data elements as rectangles. They are displayed versus axes just like XY plots.
The intensity or color of each image rectangle is controlled by the corresponding data element of a matrix 
(2D) wave, or by a layer of a 3D or 4D wave, or by a set of layers of a 3D RGB or RGBA wave.
When discussing image plots, we use the term pixel to refer to an element of the underlying image data and 
rectangle to refer to the representation of a data element in the image plot.
For each of the spatial dimensions, X and Y, the edges of each image rectangle are defined by one of the 
following:
•
The dimension scaling of the wave containing the image data or
•
A 1D auxiliary X or Y wave
In the simplest case, all pixels have the same width and height so the pixels are squares of the same size. 
Another common case consists of rectangular but not square pixels all having the same width and the same 
height. Both of these are instances of evenly-spaced data. In these cases, you specify the rectangle centers 
using dimension (X and Y) scaling. This is discussed further under Image X and Y Coordinates - Evenly 
Spaced on page II-389.
Less commonly, you may have pixels of unequal widths and/or unequal heights. In this case you must 
supply auxiliary X and/or Y waves that specify the edges of the image rectangles. This is discussed further 
under Image X and Y Coordinates - Unevenly Spaced on page II-389.
It is possible to combine these cases. For example, your pixels may have uniform widths and non-uniform 
heights. In this case you use one technique for one dimension and the other technique for the other dimen-
sion.
Sometimes you may have data that is not really image data, because there is no well-defined pixel width 
and/or height, but is stored in a matrix (2D) wave. Such data may be more suitable for a scatter plot but can 
be plotted as an image. This is discussed further under Plotting a 2D Z Wave With 1D X and Y Center Data 
on page II-389.
In other cases you may have 1D X, Y and Z waves. These cases are discussed under Plotting 1D X, Y and Z 
Waves With Gridded XY Data on page II-390 and Plotting 1D X, Y and Z Waves With Non-Gridded XY 
Data on page II-391.
The following sections include example commands. If you want to execute the commands, find the corre-
sponding section in the Igor help files by executing:
DisplayHelpTopic "Image X and Y Coordinates"
