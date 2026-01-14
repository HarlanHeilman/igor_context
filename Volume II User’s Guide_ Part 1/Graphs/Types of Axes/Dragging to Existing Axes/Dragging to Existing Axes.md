# Dragging to Existing Axes

Chapter II-13 — Graphs
II-281
3.
Remove the trace from the graph by executing:
RemoveFromGraph wave0
When you remove the last trace plotted against a given axis, Igor removes that axis from the graph.
Next we will show how to append a trace using any of the four standard axes.
4.
Select wave0 in the Data Browser, drag it to the Top drop target and pause until Top turns blue. 
Then drag the wave to the Right drop target and release the mouse.
A trace is appended to the graph using the standard right and top axes.
5.
Remove the trace from the graph by executing:
RemoveFromGraph wave0
You can cancel a drag and drop operation that you have not yet completed by dragging the wave out of the 
graph or by pressing the escape key.
Creating Free Axes by Drag and Drop
You can append a trace to a new free axis by dragging and hovering over one of the New drop targets. In 
this section, we will append a trace to a new free left axis versus the standard bottom axis. For background 
information on free axes, see Types of Axes.
1.
Select wave0 in the Data Browser, drag it to the New drop target on the left side of the graph, and 
pause until New turns blue. Then drag the wave to the Bottom drop target and release the mouse.
A dialog appears asking for a name for the new free axis:
2.
Enter left2 as the name for the new free axis an click OK.
The trace is appended versus the left2 and bottom axes.
In the history area of the command window you can see AppendToGraph and ModifyGraph com-
mands that were executed to create the new free axis and set its position.
3.
Select wave1 in the Data Browser, drag it to the New drop target on the left side of the graph, and 
pause until New turns blue. Then drag the wave to the Bottom drop target and release the mouse.
A dialog appears asking for a name for the new free axis. Enter left3.
A wave1 trace is appended versus the left3 and bottom axes. The left2 and left3 axes are identical at 
this point so you can see only one of them. In the next step we will make them distinct.
4.
Stack the left2 and left3 axes by executing:
ModifyGraph axisEnab(left2)={0,0.45}, axisEnab(left3)={0.55,1.0}
You now have a stacked graph.
You can also use the Draw Between settings of the Axis tab of the Modify Graph dialog to generate 
the axisEnab commands.
Dragging to Existing Axes
Axes that already exist in the graph, whether standard or free, act as drop targets. To append a new trace 
to an existing axis, you drag onto the existing axis and pause until it turns blue, then drag onto another drop 
target.
