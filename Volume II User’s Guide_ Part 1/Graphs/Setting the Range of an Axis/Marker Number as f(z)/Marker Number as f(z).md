# Marker Number as f(z)

Chapter II-13 — Graphs
II-300
Marker Size as f(z) in Axis Units
In Igor Pro 9.00 or later, you can specify the marker size in units of an axis. For example:
Make/O xData2 = {1,2,3}
Make/O yData2 = {100,200,300}
Make/O zData2 = {10, 20, 50}
Display/W=(400,50,700,300) yData2 vs xData2
ModifyGraph mode=3, marker=19, msize=6 // Markers mode, filled circle marker
ModifyGraph grid=1
ModifyGraph nticks(left)=10
SetAxis left,0,400
SetAxis bottom,0,4
ModifyGraph zmrkSize(yData2)={zData2,*,*,6,10,left}
The last command sets the marker size to be controlled by the wave zData2 whose values are scaled to the 
left axis. For example, zData2[2] is 50 and sets the radius of the marker for point 2 of yData2 to be 50 units 
on the left axis. This produces this graph:
The axis specified can be any axis on the graph. If that axis is later removed, the marker size, the marker 
size goes back to the "no axis" state as if you never specified an axis.
When scaling marker sizes in axis units, the values that you specify for the zMin, zMax, mrkMin, and 
mrkMax parameters of the zmrkSize keyword have no impact on the marker size unless you remove the 
specified axis in which case those parameters control the trace's marker sizes.
If the marker size scale is independent of the scales of the axes against which the trace is plotted, you can 
use a free axis to show the scale. You do this by creating a free axis with the desired range and setting it as 
the axis for the zmrkSize keyword. See Types of Axes on page II-279 for a discussion of free axes.
If the axis that you specify is a log axis, the interpretation of Z values changes. Think of a conceptual axis of 
the same length in points as the log axis. Conceptually set the min and max of the conceptual axis to the log 
of the min and log of the max of the log axis. The marker size for a given Z value is the length of Z units on 
the conceptual axis. To help visualize this, you can create a free axis representing this conceptual axis.
For a demo, choose FileExample ExperimentsGraphing TechniquesMarker Size in Axis Units 
Demo.
Marker Number as f(z)
In“Marker Number as f(z)” mode, you must create a Z wave that contains the actual marker numbers for each 
data point. See Markers on page II-291 for the marker number codes.
400
350
300
250
200
150
100
50
0
4
3
2
1
0
