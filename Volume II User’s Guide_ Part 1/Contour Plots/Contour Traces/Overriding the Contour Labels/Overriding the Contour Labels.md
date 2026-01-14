# Overriding the Contour Labels

Chapter II-15 — Contour Plots
II-378
Repositioning and Removing Contour Labels
Contour labels are “frozen” so that they can’t be dragged, but since they are tags, you can Option-drag (Mac-
intosh) or Alt-drag (Windows) them to a new attachment point. See Changing a Tag’s Attachment Point on 
page III-45. The labels are frozen to make them harder to accidentally move.
You can reposition contour labels, but they will be moved back, moved to a completely new position, or 
deleted when labels are updated. If you want full manual control of labels, turn off label updating before 
that happens. See Controlling Contour Label Updates on page II-377.
Here’s a recommended strategy for creating contour labels to your liking:
1.
Create the contour plot and set the graph window to the desired size.
2.
Choose GraphModify Contour Appearance, click the Label Tweaks button, and choose the rota-
tion for labels, and any other label formatting options you want.
3.
Choose “update now, once” from the Labels pop-up menu, and then click the Do It button.
4.
Option-drag or Alt-drag any labels you don’t want completely off the graph.
5.
Option-drag or Alt-drag any labels that are in the wrong place to another attachment point. You can drag 
them to a completely different trace, and the value printed in the label will change to the correct value.
To drag a label away from its attachment point, you must first unfreeze it with Position pop-up menu in the 
Annotation Tweaks dialog. See Overriding the Contour Labels on page II-378.
Adding Contour Labels
You can add a contour label with a Tag command like:
Tag/Q=ZW#1/F=0/Z=1/B=2/I=1/X=0/Y=0/L=1 'zw#1=2', 0 , "\\OZ"
An easier alternative is to use the Modify Annotation dialog to duplicate the annotation and then drag it to 
a new location.
Modifying Contour Labels
You can change the label font, font size, style, color, and rotation of all labels for a contour plot by clicking 
Label Tweaks in the Modify Contour Appearance dialog. This brings up the Contour Labels subdialog.
You can choose the rotation of contour labels from tangent, horizontal, vertical or both orientations. If both 
vertical and horizontal labels are permitted, Igor will choose vertical or horizontal with a preference for hor-
izontal labels. Selecting one of the Tangent choices creates labels that are rotated to follow the contour line. 
The "Snap to" alternatives convert labels within 2 degrees of horizontal or vertical to exactly horizontal or 
vertical.
You can choose a specific font, size, and style. The “default” font is the graph’s default font, as set by the 
Modify Graph dialog.
The background color of contour labels is normally the same as the graph background color (usually white). 
With the Background pop-up menu, you can select a specific background color for the labels, or choose the 
window background color or the transparent mode.
You can choose among general, scientific, fixed-point, and integer formats for the contour labels. These corre-
spond to printf conversion specifications, “%g”, “%e”, “%f”, and “%d”, respectively (see the printf). These spec-
ifications are combined with TagVal(3) into a dynamic text string that is used in each tag.
For example, choosing a Number Format of “###0.0...0” with 3 Digits after Decimal Point in the Contour-
Labels dialog results in the contour tags having this as their text: \{"%.3f",tagVal(3)}. This format will 
create contour labels such as “12.345”.
Overriding the Contour Labels
Since Igor implements contour labels using standard tags, you can adjust labels individually by simply 
double-clicking the label to bring up the Modify Annotation dialog.
