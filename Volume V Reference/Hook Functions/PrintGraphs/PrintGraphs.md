# PrintGraphs

PrintGraphs
V-773
See Also
The sprintf, fprintf, and wfprintf operations; Creating Formatted Text on page IV-259 and Escape 
Sequences in Strings on page IV-14.
PrintGraphs 
PrintGraphs [flags] graphSpec [, graphSpec]…
The PrintGraphs operation prints one or more graphs.
PrintGraphs prints one or more graphs on a single page from the command line or from a procedure. The 
graphs can be overlaid or positioned any way you want.
Parameters
The graphSpec specifies the name of a graph to print, the position of the graph on the page and some other 
options.
Flags
Details
Graph coordinates are in inches (/I) or centimeters (/M) relative to the top left corner of the physical page. 
If none of these options is present, coordinates are assumed to be in points.
The form of a graphSpec is:
graphName [(left, top, right, bottom)] [/F=f] [/T]
Here are some examples:
// Take size and position from window size and position.
PrintGraphs Graph0, Graph1
// Specify size and position explicitly.
PrintGraphs/I Graph0(1, 1, 6, 5)/F=1, Graph1(1, 6, 6, 10)/F=1
If the coordinates are missing and the /T or /S flags are present before graphSpec then the graphs are tiled or 
stacked. If the coordinates are missing but no /T or /S flags are present then the graph is sized and 
positioned based on its position on the desktop.
/C=num
Renders graphs in black and white (num=0) or in color (num=1; default).
/D
Disables high resolution printing. This flag is of use only on Macintosh. It has no effect on 
Windows.
/G=grout
Specifies grout, the spacing between objects, for tiling in prevailing units.
/I
Coordinates are in inches.
/M
Coordinates are in centimeters.
/R
Coordinates are in percent of page size (see Examples).
/PD[=d]
Displays print dialog. This allows the user to use Print Preview or to print to a file.
/S
Stacks graphs.
/T
Tiles graphs.
If present the /PD flag must be the first flag.
d=0:
Default. Prints without displaying the Print dialog.
d=1:
Displays the Print dialog. /PD is equivalent to /PD=1.
d=2:
Displays the Print Preview dialog. Requires Igor Pro 7.00 or later.
