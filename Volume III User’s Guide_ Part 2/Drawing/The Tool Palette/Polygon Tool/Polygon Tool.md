# Polygon Tool

Chapter III-3 — Drawing
III-64
Lines and Arrows Tool
You can use the Lines tool to draw lines by clicking at the desired starting point and then dragging to the 
desired ending point. Press Shift while drawing to constrain the line to be vertical or horizontal.
If you click and hold on the Lines icon, you get a pop-up menu that takes you to a dialog where you can 
specify the line numerically. You see a similar dialog if you use the arrow tool to double-click a line. It allow 
you to change the properties of the line.
The dash pattern pop-up palette is the same as the one used for graph traces. You can adjust the dash pat-
terns by use of the Dashed Lines command in the Misc menu.
The arrow fatness parameter is the desired ratio of the width of the arrow head to its length.
The line thickness and arrow length parameters are specified in terms of points and may be fractional.
Line start and end coordinates depend on the chosen coordinate system. See Drawing Coordinate Systems 
on page III-66 for detailed discussion. Programmers should note that the ends of a line are centered on the 
start and end coordinates. This is more obvious when the line is very thick.
Rectangle, Rounded Rectangle, Oval
The Rectangle, Rounded Rectangle, and Oval tools create objects that are defined by an enclosing rectangle. 
Click and hold on the appropriate icon to invoke a dialog where you can specify the object numerically. You 
see a similar dialog if you use the arrow tool to double-click the object.
Press Shift while initially dragging out the object to create a square or circle. If you press Shift while resizing 
the object with the arrow tool, you constrain the object in the horizontal, vertical, or diagonal directions 
depending on how close the cursor is to one of these directions. Thus, when you Shift-drag along a diagonal 
the sides are constrained to equal length, but if you Shift-drag along a horizontal or vertical direction, the 
object is resized along only one of these directions. If instead you hold down Option (Macintosh) or Alt (Win-
dows), dragging along a diagonal resizes the object proportionally.
The Erase fill mode functions by filling the area with the current background color of the window. The fill 
background color is used only when a fill pattern other than Solid or Erase is chosen.
An object is always drawn inside the mathematical rectangle defined by its coordinates no matter how thick 
the lines. This differs from straight lines which are centered on their coordinates.
To adjust the corners of a rounded rectangle, double-click the object and edit the RRect Radius setting in the 
resulting dialog. Units are in points.
Arcs and Circles
To draw an arc or a circle by center and radius, click and hold on the Oval icon and choose Draw Arc from 
the resulting pop-up menu. Click and drag to define the center and the radius or start angle. Click again 
without moving the mouse to create a circle or move and click to define the stop angle for an arc. A variety 
of click and click-drag methods are supported and experimentation is encouraged.
To edit an arc, click and hold on the Oval icon in the draw tool panel and then choose Edit Arc from the 
resulting pop-up menu. If necessary, click on an arc to select it. You can then drag the origin, radius, start 
angle, and stop angle.
To change the appearance of an arc, double click to get to the Modify Arc dialog. Unlike Ovals, Arcs honor the 
current dash pattern and arrowhead setting in the same way as polygons and Beziers. The center of an arc or 
circle can be in any coordinate system (see Drawing Coordinate Systems on page III-66) but the radius is always 
in points.
Polygon Tool
The polygon tool creates or edits drawing objects called polygons and, in graphs, it can create or edit waves. 
For details, see Drawing Polygons and Bezier Curves on page III-69.
