# Mover Pop-Up Menu

Chapter III-3 — Drawing
III-65
The User Shapes Tool
This tool creates drawing objects defined by procedure code written by you or another Igor user. For details 
see the DrawUserShape operation and for examples choose FileExample Experi-
mentsProgrammingUser Draw Shapes.
Drawing Environment Pop-Up Menu
TheDrawing Environment icon allows you to change properties such as line thickness, color, fill pattern, 
and other visual attributes.
You can change the attributes of existing objects, or you can change the default attributes of objects you are 
yet to create.
To change the attributes of existing objects, first select them. Then use the Drawing Environment pop-up 
menu to modify the attributes.
To change the default attributes of objects yet to be created, make sure no objects are selected. Then use the 
Drawing Environment pop-up menu to change attributes. From that point on, all new objects will have the 
new attributes, until you change them again.
The items in the menu do not affect all types of objects. The Fill Mode and Fill Color commands affect only 
enclosed shapes. The Line Dash and Line Arrow commands do not affect rectangles and ovals.
You can invoke the Modify Draw Environment dialog to change multiple attributes by choosing All from 
the Drawing Environment pop-up menu or by double-clicking an object.
Double-clicking multiple selected objects or groups of object with the selector tool also invokes the Modify 
Draw Environment dialog. In this case, the properties shown are those of the first selected object but if you 
change a property then all selected objects are affected.
Double-clicking a single drawing object with the selector tool invokes a specific dialog for objects of that 
type.
Drawing Layer Pop-up Menu
The Drawing Layer pop-up menu selects the active drawing layer. You can create and edit drawing objects 
in the active drawing layer only. See Drawing Layers on page III-68 for details.
Mover Pop-Up Menu
The Mover pop-up menu performs various actions:
•
Changing the front-to-back relationship of drawing objects in a given layer
•
Aligning drawing objects or controls to each other
•
Distributing the space between drawing objects or controls
•
Grouping and ungrouping drawing objects
•
Retrieving drawing objects or controls that are off screen
Use the Bring to Front, Send to Back, Forward and Backward commands to adjust the drawing order within 
the current drawing layer.
The Align command adjusts the positions of all the selected drawing objects relative to the first selected 
object. This works on controls as well as drawing objects.
The Distribute command evens up the horizontal or vertical spacing between selected objects. The original 
order is maintained. This operation is especially handy when working with buttons or other controls in a 
user-defined panel. This works on controls as well as drawing objects.
The Retrieve command is used to bring offscreen objects back into the viewable area. You can retrieve an 
offscreen object by selecting it from the Retrieve submenu of the Mover pop-up menu. Alternatively, if you 
press Option (Macintosh) or Alt (Windows) and select an object from the resulting pop-up menu, Igor selects
