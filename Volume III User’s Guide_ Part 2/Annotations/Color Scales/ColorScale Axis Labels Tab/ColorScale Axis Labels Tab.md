# ColorScale Axis Labels Tab

Chapter III-2 — Annotations
III-49
The size of a color scale is indirectly controlled by the size and orientation of the “color bar” inside the anno-
tation, and by the various axis and ticks parameters. The annotation adjusts itself to accommodate the color 
bar, tick labels, and axis labels.
When set to Auto or 0, the Width and Height settings cause the color scale to auto-size with the window 
along the color scale’s axis dimension. Horizontal color scales auto-size horizontally but not vertically, and 
vice versa. The long dimension of the color bar is automatically maintained at 75% of the graph plot area or 
Gizmo plot dimension. The short dimension is set to 15 points.
You can enter a custom setting for either scale dimension in units of percent or points. Choosing Percent from 
the menu causes Igor to resize the corresponding dimension in response to graph size changes. Choosing 
Points fixes the dimension so that it never changes.
ColorScale Axis Labels Tab
You set the axis label for the main axis, and for the second axis if any, in the ColorScale Axis Labels tab:
These settings apply 
only to ColorScales.

Chapter III-2 — Annotations
III-50
The axis label text is limited to one line. This text is the same as is used for text boxes, legends, and tags in 
the Text tab, but it is truncated to one line when the Annotation pop-up menu is changed to ColorScale.
The Units pop-up menu inserts escape codes related to the data units of the item the color scale is associated 
with. In the case of an image, contour or surface plot, the codes relate to the data units of the image, contour 
or surface matrix, or of an XYZ contour’s Z data wave.
Rotation, Margin, and Lateral Offset adjust the axis label’s orientation and position relative to the color axis.
The second axis label is enabled only if the Color Scale Ticks tab has created a second axis through user-
supplied tick value and label waves.
