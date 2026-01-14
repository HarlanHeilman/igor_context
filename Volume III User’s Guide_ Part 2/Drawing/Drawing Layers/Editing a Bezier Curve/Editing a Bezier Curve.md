# Editing a Bezier Curve

Chapter III-3 — Drawing
III-70
•
Freehand Poly: Enters create-freehand-polygon mode in which a click starts a freehand polygon. 
Click and drag to sweep out a smooth curve as long as you press the mouse button. When you 
release the mouse button, you automatically enter edit mode, where you can change the shape.
•
Edit Poly: Enters edit-polygon mode for editing an existing polygon as described in the next section.
•
Draw Bezier: Enters create-Bezier-polygon mode in which a click starts a Bezier polygon. Click and 
drag to define anchor and control points. Click on the first point to close the curve.
•
Edit Bezier: Enters edit-Bezier-polygon mode for editing an existing Bezier polygon as described in 
the next section. You may need to click on a Bezier curve to select it.
Editing a Polygon
To enter edit mode, click and hold on the polygon icon, and choose Edit Poly from the pop-up menu. Then 
click the polygon object you want to edit.
While in edit mode you can move, add, and delete vertices, and move line segments:
•
Move a vertex: Click and drag the vertex to move it and stretch the associated edges.
•
Create a new vertex: Click between vertices in a line segment.
•
Delete vertices: Press Option (Macintosh) or Alt (Windows) and click the vertex you want to delete.
•
Offset pairs of vertices: Press Command (Macintosh) or Ctrl (Windows), click a line segment, and drag.
Segmented Polygons
It is possible to separate a polygon into segments by adding coordinate pairs that are NaN. By default, such 
segments are drawn as if they are separate polygons. If you fill such a polygon with a color having trans-
parency, any overlapping areas will darken because they are painted twice.
If you use SetDrawEnv subpaths=1, the segments are sub paths within a single polygon. The segments are 
drawn with no line linking the subpaths, but when filled the entire polygon are treated as a single polygon, 
making it possible to create a polygon with internal holes. The way those holes are filled is affected by the 
SetDrawEnv fillRule keyword.
The subpaths keyword applies only to polygons created with DrawPoly and DrawBezier, not to those 
created manually. You can manually create subpaths by entering Edit Polygon mode, right-clicking a line 
segment of the polygon, and choosing Break Line.
A side-effect of setting SetDrawEnv subpaths=1 is a change to the way arrows are added to segmented poly-
gons: with SetDrawEnv subpaths=0 (the default), arrows are added to each segment as if they are separate 
polygons. With subpaths=1, the arrows are added only to the first or last points in the entire polygon.
Editing a Bezier Curve
There are a number of operations you can perform to edit a Bezier curve:
•
Move an anchor point: Click and drag the anchor point to move it and stretch the associated curves.
•
Move a control point: Click and drag it. If an anchor point has two control points, this move both.
•
Move only one of two control points associated with an anchor point: Click the control point, then 
press Option (Macintosh) or Alt (Windows), and drag the control point.
•
Move a control point that is directly above an anchor point: Press Command (Macintosh) or Ctrl 
(Windows), click the control point (and anchor), then drag the control point.
•
Create a new anchor point: Click the curve between anchor points.
•
Delete an anchor point: Press Option (Macintosh) or Alt (Windows) and then click the anchor point.
•
Modify an anchor point's control points: Control-click (Macintosh only) or right-click an anchor to 
display a contextual menu that sets the lengths and angles of the control points on each side of the 
anchor.
