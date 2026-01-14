# ImageRestore

ImageRestore
V-404
See Also
The ImageGenerateROIMask operation for creating ROIs.
ImageRestore
ImageRestore [flags] srcWave=wSrc, psfWave=wPSF [, relaxationGamma=h, 
startingImage=wRecon ] 
The ImageRestore operation performs the Richardson-Lucy iterative image restoration.
Flags
Parameters
Details
ImageRestore performs the Richardson-Lucy iteration solution to the deconvolution of an image. The input 
consists of the degraded image and point spread function as well as the desired number of iterations.
The operation allows you to apply additional iterations by setting the starting image to the restored output 
wave from a previous call to ImageRestore using the startingImage keyword. If startingImage is omitted, 
the starting image is created by ImageRestore with each pixel set to the value 1.
In the case of stellar images it may be useful to apply a relaxation step that involves scaling the correction 
evaluated at each iteration by 
where v is pixel value, vmax and vmin are the maximum and minimum level pixels in the image and 
gamma is the user-specified relaxationGamma.
References
W.H. Richardson, "Bayesian-Based Iterative Method of Image Restoration". JOSA 62, 1: 55-59, 1972.
L.B. Lucy, "An iterative technique for the rectification of observed distributions", Astronomical Journal 79, 6: 
745-754, 1974.
/DEST=destWave
Specifies the desired output wave.
If /DEST is omitted, the output from the operation is stored in the wave 
M_Reconstructed in the current data folder.
/ITER=iterations
Specifies the number of iterations. The default number of iterations is 100.
/Z
Do not report errors.
psfWave=wPSF
Specifies a known point spread function. wPSF must be a 2D (square NxN) wave 
of the same numeric type as wSRC. N must be an odd number greater than 1.
relaxationGamma=h
Specifies positive power gamma of in the relaxation mapping (see Details).
startingImage=wRecon
Use this keyword to specify a starting image that could be for example the output 
from a previous call to this operation. wRecon must have the same dimensions as 
wSRC and the same numeric type.
You must make sure that wRecon is not the user-specified or the default 
destination wave of the operation.
srcWave=wSrc
Specifies the degraded image which must be a 2D single-precision or double-
precision real wave.
factor(v) = sin 
2
v  vmin
vmax  vmin




 

,
