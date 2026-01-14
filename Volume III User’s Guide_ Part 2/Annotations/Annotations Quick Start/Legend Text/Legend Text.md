# Legend Text

Chapter III-2 — Annotations
III-42
which are in percent of the printable page. Annotations in a page layout can not be “frozen” as they can in 
a graph.
Legends
A legend is very similar to a textbox. It shows the symbol for some or all of the traces in a graph or page 
layout. To make a legend, choose Add Annotation from the Graph or Layout menu.
The pop-up menu at the top left of the dialog sets the type of the annotation: TextBox, Tag, Legend or Col-
orScale. If you choose Legend when there is no text in the text entry area, Igor automatically generates the text 
needed for a “standard legend”. To keep the standard legend, just click Do It. However, you can also modify 
the legend text as you can for any type of annotation.
Legend Text
The legend text consists of an escape sequence to specify the trace 
whose symbol you want in the legend plus plain text. In this 
example dialog above, \s(copper) is the escape sequence that 
inserts the trace symbol (a line and a filled square marker) for the 
trace whose name is copper. This escape sequence is followed by a 
space and the name of the wave. The part after the escape sequences 
is plain text that you can edit as needed.
Instead of specifying the name of the trace for a legend symbol, you can specify the trace number. For example, 
"\s(#0)" displays the legend for trace number 0.
There are only two differences between a legend and a textbox. First, text for a legend is automatically generated 
when you choose Legend from the pop-up menu while there is no text in the text entry area. Second, if you 
append or remove a wave from the graph or rename a wave, the legend is automatically updated by adding or 
removing trace symbols. Neither of these two actions occur for a textbox, tag or color scale.
See Trace Names on page II-282 for details on trace names.
\s(copper) copper
Trace Symbol
Text following Trace Symbol
copper
