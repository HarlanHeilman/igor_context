# ImageSkeleton3D

ImageSkeleton3D
V-413
minimum energy configuration is usually time consuming and it strongly depends on the format of the 
energy function and the initial conditions (as defined by the starting snake). The operation computes the 
energy as a sum of the following 5 terms:
1.
The coefficient alpha times a sum of absolute deviations from the average snake segment length. This 
term tends to distribute the vertices of the snake at even intervals.
2.
The coefficient beta times a sum of energies associated with the curvature of the snake at each vertex.
3.
The coefficient gamma times a sum of energies computed from the negative magnitude of the gradient 
of a Gaussian kernel convolved with the image. This term is usually referred to in the literature as the 
external energy and usually drives the snake to follow the direction of high image gradients.
4.
The coefficient delta times a repulsion energy. Repulsion is computed as an inverse square law by 
adding contributions from all vertices except the two that are immediately connected to each vertex. 
This energy term is designed to make sure that the snake does not fold itself into “valleys”.
5.
The coefficient eta times the sum of values corresponding to the positions of all snake vertices in the 
wave you provide in /EXEN.
The energy calculation skips all terms for which the coefficient is zero. In addition there is a built-in scan 
which adds a very high penalty for configurations in which the snake crosses itself.
ImageSkeleton3D
ImageSkeleton3D [/DEST=destWave /METH=method /Z ] srcWave
The ImageSkeleton3D operation computes the skeleton of a 3D binary object in srcWave by "thinning". 
Thinning is a layer-by-layer erosion until only the "skeleton" of an object remains. (See reference below.) It 
is used in neuroscience to trace neurons.
The ImageSkeleton3D operation was added in Igor Pro 7.00.
Parameters
srcWave is a 3D unsigned-byte wave where object voxels are set to 1 and the background is set to 0.
Flags
Details
The output is stored in the wave M_Skeleton in the current data folder or in the wave specified by /DEST.
Skeleton voxels are set to the value 1 and background voxels are set to 0.
Example
// Create a cube with orthogonal square holes
Make/B/U/N=(30,30,30) ddd=0
ddd[2,27][2,27][2,27]=1
ddd[2,27][10,20][10,20]=0
ddd[10,20][2,27][10,20]=0
ddd[10,20][10,20][2,27]=0
ImageSkeleton3D ddd
See Also
Chapter III-11, Image Processing, ImageMorphology, ImageSeedFill
/DEST=destWave
Specifies the wave to contain the output of the operation. If the specified wave already 
exists, it is overwritten.
When used in a user-defined function, ImageSkeleton3D creates wave reference for 
destWave if it is a simple name. See Automatic Creation of WAVE References on page 
IV-72 for details.
If you omit /DEST the output wave is M_Skeleton in the current data folder.
/METH=m
/Z
Do not report any errors.
Sets the method used to compute the skeleton.
This is currently the only supported method.
m=1:
Uses elements of an algorithm by Kalman Palagyi (default).
