# Segmented Bezier Curves

Chapter III-3 — Drawing
III-71
For example, choosing Make Sharp Corner sets the length of the control points to 0, so they lay 
directly on top of the anchor, making that point of the Bezier identical to a regular polygon. During 
editing mode, a "sharp corner" looks like a square marker with a red round marker inside of it.
•
Modify a control point or the "other" control point: Control-click (Macintosh only) or right-click a 
control point to display a contextual menu that sets the lengths and angles of the clicked control 
point or the control point on the "other side" of the control point's anchor.
For example, choosing Make Other Control Point Parallel sets the angle of the other control point so 
that the Bezier curve is tangent on both sides of the anchor to the angle already defined by the 
clicked control point.
•
Modify the control points that define the curve between two anchors: Control-click (Macintosh 
only) or right-click the curve between anchors to display a contextual menu that sets the lengths and 
angles of the two control points attached to the two anchors that start and end that curve.
For example, choosing Make 90 Degree Arc sets the angles and lengths of the two control points to 
draw a 90 degree arc between the two anchor points. In order for this choice to be available, the line 
between the two anchors must have some curve to it so that the correct orientation of the arc can be 
chosen.
Choosing Break Curve to Start Another Bezier replaces the two control points between the anchors 
with one (NaN,NaN) coordinate pair to draw two separate Beziers curves. See Segmented Bezier 
Curves below for details. Choosing Remove All Bezier Breaks removes all (NaN,NaN) coordinate 
pairs from the Bezier object.
Pressing the Shift key while dragging a Bezier control handle constrains movement to angles that are incre-
ments of 15 degrees from horizontal/vertical.
Pressing the Shift key while dragging while dragging a polygon or Bezier anchor point snaps the anchor 
location to the nearest of lines through the original anchor location and through the locations of the two 
neighboring anchor points.
Pressing Shift while dragging constrains movement to horizontal or vertical directions.
Exit edit mode by clicking the arrow tool.
After exiting edit mode, you can use the environment icon to adjust the other attributes of the polygon. You 
can even add arrows to the start or end of the polygon. Or you can double-click a polygon to invoke the 
Modify Polygon dialog.
The X0 and Y0 settings determine the location of the first point.
You can change the size of the polygon by modifying the Xscale and Yscale parameters in the dialog. For 
example, enter 0.5 for both settings to shrink the polygon to half its normal size.
Segmented Bezier Curves
It is possible to separate a Bezier curve into segments by adding coordinate pairs that are NaN. By default, 
such segments are drawn as if they are separate Bezier curves. If you fill such a curve with a color having 
transparency, any overlapping areas will darken because they are painted twice.
If you use SetDrawEnv subpaths=1, the segments are treated as subpaths within a single Bezier curve. The 
segments are drawn with no line linking the subpaths, but when filled the entire curve are treated as a 
single Bezier curve, making it possible to create a curve with internal holes. The way those holes are filled 
is affected by the SetDrawEnv fillRule keyword.
The subpaths keyword applies only to polygons created with DrawPoly and DrawBezier, not to those 
created manually. You can manually create subpaths by entering Edit Bezier mode, right-clicking the curve, 
and choosing Break Curve.
A side-effect of setting SetDrawEnv subpaths=1 is a change to the way arrows are added to segmented 
Bezier curves. With SetDrawEnv subpaths=0 (the default), arrows are added to each segment as if they are 
separate Bezier curves. With subpaths=1, the arrows are added only to the first or last points in the entire 
Bezier curve.
