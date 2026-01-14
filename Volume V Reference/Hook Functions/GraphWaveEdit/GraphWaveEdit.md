# GraphWaveEdit

GraphWaveEdit
V-326
Details
Once drawing starts no other user actions are allowed.
In normal mode, drawing stops when you double-click or when you click the first point (in which case the 
last point is set equal to the first point). When drawing finishes, the edit mode is entered.
In freehand mode, drawing stops when the mouse is released or when 10000 points have been drawn.
If you include /O and the waves are already on the graph then the first trace instance on the graph 
displaying them is used even if the trace uses a different pair of axes than specified by /L, /R, /B, and /T.
Output Variables
See Also
The GraphNormal, GraphWaveEdit and DrawAction operations.
GraphWaveEdit 
GraphWaveEdit [flags] traceName
The GraphWaveEdit operation initiates editing a wave trace in a graph. The wave trace must already be in 
the graph.
Normally, you would initiate editing by choosing ShowTools from the Graph menu and clicking in the 
appropriate tool rather than using GraphWaveEdit.
Parameters
traceName is a wave name, optionally followed by the # character and an instance number: “myWave#1” is 
the second instance of myWave appended to the graph (“myWave” is the first).
If traceName is omitted then you get to pick the wave trace to edit by clicking it.
Flags
/L/R/B/T
Specifies which axes to use (Left, Right, Bottom, Top). Bottom and Left axes are used 
by default. Can specify free axes using /L=axis name type notation. See 
AppendToGraph for details. If necessary, the specified axes will be created. If an axis 
is created its range is set to -1 to 1.
/M
Specifies that the curve being edited must be monotonic in the X dimension. The user 
is not allowed drag points so that they cross horizontally.
/O
Overwrites yWave and xWave if they already exist.
/W=winName
Draws in the named graph window or subwindow. When omitted, action will affect 
the active window or subwindow. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
S_xWave
Path to the X wave relative to the current data folder. S_xWave is create in Igor Pro 9.00 
and later.
S_yWave
Path to the X wave relative to the current data folder. S_yWave is create in Igor Pro 
9.00 and later.
/M
Specifies that the edited trace must be monotonic in the X dimension. You cannot drag 
points so that they cross horizontally.
/ND
Suppresses deletion of a data point when the user presses Option (Macintosh) or Alt 
(Windows) and clicks on the point.
/NI
Suppresses insertion of a new data point when the user clicks between points.
