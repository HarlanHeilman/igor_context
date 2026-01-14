# ImageStats

ImageStats
V-414
Reference
K. Palagyi, "A 3D fully parallel surface-thinning algorithm", Theoretical Computer Science 406 (2008) 119-135.
ImageStats 
ImageStats [ flags ] imageWave
The ImageStats operation calculates wave statistics for specified regions of interest in a real matrix wave. 
The operation applies to image pixels whose corresponding pixels in the ROI wave are set to zero. It does 
not print any results in the history area.
Flags
/BEAM
Computes the average, minimum, and maximum pixel values in each layer of a 3D 
wave and 2D ROI. Output is to waves W_ISBeamAvg, W_ISBeamMax, and 
W_ISBeamMin in the current data folder. Use /RECT to improve efficiency for simple 
ROI domains. V_ variable results correspond to the last evaluated layer of the 3D 
wave. Do not use /G, /GS, or /P with this flag. Set /M=1 for maximum efficiency.
/BRXY={xWave, yWave}
Use this option with a 3D imageWave. It provides a more efficient method for 
computing average, minimum and maximum values when the set of points of interest 
is much smaller than the dimensions of an image.
Here xWave and yWave are 1D waves with the same number of points containing XY 
integer pixel locations specifying arbitrary pixels for which the statistics are 
calculated on a plane by plane basis as follows:
Pixel locations are zero-based; non-integer entries may produce unpredictable results.
The calculated statistics for each plane are stored in the current data folder in the 
waves W_ISBeamAvg, W_ISBeamMax and W_ISBeamMin.
Note: This flag is not compatible with any other flag except /BEAM.
/C=chunk
When imageWave is a 4D wave, /C specifies the chunk for which statistics are 
calculated. By default chunk = 0.
Added in Igor Pro 7.00.
/G={startP, endP, startQ, endQ}
Specifies the corners of a rectangular ROI. When this flag is used an ROI wave is not 
required. This flag requires that startP  endP and startQ endQ. When the parameters 
extend beyond the image area, the command will not execute and V_flag will be set 
to -1. You should therefore verify that V_flag0 before using the results of this 
operation.
/GS={sMinRow,sMaxRow,sMinCol,sMaxCol}
Specifies a rectangular region of interest in terms of the scaled image coordinates. 
Each one of the 4 values will be translated to an integer pixel using truncation.
This flag, /G, and an ROI specification are mutually exclusive.
/M=val
Calculates the average and locates the minimum and the maximum in the ROI when 
/M=1. This will save you the computation time associated with the higher order 
statistical moments.
/P=planeNumber
Restricts the calculation to a particular layer of a 3D wave. By default, planeNumber= -
1 and only the first layer of the wave is processed.
W_ISBeamAvg[k]= 1
n
Image[xWave[i]][yWave[i]].
i=1
n

