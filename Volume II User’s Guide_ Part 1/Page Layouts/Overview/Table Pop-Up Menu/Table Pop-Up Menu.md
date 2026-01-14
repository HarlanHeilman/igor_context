# Table Pop-Up Menu

Chapter II-18 — Page Layouts
II-483
Annotation Tool
When you click the annotation tool, it becomes highlighted and the cursor changes to an I-beam. The annotation 
tool creates new annotations or modifies existing annotations. Annotations include textboxes, legends, and col-
orscales.
Clicking an existing annotation invokes the Modify Annotation dialog. Clicking anywhere else on the page 
invokes the Add Annotation dialog which you use to create a new annotation. See Page Layout Annota-
tions on page II-494 for details.
Frame Pop-Up Menu
When an object is selected, you can change its frame by choosing an item from the Frame pop-up menu. 
Each object can have no frame or a single, double, triple or shadow frame.
When you change the frame of a graph, table or picture object, its outer dimensions (width and height) do 
not change. Since the different frames have different widths, the inner dimensions of the object do change. 
In the case of graphs this is usually the desired behavior. For tables, changing the frame shows a non-inte-
gral number of rows and columns. You can restore the table to an integral number of rows and columns by 
pressing Option (Macintosh) or Alt (Windows) and double-clicking the table. For pictures, changing the 
frame slightly resizes the picture to fit into the new frame. To restore the picture to 100% sizing, press 
Option (Macintosh) or Alt (Windows) and double-click the picture.
When you change the frame of an annotation object, Igor does change the outer dimensions of the object to 
compensate for the change in width of the frame.
Misc Pop-Up Menu
The Misc pop-up menu adjusts some miscellaneous settings related to the layout.
You can choose Points, Inches, or Centimeters. This sets the units used in the info panel.
You can enable or disable the DelayUpdate item. If DelayUpdate is on, when a graph or table which corre-
sponds to an object in the layout changes, the layout is not updated until you activate it (make it the front 
window). If you disable DelayUpdate then changes to graphs or tables are reflected immediately in the 
layout. This also affects drawing commands. If you want to see the effect of drawing commands immedi-
ately, turn the DelayUpdate setting off.
DelayUpdate does not affect embedded graph and table subwindows.
DelayUpdate is a global setting that affects all existing and future layouts. When you change it in one 
layout, you change it for all layouts in all experiments.
You can use the Background Color submenu to change the layout’s background color. See Page Layout 
Background Color on page II-477 for details.
Graph Pop-Up Menu
The Graph pop-up menu provides a handy way to append a graph object to the layout layer. It contains a list 
of all the graph windows that are currently open. Choosing the name of a graph appends the graph object to 
the layout layer. The initial size of the graph object in the layout is taken from the size of the graph window.
Table Pop-Up Menu
The Table pop-up menu provides a handy way to append a table object to the layout layer. It contains a list 
of all the table windows that are currently open. Choosing the name of a table appends the table object to 
the layout layer.
