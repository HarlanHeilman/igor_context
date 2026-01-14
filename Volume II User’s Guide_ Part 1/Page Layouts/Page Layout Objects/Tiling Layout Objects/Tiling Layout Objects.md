# Tiling Layout Objects

Chapter II-18 — Page Layouts
II-487
Modifying Layout Objects
You can modify the properties of layout objects using the Modify Objects dialog. To invoke it, choose 
Modify Objects from the Layout menu or double-click an object with the layout layer arrow tool.
The effect of each property is described under Layout Object Properties on page II-486.
Once you have modified an object you can select another object from the Object list and modify it.
Automatic Updating of Layout Objects
Graph, table and Gizmo objects are dynamic. When the corresponding window changes, Igor automatically 
updates the layout object. Also, if you change the symbol for a wave in a graph and if that symbol is used 
in a layout legend, Igor automatically updates the legend.
Normally, Igor waits until the layout window is activated before doing an automatic update. You can force 
Igor to do the update immediately by deselecting the DelayUpdate item in the Misc pop-up menu in the 
layout’s tool palette.
Dummy Objects
If you append a graph, table, or 3D Gizmo plot to the layout layer, this creates a layout object corresponding 
to the window. If you then kill the original window, the layout object remains and is said to be a “dummy 
object”. A dummy object can be moved, resized or changed just as any other object.
If you later recreate the window or create a new window with the same name as the original, the object is 
reassociated with the window and ceases to be a dummy object.
Arranging Layout Objects
This section applies to layout objects in the layout layer only, not to drawing elements or subwindows.
Front-To-Back Relationship of Objects
New objects added to the layout layer are added in front of existing objects. You can move objects in front 
of or in back of other objects using the Layout menu after selecting a single object with the arrow tool.
These menu commands affect the layout layer only. To put drawing elements in front of the layout layer, 
use the User Front drawing layer. To put drawing elements behind the layout layer, User Back drawing 
layer.
Tiling Layout Objects
You can tile or stack objects in a layout by choosing the Arrange Objects item from the Layout menu. This 
displays the Arrange Objects dialog. The rest of this section refers to that dialog.
Click the Tile radio button to do tiling instead of stacking.
When you tile objects, Igor needs to know the following:
•
Which objects you want to tile
•
The area of the page into which you want to tile the objects
•
The number of rows and columns of tiles that you want
•
The spacing between tiles (grout)
You can specify all of this information via the Arrange Objects dialog.
In most cases, it is worthwhile for you pre-arrange the objects to be tiled in roughly the desired sizes and 
positions and select those objects before summoning the dialog. This facilitates using features of the dialog 
to precisely arrange the objects.
