# Unevenly-Spaced Waterfall Plot Example

Chapter II-13 — Graphs
II-327
waterfall traces. For example, if you change the color in the dialog, then all of the waterfall traces will 
change to the same color. If you want each of the traces to have a different color, then you will need to use 
a separate wave to specify (as f(z)) the colors of the traces. See the example in the next section for an illus-
tration of how this can be done.
The X and Z axes of a waterfall are always at the bottom and left while the Y axis runs at a default 45 degrees 
on the right-hand side. The angle and length of the Y axis can be changed using ModifyWaterfall. Except 
when hidden lines are active, the traces are drawn in back to front order. Note that hidden lines are active 
only when the trace mode is lines between points.
Marquee expansion is based only on the bottom and right (waterfall) axes. The marquee is drawn as a box 
with the bottom face in the ZY plane at zmin and the top face is drawn in the ZY plane at zmax.
Cursors may be used and the readout panel provides X, Y and Z axis information. The hcsr and xcsr functions 
are unchanged; the vcsr function returns the Y data value (waterfall) and the zcsr returns the data (Z axis) value.
Evenly-Spaced Waterfall Plot Example
In this example we create a waterfall plot with evenly-spaced X and Y values that come from the X and Y 
scaling of the matrix being plotted.
Function EvenlySpacedWaterfallPlot()
// Create matrix for waterfall plot
Make/O/N=(200,30) mat1
SetScale x,-3,4,mat1
SetScale y,-2,3,mat1
mat1=exp(-((x-y)^2+(x+3+y)^2))
mat1=exp(-60*(x-1*y)^2)+exp(-60*(x-0.5*y)^2)+exp(-60*(x-2*y)^2)
mat1+=exp(-60*(x+1*y)^2)+exp(-60*(x+2*y)^2)
// Create waterfall plot
NewWaterfall /W=(21,118,434,510) mat1
ModifyWaterfall angle=70, axlen= 0.6, hidden= 3
// Apply color as a function of Z
Duplicate mat1,mat1ColorIndex
mat1ColorIndex=y
ModifyGraph zColor(mat1)={mat1ColorIndex,*,*,Rainbow}
End
Unevenly-Spaced Waterfall Plot Example
In this example we create a waterfall plot with unevenly-spaced X and Y values that come from separate 
1D waves.
5
4
3
2
1
0
4
3
2
1
0
-1
-2
-3
3
2
1
0
-1
-2
