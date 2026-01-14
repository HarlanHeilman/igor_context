# Waterfall Plots

Chapter II-13 — Graphs
II-326
Staggered Stacked Plot
Here is a common variant of the stacked plot:
This example was created from three of the waves used in the previous plot. Wave1 was plotted using the left 
and bottom axes, wave2 used the right and bottom axes and wave3 used L2 and bottom axes. Then the Axis 
tab of the Modify Axis dialog was used to set the left axis to be drawn from 0% to 33% of normal, the right axis 
from 33% to 66% and the L2 axis from 66% to 100%. The Axis Standoff checkbox was unchecked for the bottom 
axis. This was not necessary for the other axes as axis standoff is not used when axes are drawn on a reduced 
extent.
After returning from the Modify Axis dialog, the graph was resized and the frame around the plot area was 
drawn using a polygon in plot-relative coordinates.
Waterfall Plots
You can create a graph displaying a sequence of traces in a perspective view. We refer to these types of 
graphs as waterfall plots, which can be created and modified using the NewWaterfall operation or by 
choosing WindowsNewPackagesWaterfall Plot.
To display a waterfall plot, you must first create or load a matrix wave. (If your data is in 1D waveform or 
XY pair format, you may find it easier to create a fake waterfall plot - see Fake Waterfall Plots on page 
II-328.) In this 2D matrix, each of the individual matrix columns is displayed as a separate trace in the water-
fall plot. Each column from the matrix wave is plotted in, and clipped by, a rectangle defined by the X and 
Z axes with the plot rectangle displaced along the angled Y axis, which is the right-hand axis, as a function 
of the Y value.
You can display only one matrix wave per plot.
The traces can be plotted evenly-spaced, in which case their X and Y positions are determined by the X and 
Y dimension scaling of the matrix. Alternatively they can be plotted unevenly-spaced as determined by sep-
arate 1D X and Y waves.
To modify certain properties of a waterfall plot, you must use the ModifyWaterfall operation. For other 
properties, you will need to use the usual axis and trace dialogs.
Because the traces in the waterfall plot are from a single wave, any changes to the appearance of the water-
fall plot using the Modify Trace Appearance dialog or ModifyGraph operation will globally affect all of the 
1.0
0.5
0.0
-0.5
-1.0
10
8
6
4
2
0
1.0
0.5
0.0
-0.5
-1.0
-1.0
-0.5
0.0
0.5
1.0
