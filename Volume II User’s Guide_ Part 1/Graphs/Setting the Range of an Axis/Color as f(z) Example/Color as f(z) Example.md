# Color as f(z) Example

Chapter II-13 — Graphs
II-298
Note:
All of the waves you use for the various grouping, adding, and stacking modes should have the 
same numbers of points, X scaling, and should all be displayed using the same axes.
Trace Color
You can choose a color for the selected trace from the color pop-up palette of colors.
In addition to color, you can specify opacity using the color pop-up via the “alpha” property. An alpha of 
1.0 makes the trace fully opaque. An alpha of 0.0 makes it fully transparent.
Setting Trace Properties from an Auxiliary (Z) Wave
You can set the color, marker number, marker size, and pattern number of a trace on a point-by-point basis 
based on the values of an auxiliary wave. The auxiliary wave is called the “Z wave” because other waves 
control the X and Y position of each point on the trace while the Z wave controls a third property.
For example, you could position markers at the location of earthquakes and vary their size to show the mag-
nitude of each quake. You could show the depth of the quake using marker color and show different types 
of quakes as different marker shapes.
To set a trace property to be a function of a Z wave, click the “Set as f(z)” button in the Modify Trace Appear-
ance dialog to display the “Set as f(z)” subdialog.
Color as f(z)
Color as f(z) has four modes: Color Table, Color Table Wave, Color Index Wave, and Three or Four Column 
Color Wave. You select the mode from the Color Mode menu.
In Color Table mode, the color of each data point on the trace is determined by mapping the corresponding 
Z wave value into a built-in color table. The mapping is logarithmic if the Log Colors checkbox is checked 
and linear otherwise. The Log Colors option is useful when the zWave spans many decades and you want 
to show more detailed changes of the smaller values.
The zMin and zMax settings define the range of values in your Z wave to map onto the color table. Values 
outside the range take on the color at the end of the range. If you choose Auto for zMin or zMax, Igor uses 
the smallest or largest value it finds in your Z wave. If any of your Z values are NaN, Igor treats those data 
points in the same way it does if your X or Y data is NaN. This depends on the Gaps setting in the main 
dialog.
Color Table Wave mode is the same as Color Table mode except that the colors are determined by a color 
table wave that you provide instead of a built-in color table. See Color Table Waves on page II-399 for 
details.
In Color Index Wave mode, the color of data points on the trace is derived from the Z wave you choose by 
mapping its values into the X scaling of the selected 3-column color index wave. This is similar to the way 
ModifyImage cindex maps image values (in place of the Z wave values) to a color in a 3-column color index 
matrix. See Indexed Color Details on page II-400.
In Three or Four Column Color Wave mode, data points are colored according to Red, Green and Blue 
values in the first three columns of the selected wave. Each row of the three column wave controls the color 
of a data point on the trace. This mode gives absolute control over the colors of each data point on a trace. 
If the wave has a fourth column, it controls opacity. See Direct Color Details on page II-401 for further 
information.
Color as f(z) Example
Create a graph:
Make/N=5 yWave = {1,2,3,2,1}
Display yWave
ModifyGraph mode=3, marker=19, msize=5
