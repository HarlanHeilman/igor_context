# BinarySearchInterp

BinarySearch
V-51
SetDrawLayer UserBack
SetDrawEnv xcoord= bottom,ycoord= left,save
SetDrawEnv linethick= 3,linefgc= (48059,48059,48059)
DrawBezier wx[0],wy[0],1,1,wx,wy
SetDrawLayer UserFront
EndMacro
See Also
DrawBezier, DrawPoly, Drawing Polygons and Bezier Curves on page III-69
BinarySearch 
BinarySearch(waveName, val)
The BinarySearch function performs a binary search of the one-dimensional waveName for the value val. 
BinarySearch returns an integer point number p such that waveName[p] and waveName[p+1] bracket val. If 
val is in waveName, then waveName[p]==val.
Details
BinarySearch is useful for finding the point in an XY pair that corresponds to a particular X coordinate.
WaveName must contain monotonically increasing or decreasing values.
BinarySearch returns -1 if val is not within the range of values in the wave, but would numerically be placed 
before the first value in the wave.
BinarySearch returns -2 if val is not within the range of values in the wave, but would fall after the last value 
in the wave.
BinarySearch returns -3 if the wave has zero points.
Examples
Make/O data = {1, 2, 3.3, 4.9}
// Monotonic increasing
Print BinarySearch(data,3)
// Prints 1
// BinarySearch returns 1 because data[1] <= 3 < data[2].
Make/O data = {9, 4, 3, -6}
// Monotonic decreasing
Print BinarySearch(data,2.5)
// Prints 2
// BinarySearch returns 2 because data[2] >= 2.5 > data[3].
Print BinarySearch(data,10)
// Prints -1, precedes first value
Print BinarySearch(data,-99)
// Prints -2, beyond last value
See Also
The BinarySearchInterp and FindLevel operations. See Indexing and Subranges on page II-76.
BinarySearchInterp 
BinarySearchInterp(waveName, val)
The BinarySearchInterp function performs a binary interpolated search of the named wave for the value val. 
The returned value, pt, is a floating-point point index into the named wave such that waveName[pt] == val.
Details
BinarySearchInterp is useful for finding the point in an XY pair that corresponds to a particular X 
coordinate.
WaveName must contain monotonically increasing or decreasing values.
When the named wave does not actually contain the value val, BinarySearchInterp locates a value below val 
and a value above val and uses reverse linear interpolation to figure out where val would fall if a straight 
line were drawn between them. It includes that fractional amount in the resulting point index.
BinarySearchInterp returns NaN if val is not within the range of values in the wave.
Examples
Make/O data = {1, 2, 3.3, 4.9}
// Monotonic increasing
Print BinarySearchInterp(data,3)
// Prints 1.76923
Print data[1.76923]
// Prints 3
Make/O data = {9, 4, 3, 1}
// Monotonic decreasing
Print BinarySearchInterp(data,2.5)
// Prints 2.25
Print data[2.25]
// Prints 2.5
