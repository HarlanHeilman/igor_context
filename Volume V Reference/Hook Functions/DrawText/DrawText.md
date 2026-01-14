# DrawText

DrawRect
V-178
DrawRect 
DrawRect [/W=winName] left, top, right, bottom
The DrawRect operation draws a rectangle in the target graph, layout or control panel within the rectangle 
defined by left, top, right, and bottom.
Flags
Details
The coordinate system as well as the rectangle’s thickness, color, dash pattern and other properties are 
determined by the current drawing environment. The rectangle is drawn in the current draw layer for the 
window, as determined by SetDrawLayer.
See Also
Chapter III-3, Drawing.
SetDrawEnv, SetDrawLayer, DrawAction, BezierToPolygon
DrawRRect 
DrawRRect [/W=winName] left, top, right, bottom
The DrawRRect operation draws a rounded rectangle in the target graph, layout or control panel within the 
rectangle defined by left, top, right, and bottom.
Flags
Details
The coordinate system as well as the rectangle’s rounding, thickness, color, dash pattern and other 
properties are determined by the current drawing environment. The rounded rectangle is drawn in the 
current draw layer for the window, as determined by SetDrawLayer.
See Also
Chapter III-3, Drawing.
The SetDrawEnv, SetDrawLayer and DrawAction operations.
DrawText 
DrawText [/W=winName] x0, y0, textStr
The DrawText operation draws the specified text in the target graph, layout or control panel. The position 
of the text is determined by (x0, y0) along with the current textxjust, textyjust and textrot settings as set by 
SetDrawEnv.
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
