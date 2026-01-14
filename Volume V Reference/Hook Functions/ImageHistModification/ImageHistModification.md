# ImageHistModification

ImageHistModification
V-378
There are at least two versions of f7 used in the literature and in software. We know of at least three versions 
of f14 so ImageGLCM does not compute it.
References
R.M. Haralick, K. Shanmugam and Itshak Dinstein, "Textural Features for Image Classification", IEEE 
Transactions on Systems, Man, and Cybernetics, 1973.
ImageHistModification 
ImageHistModification [flags] imageMatrix
The ImageHistModification operation performs a modification of the image histogram and saves the results 
in the wave M_ImageHistEq. If /W is not specified, the operation is a simple histogram equalization of 
imageMatrix. If /W is specified, the operation attempts to produce an image with a histogram close to 
waveName. If /A is specified, the operation performs an adaptive histogram equalization. imageMatrix is a 
wave of any noncomplex numeric type. Adaptive histogram equalization applies only to 2D waves and the 
other parts apply to both 2D and 3D waves.
Flags
/A
Performs an adaptive histogram equalization by subdividing the image into a 
minimum of 4 rectangular domains and using interpolation to account for the 
boundaries between adjacent domains. When the /C flag is specified with contrast 
factor greater than 1, this operation amounts to contrast-limited adaptive histogram 
equalization. By default the operation divides the image into 8 horizontal and 8 
vertical regions. See /H and /V.
/B=bins
Specifies the number of bins used with the /A flag. If not specified, this value defaults 
to 256.
/C=cFactor
Specifies a contrast factor (or clipping value) above which pixels are equally 
distributed over the whole range. cFactor must be greater than 1, in the limit as cFactor 
approaches 1 the operation is a regular adaptive histogram equalization. Note: this 
flag is used only with the /A flag.
/H=hRegions
Specifies the number of horizontal subdivisions to be used with the /A feature. Note, 
the number of image pixels in the horizontal direction must be an integer multiple of 
hRegions.
/I
Extends the standard histogram equalization by using 216 bins instead of 28 when 
calculating histogram equalization. This feature does not apply to the adaptive 
histogram equalization (/A flag).
/O
Overwrites the source image. If this flag is not specified, the resulting image is saved 
in the wave M_ImageHistEq.
HXY1= −
p[i][ j]log px(i)py( j)
(
),
j∑
i∑
HXY1= −
p[i][ j]log px(i)py( j)
(
),
j∑
i∑
HXY 2 = −
px(i)py( j)log px(i)py( j)
(
)
j∑
i∑
,
HX = −
px(i)log px(i)
(
),
i∑
HY = −
py(i)log py(i)
(
).
i∑
