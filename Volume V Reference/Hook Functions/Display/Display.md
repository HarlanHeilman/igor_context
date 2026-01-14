# Display

Display
V-161
Display 
Display [flags] [waveName [, waveName ]…[vs xwaveName]]
[as titleStr]
The Display operation creates a new graph window or subwindow, and appends the named waves, if any. 
Waves are displayed as 1D traces.
By default, waves are plotted versus the left and bottom axes. Use the /L, /B, /R, and /T flags to plot the 
waves against other axes.
Parameters
Up to 100 waveNames may be specified, subject to the 2500 byte command line length limit. If no wave 
names are specified, a blank graph is created and the axis flags are ignored.
If you specify “vs xwaveName”, the Y values of the named waves are plotted versus the Y values of xwaveName. 
If you don’t specify “vs xwaveName”, the Y values of each waveName are plotted versus its own X values.
If xwaveName is a text wave or the special keyword '_labels_', the resulting plot is a category plot. Each element 
of waveName is plotted by default in bars mode (ModifyGraph mode=5) against a category labeled with the 
text of the corresponding element of xwaveName or the text of the dimension labels of the first Y wave..
The Y waves for a category plot should have point scaling (see Changing Dimension and Data Scaling on 
page II-68); this is how category plots were intended to work. However, if all the Y waves have the same 
scaling, it will work correctly.
titleStr is a string expression containing the graph’s title. If not specified, Igor will provide one which 
identifies the waves displayed in the graph.
Subsets of data, including individual rows or columns from a matrix, may be specified using Subrange 
Display Syntax on page II-321.
You can provide a custom name for a trace by appending /TN=traceName to the waveName specification. 
This is useful when displaying waves with the same name but from different data folders. See User-defined 
Trace Names on page IV-89 for more information.
Flags 
/B[=axisName]
Plots X coordinates versus the standard or named bottom axis.
/FG=(gLeft, gTop, gRight, gBottom)
Specifies the frame guide to which the outer frame of the subwindow is attached 
inside the host window.
The standard frame guide names are FL, FR, FT, and FB, for the left, right, top, and 
bottom frame guides, respectively, or user-defined guide names as defined by the 
host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/HOST=hcSpec
Embeds the new graph in the host window or subwindow specified by hcSpec.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
 /I
Specifies that /W coordinates are in inches.
/K=k
/L[=axisName]
Plots Y coordinates versus the standard or named left axis.
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.

Display
V-162
Details
If /N is not used, Display automatically assigns to the graph a name of the form “Graphn”, where n is some 
integer. In a function or macro, the assigned name is stored in the S_name string. This is the name you can 
use to refer to the graph from a procedure. Use the RenameWindow operation to rename the graph.
Examples
To make a contour plot, use: 
Display; AppendMatrixContour waveName
or
Display; AppendXYZContour waveName
To display an image, use: 
Display; AppendImage waveName
or
NewImage waveName
See Also
The AppendToGraph operation.
The operations AppendImage, AppendMatrixContour, AppendXYZContour, and NewImage. For more 
information on Category Plots, see Chapter II-14, Category Plots.
The operations ModifyGraph, ModifyContour, and ModifyImage for changing the characteristics of graphs.
/M
Specifies that /W coordinates are in centimeters.
/N=name
Requests that the created graph have this name, if it is not in use. If it is in use, then 
name0, name1, etc. are tried until an unused window name is found. In a function or 
macro, S_name is set to the chosen graph name.
/NCAT
In Igor Pro 6.37 or later, allows subsequent appending of a category trace to a numeric 
plot. See for details.
/PG=(gLeft, gTop, gRight, gBottom)
Specifies the inner plot rectangle of the graph subwindow inside its host window.
The standard plot rectangle guide names are PL, PR, PT, and PB, for the left, right, top, 
and bottom plot rectangle guides, respectively, or user-defined guide names as 
defined by the host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/R[=axisName]
Plots Y coordinates versus the standard or named right axis.
/T[=axisName]
Plots Y coordinates versus the standard or named top axis.
/TN=traceName
Allows you to provide a custom trace name for a trace. This is useful when displaying 
waves with the same name but from different data folders. See User-defined Trace 
Names on page IV-89 for details.
/W=(left,top,right,bottom)
Gives the graph a specific location and size on the screen. Coordinates for /W are 
in points unless /I or /M are specified before /W.
When used with the /HOST flag, the specified location coordinates of the sides can 
have one of two possible meanings:
When the subwindow position is fully specified using guides (using the /HOST, 
/FG, or /PG flags), the /W flag may still be used although it is not needed.
1:
When all values are less than 1, coordinates are assumed to be 
fractional relative to the host frame size.
2:
When any value is greater than 1, coordinates are taken to be fixed 
locations measured in points, or Control Panel Units for control 
panel hosts, relative to the top left corner of the host frame.
