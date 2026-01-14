# Textbox, Legend, and Color Scale Positioning in a Graph

Chapter III-2 — Annotations
III-40
Annotation Positioning
You can rotate the annotation into the four principal orientations with the in the Position tab's Rotation pop-
up menu. You can also enter an arbitrary rotation angle in integral degrees. Tags attached to contour traces 
and color scales have specialized rotation settings; see Modifying Contour Labels on page II-378 and Col-
orScale Size and Orientation on page III-48.
You can position an annotation anywhere in a window by dragging it and in many cases this is all you need 
to know. However, if you attend to a few extra details you can make the annotation go to the correct posi-
tion even if you resize the window or print the window at a different size.
This is particularly important when a graph is placed into a page layout window, where the size of the 
placed graph usually differs from the size of the graph window.
Annotations are positioned using X and Y offsets from “anchor points”. The meaning of these offsets and 
anchors depends on the type of annotation and whether the window is a graph, layout or Gizmo plot. Tags, 
for instance, are positioned with offsets expressed as a percentage of the horizontal and vertical sizes of the 
graph. See Tag Positioning on page III-46.
Textbox, Legend, and Color Scale Positioning in a Graph
A textbox, legend, and color scale are positioned identically, so this description will use “textbox” to refer 
to all of them. A textbox in a graph can be “interior” or “exterior” to the graph’s plot area. You choose this 
positioning option with the Exterior checkbox:
The Anchor pop-up menu specifies the precise location of the reference point on the plot area or graph window 
edges. It also specifies the location on the textbox which Igor considers to be the “position” of the textbox.
An interior textbox is positioned relative to a reference point on the edge of a graph’s plot area. (The plot 
area is the central rectangle in a graph window where traces are plotted. The standard left, right, bottom, 
and top axes surround this rectangle.)
Graph color
The background is opaque and is the same color as the graph background 
color. This is not available for annotations added to page layout windows.
Window color
The background is opaque and is the same color as the window background 
color.
Opaque
The annotation background covers objects behind. You choose the 
background color from a pop-up menu.
Transparent
Objects behind the annotation show through.
Check to make 
textbox exterior to 
graph’s plot area.
