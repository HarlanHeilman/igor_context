# Graph Dimensions

Chapter II-13 — Graphs
II-288
X range. Select the Autoscale Only Visible Data checkbox to have Igor use only the data included within the 
horizontal range for autoscaling. This checkbox is available only if the selected axis is a vertical axis.
Overall Graph Properties
You can specify certain overall properties of a graph by choosing Modify Graph from the Graph menu. This 
brings up the Modify Graph dialog. You can also get to this dialog by double-clicking a blank area outside 
the plot rectangle.
Normally, X axes are plotted horizontally and Y axes vertically. You can reverse this behavior by checking 
the “Swap X & Y Axes” checkbox. This is commonly used when the independent variable is depth or height. 
This method swaps X and Y for all traces in the graph. You can cause individual traces to be plotted verti-
cally by selecting the “Swap X & Y Axes” checkbox in the New Graph and Append Traces dialogs as you 
are creating your graph.
Initially, the graph font is determined by the default font which you can set using the Default Font item in the 
Misc menu. The graph font size is initially automatically calculated based on the size of the graph. You can over-
ride these initial settings using the “Graph font” and “Font size” settings. Igor uses the font and size you specify 
in annotations and axis labels unless you explicitly set the font or size for an individual annotation or label.
Initially, the graph marker size is automatically calculated based on the size of the graph. You can override 
this using the “Marker size” setting. You can set it to “auto” (or 0 which is equivalent) or to a number from 
-1 to 99. Use -1 to make a graph subwindow get is default font size from its parent. Igor uses the marker size 
you specify unless you explicitly set the marker size for an individual wave in the graph.
The “Use comma as decimal separator” checkbox determines whether dot or comma is used as the decimal 
separator in tick mark labels.
Graph Margins
The margin is the distance from an outside edge of the graph to the edge of the plot area of the graph. The plot 
area, roughly speaking, is the area inside the axes. See Graph Dimensions on page II-288 for a definition. Ini-
tially, Igor automatically sets each margin to accommodate axis and tick mark labels and exterior textboxes, 
if any. You can override the automatic setting of the margin using the Margins settings. You would do this, 
for example, to force the left margins of two graphs to be identical so that they align properly when stacked 
vertically in a page layout. The Units pop-up menu determines the units in which you enter the margin values.
You can also set graph margins interactively. If you press Option (Macintosh) or Alt (Windows) and position 
the cursor over one of the four edges of the plot area rectangle, you will see the cursor change to this shape: 
. Use this cursor to drag the margin. You can cause a margin to revert to automatic mode by dragging the 
margin all the way to the edge of the graph window or beyond. If you drag to within a few pixels of the edge, 
the margin will be eliminated entirely. If you double click with this cursor showing, Igor displays the Modify 
Graph dialog with the corresponding margin setting selected.
If you specify a margin for a given axis, the value you specify solely determines where the axis appears. 
Normally, dragging an axis will adjust its offset relative to the nominal automatic location. If, however, a 
fixed margin has been specified then dragging the axis will drag the margin.
Graph Dimensions
The Modify Graph dialog provides several ways of controlling the width and height of a graph. Usually 
you don’t need to use these. They are intended for certain specialized applications.
These techniques are powerful but can be confusing unless you understand the algorithms, described 
below, that Igor uses to determine graph dimensions.

Chapter II-13 — Graphs
II-289
The graph can be in one of five modes with respect to each 
dimension: auto, absolute, per unit, aspect, or plan. These 
modes control the width and height of the plot area of the 
graph. The plot area is the shaded area in the illustration. 
The width mode and height mode are independent.
In this graph, the axis standoff feature, described in the Mod-
ifying Axes section on page II-306, is off so the plot area 
extends to the center of the axis lines. If it were on, the plot 
area would extend only to the inside edge of the axis lines.
Auto mode automatically determines the width or height of 
the plot area based on the outside dimensions of the graph and other factors that you specify using Igor’s 
dialogs. This is the normal default mode which is appropriate for most graphing jobs. The remaining modes 
are useful for special purposes such as matching the axis lengths of two or more graphs or replicating a stan-
dard graph or a graph from a journal.
If you select any mode other than auto, you are putting a constraint on the width or height of the plot area 
which also affects the outside dimensions of the graph. If you adjust the outside size of the graph, by drag-
ging the window’s size box, by tiling, by stacking or by using the MoveWindow operation, Igor first deter-
mines the outside dimensions as you have specified them and then applies the constraints implied by the 
width/height mode that you have selected. A graph dimension can be changed by dragging with the mouse 
only if it is auto mode.
With Absolute mode, you specify the width or height of the plot area in absolute units; in inches, centime-
ters or points. For example, if you know that you want your plot area to be exactly 5 inches wide and 3.5 
inches high, you should use those numbers with an absolute mode for both the width and height.
If you want the outside width and height to be an exact size, you must also specify a fixed value for all four 
margins. For instance, setting all margins to 0.5 inches in conjunction with an absolute width of 5 inches and 
a height of 3.5 inches yields a graph whose outside dimensions will be 6 inches wide by 4.5 inches high.
The Aspect mode maintains a constant aspect ratio for the plot area. For example, if you want the width to be 
1.5 times longer than the height, you would set the width mode to aspect and specify an aspect ratio of 1.5.
The remaining modes, per unit and plan, are quite powerful and convenient for certain specialized types of 
graphs, but are more difficult to understand. You should expect that some experimentation will be required 
to get the desired results.
In Per unit mode, you specify the width or height of the plot area in units of length per axis unit. For exam-
ple, suppose you want the plot width to be one inch per 20 axis units. You would specify 1/20 = 0.05 inches 
per unit of the bottom axis. If your axis spanned 60 units, the plot width would be three inches.
Igor allows you to select a horizontal axis to control the vertical dimension or a vertical axis to control the 
horizontal direction, but it is very unlikely that you would want to do that.
In Plan mode, you specify the length of a unit in the horizontal dimension as a scaling factor times the length of 
a unit in the vertical dimension, or vice versa. The simplest use of plan scaling is to force a unit in one dimension 
to be the same as in the other, such as would be appropriate for a map. To do this, you select plan scaling for one 
dimension and set the scaling factor to 1.
Until you learn how to use the per unit and plan modes, it is easy to create a graph that is ridiculously small 
or large. Since the size of the graph is tied to the range of the axes, expanding, shrinking or autoscaling the 
graph makes its size change.
Applying plan or aspect mode to both the X and Y dimensions of a graph is a bad idea. Interactions between 
the dimensions cause huge or tiny graphs, or other bizarre results. The Modify Graph dialog does not allow 
both dimensions to be plan or aspect, or a combination of the two. However, the ModifyGraph operation 
permits it and it is left to you to refrain from doing this.
-100
-50
0
50
100
100
80
60
40
20
0
Inside Width
Plot Area
Outside Width
