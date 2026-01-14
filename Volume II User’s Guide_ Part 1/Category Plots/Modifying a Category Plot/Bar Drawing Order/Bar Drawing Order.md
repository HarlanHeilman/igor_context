# Bar Drawing Order

Chapter II-14 — Category Plots
II-359
Horizontal Bars
To create a category plot in which the category axis runs vertically 
and the bars run horizontally, create a normal vertical bar plot and 
then select the Swap XY checkbox in the Modify Graph dialog.
Reversed Category Axis
Although the ordering of the categories is determined by the order-
ing of the value (numeric) and category (text) waves, you can reverse a category axis just like you can reverse a 
numeric axis. Double-click one of the category axis tick labels or choose the Set Axis Range from the Graph menu 
to access the Axis Range pane in the Modify Axes dialog. When the axis is in autoscale mode, select the Reverse 
Axis checkbox to reverse the axis range.
Category Axis Range
You can also enter numeric values in the min and max value items of the Axis Range pane of the Modify 
Axes dialog. The X scaling of the numeric waves determine the range of the category axis. We used “point” 
X scaling for the numeric waves, so the numeric range of the category axis for the 15 min, 1 hr, 6 hrs, 24hrs 
example is 0 to 4. To display only the second and third categories, set the min to 1 and the max to 3.
Bar Drawing Order
When you plot multiple numeric waves against a single category axis, you have multiple bars within each cate-
gory group. In the examples so far, there are two bars per category group.
The order in which the bars are initially drawn is the same as the order of the numeric waves in the Display or 
AppendToGraph command:
Display control,test vs elapsed
//control on left, test on right
You can change the drawing order in an existing graph using the Reorder Traces dialog and the Trace pop-
up menu (see Graph Pop-Up Menus on page II-352).
The ordering of the traces is particularly important for stacked bar charts.
200
150
100
50
0
15 min
1 hr
15 min
1 hr
6 hrs
24 hrs
15 min
1 hr
6 hrs
24 hrs
Normal Range
Reversed Range
x=0
x=4
x=4
x=0
500
400
300
200
100
0
1 hr
6 hrs
 control
 test
