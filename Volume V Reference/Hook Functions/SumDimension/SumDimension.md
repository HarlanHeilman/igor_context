# SumDimension

sum
V-1007
sum 
sum(waveName [, x1, x2])
The sum function returns the sum of the wave elements for points from x=x1 to x=x2.
Details
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x2. To use point indexing, 
replace x1 with pnt2x(waveName,pointNumber1), and a similar expression for x2.
If x1 and x2 are not specified, they default to - and +, respectively.
If the points nearest to x1 or x2 are not within the point range of 0 to numpnts(waveName)-1, sum limits them 
to the nearest of point 0 or point numpnts(waveName)-1.
If any values in the point range are NaN, sum returns NaN.
Examples
Make/O/N=100 data; SetScale/I x 0,Pi,data
data=sin(x)
Print sum(data,0,Pi)
// the entire point range, and no more
Print sum(data)
// same as -infinity to +infinity
Print sum(data,Inf,-Inf)
// +infinity to -infinity
The following is printed to the history area:
Print sum(data,0,Pi)
// the entire point range, and no more
63.0201
Print sum(data)
// same as -infinity to +infinity
63.0201
Print sum(data,Inf,-Inf)
// +infinity to -infinity
63.0201
See Also
mean, area, SumSeries, SumDimension
SumDimension
SumDimension [flags] srcWave
The SumDimension operation sums values in srcWave along the specified dimension.
The SumDimension operation was added in Igor Pro 7.00.
Flags
Details
The operation sums one dimension of an N dimensional wave producing an output wave with N-1 
dimensions except if srcWave is 1D wave in which case SumDimension produces a single point 1D output 
wave. For example, given a 4D wave of dimensions dim0 x dim1 x dim2 x dim3 and the command:
/D=dimension
/DEST=destWave 
Specifies the output wave created by the operation. If destWave already exists it is 
overwritten by the new results. 
If you omit /DEST the operation saves the data in W_SumDimension if the output 
wave is 1D or M_SumDimension otherwise.
/Y=type
Specifies the data type of the output wave. See WaveType for the supported values of 
type.
If you omit /Y, the output wave is double precision.
Pass -1 for type to force the output wave to have the same data type as srcWave.
Specifies a zero-based dimension number.
If you omit /D the operation sums the highest dimension in the wave.
dimension=0:
Rows
dimension=1:
Columns
dimension=2:
Layers
dimension=3:
Chunks
