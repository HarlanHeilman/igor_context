# TileWindows

TileWindows
V-1036
Details
If /A=(rows,cols) is not used, Tile uses an appropriate number of rows and columns. If /A=(rows,cols) is used, 
objects are tiled in a grid of that many rows and columns. If rows or cols is zero, it substitutes an appropriate 
number for the zero parameter.
Objects to be tiled are determined by the /S and /O=objTypes flags and by any objectNames.
If no /S or /O flags are present and there are no objectNames, then all objects in the layout are tiled.
Otherwise the objects to be tiled are determined as follows:
•
All objects specified by objectNames are tiled.
•
If the /S flag is present, the selected objects, if any, are also tiled.
•
If the /O=objTypes flag is present then any objects specified by objTypes are also tiled. objTypes is a 
bitwise mask, so /O=3 tiles both graphs and tables.
See Also
The Stack operation.
TileWindows 
TileWindows [flags] [windowName [, windowName]…]
The TileWindows operation tiles the specified windows on the desktop (Macintosh) or in the Igor frame 
window (Windows).
Flags
/M
Specifies coordinates in centimeters.
/O=objTypes
/PA[=preserve]
/PA and /PA=1 specify that you want to preserve the rough arrangement of the objects 
to be tiled. See Preserving Your Rough Arrangement on page II-490 for details. 
Added in Igor Pro 9.00.
/R
Specifies coordinates measured in percent of the printable page.
/S
Adds selected objects to objects to be tiled.
/W=(left,top,right,bottom)
Specifies page layout area in which to tile objects. Coordinates are in points unless /I, 
/M or /R are specified before /W. /BBOX overrides /W.
/A=(rows,cols)
Specifies number of rows/columns in which to tile windows.
/C
Adds the command window to the windows to be tiled.
/G=grout
Specifies grout, the spacing between tiles, in prevailing units (points unless /I or /M 
are used).
/I
Specifies coordinates in inches.
/M
Specifies coordinates in centimeters.
/O=objTypes
Adds windows of types specified by objTypes to windows to be tiled.
Adds objects of type(s) specified by bitwise mask to list of objects to be tiled:
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Tile graphs.
Bit 1:
Tile tables.
Bit 3:
Tile pictures.
Bit 5:
Tile textboxes.
