# Interp3D

interp
V-458
The CVODE package was derived in part from the VODE package. The parts used in Igor are described in 
this paper:
Brown, P.N., G. D. Byrne, and A. C. Hindmarsh, VODE, a Variable-Coefficient ODE Solver, SIAM J. Sci. Stat. 
Comput., 10, 1038-1051, 1989.
interp 
interp(x1, xwaveName, ywaveName)
The interp function returns a linearly interpolated value at the location x = x1 of a curve whose X components 
come from the Y values of xwaveName and whose y components come from the Y values of ywaveName.
Details
interp returns nonsense if the waves are complex or if xwaveName is not monotonic or if either wave 
contains NaNs.
The interp function is not multidimensional aware. See Analysis on Multidimensional Waves on page 
II-95 for details.
Examples
See Also
Interpolate2
The Loess, ImageInterpolate, Interpolate3D, and Interp3DPath operations.
The Interp2D, Interp3D and ContourZ functions.
Interp2D 
Interp2D(srcWaveName, xV, y)
The Interp2D function returns a double precision number as the bilinear interpolation value at the specified 
coordinates of the source wave. It returns NaN if the point is outside the source wave domain or if the source 
wave is complex.
Parameters
srcWaveName is the name of a 2D wave which wave must be real.
x is the X location of the interpolated point.
y is the Y location of the interpolated point.
See Also
The ImageInterpolate operation. Interpolation on page III-114.
Interp3D 
Interp3D(srcWave, x, y, z [, triangulationWave])
The Interp3D function returns an interpolated value for location P=(x, y, z) in a 3D scalar distribution srcWave.
If srcWave is a 3D wave containing a scalar distribution sampled on a regular lattice, the function returns a 
linearly interpolated value for any P=(x, y, z) location within the domain of srcWave. If P is outside the 
domain, the function returns NaN.
Examples
100
80
60
40
20
0
yData vs xData
interp(12.85,xData,yData) = 68.75
x1 = 12.85
