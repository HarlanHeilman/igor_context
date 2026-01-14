# ImageMorphology

ImageMorphology
V-395
•
Separate 2D waves by omitting the /LR3D flag
•
A single 3D wave by using the /LR3D flag
When you use /LR3D, ImageLoad stores each image from the TIFF file in a layer of the 3D output wave. 
This option works with grayscale images only, not with full color (e.g., RGB).
EXIF Metadata
Some applications embed metadata (information about the image) in EXIF format. In both JPEG and TIFF 
files, the metadata is stored using TIFF tags. To read the metadata, use the /RAT flag, even if you are loading 
a JPEG file.
Examples
// Load all images from a TIFF stack into separate 2D waves
ImageLoad /C=-1 /T=TIFF
// Load a single image from a TIFF stack into a 2D wave
ImageLoad/S=10/C=1/T=TIFF
// Load image 10 (zero based)
// Load all images from a TIFF stack into a single 3D wave
ImageLoad/LR3D/S=0/C=-1/T=TIFF
// Read all tags without loading any images
ImageLoad/C=-1/T=TIFF/RTIO
// Get the number of images in a TIFF stack
NewDataFolder/O/S tmp
ImageLoad/C=-1/T=TIFF/RTIO
Print V_numImages
KillDataFolder :
See Also
Loading Image Files on page II-157.
The ImageSave operation for saving waves as image files.
ImageMorphology 
ImageMorphology [flags] Method imageMatrix
The ImageMorphology operation performs one of several standard image morphology operations on the 
source imageMatrix. Unless the /O flag is specified, the resulting image is saved in the wave 
M_ImageMorph. The operation applies only to waves of type unsigned byte. All ImageMorphology 
methods except for watershed use a structure element. The structure element may be one of the built-in 
elements (see /E flag) or a user specified element.
Erosion, Dilation, Opening, and Closing are the only methods supported for a 3D imageMatrix.
Parameters
Method is one of the following names:
BinaryErosion
Erodes the source binary image using a built-in or user specified structure element 
(see /E and /S flags).
BinaryDilation
Dilates the source binary image using a built-in or user specified structure element 
(see /E and /S flags).
Closing
Performs the closing operation (dilation followed by erosion). The same structure 
element is used in both erosion and dilation. Note that this operation is an 
idempotent, which means that there is no point of executing it more than once.
Dilation
Performs a dilation of the source grayscale image using either a built-in structure 
element or a user specified structure element. The operation supports only 8-bit gray 
images.
Erosion
Erodes the source grayscale image using either a built-in structure element or a user 
specified structure element. The operation supports only 8-bit gray images.

ImageMorphology
V-396
Flags
Opening
Performs an opening operation (erosion followed by dilation). The same structure 
element is used in both erosion and dilation. Note that this operation is an idempotent 
which means that there is no point of executing it more than once.
TopHat
Calculates the difference between the eroded image and dilated image using the same 
structure element.
Watershed
Calculates the watershed regions for grayscale or binary image. Use the /N flag to 
mark all nonwatershed lines as NaNs. The /L flag switches from using 4 neighboring 
pixels (default) to 8 neighboring pixels.
/E=id
/I= iterations
Repeats the operation the specified number of iterations.
/L
Uses 8-connected neighbors instead of 4.
Uses a particular built in structure element. The following are the built-in structure 
element. The following are the built-in structure elements; make sure to use the 
appropriate id for the dimensionality of imageMatrix:
Note that this flag has no effect on watershed calculations.
id
Element
Origin
Shape
1
2x2 
(0,0)
square (default)
2
1x3 
(1,1)
row (in 3x3 square)
3
3x1
(1,1)
column (in 3x3 square)
4
3x3 
(1,1)
cross (in 3x3 square)
5
5x5
(2,2)
circle (in 5x5 square)
6
3x3
(1,1)
full 3x3 square
200
2x2x2
(1,1,1)
symmetric cube
202
2x2x2
(1,1,1)
2 voxel column in Y direction
203
2x2x2
(1,1,1)
2 voxel column in X direction
204
2x2x2
(1,1,1)
2 voxel column in Z direction
205
2x2x2
(1,1,1)
XY plane
206
2x2x2
(1,1,1)
YZ plane
207
2x2x2
(1,1,1)
XZ plane
300
3x3x3
(1,1,1)
symmetric cube
301
3x3x3
(1,1,1)
symmetric ball
302
3x3x3
(1,1,1)
3 voxel column in Y direction
303
3x3x3
(1,1,1)
3 voxel column in X direction
304
3x3x3
(1,1,1)
3 voxel column in Z direction
305
3x3x3
(1,1,1)
XY plane
306
3x3x3
(1,1,1)
YZ plane
307
3x3x3
(1,1,1)
XY plane
500
5x5x5
(2,2,2)
symmetric cube
501
5x5x5
(2,2,2)
symmetric ball
700
7x7x7
(3,3,3)
symmetric cube
701
7x7x7
(3,3,3)
symmetric ball
