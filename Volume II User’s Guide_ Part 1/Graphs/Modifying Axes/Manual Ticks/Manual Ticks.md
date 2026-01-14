# Manual Ticks

Chapter II-13 — Graphs
II-312
margin modes are useful for aligning labels on stacked graphs. The “Axis label margin” setting applies to 
margin modes while the “Axis label position” setting applies to axis modes.
The absolute modes measure distance in points. Scaled modes have similar numerical values but are scaled 
to respond to changes in the font size.
The Labels pop-up menu controls which labels are drawn. On gives normal axis labeling. Axis Only leaves 
the axis label in place but removes the tick mark labels. Off removes the axis labels and tick mark labels.
Axis and Tick label rotations can be set to any value between -360 and 360 degrees.
Axis Range Tab
See Scaling Graphs on page II-285.
Manual Ticks
If Igor’s automatic selection of ticks does not suit you, and you can’t find any adjustments that make the tick 
marks just the way you want them, Igor provides two methods for specifying the tick marks yourself. On the 
Auto/Man Ticks tab of the Modify Axis dialog, you can choose either Computed Manual Ticks or User Ticks 
from Waves.
Computed Manual Ticks
Use Computed Manual Ticks to enter a numeric specification of the increment between tick marks and the 
starting point for calculating where the tick marks fall. This style of manual ticking is available for normal 
axes and date/time axes. It is not available for normal log axes but is available in LogLin mode.
When you choose Computed Manual Ticks, the corresponding settings in theAuto/Man Ticks tab becomes 
available.
If you click the “Set to auto values” button, Igor sets all of the items in the Compute Manual Ticks section to 
the values they would have if you let Igor automatically determine the ticking. This is usually a good starting 
point.
Using the “Canonic tick” setting, you specify the value of any major tick mark on the axis. Using the “Tick 
increment” setting, you specify the number of axis units per major tick mark. Both of these numbers are spec-
ified as a mantissa and an exponent. The canonic tick is not necessarily the first major tick on the axis. Rather, 
it is a major tick on an infinitely long axis of which the axis in the graph is a subset. That is, it can be any major 
tick whether it shows on the graph or not.
When you use computed manual ticks on a large range logarithmic axis in LogLin mode, the settings in the 
dialog refer to the exponent of the tick value.
Imagine that you want to show the temperature of an object as it cools off. You want to show time in seconds but 
you want it to be clear where the integral minutes fall on the axis. You would turn on manual ticking for the 
bottom axis and set the canonic tick to zero and the tick increment to 60. You could show the half and quarter 
minute points by specifying three minor ticks per major tick (“Number per major tick” in the Minor Ticks sec-
tion) with every second minor tick emphasized (“Emphasize every” setting). This produces the following graph:
100
80
60
40
Temp (C)
120
60
0
Time (s)
temp= -1.17 + 101.4 * e
(-.0099x)
 
Sigma = {2.9, 2.58, 0.000505}

Chapter II-13 — Graphs
II-313
Now, imagine that you want to zoom in on t = 60 seconds.
The canonic tick, at t = 0, does not appear on the graph but it still controls major tick locations.
User Ticks from Waves
With Computed Manual Ticks you have complete control over ticking as long as you want equally-spaced 
ticks. If you want to specify your own ticking on a normal log axis, or you want ticks that are not equally 
spaced, you need User Ticks from Waves.
The first step in setting up User Ticks from Waves is to create two waves: a 1D numeric wave and a text 
wave. Numbers entered in the numeric wave specify the positions of the tick marks in axis units. The cor-
responding rows of the text wave give the labels for the tick marks.
Perhaps you want to plot data as a function of Tm/T (melting temperature over temperature, but you want 
the tick labels to be at nice values of temperature. Starting with this data:
you might have this graph:
Create the waves for labelling the axes:
Make/N=5 TickPositions
Make/N=5/T TickLabels
Assuming that Tm is 450 degrees and that you have determined that tick marks at 20, 30, 50, 100, and 400 
degrees would look good, you would enter these numbers in the text wave, TickLabels. At this point, a con-
venient way to enter the tick positions in the TickPositions wave is a wave assignment that embodies the 
relationship you think is appropriate:
TickPositions = 450/str2num(TickLabels)
70
65
60
55
50
45
40
Temp (C)
60
Time (s)
temp= -1.17 + 101.4 * e
(-.0099x)
 
Sigma = {2.9, 2.58, 0.000505}
Point
InverseTemp
Mobility
0
30
0.211521
1
20
0.451599
2
14.2857
0.612956
3
10
0.691259
4
5
0.886406
5
3.0303
0.893136
6
2.22222
0.921083
7
1.25
1
1.0
0.8
0.6
0.4
30
25
20
15
10
5

Chapter II-13 — Graphs
II-314
Note that the str2num function was used to interpret the text in the label wave as numeric data. This only 
works, of course, if the text includes only numbers.
Finally, double-click the bottom axis to bring up the Modify Axis dialog, select the Auto/Man Ticks tab and 
select User Ticks from Waves. Choose the TickPositions and TickLabels waves:
The result is this graph:
You can add other text to the labels, including special marks. For instance:
Finally, you can add a column to the text wave and add minor, subminor and emphasized ticks by entering 
appropriate keywords in the other column. To add a column to a wave, select Redimension Waves from the 
Data menu, select your text wave in the list and click the arrow. Then change the number of columns from 
0 to 2.
This extra column must have the column label ‘Tick Type’. For instance:
 
1.0
0.8
0.6
0.4
20
30
50
100
TickLabels.d
TickPositions
20 degrees
22.5
30
15
50
9
100
4.5
400
1.125
1.0
0.8
0.6
0.4
20 degrees
30
50
100
Blank entries make 
ticks with no labels.
Dimension label “Tick Type” has 
keywords to set tick types
Use keyword “Subminor” for subminor 
ticks such as Igor uses on log axes.
TickLabels[][0].d TickLabels[][1].d
TickPositions
Tick Type
20 degrees
Major
22.5
30
Major
1 5
50
Major
9
100
Major
4.5
400
Major
1.125
 
Minor
21.4286
 
Minor
20.4545
 
Minor
19.5652
 
Minor
18.75
 
Emphasized
1 8
 
Minor
17.3077
 
Minor
16.6667
 
Minor
16.0714
 
Minor
15.5172
