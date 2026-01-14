# Controlling Contour Label Updates

Chapter II-15 — Contour Plots
II-377
Display
AppendMatrixContour zw; AppendMatrixContour zw
// Two contour plots
ModifyContour zw ctabLines={*,*,RedWhiteBlue}
// Change first plot
ModifyContour zw#1 ctabLines={*,*,BlueHot}
// Change second plot
You might have two contour plots of the same data to show different subranges of the data side-by-side. 
This example uses separate axes for each plot.
The ContourNameList function returns a string containing a list of contour instance names. Each name cor-
responds to one contour plot in the graph. ContourInfo (see page V-85) returns information about a par-
ticular named contour plot.
Contour Legends
You can create two kinds of legends appropriate for contour plots using the Add Annotation dialog: a 
Legend or a ColorScale. For more details about the Add Annotation dialog and creating legends, see 
Chapter III-2, Annotations, and the Legends (see page III-42) and Color Scales (see page III-47) sections.
A Legend annotation will display the contour traces with their associated color. A ColorScale will display the 
entire color range as a color bar with an axis that spans the range of colors associated with the contour data.
Contour Labels
Igor uses specialized tags to create the numerical labels for contour plots. Igor puts one label on every 
contour curve. Usually there are several contour curves drawn by one contour trace. The tag uses the \OZ 
escape code or the TagVal(3) function to display the contour level value in the tag instead of displaying the 
literal value. See Annotation Text Content on page III-35 for more about escape codes and tags.
You can select the rotation of contour labels using the Label Tweaks subdialog of the Modify Contour 
Appearance Dialog. You can request tangent, horizontal, vertical or both orientations. If permitted, Igor 
will prefer horizontal labels. The "Snap to" alternatives convert horizontal or vertical labels within 2 degrees 
of horizontal or vertical to exactly horizontal or vertical.
Igor positions the labels so that they don't overlap other annotations and aren't outside the graph's plot area. 
Contour labels are slightly special in that they are always drawn below all other annotations, so that they 
will never show up on top of a legend or axis label. Igor chooses label locations and tangent label orienta-
tions based on the slope of the contour trace on the screen.
Controlling Contour Label Updates
By default, Igor automatically relabels the graph only when the contour data or contour levels change, but you 
can control when labels update with the Labels pop-up menu in the Modify Contour Appearance dialog. See 
Contour Labels Pop-Up Menu on page II-369. Be aware that updating a graph containing many labels can 
be slow.
Legend
Color Scale
