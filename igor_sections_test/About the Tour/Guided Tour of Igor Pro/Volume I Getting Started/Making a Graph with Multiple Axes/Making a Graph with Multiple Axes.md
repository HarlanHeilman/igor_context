# Making a Graph with Multiple Axes

Chapter I-2 — Guided Tour of Igor Pro
I-36
Choosing _calculated_ from the X Wave list graphs the spiralY data values versus these calculated X 
values.
6.
Position the cursor in the interior of the graph.
The cursor changes to a cross-hair shape.
7.
Click and drag down and to the right to create a marquee as shown:
You can resize the marquee with the handles (black squares). You can move the marquee by dragging 
the dashed edge of the marquee.
8.
Position the cursor inside the marquee.
The mouse pointer changes to this shape: 
, indicating that a pop-up menu is available.
9.
Click and choose Expand from the pop-up menu.
The axes are rescaled so that the area enclosed by the marquee fills the graph.
10.
Choose EditUndo Scale Change or press Command-Z (Macintosh) or Ctrl+Z (Windows).
11.
Choose EditRedo Scale Change or press Command-Shift-Z (Macintosh) or Ctrl+Shift+Z (Win-
dows).
12.
Press Option (Macintosh) or Alt (Windows) and position the cursor in the middle of the graph.
The cursor changes to a hand shape. You may need to move the cursor slightly before it changes 
shape.
13.
With the hand cursor showing, drag about 2 cm to the left.
14.
While pressing Option (Macintosh) or Alt (Windows), click the middle of the graph and gently 
fling it to the right.
The graph continues to pan until you click again to stop it.
15.
Click the plot area of the graph to stop panning.
16.
Choose GraphAutoscale Axes or press Command-A (Macintosh) or Ctrl+A (Windows).
Continue experimenting with zooming and panning as desired.
17.
Press Command-Option-W (Macintosh) or Ctrl+Alt+W (Windows).
The graph is killed. Option (Macintosh) or Alt (Windows) avoided the normal dialog asking whether 
to save the graph.
Making a Graph with Multiple Axes
1.
Choose the WindowsNew Graph menu item.
2.
If you see a button labeled More Choices, click it.
We will use the more complex form of the dialog to create a multiple-axis graph in one step.

Chapter I-2 — Guided Tour of Igor Pro
I-37
3.
In the Y Waves list, select “spiralY”.
4.
In the X Wave list, select “spiralX”.
5.
Click Add.
The selections are inserted into the lower list in the center of the dialog.
6.
In the Y Waves list, again select “spiralY”.
7.
In the X Wave list, select “_calculated_”.
8.
Choose New from the Axis pop-up menu under the X Waves list.
9.
Enter “B2” in the name box.
10.
Click OK.
Note the command box at the bottom of the dialog. It contains two commands: a Display command 
corresponding to the initial selections that you added to the lower list and an AppendToGraph com-
mand corresponding to the current selections in the Y Waves and X Wave lists.
11.
Click Do It.
The following graph is created:
The interior axis is called a “free” axis because it can be moved relative to the plot rectangle. We will be 
moving it outside of the plot area but first we must make room by adjusting the plot area margins.
12.
Press Option (Macintosh) or Alt (Windows) and position the cursor over the bottom axis until the 
cursor changes to this shape: 
.
This shape indicates you are over an edge of the plot area rectangle and that you can drag that edge 
to adjust the margin.
13.
Drag the margin up about 2 cm. Release the Option (Macintosh) or Alt (Windows).
14.
Drag the interior axis down into the margin space you just created.
