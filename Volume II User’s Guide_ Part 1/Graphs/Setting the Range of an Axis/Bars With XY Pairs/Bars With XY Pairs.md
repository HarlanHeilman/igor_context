# Bars With XY Pairs

Chapter II-13 — Graphs
II-295
For any mode except the Markers mode you can set the line size. The line size is in points and can be frac-
tional. If the line size is zero, the line disappears.
For more information see Dashed Lines on page III-496.
Fills
For traces in the Bars and “Fill to zero” modes, Igor presents a choice of fill type. The fill type can be None, 
which means the fill is transparent, Erase, which means the fill is white and opaque, Solid, or three patterns 
of gray. You can also choose a pattern from a palette and can choose the fill types and colors for positive 
going regions and negative going regions independently.
For more information see Fill Patterns on page III-498 and Gradient Fills on page III-498.
Bars With Waveforms
When Bars mode is used for a waveform plotted on a normal continuous X axis (rather than a category axis, 
see Chapter II-14, Category Plots), the X values are computed from the wave’s X scaling. The bars are 
drawn from the X value for a given point up to but not including the X value for the next point. Such bars are 
commonly called “histogram bars” because they are usually used to show the number of counts in a histo-
gram that fall between the two X values.
If you want your bars centered on their X values, then you should create a Category Plot, which is more 
suited for traditional bar charts (see Chapter II-14, Category Plots). You can, however, adjust the X values 
for the wave so that the flat areas appear centered about its original X value as for a traditional bar chart. 
One way to do this without actually modifying any data is to offset the trace in the graph by one half the 
bar width. You can just drag it, or use the Modify Trace Appearance dialog to generate a more precise offset 
command. In our example, the bars are 0.5 X units wide:
ModifyGraph offset(wave0)={-0.25,0}
Bars With XY Pairs
If your X axis is controlled by an XY pair, the width of each bar is determined by two X values. One X value 
provides the location of the left edge of the bar and the next X value provides the location of the right edge 
of the bar.
20
15
10
5
0
-3
-2
-1
0
1
2
3
 wave0
 wave0#1
Histogram mode 
extends to X = 3.0
Last X value is 2.5
20
15
10
5
0
-3
-2
-1
0
1
2
3
 wave0
 wave0#1
