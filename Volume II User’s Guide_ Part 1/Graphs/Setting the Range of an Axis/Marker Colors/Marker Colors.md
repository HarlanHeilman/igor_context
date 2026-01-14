# Marker Colors

Chapter II-13 — Graphs
II-292
You can also create custom markers. See the SetWindow operation's markerHook keyword.
Marker Colors
Igor provides control of three colors for graph markers: the trace color, the stroke color and the fill color.
The trace color is simply the color selected for the trace overall and is the same for any trace mode.
The stroke color is the color of the lines making the outlines of the markers. By default the stroke color is 
the same as the trace color.
The fill color is used to fill the background space of hollow markers. By default there is no fill color so that 
you see background objects through the interiors of hollow markers.
Here is a sample of some of Igor's markers with the trace color set to black, the marker size set to 10 and the 
marker stroke thickness set to 2 points. A blue rectangle is drawn beneath the markers:
The blue rectangle shows through the interior of the hollow markers (5, 11, 12, 8, 41, 42, 43). The solid 
markers (16, 19) are solid black because the trace color is black.
You can set the stroke color using the Modify Trace Appearance dialog: turn on the Stroke checkbox and 
select a color. You can also use the command ModifyGraph mrkStrokeRGB. In the next figure, the stroke 
color was set to green using the command
ModifyGraph mrkStrokeRGB=(1,52428,26586)
The stroke color overrides the trace color, so the outlines of all the markers are now green. The solid markers 
are black with green outlines.
You can choose to make the interiors of hollow markers opaque. In the Modify Trace Appearance dialog, 
turn on the Fill checkbox. The command is
ModifyGraph opaque=1
0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
