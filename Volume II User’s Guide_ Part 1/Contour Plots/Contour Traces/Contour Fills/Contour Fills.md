# Contour Fills

Chapter II-15 — Contour Plots
II-373
Here is a code fragment that creates a color index wave that varies from blue to red:
Function CreateBlueRedColorIndexWave(numberOfColors,zMin,zMax)
Variable numberOfColors
Variable zMin,zMax
// From min, max of contour or image data
Make/O/N=(numberOfColors,3) colorIndexWave
Variable white = 65535
// black is zero
Variable colorStep = white / (numberOfColors-1)
colorIndexWave[][0]= colorStep*p // red increases with row number,
colorIndexWave[][1]= 0
// no green
colorIndexWave[][2]= colorStep*(numberOfColors-1-p)
// blue decreases
SetScale/I x,zMin,zMax,colorIndexWave// Match X scaling to Z range
End 
Log Color for Contour Traces
You can obtain a logarithmic mapping of z level values to colors using the Log Color checkbox in the 
Contour Line Colors dialog. This generates a ModifyContour logLines=1 command. In this mode, the 
colors change more rapidly at smaller contour z level values than at larger values.
For a color index wave, the colors are mapped using the log(color index wave's x scaling) and log(contour 
z level) values this way:
colorIndexWaveRow = (nRows-1)*(log(Z)-log(xMin))/(log(xmax)-log(xMin))
where,
nRows = DimSize(colorIndexWave,0)
xMin = DimOffset(colorIndexWave,0)
xMax = xMin + (nRows-1) * DimDelta(colorIndexWave,0)
The colorIndexWaveRow value is rounded before it is used to select a color from the color index wave.
A similar mapping is performed with color tables, where the xMin and xMax are replaced with the auto-
matically determined or manually provided zMin and zMax values.
Overriding the Color of Contour Traces
You can override the color set by the Line Color subdialog by using the Modify Trace Appearance dialog, 
the ModifyGraph command, or by Control-clicking (Macintosh) or right-clicking (Windows) the graph’s plot 
area to pop up the Trace Pop-Up Menu. The color you choose will continue to be used until either:
1.
The trace is removed when the contours are updated, because the levels changed, for instance.
2.
You choose a new setting in the Line Color subdialog.
Contour Fills
You can specify colors or patterns to fill contour levels. To fill all contour levels with colors, check the Fill 
Contours checkbox in the Modify Contour dialog. To fill individual contour levels with colors or patterns, 
use the Contour Fill controls in the Modify Trace Appearance dialog. You can use the Add Annotation 
dialog to create a legend for contour fills.
Programatically, to turn contour fills on for all contour levels, execute:
ModifyContour <contour instance name>, fill=1
