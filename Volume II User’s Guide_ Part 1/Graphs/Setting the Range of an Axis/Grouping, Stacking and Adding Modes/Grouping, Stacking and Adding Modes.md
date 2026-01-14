# Grouping, Stacking and Adding Modes

Chapter II-13 — Graphs
II-296
If you imagine a bar plot with one bar, this requires an XY pair with two points - one X value to set the left 
edge of the bar and the next X value to set the right edge.
Generalizing, for a bar plot with N bars, you need N+1 points in your X and Y waves. Here is an example 
using 3 XY points to produce two bars:
Make/O barX={0,1,3}, barY = {1,2,2}
Display barY vs barX
ModifyGraph mode=5, hbFill=4
SetAxis left 0,*
Grouping, Stacking and Adding Modes
For the four modes that normally draw to y=0 (“Sticks to zero”, “Bars”, “Fill to zero”, and “Sticks and markers”) 
you can choose variants that draw to the Y values of the next trace. The four variant modes are: “Sticks to next”, 
“Bars to next”, “Fill to next” and “Sticks&markers to next”. Next in this context refers to the trace listed after 
(below) the selected trace in the list of traces in the Modify Trace Appearance and the Reorder Traces dialogs.
If you choose one of these four modes, Igor automatically selects “Draw to next” from the Grouping pop-
up menu. You can also choose “Add to next” and “Stack on next” modes.
The Grouping pop-up menu the Modify Trace Appearance dialog is used to create special effects such as 
layer graphs and stacked bar charts. The available modes are “Keep with next”, None, “Draw to next”, 
“Add to next”, and “Stack on next.
“Keep with next” is used only with category plots and is described in Chapter II-14, Category Plots.
“Draw to next” modifies the action of those modes that normally draw to y=0 so that they draw to the Y 
values of the next trace that is plotted against the same pair of axes as the current trace. The X values for the 
next trace should be the same as the X values for the current trace. If not, the next trace will not line up with 
the bottom of the current trace.
“Add to next” adds the Y values of the current trace to the Y values of the next trace before plotting. If the 
next trace is also using “Add to next” then that addition is performed first and so on. When used with one 
of the four modes that normally draw to y=0, this mode also acts like “Draw to next”.
“Stack on next” works just like “Add to next” except Y values are not allowed to backtrack. On other words, 
negative values act like zero when the Y value of the next trace is positive and positive values act like zero 
with a negative next trace.
Here is a normal plot of a small sine wave and a bigger sine wave:
In this version, the small sine wave is set to “Add to next” mode:
1.0
0.5
0.0
-0.5
-1.0
120
100
80
60
40
20
0

Chapter II-13 — Graphs
II-297
And here we use “Stack on next”:
You can create layer graphs by plotting a number of waves in a graph using the fill to next mode. Depend-
ing on your data you may also want to use the add to next grouping mode. For example, in the following 
normal graph, each trace might represent the thickness of a geologic layer:
We can show the layers in a more understandable way by using fill to next and add to next modes:
Because the grouping modes depend on the identity of the next trace, you may need to adjust the order of 
traces in the graph. You can do this using the Reorder Traces dialog. Choose GraphReorder Traces. Select 
the traces you want to move. Adjust the order by dragging the selected traces up and down in the list, drop-
ping them in the appropriate spot.
1.0
0.5
0.0
-0.5
-1.0
120
100
80
60
40
20
0
1.0
0.5
0.0
-0.5
-1.0
120
100
80
60
40
20
0
2.0
1.5
1.0
0.5
0.0
8
6
4
2
0
4
3
2
1
0
8
6
4
2
0
