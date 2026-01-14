# Legend

LayoutStyle
V-483
LayoutStyle 
LayoutStyle
LayoutStyle is a procedure subtype keyword that puts the name of the procedure in the Style pop-up menu 
of the New Layout dialog and in the Layout Macros menu. See Page Layout Style Macros on page II-498 for 
details.
See Also
See Chapter II-18, Page Layouts and Page Layout Style Macros on page II-498.
leftx 
leftx(waveName)
The leftx function returns the X value of point 0 (the first point) of the named 1D wave. The leftx function 
is not multidimensional aware. The multidimensional equivalent of this function is DimOffset.
Details
Point 0 contains a wave’s first value, which is usually the leftmost point when displayed in a graph. Leftx 
returns the value elsewhere called x0. The function DimOffset returns any of x0, y0, z0, or t0, for dimensions 
0, 1, 2, or 3.
See Also
The deltax and rightx functions.
For multidimensional waves, see DimDelta, DimOffset, and DimSize.
For an explanation of waves and X scaling, see Changing Dimension and Data Scaling on page II-68.
Legend 
Legend [flags] [legendStr]
The Legend operation puts a legend on a graph or page layout.
Parameters
legendStr contains the text that is printed in the legend.
If legendStr is missing or is an empty string (""), the text needed for a default legend is automatically 
generated. Legends are automatically updated when waves are appended to or removed from the graph or 
when you rename a wave in the graph.
legendStr can contain escape codes which affect subsequent characters in the text. An escape code is 
introduced by a backslash character. In a literal string, you must enter two backslashes to produce one. See 
Backslashes in Annotation Escape Sequences on page III-58 for details.
Using escape codes you can change the font, size, style and color of text, create superscripts and subscripts, 
create dynamically-updated text, insert legend symbols, and apply other effects. See Annotation Escape 
Codes on page III-53 for details. However normally you leave it to Igor to automatically manage the legend.
See Legend Text on page III-42 for a discussion of what legendStr may contain.
Flags
/H=legendSymbolWidth
Sets the width in points of the area in which to draw the wave symbols. A value of 0 
means “default”. This results in a width that is based on the text size in effect when the 
symbol is drawn. A value of 36 gives a 0.5 inch (36 points) width which is nice in most 
cases.
/H={legendSymbolWidth, minThickness, maxThickness}
