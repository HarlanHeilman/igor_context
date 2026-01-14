# ImageNameList

ImageNameList
V-397
Examples
If you would like to apply a morphological operation to a wave whose data type is not an unsigned byte 
and you wish to retain the wave’s dynamic range, you can use the following approach:
Function ScaledErosion(inWave)
Wave inWave
WaveStats/Q inWave
Variable nor=255/(V_max-V_min)
MatrixOp/O tmp=nor*(inWave-V_min)
Redimension/B/U tmp
ImageMorphology/E=5 Erosion tmp
Wave M_ImageMorph
MatrixOp/O inWave=(M_ImageMorph/nor)+V_min
KillWaves/Z tmp,M_ImageMorph
End
See Also
The ImageGenerateROIMask operation for creating ROIs. For details and usage examples see 
Morphological Operations on page III-368 and Particle Analysis on page III-375.
ImageNameList 
ImageNameList(graphNameStr, separatorStr)
The ImageNameList function returns a string containing a list of image names in the graph window or 
subwindow identified by graphNameStr.
/N
Sets the background level to 64 (= NaN).
/O
Overwrites the source wave with the output.
/R=roiSpec
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/b/u). The ROI wave must have the same number of rows and columns as the 
image wave. The ROI itself is defined by the entries/pixels whose values are 0. Pixels 
outside the ROI can take any nonzero value. The ROI does not have to be contiguous 
and can take any arbitrary shape. See ImageGenerateROIMask for more information 
on creating ROI waves.
By default roiFlag is set to 1 and it is then possible to use the /R flag using the 
abbreviated form /R=roiWave.
/S= seWave
Specifies your own structure element.
seWave must be of type unsigned byte with pixels that belong to the structure element 
set to 1 and background pixels set to 0.
There are no limitations on the size of the structure element and you can use the /X 
and /Y flags to specify the origin of your structure element.
/W= whiteVal
Sets the white value in the binary image if it is different than 255. The black level is 
assumed to be zero.
/X= xOrigin
Specifies the X-origin of a user-defined structure element starting at 0. If you do not 
use this flag Igor sets the origin to the center of the specified structure element.
/Y= yOrigin
Specifies the Y-origin of a user defined structure element starting at 0. If you do not 
use this flag Igor sets the origin to the center of the specified structure element.
/Z= zOrigin
Specifies the Z-origin of the element for 3D structure elements. If you do not use this 
flag Igor sets the origin to the center of the specified structure element.
In general, the roiSpec has the form {roiWaveName, roiFlag}, where roiFlag can take 
the following values:
roiFlag=0:
Set pixels outside the ROI to 0.
roiFlag=1:
Set pixels outside the ROI as in original image.
roiFlag=2:
Set pixels outside the ROI to NaN (=64).
