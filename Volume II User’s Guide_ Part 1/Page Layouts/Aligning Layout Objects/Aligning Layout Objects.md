# Aligning Layout Objects

Chapter II-18 — Page Layouts
II-490
bottom-most edges. Select the objects to be tiled, summon the dialog, and check the Use Bounding Box and 
Preserve Arrangement checkboxes. See Layout Tiling Guided Tour on page II-488 for an example.
If you uncheck both Use Marquee and Use Bounding Box, the tiling area is the entire page.
Setting the Number of Rows and Columns
You can set the number of rows and columns of tiles or you can leave them both on auto. If auto, Igor figures 
out a nice arrangement based on the number of objects to be tiled and the available space. Setting rows or 
columns to zero is the same as setting it to auto.
If you set both the rows and columns to a number between 1 and 100, Igor tiles the objects in a grid deter-
mined by your row/column specification. If you set either rows or columns to a number between 1 and 100 
but leave the other setting on auto, Igor figures out what the other setting should be to properly tile the 
objects. In all cases, Igor tiles starting from the top-left cell in a grid defined by the rows and columns, 
moving horizontally first and then vertically.
If the grid that you specify has fewer tiles than the number of objects to be tiled, once all of the available 
tiles have been filled, Igor starts tiling from the top-left corner again.
Setting the Space Between Tiles
To set the space between tiles, enter a value in points in the Grout edit box.
Preserving Your Rough Arrangement
If you check the Preserve Arrangement checkbox, Igor tries to keep the tiled objects in the same approxi-
mate positions as your rough pre-positioning. See Layout Tiling Guided Tour on page II-488 for an exam-
ple.
If your approximate positioning is not close enough and if you have left the number of rows and columns 
as Auto, Preserve Arrangement may get the wrong row/column arrangement. In this case, enter specific 
values for the number of rows and columns and try again.
Other Tiling Issues
Regardless of the parameters you specify, Igor clips coordinates so that a tiled object is never completely off 
the page. Also, objects are never set smaller than a minimum size or larger than the page.
If Preserve Arrangement is unchecked, objects are tiled from left to right, top to bottom. If you select objects 
in the Objects to Arrange list, they are tiled in the order in which you selected them. If you select no objects 
in the list, the order in which objects are tiled is determined by the front to back ordering of the objects in 
the layout.
Aligning Layout Objects
It is a common practice to stack a group of graphs vertically in a column. Sometimes, only one X axis is used 
for a number of vertically stacked graph. Here is an example.
