# gammaInc

GalleryGlobal
V-288
Otherwise FunctionPath returns the path to the named function or "" if no function by that name exists.
Examples
This example loads a lookup table into memory. The lookup table is stored as a wave in an Igor binary wave 
file.
Function LoadMyLookupTable()
String path
path = FunctionPath("")
// Path to file containing this function.
if (CmpStr(path[0],":") == 0)
// This is the built-in procedure window or a packed procedure
// file, not a standalone file. Or procedures are not compiled.
return -1
endif
// Create path to the lookup table file.
path = ParseFilePath(1, path, ":", 1, 0) + "MyTable.ibw"
DFREF dfSave = GetDataFolderDFR()
// A previously-created place to store my private data.
SetDataFolder root:Packages:MyData
// Load the lookup table.
LoadWave/O path
SetDataFolder dfSave
return 0
End
See Also
The FunctionList function.
GalleryGlobal 
GalleryGlobal#pictureName
The GalleryGlobal keyword is used in an independent module to reference a picture in the global picture 
gallery which you can view by choosing MiscPictures.
See Also
See Independent Modules and Pictures on page IV-244.
gamma 
gamma(num)
The gamma function returns the value of the gamma function of num. If num is complex, it returns a 
complex result. Note that the return value for num close to negative integers is NaN, not ±Inf.
See Also
The gammln function.
gammaEuler
gammaEuler
The gammaEuler function returns the Euler-Mascheroni constant 0.5772156649015328606065.
The gammaEuler function was added in Igor Pro 7.00.
gammaInc 
gammaInc(a, x [, upperTail])
The gammaInc function returns the value of the incomplete gamma function, defined by the integral
If upperTail is zero, the limits of integration are 0 to x. If upperTail is absent, it defaults to 1, and the limits of 
integration are x to infinity, as shown. Note that gammaInc(a, x) = gamma(a) - gammaInc(a, x, 0).
Γ(a,x) =
e−tt a−1 dt.
x
∞∫
