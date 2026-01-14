# JointHistogram

jlim
V-466
jlim 
jlim
The jlim function returns the ending loop count for the 2nd inner most iterate loop. Not to be used in a 
function. iterate loops are archaic and should not be used.
JointHistogram
JointHistogram [flags] wave1, wave2 [, wave3, wave4]
The JointHistogram computes 2D, 3D and 4D joint histograms of data provided in the input waves. The 
input waves must be 1D real numeric waves having the same number of points. The result of the operation 
is stored in the multidimensional wave M_JointHistogram in the current data folder or in the wave 
specified via the /DEST flag.
This operation was added in Igor Pro 7.00.
Flags
/BINS={nx, ny, nz, nt}
Specifies the number of bins along each axis. Set the number of bins for unused 
axes to zero. If the number of bins is non-zero, then the flags /XBMT, /YBMT, 
/ZBMT, and /TBMT are overridden.
/C
Sets the output wave scaling so that the values in each axis are centered in the 
bins. By default, wave scaling of the output wave is set with values at the left bin 
edges. This flag has no effect on axes where bins are specified by using /XBWV, 
/YBWV, /ZBWV or /TBWV.
/E
Excludes outliers. This flag is relevant only if there are one or more bin waves 
specified by using /XBWV, /YBWV, /ZBWV or /TBWV. By default values that 
might fall below the first bin or above the last bin are folded into the first and last 
bin respectively. These values (outliers) are excluded from the joint histogram 
when you use /E. See /P below for the way outliers affect the probability 
calculation.
/DEST=destWave
Specifies the output wave created by the operation. If you omit /DEST then the 
output wave is M_JointHistogram in the current data folder.
It is an error to specify a destination which is the same as one of the input waves.
When used in a user-defined function, the JointHistogram operation by default 
creates a real wave reference for the destination wave. See Automatic Creation of 
WAVE References on page IV-72 for details.
/P=mode
Normalizes the histogram to a probability density.
Use mode=0 to count all points, including possible outliers but excluding non-
finite values, in the probability calculation. This is the default setting.
Use mode=1 if you want to completely exclude outliers from the normalization.
When outliers are excluded the output wave sums to 1. When they are included 
the sum of the output wave is smaller by the ratio of the number of outliers to the 
total number of points in the histogram.
/W=weightWave
Creates a weighted histogram. Instead of adding a single count to the appropriate 
bin, the corresponding value from weightWave is added to the bin. weightWave 
may be any real number type.
/XBMT=method
/YBMT=method
/ZBMT=method
/TBMT=method
These flags specify which method is used to set the bins. By default method=0. 
These flags are overridden by /BINS if a non-zero value is specified for a given 
axis and by /XBWV, /YBWV, /ZBWV and /TBWV.
See JointHistogram Binning Methods below for details.

JointHistogram
V-467
Details
The input waves must be 1D real numeric waves. If one or more waves contain a non-finite value (a NaN 
or INF) the corresponding row of all waves are not counted in the joint histogram.
The optional waves that define user-specified bins must be real numeric waves and contain a monotonically 
increasing values. Using non-finite values in user-specified bin waves may lead to unpredictable results.
JointHistogram Binning Methods
The /XBMT, /YBMT, /ZBMT and /TBMT flags set the binning method for the X, Y, Z and T dimensions 
respectively.
These flags are overridden by /BINS if a non-zero value is specified for a given axis and by /XBWV, /YBWV, 
/ZBWV and /TBWV.
The method parameter is defined as follows: 
Bin selection methods are described at: http://en.wikipedia.org/wiki/Histogram
Example: 2D Joint Histogram
Make/O/N=(1000) xwave=gnoise(10), ywave=gnoise(5)
JointHistogram/BINS={20,30} xwave,ywave
NewImage M_JointHistogram
Example: 2D Joint Histogram using one bins wave
Make/O/N=(1000) xwave=gnoise(10), ywave=gnoise(5)
Make/O/N=3 xBinsWave={-8,0,14}
JointHistogram/BINS={0,30}/XBWV=xBinsWave/E xwave,ywave
Display; AppendImage/T M_JointHistogram vs {xBinsWave,*}
/XBWV=xBinWave
/YBWV=yBinWave
/ZBWV=zBinWave
/TBWV=tBinWave
Specifies the exact bins for a corresponding axis.
The wave must be 1D real numeric wave with monotonically increasing finite 
values and must contain a minimum of 3 data points.
The values in a bin wave specify the edges of the bins. A bin wave with N points 
defines n-1 bins. In the case of a 3-point bin wave, the first point corresponds to 
the minimum value of the first bin, the second point is the boundary between the 
two bins and the last point is the upper limit of the second bin.
These flags override the corresponding bin specification set via /BINS, /XBMT, 
/YBMT, /ZBMT and /TBMT.
/Z [=zval]
Suppresses error reporting.
/Z is equivalent to /Z=1 and /Z=0 is equivalent to not using the /Z flag at all.
method=0:
128 equally spaced bins between the minimum and maximum of the input data. This is 
the default setting.
method=1:
The number of bins is computed using Sturges' method where
numBins=1+log2(N).
N is the number of data points in each wave. The bins are distributed so that they include 
the minimum and maximum values.
method=2:
The number of bins is computed using Scott's method where the optimal bin width is 
given by
binWidth=3.49**N-1/3.
 is the standard deviation of the distribution and N is the number of points. The bins are 
distributed so that they include the minimum and maximum values.
method=3:
Freedman-Diaconis method where
binWidth=2*IQR*N-1/3,
where IQR is the interquartile distance (see StatsQuantiles) and the bins are evenly 
distributed between the minimum and maximum values.
