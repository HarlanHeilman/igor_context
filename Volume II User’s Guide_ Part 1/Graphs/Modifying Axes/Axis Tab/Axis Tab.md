# Axis Tab

Chapter II-13 — Graphs
II-307
Axis Tab
You can set the axis Mode for the selected axis to linear, log base 10, log base 2, or Date/Time.
The Date/Time mode is special. When drawing an axis, Igor looks at the controlling wave’s units to decide 
if it should be a date/time axis. Consequently, if you select Date/Time axis, the dialog immediately changes 
the units of the controlling wave. See Date/Time Axes on page II-315 for details on how date/time axes 
work.
The Standoff checkbox controls offsetting of axes. When standoff is on, Igor offsets axes so that traces do 
not cover them:
If a free axis is attached to the same edge of the plot rectangle as a normal axis then the standoff setting for 
the normal axis is ignored. This is to make it easy to create stacked plots.
Use the Mirror Axis pop-up menu to enable the mirror axis feature. A mirror axis is an axis that is the mirror 
image of the opposite axis. You can mirror the left axis to the right or the bottom axis to the top. The normal 
state is Off in which case there is no mirror axis. If you choose On from the pop-up, you get a mirror axis with 
tick marks but no tick mark labels. If you choose No Ticks, you get a mirror axis with no tick marks. If you 
choose Labels you get a mirror axis with tick marks and tick mark labels. Mirror axes may not do exactly what 
you want when using free axes, or when you shorten an axis using Draw Between. An embedded graph may 
be a better solution if free axes don’t do what you need; see Chapter III-4, Embedding and Subwindows.
Free axes can also have mirror axes. Unlike the free axis itself, the mirror for a given free axis can not be 
moved — it is always attached to the opposite side of the plot area. This feature can create stacked plots; 
see Creating Stacked Plots on page II-324.
The “Draw between” items are used to create stacked graphs. You will usually leave these at 0 and 100%, 
which draws the axis along the entire length or width of the plot area. You could use 50% and 100% to draw 
the left axis over only the top half of the plot area (mirror axes are on in this example to indicate the plot area):
For additional examples using “Draw between”, see Creating Stacked Plots on page II-324 and Creating 
Split Axes on page II-347.
The Offset setting provides a way to control the distance between the edge of the graph and the axis. It spec-
ifies the distance from the default axis position to the actual axis position. This setting is in units of the size 
of a zero character in a tick mark label. Because of this, the axis offset adjusts reasonably well when you 
change the size of a graph window. The default axis offset is zero. You can restore the axis offset to zero by 
dragging the axis to or beyond the edge of the graph. If you enter a graph margin (see Overall Graph Prop-
erties on page II-288), the margin overrides the axis offset.
30
20
10
0
-6
-4
-2
0
2
4
6
Standoff on
30
20
10
0
-6
-4
-2
0
2
4
6
Standoff off
-1.0
-0.5
0.0
0.5
1.0
120
80
40
0
Drawn from 0% to 100%
-1.0
0.0
1.0
120
80
40
0
Drawn from
50% to 100%
