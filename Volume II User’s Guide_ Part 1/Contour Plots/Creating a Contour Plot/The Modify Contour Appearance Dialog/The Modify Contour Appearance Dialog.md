# The Modify Contour Appearance Dialog

Chapter II-15 — Contour Plots
II-368
Instead of displaying an image plot with the contour plot, you can instruct Igor to add a color fill between 
contour levels. You can see this using these commands:
RemoveImage mat2d
ModifyContour mat2d ctabFill={*,*,Grays256,0}
Modifying a Contour Plot
You can change the appearance of the contour plot choosing GraphModify Contour Appearance. This 
displays the Modify Contour Appearance dialog. This dialog is also available as a subdialog of the New 
Contour Plot and Append Contour Plot dialogs.
You can open the Modify Contour Appearance by Shift-double-clicking the contour plot or by right-click-
ing it but not on a contour and choosing Modify Contour Appearance from the contextual menu.
Use preferences to change the default contour appearance, so you won’t be making the same changes over 
and over. See Contour Preferences on page II-380.
The Modify Contour Appearance Dialog
The following sections describe some of the contour plot parameters you can change using the Modify 
Contour Appearance dialog.
Contour Data Pop-Up Menu
The Contour Data pop-up menu shows the “contour instance name” of the contour plot being modified. 
The name of the contour plot is the same as the name of the Z wave containing the contour data.
If the graph contains more than one contour plot, you can use this pop-up menu to change all contour plots 
in the target graph.
If the graph contains two contour plots using the same Z wave name, an instance number is appended to those 
Z wave names in this pop-up menu. See Instance Notation on page IV-20, and Contour Instance Names 
on page II-376.
Contour Levels
Each contour trace draws lines at one constant Z level. The Z levels are assigned automatically or manually 
as specified in this part of the dialog.
Igor computes automatic levels by subdividing the range of Z values into approximately the number of 
requested levels. You can instruct Igor to compute the Z range automatically from the minimum and 
maximum of the Z data, or to use a range that you specify in the dialog. Igor attempts to choose “nice” 
contour levels that minimize the number of significant digits in the contour labels. To achieve this, Igor may 
create more or fewer levels than you requested.
-3
-2
-1
0
1
2
3
-3
-2
-1
0
1
2
3
 9 
 8 
 7 
 6 
 6 
 5 
 5 
 4 
 4 
 3 
 3 
 2 
 1 
 1 
 0 
 0 
 -1 
 -1 
 1 
 2 
-3
-2
-1
0
1
2
-3
-2
-1
0
1
2
AppendMatrixContour mat2d
AppendMatrixContour mat2d
AppendImage mat2d

Chapter II-15 — Contour Plots
II-369
You can specify manual levels directly in the dialog in several ways:
•
Linearly spaced levels (constant increment) starting with a first level and incrementing by a speci-
fied amount.
•
A list of arbitrary levels stored in a wave you choose from a pop-up Wave Browser.
•
A list of arbitrary levels you enter in the More Contour Levels dialog that appears when you click 
the More Contour Levels checkbox. These levels are in addition to automatic, manual, or from-wave 
levels.
The More Levels dialog can be used for different purposes:
•
To add a contour level to those already defined by the automatic, manual, or from-wave levels. You 
might do this to indicate a special feature of the data.
•
As the only source of arbitrary contour levels, for complete control of the levels. You might do this 
to slightly change a contour level to avoid problems (see Contouring Pitfalls on page II-379). Dis-
able the auto or manual levels by entering 0 for the number of levels. The only contour levels in effect 
will be those entered in the More Levels dialog.
WaveMetrics provides some utility procedures for dealing with contour levels. See “WaveMetrics Contour 
Plot Procedures” in the “WM Procedures Index” help file for details.
Update Contours Pop-Up Menu
Igor normally recalculates and redraws the contour plot whenever any change occurs that might alter its 
appearance. This includes changes to any data waves and the wave supplying contour levels, if any. Since 
calculating the contour lines can take a long time, you may want to disable this automatic update with the 
Update Contours pop-up menu.
“Off” completely disables updating of the contours for any reason. Choose “once, now” to update the 
contour when you click the Do It button. “Always” selects the default behavior of updating whenever the 
contour levels change.
Contour Labels Pop-Up Menu
Igor normally adds labels to the contour lines, and updates them whenever the contour lines change (see 
Update Contours Pop-Up Menu on page II-369). Since updating plots with many labels can take a long 
time, you may want to disable or modify this automatic update with the Labels pop-up menu.
“None” removes any existing contour labels, and prevents any more from being generated.
“Don’t update any more” keeps any existing labels, and prevents any more updates. This is useful if you 
have moved, removed, or modified some labels and you want to keep them that way.
“Update now, once” will update the labels when you click the Do It button, then prevents any more 
updates. Use this if updating the labels takes too long for you to put up with automatic updates.
“If contours change”, the default, updates the labels whenever Igor recalculates the contour lines.
“Always update” is the most aggressive setting. It updates the labels if the graph is modified in almost any 
way, such as changing the size of the graph or adjusting an axis. You might use this setting temporarily 
while making adjustments that might otherwise cause the labels to overlap or be too sparse.
Click Label Tweaks to change the number format and appearance of the contour labels with the Contour 
Labels dialog. See Modifying Contour Labels on page II-378.
For more than you ever wanted to know about contour labels, see Contour Labels on page II-377.
Line Colors Button
Click the Line Colors button to assign colors to the contour lines according to their Z level, or to make them 
all the same color, using the Contour Line Colors dialog.
Autoscaled color mapping assigns the first color in a color table to the minimum Z value of the contour data 
(not to the minimum contour level), and the last color to the maximum Z value.
