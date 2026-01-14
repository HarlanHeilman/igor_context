# Wind Barb Plots

Chapter II-13 — Graphs
II-329
Because of the offsetting in the X and Y directions, the axis tick mark labels can be misleading.
Igor includes a demo experiment showing how to create a fake waterfall plot. Choose FileExample 
ExperimentsGraphing TechniquesFake Waterfall Plot.
Wind Barb Plots
You can create a wind barb plot by creating an XY plot and telling Igor to use wind barbs for markers. You 
turn markers into wind barbs using "ModifyGraph arrowMarker", passing to it a wave that specifies the 
length, angle and number of barbs for each point.
If you want to color-code the wind barbs, you turn on color as f(z) mode using "ModifyGraph zColor", 
passing to it a wave that specifies the color for each point.
Here is an example. Execute the commands one section at at time to see how it works.
// Make XY data
Make/O xData = {1, 2, 3}, yData = {1, 2, 3}
Display yData vs xData
// Make graph
ModifyGraph mode(yData) = 3
// Marker mode
// Make a barb data wave to control the length, angle
// and number of barbs for each point.
// To control the number of barbs, column 2 must have a column label of WindBarb.
Make/O/N=(3,3) barbData
// Controls barb length, angle and number of barbs
SetDimLabel 1, 2, WindBarb, barbData
// Set column label to WindBarb
Edit /W=(439,47,820,240) barbData
// Put some data in barbData
barbData[0][0]= {20,25,30} // Column 0: Barb lengths in points
barbData[0][1]= {0.523599,0.785398,1.0472}
// Column 1: Barb angle in radians
barbData[0][2]= {10,20,30}
// Column 2: Wind speed code from 0 to 40
// Set trace to arrow mode to turn barbs on
ModifyGraph arrowMarker(yData) = {barbData, 1, 10, 1, 1}
// Make an RGB color wave
Make/O/N=(3,3) barbColor
Edit /W=(440,272,820,439) barbColor
// Store some colors in the color wave
barbColor[0][0]= {65535,0,0}
// Red
10
8
6
4
x10
3 
600
595
590
585
580
575
570
