# DrawLine

DrawLine
V-175
Flags
Details
Data waves defining Bezier curves must have 1+3*n data points. Every third data point is an anchor point 
and lies on the curve; intervening points are control points that define the direction of the curve relative to 
the adjacent anchor point.
Normally, you should create and edit a Bezier curve using drawing tools, and not calculate values. See 
Polygon Tool on page III-64 and Editing a Bezier Curve on page III-70 for instructions.
You can include the /ABS flag to suppress the default subtraction of the first point.
To change just the origin and scale without respecifying the data use:
DrawBezier xOrg, yOrg, hScaling, vScaling,{}
It is possible to separate a polygon into segments by adding coordinate pairs that are NaN. For details, see 
Segmented Bezier Curves on page III-71.
Example
For an example using Bezier curves, see Segmented Bezier Curves on page III-71.
See Also
Chapter III-3, Drawing.
Polygon Tool on page III-64 for discussion on creating Beziers. DrawPoly and DrawBezier Operations on 
page III-75 and the SetDrawEnv and SetDrawLayer operations.
DrawArc, DrawPoly, DrawAction, BezierToPolygon
DrawLine 
DrawLine [/W=winName] x0, y0, x1, y1
The DrawLine operation draws a line in the target graph, layout or control panel from (x0,y0) to (x1,y1).
Flags
Details
The coordinate system as well as the line’s thickness, color, dash pattern and other properties are 
determined by the current drawing environment. The line is drawn in the current draw layer for the 
window, as determined by SetDrawLayer.
See Also
Chapter III-3, Drawing.
The SetDrawEnv, SetDrawLayer and DrawAction operations.
/A
Appends the given vertices to the currently open Bezier (freshly drawn or current 
selection).
/ABS
Suppresses the default subtraction of the first point from the rest of the data.
/W=winName
Draws to the named window or subwindow. When omitted, action will affect the 
active window or subwindow. This must be the first flag specified when used in a 
Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/W=winName
Draws to the named window or subwindow. When omitted, action will affect the 
active window or subwindow. This must be the first flag specified when used in a 
Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
