# Color as f(z) Legend Example

Chapter II-13 — Graphs
II-301
Pattern Number as f(z)
In “Pattern Number as f(z)” mode, you must create a Z wave that contains the actual pattern numbers for 
each data point. See Fill Patterns on page III-498 for a list of pattern numbers.
Color as f(z) Legend Example
If you have a graph that uses the color as f(z) mode, you may want to create a legend that identifies what 
the colors correspond to. This section demonstrates using the features of the Legend operation for this pur-
pose.
Execute these commands, one-at-a-time:
// Make test data
Make /O testData = {1, 2, 3}
// Display in a graph in markers mode
Display testData
ModifyGraph mode=3,marker=8,msize=5
// Create a normal legend where the symbol comes from the trace
Legend/C/N=legend0/J/A=LT "\\s(testData) First\r\\s(testData) 
Second\r\\s(testData) Third"
// Make a color index wave to control the marker color
Make /O testColorIndex = {0, 127, 225}
// Change the graph trace to use color as f(z) mode.
// Rainbow256 is the name of a built-in color table.
// The numbers 0 and 255 set the color index values that correspond to the
// first and last entries in the color table.
ModifyGraph zColor(testData)={testColorIndex,0,255,Rainbow256,0}
// Change the legend so that it shows the colors
Legend/C/N=legend0/J/A=LT "\\k(65535,0,0)\\W608 Red\r\\k(0,65535,0)\\W608 
Green\r\\k(0,0,65535)\\W608 Blue"
The result is this graph:
The last command used the \W escape sequence to specify which marker to use in the legend (08 for the 
circle marker in this case) and the marker thickness (6 means 1.0 points).
The \k escape sequence specifies the color to use for stroking the marker specified by \W. You would use 
\K to specify the marker fill color. Colors are specified in RGB format where each component falls in the 
range 0 to 65535.
3.0
2.5
2.0
1.5
1.0
2.0
1.5
1.0
0.5
0.0
 Red
 Green
 Blue
