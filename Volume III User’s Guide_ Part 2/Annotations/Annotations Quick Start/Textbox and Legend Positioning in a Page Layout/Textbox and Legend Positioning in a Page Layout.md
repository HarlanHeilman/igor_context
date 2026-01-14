# Textbox and Legend Positioning in a Page Layout

Chapter III-2 — Annotations
III-41
An exterior textbox is positioned relative to a reference point on the edge of the window and the textbox is 
normally outside the plot area.
The purpose of the exterior textbox is to allow you to place a textbox away from the plot area of the graph. 
For example, you may want it to be above the top axis of a graph or to the right of the right axis. Igor tries 
to keep exterior textboxes away from the graph by pushing the graph away from the textbox.
The direction in which it pushes the graph is determined by the textbox’s anchor. If, for example, the textbox 
is anchored to the top then Igor pushes the graph down, away from the textbox. If the anchor is middle-
center, Igor does not attempt to push the graph away from the textbox. So, an exterior textbox anchored to 
the middle-center behaves like an interior textbox.
If you specify a margin, using the Modify Graph dialog, this overrides the effect of the exterior textbox, and 
the exterior textbox will not push the graph.
The XY Offset in the Position Tab gives the horizontal and vertical offset from the anchor to the textbox as 
a percentage of the horizontal and vertical sizes of the graph’s plot area for interior textboxes or the window 
sizes for exterior textboxes.
The Position pop-up menu allows you to set the position to moveable or frozen. “Frozen” means that the 
position of the textbox so that it moved with the mouse. This is useful if you are using the textbox to label 
an axis tick mark and don’t want to accidentally move it.
Textbox and Legend Positioning in a Page Layout
Annotations in a page layout window are positioned relative to an anchor point on the edge of the printable 
part of the page. The distance from the anchor point to the textbox is determined by the X and Y offsets 
right bottom
right top
left bottom
left center
left top
right center
middle top
middle bottom
Anchor Points for Interior Textboxes
middle center
right bottom
right top
left bottom
left center
left top
right center
middle top
middle bottom
Anchor Points for Exterior Textboxes
middle center
