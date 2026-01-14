# The Modify Image Appearance Dialog

Chapter II-16 — Image Plots
II-387
You can create an image plot in a new graph window by choosing WindowsNewImage Plot which 
displays the New Image Plot dialog. This dialog creates a blank graph to which the plot is appended.
The dialog normally generates two commands — a Display command to make a blank graph window, and an 
AppendImage command to append a image plot to that graph window. This creates a graph like any other 
graph but, for most purposes, it is more convenient to use the NewImage operation.
Checking the “Use NewImage command” checkbox replaces Display and AppendImage with NewImage. 
NewImage automatically sizes the graph window to match the number of pixels in the image and reverses the 
vertical axis so that pictures are displayed right-side-up.
You can show lines of constant image value by appending a contour plot to a graph containing an image. 
Igor draws contour plots above image plots. See Creating a Contour Plot on page II-367 for an example of 
combining contour plots and images in a graph.
X, Y, and Z Wave Lists
The Z wave is the wave that contains your image data and defines the color for each rectangle in the image 
plot.
You can optionally specify an X wave to define rectangle edges in the X dimension and a Y wave to define 
rectangle edges in the Y dimension. This allows you to create an image plot with rectangles of different 
widths and heights.
When you select a Z wave, Igor updates the X Wave and Y Wave lists to show only those waves, if any, that 
are suitable for use with the selected Z wave. Only those waves with the proper length appear in the X Wave 
and Y Wave lists. See Image X and Y Coordinates on page II-388 for details.
Choosing _calculated_ from the X Wave list uses the row scaling (X scaling) of the Z wave selected in the Z 
Wave list to provide the X coordinates of the image rectangle centers.
Choosing _calculated_ from the Y Wave list uses the column scaling (Y scaling) of the Z wave to provide Y 
coordinates of the image rectangle centers.
Modifying an Image Plot
You can change the appearance of the image plot by choosing Image-Modify Image Appearance. This dis-
plays the Modify Image Appearance dialog, which is also available as a subdialog of the New Image Plot 
dialog.
Tip:
Use the preferences to change the default image appearance, so you won’t be making the same 
changes over and over. See Image Preferences on page II-403.
The Modify Image Appearance Dialog
The Modify Image Appearance dialog applies to false color and indexed color images, but not direct color 
images. See Direct Color Details on page II-401.
To use indexed color, click the Color Index Wave radio button and choose a color index wave. For color 
index wave details, see Indexed Color Details on page II-400.
To use false color, click the Color Table radio button and choose a built-in color table or click the Color Table 
Wave radio button and choose a color table wave. Autoscaled color mapping assigns the first color in a color 
table to the minimum value of the image data and the last color to the maximum value. The dialog uses “Z” 
to refer to the values in the image wave. For more information, see Image Color Tables on page II-392.
Indexed and color table colors are distributed between the minimum and maximum Z values either linearly 
or logarithmically, based on the ModifyImage log parameter, which is set by the Log Colors checkbox.
Use Explicit Mode to select specific colors for specific Z values in the image. If an image element is exactly 
equal to the number entered in the dialog, it is displayed using the assigned color. This is not very useful
