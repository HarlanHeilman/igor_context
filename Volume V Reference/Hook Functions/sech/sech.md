# sech

ScaleToIndex
V-832
ScaleToIndex
ScaleToIndex(wave, coordValue, dim)
The ScaleToIndex function returns the number of the element in the requested dimension whose scaled 
index value is closest to coordValue.
The ScaleToIndex function was added in Igor Pro 7.00.
Parameters
dim is a dimension number: 0 for rows, 1 for columns, 2 for layers, 3 for chunks.
coordValue is a scaled index in that dimension.
Details
The ScaleToIndex function returns the value of the expression:
round((coordValue - DimOffset(wave,dim)) / DimDelta(wave,dim))
With dim=0, ScaleToIndex is equivalent to x2pnt.
If coordValue is NaN or +/-INF, ScaleToIndex returns NaN. Otherwise, the result is computed based on the 
DimOffset and DimDelta of the specified dimension of the wave. The result is not clipped to a valid 
element number for the wave dimension.
See Also
IndexToScale, x2pnt, DimDelta, DimOffset
Waveform Model of Data on page II-62 for an explanation of wave scaling.
ScreenResolution 
ScreenResolution
The ScreenResolution function returns the logical resolution of your video display screen in dots per inch 
(dpi). On Macintosh this is always 72. On Windows it is usually 96 (small fonts) or 120 (large fonts).
Examples
// 72 is the number of points in an inch which is constant.
Variable pixels = numPoints * (ScreenResolution/72)
// Convert points to pixels
Variable points = numPixels * (72/ScreenResolution)
// Convert pixels to points
See Also
PanelResolution
sec 
sec(angle)
The sec function returns the secant of angle which is in radians:
In complex expressions, angle is complex, and sec(angle) returns a complex value.
See Also
sin, cos, tan, csc, cot
sech 
sech(x)
The sech function returns the hyperbolic secant of x.
sec(x) =
1
cos(x).
csch(x) =
1
cosh(x) =
2
ex + e−x .
