# Subwindow Layout Mode and Guides

Chapter III-4 — Embedding and Subwindows
III-85
As an example, execute the following:
Make/O jack=sin(x/8)/x,sam=x
Display jack
Display/W=(0.5,0.14,0.9,0.7)/HOST=# sam
Notice the green and blue border around the newly created subwin-
dow:.
This indicates that it is the active subwindow. Now double click on 
the curve in the host window, outside the subwindow border. 
Change the color of the trace jack to blue and notice that the sub-
window is no longer active. Now move the mouse over the subwin-
dow and notice that the cursor changes to the usual shapes 
corresponding to the parts of the graph that it is hovering over. 
Drag out a selection rectangle in the plot area of the subwindow and 
notice that the marquee pop-up menu is available for use on the 
subwindow and that the subwindow has been activated. Depending on your actions in a window, Igor acti-
vates subwindows as appropriate and generally you do not have to be aware of which subwindow is active.
Choose Show Tools from the Graph menu and notice that the tools are provided by the main window. Tools 
and the cursor information panel are hosted by the base window but apply to the active subwindow, if any.
Click the drawing icon in the tool palette.
Notice the subwindow, which had been indicated as active using the 
green and blue border, now has a heavy frame.
You are now in a mode where you can use drawing tools on the sub-
window. To draw in the main window, click outside the subwin-
dow to make the host window active.
When in operate mode, the main menu bar includes a menu (e.g., 
Graph) appropriate for the base window. If a subwindow is of the same 
type as the base window, you can target it by clicking it to make it the 
active subwindow and using the same main menu bar menu.
To make changes to a subwindow of a different type, you can use a context click to access a menu appropriate 
for the subwindow.
In drawing mode, the main menu includes a menu appropriate for the active subwindow. For example, if the 
base window is a graph with an table subwindow, the menu bar shows the Graph menu when in operate mode. 
When the table subwindow is selected in drawing mode, the main menu bar shows the Table menu.
In drawing mode, you can right-click (Windows) or Control-click (Macintosh) to get a pop-up menu from 
which you can choose frame styles and insert new subwindows or delete the active subwindow. Deleting 
a subwindow is not undoable.
The info panel (see Info Panel and Cursors on page II-319) in a graph targets the active subgraph. You can 
not simultaneously view or move cursors in two different subgraphs.
Subwindow Layout Mode and Guides
To layout one or more subwindows in a host window, enter drawing mode, click the selector (arrow) tool and 
click in a subwindow. A heavy frame will be drawn with the name of the subwindow in the upper left. Now 
click on the frame to enter subwindow layout mode. In this mode, the subwindow is drawn with a light frame 
with handles in the middle of each side. In addition, built-in and user guides are drawn as dashed red and 
green lines.
In subwindow layout mode, you can move a subwindow dragging its frame and resize it using the handles. 
If you drag a handle close to a guide, it will snap in place and attach itself to the guide. However, if one or
