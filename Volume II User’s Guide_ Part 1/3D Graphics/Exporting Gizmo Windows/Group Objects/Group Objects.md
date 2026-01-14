# Group Objects

Chapter II-17 — 3D Graphics
II-466
driven by a graphics card with the most VRAM.
•
Run the experiment on hardware that has more VRAM.
Advanced Gizmo Techniques
There are many advanced Gizmo options that are, by default, hidden. To display them you need to check 
the Display Advanced Options Menus checkbox in the Gizmo section of the Miscellaneous Settings dialog 
which you can access via the Misc menu. Most Gizmo users will not need these options.
Group Objects
A Gizmo group object is an encapsulation of existing Gizmo objects and operations that are treated as a 
single object in the top-level Gizmo.
To work with group objects you must enable advanced Gizmo menus in Miscellaneous Settings options. If 
you want to try the example in this section, make sure that the Display Advanced Options in Menus check-
box is checked in the Gizmos section of the Miscellaneous Settings dialog (Misc menu).
The following example illustrates how you can use a group object to create a custom marker for a scatter 
plot.
Start a new Igor experiment and execute this command:
NewGizmo/JUNK=3
This creates a simple scatter plot with default red sphere markers.
Create a group object using the + icon below the object list in the info window.
Double-click the group0 object in the object list. This opens a new info window for the group with display, 
object and attribute lists. Add a blue sphere object with a radius of 0.15 and a red cylinder object with top 
and bottom radii of 0.05 and a height of 0.3 to the group. Drag the sphere and cylinder objects to the group's 
display list.
In the Gizmo0 Info window, drag the group0 object from the object list to the bottom of the display list. The 
sphere+cylinder group appears in the Gizmo plot.
Select the group0 object in the Gizmo0 Info window display list and delete it by clicking the - icon. The 
sphere+cylinder group disappears from the Gizmo plot.
Close the group0 info window.
In the Gizmo0 Info window, double-click the randomScatter object to open the Scatter Properties dialog. In 
the Shape and Size tab of the dialog, select Object from the Fixed Shape pop-up menu and group0 from the 
pop-up menu just to the right of it. Click Do It.
