# legendreA

legendreA
V-484
See the TextBox operation for documentation for all other flags.
Examples
The command Legend (with no parameters) creates a default legend. A default legend in a layout contains 
a line for each wave in each of the graphs in the layout, starting from the bottom graph and working toward 
the front.
The command:
Legend/C/N=name ""
changes the named existing legend to a default legend.
You can put a legend in a page layout with a command such as:
Legend "\s(Graph0.wave0) this is wave0"
This creates a legend in the layout that shows the symbol for wave0 in Graph0. The graph named in the 
command is usually in the layout but it doesn’t have to be.
See Also
TextBox, Tag, ColorScale, AnnotationInfo, AnnotationList.
Annotation Escape Codes on page III-53.
Legend Text on page III-42.
Trace Names on page II-282, Programming With Trace Names on page IV-87.
Color as f(z) Legend Example on page II-301 for a discussion of creating a legend whose symbols match 
the markers in a graph that uses color as f(z).
legendreA 
legendreA(n, m, x)
The legendreA function returns the associated Legendre polynomial:
where n and m are integers such that 0  m  n and |x|  1.
References
Arfken, G., Mathematical Methods for Physicists, Academic Press, New York, 1985.
This is an additional form of the /H flag. The legendSymbolWidth parameter works the 
same as described above.
The minThickness and maxThickness parameters allow you to create a legend whose 
line and marker thicknesses are different from the thicknesses of the associated traces 
in the graph. This can be handy to make the legend more readable when you use very 
thin lines or markers for the traces.
minThickness and maxThickness are values from 0.0 to 10.0. Also, setting minThickness 
to 0.0 and maxThickness to 0.0 (default) uses the same thicknesses for the legend 
symbols as for the traces.
/J
Disables the default legend mechanism so that a default legend is not created even if 
legendStr is an empty string ("") or omitted.
Window recreation macros use /J in case legendStr is too long to fit on the same 
command line as the Legend operation itself. In this case, an AppendText command 
appears after the Legend command to append legendStr to the empty legend. For 
really long values of legendStr, there may be multiple AppendText commands.
/M[=saMeSize]
/M or /M=1 specifies that legend markers should be the same size as the marker in the 
graph.
/M=0 turns same-size mode off so that the size of the marker in the legend is based on 
text size.
Pn
m(x)
