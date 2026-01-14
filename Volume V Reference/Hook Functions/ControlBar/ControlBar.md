# ControlBar

ControlBar
V-88
Details
For gridded contour data, ContourZ returns NaN if x or y falls outside the XY domain of the contour data. 
If x and y fall on the contour data grid, the corresponding Z value is returned.
For XYZ triplet contour data, ContourZ returns the null value if x or y falls outside the XY domain of the 
contour data. You can set the null value to v with this command:
ModifyContour contourName nullValue=v
If x and y match one of the XYZ triplet values, the corresponding Z value from the triplet usually won't be 
returned because Igor uses the Watson contouring algorithm which perturbs the x and y values by a small 
random amount. This also means that normally x and y coordinates on the boundary will return a null 
value about half the time if perturbation is on and pointFindingTolerance is greater than 1e-5.
Examples
Because ContourZ can interpolate the Z value of the contour data at any X and Y coordinates, you can use 
ContourZ to convert XYZ triplet data into gridded data:
// Make example XYZ triplet contour data
Make/O/N=50 wx,wy,wz
wx= enoise(2)
// x = -2 to 2
wy= enoise(2)
// y = -2 to 2
wz= exp(-(wx[p]*wx[p] + wy[p]*wy[p]))
// XY gaussian, z= 0 to 1
// ContourZ requires a displayed contour data set
Display; AppendXYZContour wz vs {wx,wy};DelayUpdate
ModifyContour wz autolevels={*,*,0}
// no contour levels are needed
ModifyContour wz xymarkers=1
// show the X and Y locations
// Set the null (out-of-XY domain) value
ModifyContour wz nullValue=NaN
// default is min(wz) - 1
// Convert to grid: Make matrix that spans X and Y
Make/O/N=(30,30) matrix
SetScale/I x, -2, 2, "", matrix
SetScale/I y, -2, 2, "", matrix
matrix= ContourZ("","wz",0,x,y)
// or = ContourZ("","",0,x,y)
AppendImage matrix
See Also
AppendMatrixContour, AppendXYZContour, ModifyContour, FindContour, zcsr, ContourInfo
References 
Watson, David F., Contouring: A Guide To The Analysis and Display of Spatial Data, Pergamon, 1992.
ControlBar 
ControlBar [flags] barHeight
The ControlBar operation sets the height and location of the control bar in a graph.
Parameters
barHeight is in points on Macintosh and pixels or points on Windows, depending on the screen resolution. 
See Control Panel Resolution on Windows on page III-456 for details.
Setting barHeight to zero removes the control bar.
