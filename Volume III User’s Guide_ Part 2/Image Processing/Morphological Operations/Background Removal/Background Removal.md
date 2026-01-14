# Background Removal

Chapter III-11 — Image Processing
III-379
// Create a circle.
Make/N=100 ddx,ddy
ddx=50*(1-sin(2*pi*x/100))
ddy=50*(1-cos(2*pi*x/100))
ImageBoundaryToMask width=100,height=100,xwave=ddx,ywave=ddy
// The result is an image not a curve!
NewImage M_ROIMask
Note that the resulting binary wave has the values 0 and 255, which you may need to invert before using 
them in certain operations.
In many situations the operation ImageBoundaryToMask is followed by ImageSeedFill in order to convert 
the mask to a filled region. You can obtain the desired mask in one step using the keywords seedX and 
seedY in ImageBoundaryToMask but you must make sure that the mask created by the boundary waves is 
a closed domain.
ImageBoundaryToMask width=100,height=100,xwave=ddx,ywave=ddy, 
seedX=50,seedY=50
ModifyImage M_ROIMask explicit=0
Marquee Procedures
A fourth way to create an ROI mask is using the Marquee2Mask procedures. To use this in your own exper-
iment you will have to add the following line to your procedure window:
#include <Marquee2Mask>
You can now create the ROI mask by selecting one or more rectangular marquees (drag the mouse) in the 
image. After you select each marquee click inside the marquee and choose MarqueeToMask or Append-
MarqueeToMask.
Subimage Selection
You can use an ROI to apply various image processing operations to selected portions of an image. The ROI 
is a very useful tool especially when the region of interest is either not contiguous or not rectangular. When 
the region of interest is rectangular, you can usually improve performance by creating a new subimage 
which consists entirely of the ROI. If you know the coordinates and dimensions of the ROI it is simplest to 
use the Duplicate/R operation. If you want to make an interactive selection you can use the marquee 
together with CopyImageSubset marquee procedure (after making a marquee selection in the image, click 
inside the marquee and choose CopyImageSubset).
Handling Color
Most of the image operations are designed to work on grayscale images. If you need to perform an opera-
tion on a color image certain aspects become a bit more complicated. In the next example we illustrate how 
you might sharpen a color image.
NewImage root:images:rose
ImageTransform rgb2hsl root:images:rose
// first convert to hsl
ImageTransform/P=2 getPlane M_RGB2HSL
ImageFilter Sharpen M_ImagePlane
// you can also use sharpenmore
ImageTransform /D=M_ImagePlane /P=2 setPlane M_RGB2HSL
ImageTransform hsl2rgb M_RGB2HSL
NewImage M_HSL2RGB
Background Removal
There are many approaches to removing the effect of a nonuniform background from an image. If the non 
uniformity is additive, it is sometimes useful to fit a polynomial to various points which you associate with 
the background and then subtract the resulting polynomial surface from the whole image. If the nonunifor-
mity is multiplicative, you need to generate an image corresponding to the polynomial surface and use it 
to scale the original image.

Chapter III-11 — Image Processing
III-380
Additive Background
Duplicate/O root:images:blobs addBlobs
Redimension/S addBlobs
// convert to single precision
addBlobs+=0.01*x*y
// add a tilted plane
NewImage addBlobs
To use the ImageRemoveBackground operation (see page V-403), we need an ROI mask designating 
regions in the image that represent the background. You can create one using one of the ROI construction 
methods that we discussed above. For the purposes of this example, we choose the ROI that consists of the 
7 rectangles shown in the Degraded Source image below.
// Show the ROI background selection.
AppendImage root:images:addMask
ModifyImage addMask explicit=1, eval={1,65000,0,0}
// Create a corrected image and display it.
ImageRemoveBackground /R=root:images:addMask /w/P=2 addBlobs
NewImage M_RemovedBackground
If the source image contains relatively small particles on a nonuniform background, you may remove the back-
ground (for the purpose of particle analysis) by iterating grayscale erosion until the particles are all gone. You 
are then left with a fairly good representation of the background that can be subtracted from the original image.
Multiplicative Background
This case is much more complicated because the removal of the background requires division of the image 
by the calculated background (it is assumed here that the system producing the image has an overall 
gamma of 1). The first complication has to do with the possible presence of zeros in the calculated back-
ground. The second complication is that the calculations give us the additional freedom to choose one con-
stant factor to scale the resulting image. There are many approaches for correcting a multiplicative 
background. The following example shows how an image can be corrected if we assume that the peak 
values (identified by the ROI mask) would all have the same value in the absence of a background.
Duplicate/O root:images:blobs mulBlobs
Redimension/S mulBlobs
// convert to single precision
mulBlobs*=(1+0.005*x*y)
NewImage mulBlobs
// Show us the ROI foreground selection; you can use histogram
// equalization to find fit regions in the dark area.
AppendImage root:images:multMask
ModifyImage multMask explicit=1, eval={1,65000,0,0}
ImageRemoveBackground /R=root:images:multMask/F/w/P=2 mulBlobs
// Normalize the fit.
WaveStats/Q/M=1 M_RemovedBackground
// Renormalize the fit--we can use that one free factor.
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
250
200
150
100
50
0
Degraded Source
Background Removed
