# Tags

Chapter III-2 — Annotations
III-43
Symbol Conditions at a Point
You can create a legend symbol that shows the conditions at a specific point of a trace by appending the point 
number in brackets to the trace name. For example \s(copper[3]). This feature is useful when a trace uses f(z) 
mode or when a single point on a trace has been customized.
Freezing the Legend Text
Occasionally you may not want the legend to update automatically when you append waves to the graph. 
You can freeze the legend text by converting the annotation to a textbox. To create a non-updating legend, 
invoke the Add Annotation dialog. Choose Legend from the pop-up menu to get Igor to create the legend 
text, then choose TextBox from the pop-up menu. Now you have converted the legend to a textbox so it will 
not be automatically updated.
Marker Size
A trace symbol includes a marker if the trace is drawn with one.
Normally the size of the marker drawn in the annotation is based on the font size in effect when the marker 
is drawn. When you set the font size before the trace symbol escape code, both the marker and following 
text are adjusted in proportion. You can also change the font size after the trace symbol, which sets the size 
of the following text without affecting the marker size.
The second method for setting the size of a marker is to choose “Same as on Graph” from the Marker Size 
pop-up menu in the Symbols Tab. Then the marker size matches the size of the corresponding marker in 
the graph, regardless of the size of the annotation’s text font.
Trace Symbol Centering
Some trace symbols are vertically centered relative to either the text that precedes or the text that follows 
the trace symbol escape code, and other symbols are drawn with their bottom at the baseline.
Among the trace styles whose symbols are centered are lines between points, dots, markers, lines and mark-
ers, and cityscape. Among the trace styles whose symbols are drawn from the baseline are lines from zero, 
histogram bars, fill to zero, and sticks and markers.
Trace Symbol Width
The trace symbol width is the width in which all trace symbols in a given legend are drawn. This width is 
controlled by the font size of the text preceding the trace symbol, or it is set explicitly to a given number of 
points using the Symbol Width value in the Symbols Tab.
You can widen or narrow the overall symbol size by entering a nonzero width value for Symbol Width. If 
you use large markers with small text, you may find it necessary to reduce the trace symbol width using 
this setting. For some line styles that have long dash/gap patterns, you will want to enter an explicit value 
large enough to show the pattern.
Symbol With Color as f(z)
If you create a graph that uses color as f(z) you may want to create a legend. See Color as f(z) Legend 
Example on page II-301 for a discussion of how to do this.
Tags
A tag is like a textbox but with several added capabilities. A tag is attached to a particular point on a par-
ticular trace, image, or waterfall plot in a graph:
