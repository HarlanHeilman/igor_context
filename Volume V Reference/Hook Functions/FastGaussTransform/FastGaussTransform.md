# FastGaussTransform

FakeData
V-215
See Also
VoigtPeak, VoigtFunc, Built-in Curve Fitting Functions on page III-206
FakeData 
FakeData(waveName)
The FakeData function puts fake data in the named wave, which must be single-precision float. This is 
useful for testing things that require changing data before you have the source for the eventual real data. 
FakeData can be useful in a background task expression.
The FakeData function is not multidimensional aware. See Analysis on Multidimensional Waves on page 
II-95 for details.
Examples
Make/N=200 wave0; Display wave0
SetBackground FakeData(wave0)
// define background task
CtrlBackground period=60, start
// start background task
// observe the graph for a while
CtrlBackground stop
// stop the background task
FastGaussTransform 
FastGaussTransform [flags] srcLocationsWave, srcWeightsWave
The FastGaussTransform operation implements an efficient algorithm for evaluating the discrete Gauss 
transform, which is given by
where G is an M-dimensional vector, y is an N-dimensional vector representing the observation position, 
{qi} are the M-dimensional weights, {xi} are N-dimensional vectors representing source locations, and h is 
the Gaussian width. The wave M_FGT contains the output in the current data folder.
Flags
/AERR=aprxErr
Sets the approximate error, which determines how many terms of the Taylor 
expansion of the Gaussian are used by the calculation. Default value is 1e-5.
/WDTH=h
Sets the Gaussian width. Default value is 1.
/OUTW=locWave
Specifies the locations at which the output is computed. locWave must have the same 
number of columns as srcLocationsWave. The other /OUT flags are mutually exclusive; 
you should use only one at any time.
/OUT1={x1,nx,x2}
/OUT2={x1,nx,x2,y1,ny,y2}
/OUT3={x1,nx,x2,y1,ny,y2,z1,nz,z2}
Specifies gridded output of the required dimension. In each case you set the starting 
and ending values together with the number of intervals in that dimension. You 
cannot specify an output that does not match the dimensions of the input source.
/Q
No results printed in the history area.
/RX=rx
Sets the maximum radius of any cluster. The clustering algorithm terminates when 
the maximum radius is less than rx. Without /RX, the maximum radius is the same as 
the maximum radius encountered.
/RY=ry
Sets the upper bound for the distance between an observation point and a cluster 
center for which the cluster contributes to the transform value. The default value for 
ry is 4 times the Gaussian width as specified by the /WDTH flag.
G(yj) =
qi exp −
yj −xi
2
h
⎛
⎝
⎜⎜
⎞
⎠
⎟⎟
i=0
N−1
∑
,
