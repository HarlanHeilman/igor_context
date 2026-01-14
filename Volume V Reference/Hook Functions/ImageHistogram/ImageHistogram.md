# ImageHistogram

ImageHistogram
V-379
See Also
The ImageGenerateROIMask and ImageTransform operations for creating ROIs. For examples see 
Histograms on page III-372 and Adaptive Histogram Equalization on page III-354.
ImageHistogram 
ImageHistogram [flags] imageMatrix
The ImageHistogram operation calculates the histogram of imageMatrix. The results are saved in the wave 
W_ImageHist. If imageMatrix is an RGB image stored as a 3D wave, the resulting histograms for each color 
plane are saved in W_ImageHistR, W_ImageHistG, W_ImageHistB.
imageMatrix must be a real-valued numeric wave.
Flags
/R=roiSpec
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/b/u). The ROI wave must have the same number of rows and columns as 
imageMatrix. The ROI itself is defined by the entries whose values are 0. Regions 
outside the ROI can take any nonzero value. The ROI does not have to be contiguous 
and can take any arbitrary shape.
By default roiFlag is set to 1 and it is then possible to use the /R flag with the 
abbreviated form /R=roiWave. When imageMatrix is a 3D wave, roiWave can be either 
a 2D wave (matching the number of rows and columns in imageMatrix) or it can be a 
3D wave which must have the same number of rows, columns, and layers as 
imageMatrix. When using a 2D roiWave with a 3D imageMatrix, the ROI is understood 
to be defined by roiWave for each layer in the 3D wave.
See ImageGenerateROIMask for more information on creating ROI waves.
/V=vRegions
Specifies the number of vertical subdivisions to be used with the /A flag. The number 
of image pixels in the horizontal direction must be an integer multiple of vRegions. If 
the image dimensions are not divisible by the number of regions that you want, you 
can pad the image using ImageTransform padImage.
/W=waveName
Specifies a 256-point wave that provides the desired histogram. The operation will 
attempt to produce an image having approximately the desired histogram values. 
This flag does not apply to the adaptive histogram equalization (/A flag)
/I
Calculates a histogram with 65536 bins evenly distributed between the minimum and 
maximum data values. The operation first finds the extrema and then calculates the 
bins and the resulting histogram. Data can be a 2D wave of any type including float 
or double.
/P=plane
Restricts the calculation of the histogram to a specific plane when imageMatrix is a non 
RGB 3D wave.
In general, the roiSpec has the form {roiWaveName, roiFlag}, where roiFlag can 
take the following values:
roiFlag=0:
Set pixels outside the ROI to 0.
roiFlag=1:
Set pixels outside the ROI as in original image (default).
roiFlag=2:
Set pixels outside the ROI to NaN (=64).
