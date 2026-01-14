# Annotations Quick Start

Chapter III-2 — Annotations
III-34
Overview
Annotations are custom objects that add information to a graph, page layout or Gizmo plot.
Most annotations contain text that you might use to describe the contents of a graph, point out a feature of a 
wave, identify the axis that applies to a wave, or create a legend. An annotation can also contain color scales 
showing the data range associated with colors in contour and image plots.
There are four types of annotation: textboxes, legends, color scales, and tags.
A textbox contains one or more lines of text which optionally may be surrounded by a frame, rotated, col-
orized and aligned.
A legend is similar to a textbox except that it contains trace symbols for one or more waves in a graph. 
Legends are automatically updated when waves are added to or removed from the graph, or when a wave’s 
appearance is modified.
A tag is also similar to a textbox except that it is attached to a point of a trace or image and can contain 
dynamically updated text describing that point. Tags can be added to graphs, but not to page layouts or 
Gizmo plots. In contour plots, Igor automatically generates tags to label the contour lines.
A color scale contains a color bar with an axis that spans the range of colors associated with the data. Color 
scales are automatically updated when the associated data changes. A color scale can also be completely 
disassociated from any data by directly specifying a named color table and an explicit numeric range for 
the axis.
Annotations Quick Start
To Do This
Do This
To add an annotation to a graph
Choose Add Annotation from the Graph menu.
To add an annotation to a page 
layout
Choose Add Annotation from the Layout menu or click with the 
annotation (“A”) tool.
To add an annotation to a Gizmo 
plot
Choose Add Annotation from the Gizmo menu.
To modify an annotation in a graph 
or Gizmo plot
Double-click the annotation. This invokes the Modify Annotation 
dialog.
To modify an annotation in a page 
layout
Single-click the annotation with the annotation tool. This invokes 
the Modify Annotation dialog.
To change the annotation type
Use the Annotation pop-up menu in the Modify Annotation dialog, 
or use the proper Tag, TextBox, ColorScale, or Legend operation.
To move an existing annotation
Click in the annotation and drag it to the new position. If the annotation 
is frozen, this won’t work — double-click it and make it moveable in 
the Annotation Position tab.
To change a tag’s attachment point, press Option (Macintosh) or Alt 
(Windows) and drag the tag text to the new attachment point on the 
wave. This works whether or not the tag is frozen.
To duplicate an existing annotation Double-click the annotation, then click the Duplicate Textbox 
button in upper-right corner of the Modify Annotation dialog. If the 
annotation is a tag, the button is titled Duplicate Tag, etc.
To delete an annotation
Double-click the annotation, then click the Delete button in the 
Modify Annotation dialog. A tag can be deleted by dragging its 
attachment point off the graph.
