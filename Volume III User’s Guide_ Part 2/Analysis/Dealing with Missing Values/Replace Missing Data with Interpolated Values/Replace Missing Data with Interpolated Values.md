# Replace Missing Data with Interpolated Values

Chapter III-7 — Analysis
III-113
See also NaNs, INFs and Missing Values on page II-83 for more about how NaN values.
Some routines deal with missing values by ignoring them. The CurveFit operation (see page V-124) is one 
example. Others may produce unexpected results in the presence of missing values. Examples are the FFT 
operation and the area and mean functions.
Here are some strategies for dealing with missing values.
Replace the Missing Values With Another Value
You can replace NaNs in a wave with this statement:
wave0 = NumType(wave0)==2 ? 0:wave0 
// Replace NaNs with zero
If you're not familiar with the :? operator, see Operators on page IV-6.
For multi-dimensional waves you can replace NaNs using MatrixOp. For example:
Make/O/N=(3,3) matNaNTest = p + 10*q
Edit matNaNTest
matNaNTest[0][0] = NaN; matNaNTest[1][1] = NaN; matNaNTest[2][2] = NaN
MatrixOp/O matNaNTest=ReplaceNaNs(matNaNTest,0)
// Replace NaNs with 0
Remove the Missing Values
For 1D waves you can remove NaNs using WaveTransform zapNaNs. For example:
Make/N=5 NaNTest = p
Edit NaNTest
NaNTest[1] = NaN; NaNTest[4] = NaN
WaveTransform zapNaNs, NaNTest
There is no built-in operation to remove NaNs from an XY pair if the NaN appears in either the X or Y wave. 
You can do this, however, using the RemoveNaNsXY procedure in the "Remove Points" WaveMetrics pro-
cedure file which you can access through HelpWindowsWM Procedures Index.
There is no operation to remove NaNs from multi-dimensional waves as this would require removing the 
entire row and entire column where each NaN appeared.
Work Around Gaps in Data
Many analysis routines can work on a subrange of data. In many cases you can just avoid the regions of 
data that contain missing values. In other cases you can extract a subset of your data, work with it and then 
perhaps put the modified data back into the original wave.
Here is an example of extract-modify-replace (even though Smooth properly accounts for NaNs):
Make/N=100 data1= sin(P/8)+gnoise(.05); data1[50]= NaN
Display data1
Duplicate/R=[0,49] data1,tmpdata1
// start work on first set
Smooth 5,tmpdata1
data1[0,49]= tmpdata1[P]
// put modified data back
Duplicate/O/R=[51,] data1,tmpdata1
// start work on 2nd set
Smooth 5,tmpdata1
data1[51,]= tmpdata1[P-51]
KillWaves tmpdata1
Replace Missing Data with Interpolated Values
You can replace NaN data values prior to performing operations that do not take kindly to NaNs by replac-
ing them with smoothed or interpolated values using the Smooth operation (page V-878), the Loess oper-
ation (page V-515), or The Interpolate2 Operation.
