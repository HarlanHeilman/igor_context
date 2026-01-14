# Examples

Chapter II-15 — Contour Plots
II-376
dialog appends “;DelayUpdate” to the Append Contour commands when a ModifyContour command is 
also generated.
The DoUpdate operation updates graphs and objects. You can call DoUpdate from a macro or function to 
force the contouring computations to be done at the desired time.
Drawing Order of Contour Traces
The contour traces are drawn in a fixed order. From back-to-front, that order is:
1.
Triangulation (Delaunay Triangulation trace, only for XYZ contours),
2.
Boundary
3.
XY markers
4.
Contour trace of lowest Z level
...
intervening contour traces are in order from low-to-high Z level...
N. Contour of highest Z level
You can temporarily override the drawing order with the Reorder Traces Dialog, the Trace Pop-Up Menu, 
or the ReorderTraces operation. The order you choose will be used until the contour traces are updated. 
See Contour Trace Updates on page II-375.
The order of a contour plot’s traces relative to any other traces (the traces belonging to another contour plot 
for instance) is not preserved by the graph’s window recreation macro. Any contour trace reordering is lost 
when the experiment is closed.
Extracting Contour Trace Data
Advanced users may want to create a copy of a private XY wave pair that describes a contour trace. You 
might do this to extract the Delaunay triangulation, or simply to inspect the X and Y values in a table, for 
example. To extract contour wave pair(s), include the Extract Contours As Waves procedure file:
#include <Extract Contours As Waves>
which adds “Extract One Contour Trace” and “Extract All Contour Traces” menu items to the Graph menu.
Another way to copy the traces into a normal wave is to use the Data Browser to browse the saved experiment. 
The contour traces are saved as waves in a temporary data folder whose name begins with “WM_CTraces_” and 
ends with the contour’s “contour instance name”. See The Browse Expt Button on page II-117 for details about 
browsing experiment files.
Contour Instance Names
Igor identifies a contour plot by the name of the wave providing Z values (the matrix wave or the Z wave). 
This “contour instance name” is used in commands that modify the contour plot.
Contour instance names are not the same as contour trace instance names. Contour instance names refer to an 
entire contour plot, not to an individual contour trace.
The Modify Contour Appearance dialog generates the correct contour instance name automatically.
Contour instance names work much the same way wave instance names for traces in a graph do. See 
Instance Notation on page IV-20.
Examples
In the first example the contour instance name is “zw”:
Display; AppendMatrixContour zw
// New contour plot
ModifyContour zw ctabLines={*,*,BlueHot}
// Change color table
In the unusual case that a graph contains two contour plots of the same data, an instance number must be 
appended to the name to modify the second plot: zw#1 is the contour instance name of the second contour plot:
