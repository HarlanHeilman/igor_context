# Creating a New Polygon

Chapter III-3 — Drawing
III-69
Drawing layers come in pairs named ProgSomething and UserSomething. User layers are provided for 
interactive drawing while Prog layers are provided for Igor programmers. This usage is just a recom-
mended convention and is not enforced. The purpose of the recommendation is to give Igor procedures free 
access to the Prog layers. If you were to draw into a Prog layer and then ran a procedure that used that layer 
then your drawing could be damaged or erased.
The top layer is the Overlay layer. It is provided for programmers who wish to add user-interface drawing 
elements without disturbing graphic elements. It is not included when printing or exporting graphics. This 
layer was added in Igor Pro 7.00.
Only drawing objects in the current layer can be selected. If you find you can not select a drawing object 
then it must be in a different drawing layer. You will have to try the other layers until you find the right one.
To move an object between layers you have to cut, switch layers and then paste.
Drawing Polygons and Bezier Curves
The polygon tool creates or edits drawing objects called polygons and, in graphs, it can create or edit waves. 
For details, see Drawing Polygons and Bezier Curves on page III-69.
A polygon is an open or closed shape with one or more line segments, or edges. Polygons can be filled with 
a color and pattern and can have arrow heads attached to the start or end.
Although you may create a closed polygon by making the beginning and ending points the same, Igor does 
not recognize it as a closed shape. You can thus open the Polygon by moving either the beginning or ending 
points. This is subject to change in a future release.
Creating a New Polygon
You can create a polygon in one of two ways:
•
Segment Mode: Each click defines a new vertex.
•
Freehand Mode: Igor adds new vertices as you sweep out a smooth curve.
To create a polygon using segment mode, click the polygon icon once. Then click at the desired location for the 
beginning of the polygon. As you move the cursor, you create a line segment. A second click anchors the first 
line segment, and begins the second. You can keep drawing line segments until the polygon is finished.
Pressing the Shift key while dragging constrains movement to angles that are increments of 15 degrees from 
horizontal or vertical.
Stop drawing by double-clicking to define the last vertex or by clicking at the first vertex. You then auto-
matically enter edit mode, the cursor changes to 
 , and vertices are marked with square handles. (For 
Bezier curves, vertices are called “anchors”.) In edit mode, you can reshape the polygon. To exit edit mode 
click the arrow tool.
To create a polygon using freehand mode, to edit an existing polygon, or to draw or edit a Bezier curve, 
click and hold on the polygon icon until the pop-up menu appears. Then choose one of these items:
•
Draw Poly: Enters the create-segmented-polygon mode in which a click starts a new segmented 
polygon. This is identical to a single click on the icon.
UserAxes
ProgFront
ProgFront
UserFront
UserFront
Overlay
Overlay
Overlay
