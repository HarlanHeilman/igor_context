# Page Layout Objects

Chapter II-18 — Page Layouts
II-485
Layout Contextual Menu for a Selected Object
If you Control-click or right-click on a part of the page where there is no object while objects are selected, 
the Layout contextual menu includes these items:
Recreate Selected Objects’ Windows
Runs the recreation macro for each selected graph, table or Gizmo object for which the corresponding 
window was killed.
Kill Selected Objects’ Windows
Kills the window corresponding to each selected graph, table, and Gizmo object. Before each window is 
killed, Igor displays a dialog that you can use to create or update its window recreation macro.
If you press the Option key on Macintosh while selecting this item, each window is killed with no dialog 
and without creating or updating the window recreation macro. Any changes you made to the window will 
be lost so use this feature carefully. This feature does not work on Windows because the Alt key interferes 
with menu behavior.
Show Selected Objects’ Window
Shows the corresponding windows if they are hidden.
Hide Selected Objects’ Window
Hides the corresponding windows if they are visible.
Scale Selected Objects
Changes the size of each selected layout object in terms of percent of its current size or percent of its normal 
size.
Page Layout Objects
The layout layer of a page layout page can contain five kinds of objects: graph windows, table windows, 3D 
Gizmo plot windows, annotations, and pictures. The term “layout object” references these objects in the 
layout layer only, not drawing elements or subwindows in other layers.
This table shows how you can add each of these objects to the layout layer.
Object Type
To Add Object to the Layout Layer
Graph
Use the Graph pop-up menu in the layout window.
Use the Append to Layout dialog.
Use the AppendLayoutObject operation.
Table
Use the Table pop-up menu in the layout window.
Use the Append to Layout dialog.
Use the AppendLayoutObject operation.
3D Gizmo Plots
Use the Gizmo pop-up menu in the layout window.
Use the Append to Layout dialog.
Use the AppendLayoutObject operation.
