# ImageFromXYZ

ImageFocus
V-373
ImageFocus 
ImageFocus [flags] stackWave
The ImageFocus operation creates in focus image(s) from a stack of images that contain in and out of focus 
regions. It computes the variance in a small neighborhood around each pixel and then takes the pixel value 
from the plane in which the highest variance is found.
Flags
See Also
Chapter III-11, Image Processing contains links to and descriptions of other image operations.
ImageFromXYZ
ImageFromXYZ [flags] xyzWave, dataMatrix, countMatrix
ImageFromXYZ [flags] {xWave,yWave,zWave}, dataMatrix, countMatrix
ImageFromXYZ converts XYZ data to matrix form. You might use it, for example, to convert a "sparse 
matrix" to an actual matrix for easier display and processing.
You provide the input data in the XYZ triplet xyzWave or in 1D waves xwave, ywave, and zwave.
dataMatrix and countMatrix receive output data but you must create them prior to calling ImageFromXYZ.
For each XY location in the input data, ImageFromXYZ adds the corresponding Z value to an element of 
dataMatrix. The element is determined based on the input XY location and the X and Y scaling of dataMatrix.
For each XY location in the input data, ImageFromXYZ increments the corresponding element of 
countMatrix. This permits you to obtain an average Z value if multiple input values fall into a given element 
of dataMatrix.
Parameters
xyzWave is a triplet wave containing the input XYZ data.
xWave, yWave and zWave are 1D input waves containing XYZ data.
You specify either xyzWave by itself or xWave, yWave and zWave in braces.
dataMatrix is a 2D wave to which the Z values are added. It must be either single-precision or double-
precision floating point. The X and Y scaling of dataMatrix determines how input values are mapped to 
output matrix elements.
countMatrix is a 2D wave the elements of which store the number of Z values added to each corresponding 
element of dataMatrix. ImageFromXYZ sets it to 32-bit integer if it is not already so.
Flags
Details
For each point in the XYZ input data, ImageFromXYZ adds the Z value to the appropriate element of 
dataMatrix and increments the corresponding element of countMatrix. Normally you will clear dataMatrix 
and countMatrix before calling it.
/ED=edepth
Sets the effective depth in planes. For example, an effective depth of one means that 
it computes the best focus for each plane using a stack of three planes, which includes 
the current plane and any one adjacent plane above and below it. Does not affect the 
default method (/METH=0).
/METH=method
/Q
Quiet mode; no output to history area.
/Z
No error reporting.
/AS
If /AS (autoscale) is specified, ImageFromXYZ clears both dataMatrix and countMatrix and sets 
the X and Y scaling of dataMatrix based on the range of X and Y input values.
Specifies the calculation method.
method=0:
Computes a single plane output for the stack (default).
method=1:
Computes the best image for each plane using /ED.
