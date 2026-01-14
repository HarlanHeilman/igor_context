# Display Modes

Chapter II-13 — Graphs
II-290
Sometimes you can end up with a graph whose size makes it difficult to move or resize the window. Use 
the Graph menu’s Modify Graph dialog to reset the size of the graph to something more manageable.
You can change a graph dimension by dragging with the mouse only if it is in auto mode. If you want to 
resize a graph but can't, use the Modify Graph dialog to check the width and height modes.
If you want to fully understand how Igor arrives at the final size of a graph when the width or height is 
constrained, you need to understand the algorithm Igor uses:
1.
The initial width and height are calculated. When you adjust a window by dragging, the initial 
width and height are based on the width and height to which you drag the window.
2.
If you are exporting graphics, the width and height are as specified in the Export Graphics dialog 
or in the SavePICT command.
3.
If you are printing, the width and height are modified by the effects of the printing mode, as set by 
the PrintSettings graphMode keyword.
4.
The width modes absolute and per unit are applied which may generate a new width.
5.
The height mode is applied which may generate a new height.
6.
The width modes aspect and plan are applied which may generate a new width.
Because there are many interactions, it is possible to get a graph so big that you can’t adjust it manually. If this 
occurs, use the Modify Graph dialog to set the width and height to a manageable size, using absolute mode.
Modifying Traces
You can specify each trace’s appearance in a graph by choosing Modify Trace Appearance from the Graph 
menu or by double-clicking a trace in the graph. This brings up the following dialog:
For image plots, choose Modify Image Appearance from the Graph menu, rather than Modify Trace Appearance.
For contour plots, you normally should choose Modify Contour Appearance. Use this to control the appear-
ance of all of the contour lines in one step. However, if you want to make one contour line stand out, use 
the Modify Trace Appearance dialog.
Selecting Traces to be Modified
Select the trace or traces whose appearance you want to modify from the Trace list. If you got to this dialog 
by double-clicking a trace in the graph then that trace will automatically be selected. If you select more than 
one trace, the items in the dialog will show the settings for the first selected trace.
Once you have made your selection, you can change settings for the selected traces. After doing this, you 
can then select a different trace or set of traces and make more changes. Igor remembers all of the changes 
you make, allowing you to do everything in one trip to the dialog.
Display Modes
Choose the mode of presentation for the selected trace from the Mode pop-up menu. The commonly-used 
modes are Lines Between Points, Dots, Markers, Lines and Markers, and Bars. Other modes allow you to 
draw sticks, bars and fills to Y=0 or to another trace.
1.0
0.5
0.0
-0.5
-1.0
10
8
6
4
2
0
1.0
0.5
0.0
-0.5
-1.0
10
8
6
4
2
0
Sticks to zero mode
Lines between points mode
