# Tile

Tile
V-1035
Flags
Details
The TickWavesFromAxis operation depends on drawing the axis to generate the list of ticks. It causes a 
screen refresh, equivalent to calling DoUpdate, twice during its execution.
The TickWavesFromAxis operation honors your axis format settings and manual range. It works on regular 
numeric axes, log axes and date/time axes. At this time it does not work on category axes or axes using user 
ticks from waves.
See Also
User Ticks from Waves on page II-313 , ModifyGraph (axes) UserTicks, ManTicks and ManMinor 
keywords
Tile 
Tile [flags] [objectName [, objectName]…]
The Tile operation tiles the specified objects in the top page layout.
Parameters
objectName is the name of a graph, table, picture or annotation object in the top page layout.
Flags
/AUTO=mode
/DEST={textWaveName, numericWaveName}
Specifies custom names for the generated waves. textWaveName is the name of the text 
wave containing the tick labels. numericWaveName is the name of the numeric wave 
containing the axis position values for the ticks. If the waves don't already exist, they 
are created.
You may use data folder syntax as long as the data folders already exist.
The operation may create wave references for the destination waves if called in a user-
defined function. See Automatic Creation of WAVE References on page IV-72 for 
details.
/O
Tells TickWavesFromAxis that it can overwrite existing waves.
Igor returns an error if you attempt to overwrite a numeric wave with a text wave or 
a text wave with a numeric wave.
/W=winName
Specifies the graph containing the axis. This may be a subwindow path. If you omit 
/W, the top graph window is used.
/A=(rows,cols)
Specifies number of rows/columns in which to tile objects.
/BBOX[=ubb]
Specifies that you want to use the bounding box of the objects to be tiled as the tiling 
area. /BBOX overrides /W. See Specifying the Tiling Area on page II-489 for details. 
Added in Igor Pro 9.00.
/G=grout
Specifies grout, the spacing between window tiles, in prevailing coordinates (points 
unless preceded by /I, /M or /R).
/I
Specifies coordinates in inches.
Controls the axis settings that are used when generating the output waves:
If you use /AUTO=0 and the graph is currently in auto mode, the results could be 
surprising if you haven't actually set the computed manual ticks settings.
/AUTO was added in Igor Pro 9.00.
mode = 0
Computed manual tick settings are used.
mode = 1
The automatic tick settings are used (default).
mode = 2
Either computed manual ticks or auto ticks are used, depending 
on the current setting of the graph.
