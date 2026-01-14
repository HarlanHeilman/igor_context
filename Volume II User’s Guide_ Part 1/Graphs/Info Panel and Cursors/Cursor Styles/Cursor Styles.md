# Cursor Styles

Chapter II-13 — Graphs
II-320
Cursors provide a convenient way to specify a range of points on a wave which is of particular interest. For 
example, if you want to do a curve fit to a particular range of points on a wave you can start by putting 
cursor A on one end of the range and cursor B on the other. Then you can summon the Curve Fitting dialog 
from the Analysis menu. In this dialog on the Data Options tab there is a range control. If you click the “cur-
sors” button then the range of the fit will be set to the range from cursor A to cursor B.
Using Cursors
When you first show the info panel, the cursors are at home and not associated with any wave. The slide 
control is disabled and the readout area shows no values.
To activate a cursor, click it and drag it to the desired point on the wave whose values you want to examine. Now 
the cursor appears on the graph and the cursor’s home icon turns black indicating that the cursor is active. The 
name of the wave which the cursor is on appears next to the cursor’s name. You can drag the cursor to any point 
on a trace or image plot.
To move the cursor by one element, use the arrow keys. If the cursor is on a trace, you can use the left and right 
arrow keys. If it is on an image, you can use the left, right, up, and down arrow keys. If you press Shift plus an 
arrow key, the cursor moves 10 times as far.
If the cursor is on a trace, you can drag the slide control left or right. If it is on an image, you can drag it in any 
direction.
If you have both cursors of a pair on the graph and both are active, then the slide control moves both cursors 
at once. If you want to move only one cursor you can use the mouse to drag that cursor to its new location. 
Another way to move just one cursor is to deactivate the cursor that you don’t want to move. You do this 
by clicking in the cursor’s home icon. This makes the home icon change from black to white indicating that 
the cursor is not active. Then the slide control moves only the active cursor.
You can also move both cursors of a pair at once by dragging. With both cursors on the graph, press the 
Shift key before clicking and dragging one of the cursors.
When you use the mouse to drag a cursor to a new location, Igor first searches for the trace the cursor is 
currently attached to. Only if the new location is not near a point on the current trace are all the other traces 
searched. You can use this preferential treatment of the current trace to make sure the cursor lands on the 
desired trace when many traces are overlapping in the destination region.
You can attach a cursor to a particular trace by right-clicking the cursor home icon and choosing a trace 
name from the pop-up menu.
To remove a cursor from the graph, drag it outside the plot area or right-click the cursor home icon and choose 
Remove Cursor.
Free Cursors
By default, cursors are attached to a particular point on a trace or to a particular element of an image plot. By 
contrast, you can move a free cursor anywhere within the plot area of the graph. To make a cursor free, right-
click the cursor home icon in the info panel and choose StyleFree from the resulting pop-up menu.
Cursor Styles
By default, cursors A and B are displayed in the graph using a circular icon for A and a square icon for B. 
For all other cursors, the default style is a cross. You can change the style for any cursor by right-clicking 
the cursor home icon in the info panel and using the resulting pop-up menu.
You can create a cursor style function which you can invoke later to apply a given set of cursor style settings 
Right-click the cursor home icon in the info panel and, from the resulting pop-up menu, choose 
StyleStyle FunctionSave Style Function. Igor creates a cursor style function in the built-in procedure 
window. You can edit the function to give it a more meaningful name than the default name that Igor uses.
