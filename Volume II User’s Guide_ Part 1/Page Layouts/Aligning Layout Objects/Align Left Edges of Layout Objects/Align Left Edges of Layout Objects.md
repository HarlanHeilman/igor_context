# Align Left Edges of Layout Objects

Chapter II-18 — Page Layouts
II-491
This section gives step-by-step instructions for creating a layout like the one above. It is also possible to do 
this using a single graph (see Creating Stacked Plots on page II-324 for details) or using subwindows (see 
Chapter III-4, Embedding and Subwindows).
To align the axes of multiple graph objects in a layout, it is critical to set the graph margins. This is explained 
in detail as follows.
The basic steps are:
1.
Prepare the graphs.
2.
Append the graph objects to the layout.
3.
Align the left edges of the graph objects.
4.
Set the width and height of the graph objects.
5.
Set the vertical positions of the graph objects.
6.
Set the graph plot areas and margins to uniform values.
It is possible to do steps 3, 4, and 5 at once by using the Arrange Objects dialog. However, in this section, 
we will do them one-at-a-time.
Prepare the Graphs
It is helpful to set the size of the graph windows approximately to the size you intend to use in the layout 
so that what you see in the graph window will resemble what you get in the layout. You can do this man-
ually or you can use the MoveWindow operation. For example, here is a command that sets the target 
window to 5 inches wide by 2 inches tall, one inch from the top-left corner of the screen.
MoveWindow/I 1, 1, 1 + 5, 1 + 2
In the example shown above, we wanted to hide the X axes of all but the bottom graph. We used the Axis tab 
of the Modify Graph dialog to set the axis thickness to zero and the Label Options tab to turn the axis labels off.
Append the Graphs to the Layout
Click in the layout window or create a new layout using the New Layout item in the Windows menu. If 
necessary, activate the layout tools by clicking the layout icon in the top-left corner of the layout. Use the 
Graph pop-up menu or the Append to Layout item in the Layout menu to add the graph objects to the 
layout. Drag each graph object to the general area of the layout page where you want it.
Align Left Edges of Layout Objects
Drag one of the graphs to set its left position to the desired location. Then Shift-click the other graphs to 
select them. Now choose AlignLeft Edges from the Layout menu.
1.2v
0.8
0.4
0.0
 
Sample 1
1.2v
0.8
0.4
0.0
 
Sample 2
1.2v
0.8
0.4
0.0
 
10
8
6
4
2
0
μs
Sample 3
Pulse Amplitude (Volts)
Trigger
