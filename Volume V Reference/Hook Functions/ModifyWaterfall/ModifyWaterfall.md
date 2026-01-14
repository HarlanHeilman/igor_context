# ModifyWaterfall

ModifyWaterfall
V-657
See Also
AppendViolinPlot, AddWavesToViolinPlot, ModifyGraph (traces)
Violin Plots on page II-337
ModifyWaterfall 
ModifyWaterfall [/W=winName] keyword = value [, keyword = value …]
The ModifyWaterfall operation modifies the properties of the waterfall plot in the top or named graph.
Parameters
keyword is one of the following:
Flags
Details
Painter’s algorithm draws the traces from back to front and erases hidden lines while modes 2, 3 and 4 
detect which line segments are hidden and suppresses the drawing of these segments.
See Also
Waterfall Plots on page II-326.
The NewWaterfall and ModifyGraph operations.
angle= a
Angle in degrees from horizontal of the angled Y axis (a =10 to 90).
axlen= len
Relative length of angled Y axis. len is a fraction between 0.1 and 0.9.
hidden= h
/W= winName
Modifies waterfall plot in the named graph window or subwindow. When omitted, 
action will affect the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
6
4
2
0
-2
-4
treatment 1
treatment 2
treatment 3
Controls the hidden line algorithm.
Hidden lines are active only when the mode is lines between points.
h=0:
Turns hidden lines off.
h=1:
Uses painter’s algorithm.
h=2:
True hidden.
h=3:
Hides lines with bottom removed.
h=4:
Hides lines using a different color for the bottom. When specified, the 
top color is the normal color for lines and the bottom color is set using 
ModifyGraph negRGB=(r,g,b[,a]).
