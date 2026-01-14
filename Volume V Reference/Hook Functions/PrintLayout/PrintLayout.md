# PrintLayout

PrintLayout
V-774
Finally there are these graphSpec options, which appear after the graph name:
Examples
You can put an entire graphSpec into a string variable and use the string variable in its place. In this case the 
name of the string variable must be preceded by the $ character. This is handy for printing from a procedure 
and also keeps the PrintGraphs command down to a reasonable number of characters. For example:
String spec0, spec1, spec2
spec0 = "Graph0(1, 1, 6, 5)/F=1"
spec1 = "Graph1(1, 6, 6, 10)/F=1"
spec2 = ""
// PrintGraphs will ignore spec2.
PrintGraphs/I $spec0, $spec1, $spec2
If you use a string for a graphSpec and that string contains no characters then PrintGraphs will ignore that 
graphSpec.
See Also
The PrintSettings, PrintTable, PrintLayout and PrintNotebook operations.
PrintLayout 
PrintLayout [/C=num /D] winName
The PrintLayout operation prints the named page layout window.
Parameters
winName is the window name of the page layout to print.
Flags
Details
Normally page layouts are printed at the highest available resolution of the output device (printer, plotter, 
or whatever). On Macintosh, it may not work properly at high resolution with some unusual output 
devices. If this happens, you can try using the /D flag to see if it works properly at the default resolution.
See Also
The PrintSettings, PrintGraphs, PrintTable and PrintNotebook operations.
/F=f
/T
Graph is transparent. This allows special effects when graphs are overlaid.
For this to be effective, the graph and its contents must also be transparent. Graphs are 
transparent only if their backgrounds are white. Annotations have their own 
transparent/opaque settings. PICTs may have been created transparent or opaque; an opaque 
PICT cannot be made transparent.
/C=num
Renders graphs, tables, and annotations in black-and-white (num=0) or in color (num=1; 
default). It has no effect on pictures, which are colored independently.
/D
Prints the layout at the default resolution of the output device. Otherwise it is printed at the 
highest resolution. This flag is of use only on Macintosh. It has no effect on Windows.
Specifies a frame around the graph.
f=0:
No frame (default).
f=1:
Single frame.
f=2:
Double frame.
f=3:
Triple frame.
f=4:
Shadow frame.
