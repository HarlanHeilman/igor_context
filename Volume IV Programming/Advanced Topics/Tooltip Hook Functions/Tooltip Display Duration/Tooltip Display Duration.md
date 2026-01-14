# Tooltip Display Duration

Chapter IV-10 — Advanced Topics
IV-311
s.tooltip = GetWavesDataFolder(w, 2)
// Replace Igor's tooltip
if (WaveDims(w) > 0)
s.tooltip += "[" + num2str(s.row) + "]"
if (WaveDims(w) > 1)
s.tooltip += "[" + num2str(s.column) + "]"
endif
endif
endif
return hookResult
End
Use the SetWindow operation to establish the tooltip hook function for a given window, like this:
SetWindow Graph0, tooltipHook(MyTooltipHook) = MyGraphTraceTooltipHook
You can clear the tooltip function like this:
SetWindow Graph0, tooltipHook(MyTooltipHook) = $""
Because the hook function runs during an operation that cannot be interrupted without crashing Igor, the 
debugger cannot be invoked while it is running. Consequently breakpoints set in the function are ignored. 
Use Debugging With Print Statements on page IV-212 instead.
Tooltip Tracking Rectangle
When your function is called, the WMTooltipHookStruct trackRect field is set to a tracking rectangle in local 
window coordinates. When the tooltip is displayed, the tooltip system tracks the mouse. If the mouse leaves 
the tracking rectangle, the tooltip is hidden. If the the mouse enters another area appropriate for display of 
a tooltip, the hook function is called again.
In a graph, the tracking rectangle is a 20x20 point rectangle around the mouse location. In a table, the track-
ing rectangle corresponds to the bounds of the table cell under the mouse. If the mouse hovers over a con-
trol, the tracking rectangle is the bounding box of the control.
The trackRect field is both an input and an output. You can modify it to change when the tooltip disappears, 
but this is rarely necessary. You might want to do it if, for instance, you want to define help text for different 
parts of a control.
HTML Tags in Tooltips
You can control formatting of the tooltip by including certain HTML tags in the text. The subset of tags sup-
ported is described here: http://doc.qt.io/qt-5/richtext-html-subset.html
To use HTML tags, start your text with "<html>", end it with "</html>", and set the structure field isHTML 
to 1.
For example, this code:
s.tooltip = "<html><font size=\"+2\">Large</font> and <b>bold</b> text</html>"
s.isHTML=1
results in this tooltip: This tooltip has large and bold text
The Tooltip Row, Column, Layer and Chunk Fields
These fields specify the wave element of the wave associated with the graph trace, graph image, or table 
cell under the mouse. A value of -1 indicates that the dimension is not used.
Tooltip Display Duration
By default, Igor displays a tooltip for 10 seconds or longer for long messages. After that time, the tooltip 
disappears.
