# Adding a Legend

Chapter I-2 — Guided Tour of Igor Pro
I-16
29.
Click the Minor Ticks checkbox so it is checked.
30.
Click the Ticks and Grids tab.
31.
Choose Inside from the Location pop-up.
32.
Choose the left axis from the Axis pop-up menu in the top-left corner of the dialog and then repeat 
steps 8 through 13.
33.
Click Do It.
The graph should now look like this:
 
34.
Again double-click the bottom axis.
The Modify Axis dialog appears again.
35.
Click the Axis tab.
36.
Uncheck the Standoff checkbox.
37.
Choose the left axis from the Axis pop-up menu and repeat step 18.
38.
Click Do It.
Notice that some of the markers now overlap the axes. The axis standoff setting offsets the axis so that 
markers and traces do not overlap it. You can use Igor’s preferences to ensure that this and other set-
tings default to your liking, as explained below.
39.
Double-click one of the tick mark labels (such as “6”) on the bottom axis.
The Modify Axis dialog reappears, this time with the Axis Range tab showing. If another dialog or tab 
appears, cancel and try again, making sure to double click one of the tick mark labels on the bottom 
axis.
40.
Choose “Round to nice values” from the pop-up menu that initially reads “Use data limits”.
41.
Choose the left axis from the Axis pop-up menu and repeat step 22.
42.
Click Do It.
Notice that the limits of the axes now fall on “nice” values.
Adding a Legend
1.
Choose the GraphAdd Annotation menu item.
The Add Annotation dialog appears.
2.
Click the Text tab if it is not already selected.
3.
Choose Legend from the Annotation pop-up menu in the top-left corner of the dialog.
Igor inserts text to create a legend in the Annotation text entry area. The Preview area shows what the 
annotation will look like. The text \s(yval) generates the symbol for the yval wave. This is an 
“escape sequence” which creates special effects such as this.
