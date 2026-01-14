# Error Bars

Chapter II-13 — Graphs
II-304
Error Bars
The Error Bars checkbox in the Modify Trace Appearance dialog adds error bars to the selected trace. When 
you select this checkbox or click the Options button, Igor presents the Error Bars subdialog.
Error bars are a style that you can add to a trace in a graph. Error values can be a constant number, a fixed 
percent of the value of the wave at the given point, the square root of the value of the wave at the given 
point, or they can be arbitrary values taken from other waves. In this last case, the error values can be set 
independently for the up, down, left and right directions.
Choose the desired mode from the Y Error Bars and X Error Bars pop-up menus.
The dialog changes depending on the selected mode. For the “% of base” mode, you enter the percent of the 
base wave. For the “sqrt of base” mode, you don’t need to enter any further values. This mode is meaningful 
only when your data is in counts. For the “constant” mode, you enter the constant error value for the X or Y 
direction. For the “+/- wave” mode, you select the waves to supply the positive and negative error values.
If you select “+/- wave”, pop-up menus appear from which you can choose the waves to supply the upper 
and lower or left and right error values. These waves are called error waves. The values in error waves 
should normally all be positive since they specify the length of the line from each point to its error bar. This 
is the only mode that supports single-sided error bars. Error waves do not have to have the same numeric 
type and length as the base wave. If the value of a point in an error wave is NaN then the error bar corre-
sponding to that point is not drawn.
The Cap Width setting sets the width of the cap on the end of an error bar as an integral number of points. 
You can also set the cap width to “auto” (or to zero) in which case Igor picks a cap width appropriate for 
the size of the graph. In this case the cap width is set to twice the size of the marker plus one. For best results 
the cap width should be an odd number.
You can set the thickness of the cap and the thickness of the error bar. The units for these settings are points. 
These can be fractional numbers. Nonintegral thicknesses are properly produced when exporting or print-
ing. If you set Cap Thickness to zero no caps are drawn. If you set Bar Thickness to zero no error bars are 
drawn.
If you enable the “XY Error box” checkbox then a box is drawn rather than an error bar to indicate the region 
of uncertainty. No box is drawn for points for which one or more of the error values is NaN.
Here is a simple example of a graph with error bars.
The top trace used the “+/- Wave” mode with only a +wave. The last value of the error wave was made neg-
ative to reverse the direction of the error bar.
3.0
2.5
2.0
1.5
1.0
0.5
0.0
-0.5
1.4
1.2
1.0
0.8
0.6
0.4
0.2
0.0
-0.2
