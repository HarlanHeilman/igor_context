# centerOfMassXY

CDFFunc
V-59
CDFFunc 
CDFFunc
CDFFunc is a procedure subtype keyword that identifies a function as being suitable for calling from the 
StatsKSTest operation.
ceil 
ceil(num)
The ceil function returns the closest integer greater than or equal to num.
The result for INF and NAN is undefined.
See Also
The round, floor, and trunc functions.
centerOfMass
centerOfMass(srcWave [,x1,x2])
The centerOfMass function returns the 1D center of mass for srcWave X values from x=x1 to x=x2.
The centerOfMass function was added in Igor Pro 9.00.
Center of mass and center of gravity in a uniform gravity field are different terms for the same calculation. 
When the masses are of uniform density, the center of mass is also identical to the geometric centroid.
Details
The center of mass is defined as
where the summation is over all the points in srcWave or over the X range specified by the optional 
parameters x1 and x2.
Each term in the numerator above can be written as
In this notation, yi represents an individual mass at x = xi , and the returned value xc is the X location of the 
center of the aggregate mass.
See Also
centerOfMassXY, mean, area, SumDimension, ImageAnalyzeParticles
centerOfMassXY
centerOfMassXY(waveX, waveY)
The centerOfMassXY function returns the 1D center of mass xc for the pair of waves.
The centerOfMassXY function was added in Igor Pro 9.00.
You can obtain the center of mass in the orthogonal direction (yc) by reversing the order of arguments to 
the function.
Details
The center of mass is defined as
centerMass =
xiyi
∑
yi
∑
,
xiyi = DimOffset(srcWave,0) + i⋅DimDelta(srcWave,0)
⎡⎣
⎤⎦srcWave[i].
