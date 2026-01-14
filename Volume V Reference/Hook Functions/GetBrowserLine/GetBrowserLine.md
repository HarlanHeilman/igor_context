# GetBrowserLine

GeometricMean
V-295
See Also
PrimeFactors, RatioFromNumber
GeometricMean
GeometricMean(a,b)
The GeometricMean function returns the arithmetic–geometric mean of two positive real numbers a and b. 
The mean is computed by creating two sequences {ai} and {bi} initialized to the input values: a0=a and b0=b 
with
The two sequences converge in a few iterations to a single value which is the arithmetic-geometric mean.
See Also
EllipticK, EllipticE
GetAxis 
GetAxis [/W=winName /Q] axisName
The GetAxis operation determines the axis range and sets the variables V_min and V_max to the minimum 
and maximum values of the named axis.
Parameters
axisName is usually "left", "right", "top" or "bottom", though it may also be the name of a free axis 
such as "VertCrossing".
Flags
Details
GetAxis sets V_min according to the bottom of vertical axes or left of horizontal axes and V_max according 
to the top of vertical axes or right of horizontal axes. It also sets the variable V_flag to 0 if the specified axis 
is actually used in the graph, or to 1 if it is not.
Axis ranges and other graph properties are computed when the graph is redrawn. Since automatic screen 
updates are suppressed while a user-defined function is running, if the graph was recently created or 
modified, you must call DoUpdate to redraw the graph so you get accurate axis information.
See Also
The AxisInfo function.
GetBrowserLine
GetBrowserLine(fullPathStr [, mode])
The GetBrowserLine function returns the zero-based line number of the data folder referenced by 
fullPathStr.
/Q
Prevents values of V_flag, V_min, and V_max from being printed in the history area. 
The results are still stored in the variables.
/W=winName
Retrieves axis info from the named graph window or subwindow. When omitted, 
action will affect the active window or subwindow. This must be the first flag 
specified when used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
an+1 = 1
2 an + bn
(
),
bn+1 =
anbn.
