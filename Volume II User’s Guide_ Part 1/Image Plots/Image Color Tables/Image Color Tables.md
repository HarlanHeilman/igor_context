# Image Color Tables

Chapter II-16 — Image Plots
II-392
your plot appears upside down.
You can flip an image vertically by reversing the Y axis, and horizontally by reversing the X axis, using the 
Axis Range tab in the Modify Axes dialog:
You can also flip the image vertically by reversing the Y scaling of the image wave.
A simpler alternative is to use NewImage instead of AppendImage. You can do this in the New Image Plot 
dialog by checking the “Use NewImage command” checkbox. NewImage automatically reverses the left 
axes.
Image Rectangle Aspect Ratio
By default, Igor does not make the image rectangles square. Use the Modify Graph dialog (in the Graph 
menu) to correct this by choosing Plan as the graph’s width mode. You can use the Plan height mode to 
accomplish the same result.
If DimDelta(imageWave,0) does not equal DimDelta(imageWave,1), you will need to enter the ratio (or 
inverse ratio) of these two values in the Plan width or height:
SetScale/P x 0,3,"", mat2dImage
SetScale/P y 0,1,"", mat2dImage
ModifyGraph width=0, height={Plan,3,left,bottom}
// or
ModifyGraph height=0, width={Plan,1/3,bottom,left}
Do not use the Aspect width or height modes; they make the entire image plot square even if it shouldn’t be.
Plan mode ensures the image rectangles are square, but it allows them to be of any size. If you want each 
image rectangle to be a single point in width and height, use the per Unit width and per Unit height modes. 
With point X and Y scaling of an image matrix, use one point per unit:
You can also flip an image along its diagonal by setting the Swap XY checkbox.
Image Polarity
Sometimes the image’s pixel values are inverted, too. False color images can be inverted by reversing the color 
table. Select the Reverse Colors checkbox in the Modify Image Appearance dialog. See Image Color Tables 
on page II-392. To reverse the colors in an index color plot is harder: the rows of the color index wave must be 
reversed.
Image Color Tables
In a false color plot, the data values in the 2D image wave are normally linearly mapped into a table of colors 
containing a set of colors that lets the viewer easily identify the data values. The data values can be loga-
rithmically mapped by using the ModifyImage log=1 option, which is useful when they span multiple 
orders of magnitude.
After SetAxis/A/R left
ModifyGraph width={Plan,1,bottom,left}
After reversing
the Grays color table
