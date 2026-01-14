# Working with ROI

Chapter III-11 — Image Processing
III-378
Other Tools
Igor provides a number of utility operations that help you manage and manipulate image data.
Working with ROI
Many of the image processing operations support a region of interest (ROI). The region of interest is the 
portion of the image that we want to affect by an operation. Igor supports a completely general ROI, spec-
ified as a binary wave (unsigned byte) that has the same dimensions as the image. Set the ROI wave to zero 
for all pixels within the region of interest and to any other value outside the region of interest. Note that in 
some situations it is useful to set the ROI pixels to a nonzero value (e.g., if you use the wave as a multipli-
cative factor in a mathematical operation). You can use ImageTransform with the invert keyword to quickly 
convert between the two options.
The easiest way to create an ROI wave is directly from the command line. For example, an ROI wave that 
covers a quarter of the blobs image may be generated as follows:
Duplicate root:images:blobs myROI
Redimension/B/U myROI
myROI=64
// arbitrary nonzero value
myROI[0,128][0,127]=0
// the actual region of interest
// Example of usage:
ImageThreshold/Q/M=1/R=myROI root:images:blobs
NewImage M_ImageThresh
If you want to define the ROI using graphical drawing tools you need to open the tools and set the drawing 
layer to progFront. This can be done with the following instructions:
SetDrawLayer progFront
ShowTools/A rect
// selects the rectangle drawing tool first
Generating ROI Masks
You can now define the ROI as the area inside all the closed shapes that you draw. When you complete 
drawing the ROI you need to execute the commands:
HideTools/A
// Drawing tools are not needed any more.
// M_ImageThresh is the top image in this example.
ImageGenerateROIMask M_ImageThresh
// The ROI wave has been created; To see it,
NewImage M_ROIMask
The Image Processing procedures provide a utility for creating an ROI wave by drawing on a displayed 
image.
Converting Boundary to a Mask
A third way of generating an ROI mask is using the ImageBoundaryToMask operation (see page V-367). This 
operation takes a pair of waves (y versus x) that contain pixel values and scan-converts them into a mask. 
When you invoke the operation you also have to specify the rectangular width and height of the output mask.
250
200
150
100
50
0
250
200
150
100
50
0
