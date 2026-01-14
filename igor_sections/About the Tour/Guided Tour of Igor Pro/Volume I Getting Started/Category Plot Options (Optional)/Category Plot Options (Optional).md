# Category Plot Options (Optional)

Chapter I-2 — Guided Tour of Igor Pro
I-31
7.
Choose WindowsNewCategory Plot.
A dialog similar to the New Graph dialog appears. This dialog shows only text waves in the right-
hand list.
8.
In the Y Waves list, select wave0 and wave1.
9.
In the X Wave listm select textWave0.
10.
Click Do It.
A category plot is created.
11.
Double-click one of the bars.
The Modify Trace Appearance dialog appears.
12.
Using the Color pop-up menu, set the color of the wave0 trace to green.
13.
Click Do It.
The graph should now look like this:
14.
Choose FileSave Experiment As and save the current experiment as “Category Plots.pxp”.
Category Plot Options (Optional)
This section explores various category-plot options. If you are not particularly interested in category plots, 
you can stop now, or at any point in the following steps, by skipping to the next section.
1.
Double-click one of the bars and, if necessary, select the wave0 in the list.
2.
From the Grouping pop-up menu, choose Stack on Next.
3.
Click Do It.
The left bar in each group is now stacked on top of the right bar.
4.
Choose the GraphReorder Traces menu item.
The Reorder Traces dialog appears.
5.
Reverse the order of the items in the list by dragging the top item down and click Do It.
The bars are no longer stacked and the bars that used to be on the left are now on the right. The reason 
the bars are not stacked is that the trace that we set to Stack on Next mode is now last and there is no 
next trace.

Chapter I-2 — Guided Tour of Igor Pro
I-32
6.
Using the Modify Trace Appearance dialog, set the wave1 trace to Stack on next. Click Do It.
The category plot graph should now look like this:
7.
Enter the following values in the next blank column in the table:
7
10
15
9
This creates a new wave named wave2.
8.
Click the graph to bring it to the front.
9.
Choose GraphAppend to GraphCategory Plot.
The Append Category Traces dialog appears.
10.
In the Y Waves list, select wave2 and click Do It.
This adds a red bar underneath each green bar.
11.
Control-click (Macintosh) or right-click (Windows) one of the new red bars (underneath a green 
bar) to display the contextual pop-up menu and choose blue from the Color submenu.
The new bars are now blue.
12.
Using the Modify Trace Appearance dialog, change the grouping mode of the middle trace, wave0, 
to none.
We now have wave1 (red) stacked on wave0 (green) and wave0 not stacked on anything.
Now the new wave2 bars (blue) are to the right of a group of two stacked bars. You can create any 
combination of stacked and side-by-side bars.
13.
Double-click the bottom axis.
The Modify Axis dialog appears with the bottom axis selected.
14.
Click the Auto/Man Ticks tab.
