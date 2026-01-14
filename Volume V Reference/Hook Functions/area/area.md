# area

area
V-40
Details
AppendXYZContour creates and displays contour level traces. You can modify these as a group using the 
Modify Contour Appearance dialog or individually using the Modify Trace Appearance dialog. In most 
cases, you will have no need to modify the traces individually.
See AppendMatrixContour for a discussion of how the contour level traces are named.
Examples
Make/O/N=(100) xW, yW, zW
// Make X, Y, and Z waves
xW = sawtooth(2*PI*p/10)
// Generate X values
yW = trunc(p/10)/10
// Generate Y values
zW = sin(2*PI*xW)*cos(2*PI*yW)
// Generate Z values
Display; AppendXYZContour zW vs {xW, yW}; DelayUpdate
ModifyContour zW autoLevels={*,*,9}
// roughly 9 automatic levels
See Also
The Display operation. AppendToGraph for details about other axis flags. The AppendMatrixContour, 
ModifyContour, and RemoveContour operations. For general information on contour plots, see Chapter 
II-15, Contour Plots.
area 
area(waveName [, x1, x2])
The area function returns the signed area between the named wave and the line y=0 from x=x1 to x=x2 using 
trapezoidal integration, accounting for the wave’s X scaling. If your data are in the form of an XY pair of 
waves, see areaXY.
Details
If x1 and x2 are not specified, they default to - and +, respectively.
If x1 or x2 are not within the X range of waveName, area limits them to the nearest X range limit of waveName.
If any values in the X range are NaN, area returns NaN.
The function returns NaN if the input wave has zero points.
Reversing the order of x1 and x2 changes the sign of the returned area.
The area function is intended to work on 1D real or complex waves only.
The area function returns a complex result for a complex input wave. The real part of the result is the area 
of the real components in the input wave, and the imaginary part of the result is the area of the imaginary 
components.
Examples
Make/O/N=100 data; SetScale/I x 0,Pi,data
data=sin(x)
Print area(data,0,Pi)
// the entire X range, and no more
Print area(data)
// same as -infinity to +infinity
Print area(data,Inf,-Inf)
// +infinity to -infinity
The following is printed to the history area:
Print area(data,0,Pi)
// the entire X range, and no more
1.99983
Print Print area(data)
// same as -infinity to +infinity
1.99983
Print area(data,Inf,-Inf)
// +infinity to -infinity
-1.99983
The -Inf value was limited to 0 and Inf was limited to Pi to keep them within the X range of data.
/W=winName
Appends to the named graph window or subwindow. When omitted, action affects 
the active window or subwindow. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
