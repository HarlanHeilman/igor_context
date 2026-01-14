# Drawing in a Graph

Chapter I-2 — Guided Tour of Igor Pro
I-24
8.
Choose dashed line #2 from the Line Style pop-up menu.
9.
Select voltage_2 in the list of traces.
10.
Choose dashed line #3 from the Line Style pop-up menu.
11.
Click Do It.
The graph should now look like this:
Offsetting a Trace
1.
Position the cursor directly over the voltage_2 trace.
The voltage_2 trace has the longer dash pattern.
2.
Click and hold the mouse button for about 1 second.
An XY readout appears in the lower-left corner of the graph and the trace will now move with the mouse.
3.
With the mouse button still down, press Shift while dragging the trace up about 1 cm and release.
The Shift key constrains movement to vertical or horizontal.
You have added an offset to the trace. If desired, you could add a tag to the trace indicating that it has 
been offset and by how much. This trace offset does not affect the underlying wave data.
Unoffsetting a Trace
4.
Choose the EditUndo Trace Drag menu item.
You can undo many of the interactive operations on Igor windows.
5.
Choose EditRedo Trace Drag.
The following steps show how to remove an offset after it is no longer undoable.
6.
Double-click the voltage_2 trace.
The Modify Trace Appearance dialog appears with voltage_2 selected. (If voltage_2 is not selected, 
select it.) The Offset checkbox is checked.
7.
Click the Offset checkbox.
This turns offset off for the selected trace and the offset controls in the dialog are hidden.
8.
Click Do It.
The voltage_2 trace is returned to its original position.
Drawing in a Graph
1.
If necessary, click Graph0 to bring it to the front.

Chapter I-2 — Guided Tour of Igor Pro
I-25
2.
Choose the GraphShow Tools menu item or press Command-T (Macintosh) or Ctrl+T (Win-
dows).
A tool palette is added to the graph. The second icon from the top (
) is selected indicating that 
the graph is in drawing mode as opposed to normal (or “operate”) mode.
3.
Click the top icon (
) to go into normal mode.
Normal mode is for interacting with graph objects such as traces, axes and annotations. Drawing 
mode is for drawing lines, rectangles, polygons and so on.
4.
Click the second icon to return to drawing mode.
5.
Click the drawing layer icon 
.
A pop-up menu showing the available drawing layers and their relationship to the graph layers 
appears. The items in the menu are listed in back-to-front order.
6.
Choose UserBack from the menu.
We will be drawing behind the axes, traces and all other graph elements.
7.
Click the rectangle tool and drag out a rectangle starting at the upper-left corner of the plot area (y= 
1.4, x=0 on the axes) and ending at the bottom of the plot area and about 1.5 cm in width (y= -0.2, x= 
1.6).
8.
Click the line tool and draw a diagonal line as shown, starting at the left, near the peak of the top 
trace, and ending at the right:
9.
Click the drawing environment icon (
) and choose At Start from the Line Arrow item.
10.
Click the Text tool icon 
.
11.
Click just to the right of the line you just drew.
The Create Text dialog appears.
12.
Type “Precharge”.
13.
From the Anchor pop-up menu, choose Left Center.
14.
Click Do It.
