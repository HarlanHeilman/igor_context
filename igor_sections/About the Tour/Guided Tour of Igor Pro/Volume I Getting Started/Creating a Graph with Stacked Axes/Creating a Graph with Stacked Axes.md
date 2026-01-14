# Creating a Graph with Stacked Axes

Chapter I-2 — Guided Tour of Igor Pro
I-39
9.
Click once on the dock for cursor A (the round black circle).
The circle turns white, indicating that cursor A is deselected.
10.
Move the slider to the left and right.
Notice that only cursor B moves.
11.
Click cursor B in the graph and drag it to another position on either trace.
You can also drag cursors from their docks to the graph.
12.
Click cursor A in the graph and drag it completely outside the graph.
The cursor is removed from the graph and returns to its dock.
13.
Choose GraphHide Info.
14.
Click in the command window, type the following and press Return or Enter.
Print vcsr(B)
The Y value at cursor B is printed into the history area. There are many functions available for obtain-
ing information about cursors.
15.
Click in the graph and then drag cursor B off of the graph.
Removing a Trace and Axis
16.
Choose the GraphRemove from Graph menu item.
The Remove From Graph dialog appears with spiralY listed twice. When we created the graph we 
used spiralY twice, first versus spiralX to create the spiral and second versus calculated X values to 
show the sine wave.
17.
Click the second instance of spiralY (spiralY#1) and click Do It.
The sine wave and the lower axis are removed. An axis is removed when its last trace is removed.
18.
Drag the horizontal axis off the bottom of the window.
This returns the margin setting to auto. We had set it to a fixed position when we option-dragged (Macin-
tosh) or Alt-dragged (Windows) the margin in a previous step.
Creating a Graph with Stacked Axes
1.
Choose the WindowsNew Graph menu item.
2.
If you see a button labeled More Choices, click it.
3.
In the Y Waves list, select “spiralY”.
4.
In the X Wave list, select “_calculated_”.
5.
Click Add.
6.
In the Y Waves list, select “spiralX”.
7.
In the X Wave list, select “_calculated_”.
8.
Choose New from the Axis pop-up menu under the Y Waves list.
9.
Enter “L2” in the name box.
10.
Click OK.

Chapter I-2 — Guided Tour of Igor Pro
I-40
11.
Click Do It.
The following graph is created.
In the following steps we will stack the L2 axis on top of the left axis.
12.
Double-click the far left axis.
The Modify Axis dialog appears. If any other dialog appears, cancel and try again making sure the 
cursor is over the axis.
The Left axis should be selected in the Axis pop-up menu in the upper-left corner of the dialog.
13.
Click the Axis tab.
14.
Set the Left axis to draw between 0 and 45% of normal.
15.
Choose L2 from the Axis pop-up menu.
16.
Set the L2 axis to draw between 55 and 100% of normal.
17.
In the Free Axis Position box, pop up the menu reading Distance from Margin and select Fraction 
of Plot Area.
18.
Verify that the box labeled “% of Plot Area” is set to zero.
Steps 17 and 18 move the L2 axis so it is in line with the Left axis.
Why don’t we make this the default? Good question — positioning as percent of plot area was added 
in Igor Pro 6; the default behavior maintains backward compatibility.
19.
Choose Bottom from the Axis pop-up menu.
20.
Click the Axis Standoff checkbox to turn standoff off.
21.
Click Do It.
