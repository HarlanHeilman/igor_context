# Label Options Tab

Chapter II-13 — Graphs
II-311
The Enable/Inhibit Ticks section allows you to limit tick marks to a specific range and to suppress specific 
tick marks.
The Log Ticks section provides control over minor tick marks and labels on log axes.
The Tick Label Tweaks section provides the following settings:
Axis Label Tab
See Axis Labels on page II-318.
Label Options Tab
The Label Options tab provides control of the placement and orientation of axis and tick mark labels. You 
can also hide these labels completely.
Normally, you will adjust the position of the axis label by simply dragging it around on the graph. The 
“Axis label position” or “Axis label margin” and the “Axis label lateral offset” settings are useful when you 
want precise numeric control over the position.
The calculations used to position the axis label depend on the setting in the Label Position Mode menu. By 
default this is set to Compatibility, which will work with older versions of Igor. The other modes may allow 
you to line up labels on multiple axes more accurately. The choice of positioning mode affects the meaning 
of the three settings below the menu.
In Compatibility mode, the method Igor uses to position the axis label depends on whether or not a free axis 
is attached to the given plot rectangle edge. If no free axis is attached then the label position is measured 
from the corresponding window edge. We call this the axis label margin. Thus if you reposition an axis the 
axis label will not move. On the other hand, if a free axis is attached to the given plot rectangle edge then 
the label position is measured from the axis and when you move the axis, the label will move with it.
Because the method used to set the axis label varies depending on circumstances, one or the other of the 
“Axis label margin” or “Axis label position” settings may be unavailable. If you have selected an axis on 
the same edge as a free axis, the “Axis label position” setting is made available. If you have selected an axis 
that does not share an edge with a free axis, the “Axis label margin” setting is made available. If you have 
selected multiple axes it is possible for both settings to be available.
The axis label position is the distance from the axis to the label and is measured in points.
The axis label margin is the distance from the edge of the graph to the label and is measured in points. The 
default label margin is zero which butts the axis label up against the edge of the graph.
The margin modes measure relative to an edge of the graph while the axis modes measure relative to the 
position of the axis. Using an axis mode causes the label to follow a free axis when you move the axis. The 
Checkbox
Result
Thousands separator
Tick labels like 10000 are drawn as 10,000.
Zero is '0'
Select this to force the zero tick mark to be drawn as 0 where it would ordi-
narily be drawn as 0.0 or 0.00.
No trailing zeroes
Tick labels that would normally be drawn as 1.50 or 2.00 are drawn as 1.5 or 2.
No leading zero
Select if you want tick labels such as 0.5 to be drawn as .5
Tick Unit Prefix is Exponent
If tick mark would have prefix and units (Torr), force to exponential nota-
tion (10-6 Torr).
No Units in Tick Labels
If tick mark would have units, suppress them.
Units in Every Tick Label
If normal axis, force exponent or prefix and units into each label.
