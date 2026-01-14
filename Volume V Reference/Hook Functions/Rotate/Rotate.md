# Rotate

RGBColor
V-810
RGBColor
The RGBColor structure is used as a substructure usually to store various color settings.
Structure RGBColor
UInt16 red
UInt16 green
UInt16 blue
EndStructure
RGBAColor
The RGBAColor structure is the same as RGBColor but with an alpha field to represent translucency.
Structure RGBAColor
UInt16 red
UInt16 green
UInt16 blue
UInt16 alpha
EndStructure
rightx 
rightx(waveName)
The rightx function returns the X value corresponding to point N of the named 1D wave of length N.
Details
Note that the point numbers in a wave run from 0 to N-1 so there is no point with this X value. To get the 
X value of the last point in a wave (point N-1), use the following:
pnt2x(waveName,numpnts(waveName)-1)
// N = numpnts(waveName)
which is more accurate than:
rightx(waveName) - deltax(waveName)
The rightx function is not multidimensional aware. See Analysis on Multidimensional Waves on page 
II-95 for details. The equivalent information for any dimension can be calculated this way:
IndexN = DimSize(wave, dim)*DimDelta(wave, dim) + DimOffset(wave, dim)
Here IndexN is the value of the scaled dimension index corresponding to element N of the dimension dim 
in a wave named wave that has N elements in that dimension.
See Also
The deltax and leftx functions, also the pnt2x and numpnts functions.
For an explanation of waves and dimension scaling, see Changing Dimension and Data Scaling on page II-68.
For multidimensional waves, see DimDelta, DimOffset, and DimSize.
root 
root[:dataFolderName[:dataFolderName[:…]]][:objectName]
Igor’s data folder hierarchy starts with the root folder as its basis. The root data folder always exists and it 
contains all other objects (waves, variables, strings, and data folders). By default, the root data folder is the 
current data folder in a new experiment. In commands, root is used as part of a path specifying the location 
of a data object in the folder hierarchy.
See Also
Chapter II-8, Data Folders.
Rotate 
Rotate rotPoints, waveName [, waveName]…
The Rotate operation rotates the Y values of waves in wavelist by rotPoints points.
Parameters
If rotPoints is positive then values are rotated from the start of the wave toward the end and rotPoints values 
from the end of a wave wrap around to the start of the wave.
