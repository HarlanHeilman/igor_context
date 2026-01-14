# Date/Time Axes

Chapter II-13 — Graphs
II-315
Dimension labels allow you (or Igor) to refer to a row or column of a wave using a name rather than a 
number. Thus, the Tick Type column doesn't have to be the second column (that is, column 1). For instruc-
tions on showing dimension labels in a table, see Showing Dimension Labels on page II-235.
An easy way to get started is to let the Modify Axis dialog generate waves for you. Double-click the axis for 
which you want user ticks. Click the Auto/Man Ticks tab and select User Ticks from Waves from the pop-
up menu. Click the New from Auto Ticks button. Igor immediately generates waves with names of the form 
<graphname>_<axisname>_labels and <graphname>_<axisname>_values and selects them in the Labels 
and Locations pop-up menus. Click Do It. If you now edit the generated waves, the ticks in the graph will 
change. You can achieve the same thing programmatically using the TickWavesFromAxis operation.
Log Axes
To create a logarithmic axis, set the axis mode to Log in the Axis tab of the Modify Axis dialog.
Computed manual ticks and zero lines are not supported for normal log axes.
Igor has three ways of ticking a log axis that are used depending on the range (number of decades) of the axis: 
normal, small range and large range. The normal mode is used when the number of decades lies between 
about one third to about ten. The exact upper limit depends on the physical size of the axis and the font size.
If the number of decades of range is less than two or greater than five, you can force Igor to use the 
small/large range methods by checking the LogLin checkbox, which may give better results for log axes 
with small or very large range. When you do this, all of the settings of a linear axis are enabled including 
manual ticking.
Here is a normal log axis with a range of 0.5 to 30:
If we zoom into a range of 1.5 to 4.5 we get this:
But if we then check the LogLin checkbox, we get better results:
Selecting a log axis makes the Log Ticks box in the Tick Options tab available. 
The “Max log cycles with minor ticks” setting controls whether minor ticks appear on a log axis. This setting 
can range from 0 to 20 and defaults to 0. If it is 0 or “auto”, Igor automatically determines if minor ticks are 
appropriate. Otherwise, if the axis has more decades than this number, then the minor ticks are not dis-
played. Minor ticks are also not displayed if there is not enough room for them.
Similarly, you can control when Igor puts labels on the minor ticks of a log axis using the “Max log cycles 
with minor tick labels” item. This is a number from 0 to 8. 0 disables the minor tick labels. As long as the 
axis has fewer decades than this setting, minor ticks are labeled.
Date/Time Axes
In addition to numeric axes, Igor supports axes labeled with dates, times or dates and times.
Dates and date/times are represented in Igor as the number of seconds since midnight, January 1, 1904.
5
6 7 8 9
1
2
3
4
5
6
7 8 9
1 0
2
3
2x10
0
3
4
4.5
4.0
3.5
3.0
2.5
2.0
1.5
