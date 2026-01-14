# Creating Stacked Plots

Chapter II-13 — Graphs
II-324
Exporting Graphs
You can export a graph to another application through the clipboard or by creating a file. To export via the 
clipboard, choose EditExport Graphics. To export via a file, choose FileSave Graphics.
The process of exporting graphics from a graph is very similar to exporting graphics from a layout. Because 
of this, we have put the details in Chapter III-5, Exporting Graphics (Macintosh), and Chapter III-6, Export-
ing Graphics (Windows). These chapters describe the various export methods you can use and how to 
choose a method that will give you the best results.
Creating Graphs with Multiple Axes
This section describes how to create a graph that has many axes attached to a given plot edge. For example:
To create this example we first created some data:
Make/N=100 wave1,wave2,wave3; SetScale x,0,20,wave1,wave2,wave3
wave1=sin(x); wave2=5*cos(x); wave3=10*sin(x)*exp(-0.1*x)
We then followed these steps:
1.
Use the New Graph dialog to display the following
wave1 versus the built-in left axis and the built-in bottom axis
wave2 versus a free left axis, L1, and the built-in bottom axis
wave3 versus another free left axis, L2, and the built-in bottom axis
Use the Axis pop-up menu under the Y Waves list to create the L1 and L2 axes.
2.
Use the Modify Graph dialog to set the left margin to 1.5 inches.
This moves the built-in left axis to the right, creating room for the free axes.
3.
Drag the L1 axis to the left of the left axis.
4.
Drag the L2 axis to the left of the L1 axis.
5.
Use the Modify Trace Appearance dialog to set the trace dash patterns.
6.
Use the Axis Label tab of the Modify Axis dialog to set the axis labels.
We used Wave Symbol from the Special pop-up menu to include the line style.
7.
Drag the axis labels into place.
Creating Stacked Plots
Igor’s ability to use an unlimited number of axes in a graph combined with the ability to shrink the length of an 
axis makes it easy to create stacked plots. You can even create a matrix of plots and can also create inset plots.
-1.0
-0.5
0.0
0.5
1.0
 sin
15
10
5
0
4
2
0
-2
-4
 cos
8
6
4
2
0
-2
-4
-6
 sin*exp

Chapter II-13 — Graphs
II-325
Another way to make a stacked graph is to use subwindows. See Layout Mode and Guide Tutorial on page 
III-86 for an example. It is also possible to do make stacked graphs in page layouts, using either graph sub-
windows or graph layout objects.
In this section we create stacked plot areas in a single graph window using Igor’s ability to limit a plot to a 
portion of a graph. As an example, we will create the following graph:
First we create some data:
Make wave1,wave2,wave3,wave4
SetScale/I x 0,10,wave1,wave2,wave3,wave4
wave1=sin(2*x); wave2=cos(2*x)
wave3=cos(2*x)*exp(-0.2*x)
wave4=sin(2*x)*exp(-0.2*x)
We then followed these steps:
1.
Use the New Graph dialog to display the following
wave1 versus the built-in left axis and the built-in bottom axis
wave2 versus a free left axis, L2, and the built-in bottom axis
wave3 versus L2 and a free bottom axis, B2
wave4 versus the built-in left axis and B2
Use the Axis pop-up menu under the Y Waves list to create the L2 axis.
Use the Axis pop-up menu under the X Waves list to create the B2 axis.
This creates a graph consisting of a jumble of axes and traces.
2.
Choose GraphModify Graph and click the Axis tab.
The next four steps use the “Draw between” settings in the Axis section of the Axis tab.
3.
From the Axis pop-up menu, select left and set the left axis to draw between 0% and 45% of normal.
4.
From the Axis pop-up menu, select bottom and set the bottom axis to draw between 0% and 45% of 
normal.
5.
From the Axis pop-up menu, select L2 and set the L2 axis to draw between 55% and 100% of normal. 
Also, in the Free Position section, choose Distance from Margin from the pop-up menu and set the Dis-
tance setting to 0.
6.
From the Axis pop-up menu, select B2 and set the B2 axis to draw between 55% and 100% of normal. 
Also, in the Free Position section, choose Distance from Margin from the pop-up menu and set the Dis-
tance setting to 0.
7.
Click Do It.
1.0
0.5
0.0
-0.5
-1.0
10
8
6
4
2
0
1.0
0.5
0.0
-0.5
-1.0
10
8
6
4
2
0
