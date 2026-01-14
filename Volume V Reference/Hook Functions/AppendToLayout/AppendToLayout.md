# AppendToLayout

AppendToLayout
V-36
Subsets of data, including individual rows or columns from a matrix, may be specified using Subrange 
Display Syntax on page II-321.
You can provide a custom name for a trace by appending /TN=traceName to the waveName specification. 
This is useful when displaying waves with the same name but from different data folders. See User-defined 
Trace Names on page IV-89 for more information.
Flags
See Also
The Display operation.
AppendToLayout 
AppendToLayout [flags] objectSpec [, objectSpec]…
The AppendToLayout operation appends the specified objects to the top layout.
The AppendToLayout operation can not be used in user-defined functions. Use the AppendLayoutObject 
operation instead.
Parameters
The optional objectSpec parameters identify a graph, table, textbox or PICT to be added to the layout. An 
object specification can also specify the location and size of the object, whether the object should have a 
frame or not, whether it should be transparent or opaque, and whether it should be displayed in high 
fidelity or not. See the Layout operation for details.
Flags
/B [=axisName]
Plots X coordinates versus the standard or named bottom axis.
/C=(r,g,b[,a])
Sets the color of appended traces. r, g, b, and a specify the color and optional opacity 
as RGBA Values.
/L [=axisName]
Plots Y coordinates versus the standard or named left axis.
/NCAT
Causes trace to be plotted normally on what otherwise is a category plot. X values are 
just category numbers but can be fractional. Category numbers start from zero. This 
can be used to overlay the original data points for a box plot.
See Combining Numeric and Category Traces on page II-362 for details.
/Q
Uses a special, quick update mode when appending to a pair of existing axes. A side 
effect of this mode is that waves that are appended are marked as not modified. This 
will prevent other graphs containing these waves, if any, from being updated 
properly.
/R [=axisName]
Plots Y coordinates versus the standard or named right axis.
/T [=axisName]
Plots X coordinates versus the standard or named top axis.
/TN=traceName
Allows you to provide a custom trace name for a trace. This is useful when displaying 
waves with the same name but from different data folders. See User-defined Trace 
Names on page IV-89 for details.
/VERT
Plots data vertically. Similar to SwapXY (ModifyGraph (axes)) but on a trace-by-
trace basis.
/W=winName
Appends to the named graph window or subwindow. When omitted, action will 
affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/G=g
Specifies grout, the spacing between tiled objects. Units are points unless /I, /M, or /R are 
specified.
/I
objectSpec coordinates are in inches.
