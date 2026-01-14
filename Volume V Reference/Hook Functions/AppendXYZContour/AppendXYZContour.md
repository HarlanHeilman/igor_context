# AppendXYZContour

AppendXYZContour
V-39
ds4 = enoise(2)
dsX = p^2
Display; AppendViolinPlot ds1,ds2,ds3,ds4 vs dsX
ModifyGraph swapXY=1
// Horizontal boxes
ModifyGraph margin(top)=20
// Top margin may be too small
See Also
Display, AppendToGraph, ModifyGraph (traces), ModifyViolinPlot
Box Plots on page II-331, Violin Plots on page II-337
AppendXYZContour 
AppendXYZContour [/W=winName /F=formatStr][axisFlags] zWave [vs {xWave, yWave}]
The AppendXYZContour operation appends to the target or named graph a contour of a 2D wave 
consisting of XYZ triples with autoscaled contour levels and using the Rainbow color table.
To contour a matrix of Z values, use AppendMatrixContour.
Note:
There is no DisplayContour operation. Use Display; AppendXYZContour.
Parameters
If you provide the xWave and yWave specification, xWave provides X values for the rows, and yWave 
provides Y values for the columns, zWave provides Z values and all three waves must be 1D. All must have 
at least four rows and must have the same number of rows.
If you omit the xWave and yWave specification, zWave must be a 2D wave with 4 or more rows and 3 or more 
columns. The first column is X, the second is Y, and the third is Z. Any additional columns are ignored.
If any of X, Y, or Z in a row is blank, (NaN), that row is ignored.
In a macro, to modify the appearance of contour levels before the contour is calculated and displayed with 
the default values, append ";DelayUpdate" and immediately follow the AppendXYZContour command 
with the appropriate ModifyContour commands. All but the last ModifyContour command should also 
have ;DelayUpdate appended. DelayUpdate is not needed in a function, but DoUpdate is useful in a 
function to force the contour traces to be built immediately rather than the default behavior of waiting until 
all functions have completed.
On the command line, the Display command and subsequent AppendXYZContour commands and any 
ModifyContour commands can be typed all on one line with semicolons between:
Display; AppendXYZContour zWave; ModifyContour ...
Flags
axisFlags
Flags /L, /R, /B, and /T are the same as used by AppendToGraph.
/F=formatStr
Determines names assigned to the contour level traces. This is the same as for 
AppendMatrixContour.
6
4
2
0
-2
-4
8
6
4
2
0
