# ImageRemoveBackground

ImageRemoveBackground
V-403
References
The ImageRegistration operation is based on an algorithm described by:
Thévenaz, P., and M. Unser, A Pyramid Approach to Subpixel Registration Based on Intensity, IEEE 
Transactions on Image Processing, 7, 27-41, 1998.
ImageRemoveBackground 
ImageRemoveBackground /R=roiWave [flags] srcWave
The ImageRemoveBackground operation removes a general background level, described by a polynomial 
of a specified order, from the image in srcWave. The result of the operation are stored in the wave 
M_RemovedBackground.
Flags
Details
The identification of the background is done via the ROI wave. Set the pixels that define the background 
region to 1. The remaining pixels can be any value other than 1. We recommend using 64 which Igor image 
processing operations often interpret as "blank" in unsigned byte image waves.
The operation first performs a polynomial fit to the points designated by the ROI wave using the specified 
polynomial order. A polynomial of order N corresponds to the function:
Using the polynomial fit, a surface corresponding to the polynomial is subtracted from the source wave and 
the result is saved in M_RemovedBackground, unless the /O flag is used, in which case the original wave 
is overwritten.
Use the /W flag if you want polynomial coefficients to be saved in the W_BackgroundCoeff wave. 
Coefficients are stored in the same order as the terms in the sums above.
If you do not specify the polynomial order using the /P flag, the default order is 1, which means that the 
operation subtracts a plane (fitted to the ROI data) from the source image.
Note, if the image is stored as a wave of unsigned byte, short, or long, you might consider converting it into 
single precision (using Redimension/S) before removing the background. To see why this is important, 
consider an image containing a region of pixels equal to zero and subtracting a background plane 
corresponding to a nonconstant value. After subtraction, at least some of the pixels in the zero region should 
become negative, but because they are stored as unsigned quantities, they appear incorrectly as large values.
Examples
See Background Removal on page III-379.
/F
Computes only the background surface fit. Will only store the resulting fit in 
M_RemovedBackground. This will not subtract the fit from the image.
/O
Overwrites the original wave.
/P=polynomial order
Specifies the order of the polynomial fit to the background surface. If omitted, the 
order is assumed to be 1.
/R=roiWave
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/B/U), which has the same number of rows and columns as the image wave.
Set the pixels that define the background region to 1. The remaining pixels can be 
any value other than 1. We recommend using 64 which Igor image processing 
operations often interpret as "blank" in unsigned byte image waves.
The ROI does not have to be contiguous.
See ImageGenerateROIMask for more information on creating ROI waves.
/W
Specifies that polynomial coefficients are to be saved in the wave 
W_BackgroundCoeff.
FN x,y
(
) =
cnmxm−nyn.
n=0
m
∑
m=0
N
∑
