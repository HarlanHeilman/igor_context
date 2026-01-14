# Removing Objects from the Layout Layer

Chapter II-18 — Page Layouts
II-486
Layout Object Names
Each object in the layout layer has a name so that you can manipulate it from the command line or from an 
Igor procedure as well as with the mouse. When you position the cursor over an object, its name, position 
and dimensions are shown in the info panel at the bottom of the layout window.
For a graph, table, or Gizmo object, the object name is the same as the name of the corresponding window. 
For an annotation, the object name is determined by the Textbox or Legend operation that created the anno-
tation. When you paste a picture from the clipboard into a page layout, Igor automatically gives it a name 
like PICT_0 and adds it to the current experiment’s picture gallery which you can see by choosing 
MiscPictures.
Layout Object Properties
This table shows the properties of each object in the layout layer.
All of the properties can also be set using the ModifyLayout operation from the command line or from an 
Igor procedure.
Appending a Graph, Table, or Gizmo Plot to the Layout Layer
You can append a graph, table, or 3D Gizmo plot to a layout by choosing the Append to Layout item from the 
Layout menu or by using the pop-up menus in the layout’s tool palette.
Removing Objects from the Layout Layer
You can remove objects from a layout by choosing the Remove from Layout item from the Layout menu.
You can also remove objects by selecting them and choosing EditClear or EditCut.
Removing a picture from a layout does not remove it from the picture gallery. To do that, use the Pictures 
dialog.
Annotations
Click the text (“A”) tool and then click in the page area.
Use the Add Annotation dialog.
Use the TextBox or Legend operations.
Pictures
Paste from the clipboard.
Use the Pictures dialog (Misc menu).
Use the AppendLayoutObject operation if the picture already exists in the current 
experiment’s picture gallery.
Object Property
Comment
Left coordinate
Measured from the left edge of the paper.
Set using mouse or Modify Objects dialog.
Top coordinate
Measured from the top edge of the paper.
Set using mouse or Modify Objects dialog.
Width
Set using mouse or Modify Objects dialog.
Height
Set using mouse or Modify Objects dialog.
Frame
None, single, double, triple, or shadow.
Set using Frame pop-up menu or Modify Objects dialog.
Transparency
Set using Modify Objects dialog.
Object Type
To Add Object to the Layout Layer
