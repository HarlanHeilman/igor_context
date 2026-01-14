# Insufficient Resolution

Chapter II-15 — Contour Plots
II-379
However, once you modify a label, Igor no longer considers it a contour label and will not automatically 
update it any more. When the labels are updated, the modified label will be ignored, which may result in 
two labels on a contour curve.
You may want to take complete, manual control of contour labels. In this case, set the Labels pop-up menu 
in the Modify Contour Appearance dialog to “no more updates” so that Igor will no longer update them. 
You can then make any desired changes without fear that Igor will undo them.
Contour labels are distinguished from other tags by means of the /Q flag. Tag/Q=contourInstanceName 
assigns the tag to the named contour. Igor uses the /Q flag in recreation macros to assign tags to a particular 
contour plot.
When you edit a contour label with the Modify Annotation dialog, the dialog adds a plain /Q flag (with no 
=contourInstanceName following it) to the Tag command to divorce the annotation from its contour plot.
Add the /Q=ContourInstanceName to Tag commands to temporarily assign ownership of the annota-
tion to the contour so that it is deleted when the contour labels are updated.
Contour Labels and Drawing Tools
One problem with Igor’s use of annotations as contour labels is that normal drawing layers are below anno-
tations. If you use the drawing tools to create a rectangle in the same location as some contour labels, you 
will encounter something like the following window.
You can solve this by putting the drawing in the overlay layer. See Drawing Layers on page III-68 for 
details.
Another solution is to remove the offending labels as described under Repositioning and Removing 
Contour Labels on page II-378.
Contouring Pitfalls
You may encounter situations in which the contour plot doesn’t look as you expect. This section discusses 
these pitfalls.
Insufficient Resolution
Contour curves are generally closed curves, or they intersect the data boundary. Under certain conditions, typ-
ically when using XYZ triplet data, the contouring algorithm may generate what appears to be an open curve (a 
line rather than a closed shape). This open curve typically corresponds to a peak ridge or a valley trough in the 
surface. At times, an open curve may also correspond to a line that intersects a nonobvious boundary.
The line may actually be a very narrow closed curve: zoom in by dragging out a marquee, clicking inside, 
and choosing “expand” from the pop-up menu.
If it really is a line, increasing the resolution of the data in that region, by adding more X, Y, Z triplets, may 
result in a closed curve. Selecting a higher interpolation setting using the Modify Contour Appearance 
dialog may help.
2
1
0
-1
-2
-3
-2
-1
0
1
2
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
 2 
 1 
 0 
 -1 
 -1 
 -2
