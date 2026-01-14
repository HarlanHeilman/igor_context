# ImageBoundaryToMask

ImageBoundaryToMask
V-367
Flags
See Also
ImageComposite
ImageBoundaryToMask 
ImageBoundaryToMask width=w, height=h, xwave=xwavename, ywave=ywavename [, 
scalingWave=scalingWaveName, [seedX=xVal, seedY=yVal]]
The ImageBoundaryToMask operation scan-converts a pair of XY waves into an ROI mask wave.
Parameters
Details
ImageBoundaryToMask generates an unsigned char 2D wave named M_ROIMask, of dimensions specified 
by width and height. The wave consists of a background pixels that are set to 0 and pixels representing the 
mask that are set to 1.
The x and y waves can be of any type. However, if the waves describe disjoint regions there must be at least 
one NaN entry in each wave corresponding to the discontinuity, which requires that you use either single or 
double precision waves. The values stored in the waves must correspond to zero-based integer pixel values.
If the x and y waves include a vertex that lies outside the mask rectangle, the offending vertex is moved to 
the boundary before the associated line segment is scan converted.
If you want to obtain a true ROI mask in which closed regions are filled, you can specify the seedX and 
seedY keywords. The ROI mask is set with zero outside the boundary of the domain and 1 everywhere 
inside the domain.
Examples
Make/O/N=(100,200) src=gnoise(5)
// create a test image
SetScale/P x 500,1,"", src;DelayUpdate
// give it some funny scaling
SetScale/P y 600,1,"", src
Display; AppendImage src
Make/O/N=201 xxx,yyy
// create boundary waves
xxx=550+25*sin(p*pi/100)
// representing a close ellipse
yyy=700+35*cos(p*pi/100)
AppendToGraph yyy vs xxx
Now create a mask from the ellipse and scale it so that it will be appropriate for src:
ImageBoundaryToMask ywave=yyy,xwave=xxx,width=100,height=200,scalingwave=src
/A=alpha
Specifies a single alpha value for the whole image
/W=alphaWave
Single precision wave that specifies an alpha value for each pixel.
height = h
Specifies the mask height in pixels.
scalingWave = scalingWaveName
2D or 3D wave that provides scaling for the mask. If specified, the scaling of the 
first two dimensions of scalingWave are copied to M_ROIMask, and both the X 
and Y waves are assumed to describe pixels in the scaled domain.
seedX = xVal
Specifies seed pixel location. The operation fills the region defined by the seed 
and the boundary with the value 1. Background pixels are set to zero. Requires 
seedY.
seedY = yVal
Specifies seed pixel location. The operation fills the region defined by the seed 
and the boundary with the value 1. Background pixels are set to zero. Requires 
seedX.
width = w
Specifies the mask width in pixels.
xwave = xwavename
Name of X wave for mask region.
ywave = ywavename
Name of Y wave for mask region.
