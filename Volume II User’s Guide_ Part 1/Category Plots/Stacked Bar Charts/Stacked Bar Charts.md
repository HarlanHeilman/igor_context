# Stacked Bar Charts

Chapter II-14 — Category Plots
II-360
Stacked Bar Charts
You can stack one bar on top of the next by choosing one of several grouping modes in the Modify Trace 
Appearance dialog which you can invoke by double-clicking a bar. The Grouping pop-up menu in the 
dialog shows the available modes. The choices are:
For most uses, you will use the None and “Stack on next” modes which produce the familiar bar and 
stacked bar chart:
In all of the Stacked Bar Chart examples that follow, the stacking mode is applied to the Gain Test #1 bar 
and Gain Test #2 is the “next” bar.
We have offset Gain Test #1 horizontally by 0.1 so that you can see what is being drawn behind Gain Test #2.
Choosing “Draw to next” causes the current bar to be in the same horizontal position as the next bar and 
to be drawn from the y value of this trace to the Y value of the next trace.
If the next bar is taller than the current bar then the current bar will not be visible because it will be hidden 
by the next bar. The result is as if the current bar is drawn behind the next bar, as is done when bars are 
displayed using a common numeric X axis.
“Add to next” is similar to “Draw to next” except the Y values of the current bar are added to the Y values 
of the next bar(s) before plotting.
Mode
Mode Name
Purpose
-1
Keep with next
For special effects
0
None
Side-by-side bars (default)
1
Draw to next
Overlapping bars
2
Add to next
Arithmetically combined bars
3
Stack on next
Stacked bars
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2
None Mode
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2
Stack on Next Mode
Draw to Next Mode
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2

Chapter II-14 — Category Plots
II-361
If the current Y value is negative and the next is positive then the final position will be shorter than the next 
bar, as it is here for the 24 hrs bar.
“Stack on next” is similar to “Add to next” except bars are allowed only to grow, not shrink.
Negative values act like zero when added to a positive next trace (see the 24 hrs bar) and positive values act 
like zero when added to a negative next trace (see the 1 hr bar). Zero height bars are drawn as a horizontal 
line. Normally the values are all positive, and the bars stack additively, like the 15 min and 6 hrs bars.
“Keep with next” creates special effects in category plots. Use it when you want the current trace to be 
plotted in the same horizontal slot as the next but you don’t want to affect the length of the current bar. For 
example, if the current trace is a bar and the next is a marker then the marker will be plotted on top of the 
bar. Here we set the Gain Test #2 wave to Lines from Zero mode, using a line width of 10 points.
“Keep with next” mode is also useful for category plots that don’t use bars; you can keep markers from dif-
ferent traces vertically aligned within the same category:
Add to Next Mode
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2
Stack on Next Mode
80
40
0
15 min
1 hr
6 hrs
24 hrs
 Gain Test #1 
 Gain Test #2
Keep with Next Mode
