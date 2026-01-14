# ImageEdgeDetection

ImageEdgeDetection
V-370
AutoPositionWindow/M=0/R=comp1 
End
Function RemoveAlphaChannel()
// Remove the alpha channel from imageA
Wave imageA
Duplicate/R=[][][0,2] imageA, imageA_rgb
NewImage/S=0 imageA_rgb
End
References
T. Porter & T. Duff - Compositing Digital Images. Computer Graphics Volume 18, Number 3, July 1984 pp 
253-259.
See Also
ImageBlend
ImageEdgeDetection 
ImageEdgeDetection [flags] Method imageMatrix
The ImageEdgeDetection operation performs one of several standard image edge detection operations on 
the source wave imageMatrix.
Unless the /O flag is specified, the resulting image is saved in the wave M_ImageEdges.
The edge detection methods produce binary images on output; the background is set to 0 and the edges to 
255. This is due, in most cases to a thresholding performed in the final stage.
Except for the case of marr and shen detectors, you can use the /M flag to specify a method for automatic 
thresholding; see the ImageThreshold /M flag.
Parameters 
Method selects type of edge detection. Method is one of the following names:
Flags
canny
Canny edge detector uses smoothing before edge detection and thresholding. You can 
optionally specify the threshold using the /T flag and the smoothing factor using /S.
frei
Calculates the Frei-Chen edge operator (see Pratt p. 503) using only the row and column 
filters.
kirsch
Kirsch edge detector (see Pratt p. 509). Performs convolution with 8 masks calculating 
gradients.
marr
Marr-Hildreth edge detector. Performs two convolutions with Laplacian of Gaussian and then 
detects zero crossings. Use the /S flag to define the width of the convolution kernel.
prewitt
Calculates the Prewitt compass gradient filters. Returns the result for the largest filter 
response.
roberts
Calculates the square root of the magnitude squared of the convolution with the Robert’s row 
and column edge detectors.
shen
Shen-Castan optimized edge detector. Supposed to be effective in the presence of noise. The flags 
that modify this operation are: /F for the threshold ratio (0.9 by default), /S for smoothness factor 
(0.9 by default), /W for window width (default is 10), /H for thinning factor which by default is 1.
sobel
Sobel edge detector using convolutions with row and column edge gradient masks (see Pratt p. 
501).
/F=fraction
Determines the threshold value for the shen algorithm by starting from the histogram 
of the image and choosing a threshold such that fraction specifies the portion of the 
image pixels whose values are below the threshold. Valid values are in the interval (0 
< fraction < 1).
/H=thinning
Thins edges when used with shen edge detector. By default the thinning value is 1. 
Higher values produce thinner edges.
/I
Inverts the output, i.e., sets the edges to 255 and the background to 0.

ImageEdgeDetection
V-371
See Also
The ImageGenerateROIMask operation for creating ROIs and the ImageThreshold operation.
Edge Detectors on page III-365 for a number of examples.
References
Pratt, William K., Digital Image Processing, John Wiley, New York, 1991.
/M=threshMethod
See the ImageThreshold automatic methods for obtaining a threshold value. 
Methods 1, 2, 4 and 5 are supported in this operation. If you use threshMethod = -1, 
threshold is not applied.
If you want to apply your own thresholding algorithm, use /M=6 to bypass the 
thresholding completely. The wave M_RawCanny contains the result regardless of 
any other flags you may have used.
/N
Sets the background level to 64 (i.e., NaN)
/O
Overwrites the source image with the output image.
/P=layer
Applies the operation to the specified layer of a 3D wave.
/P is incompatible with /O.
/P was added in Igor Pro 7.00.
/R=roiSpec
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/b/u). The ROI wave must have the same number of rows and columns as the 
image wave. The ROI itself is defined by entries/pixels whose values are 0. Pixels 
outside the ROI can be any nonzero value. The ROI does not have to be contiguous 
and can be any arbitrary shape. See ImageGenerateROIMask for more information 
on creating ROI waves.
By default roiFlag is set to 1 and it is then possible to use the /R flag using the 
abbreviated form /R=roiWave.
/S= smoothVal
Specifies the standard deviation or the width of the smoothing filter. By default the 
operation uses 1. Larger values require longer computation time. In the shen 
operation the default value is 0.9 and the valid range is (0 < smoothVal< 1).
/T=thresh
Sets a manual threshold for any method above that uses a single threshold. This is 
faster than using /M.
/W=width
Specifies window width when used in the shen operation. By default width is set to 
10 and it is clipped to 49.
In general, the roiSpec has the form {roiWaveName, roiFlag}, where roiFlag can take 
the following values:
roiFlag=0:
Set pixels outside the ROI to 0.
roiFlag=1:
Set pixels outside the ROI as in original image.
roiFlag=2:
Set pixels outside the ROI to NaN (=64).
