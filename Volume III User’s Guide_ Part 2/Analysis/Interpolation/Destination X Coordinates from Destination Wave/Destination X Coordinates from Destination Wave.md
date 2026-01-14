# Destination X Coordinates from Destination Wave

Chapter III-7 — Analysis
III-119
Smoothing Spline Parameters
The smoothing spline operation requires a standard deviation parameter and a smoothing factor parame-
ter. The standard deviation parameter should be a good estimate of the standard deviation of the noise in 
your Y data. The smoothing factor should nominally be close to 1.0, assuming that you have an accurate 
standard deviation estimate.
Using the Standard Deviation section of the Interpolate2 dialog, you can choose one of three options for the 
standard deviation parameter: None, Constant, From Wave.
If you choose None, Interpolate2 uses an arbitrary standard deviation estimate of 0.05 times the amplitude 
of your Y data. You can then play with the smoothing factor parameter until you get a pleasing smooth 
spline. Start with a smoothing factor of 1.0. This method is not recommended.
If you choose Constant, you can then enter your estimate for the standard deviation of the noise and Inter-
polate2 uses this value as the standard deviation of each point in your Y data. If your estimate is good, then 
a smoothing factor around 1.0 will give you a nice smooth curve through your data. If your initial attempt 
is not quite right, you should leave the smoothing factor at 1.0 and try another estimate for the standard 
deviation. For most types of data, this is the preferred method.
If you choose From Wave then Interpolate2 expects that each point in the specified wave contains the esti-
mated standard deviation for the corresponding point in the Y data. You should use this method if you have 
an appropriate wave.
Interpolate2's Pre-averaging Feature
A linear or cubic spline interpolation goes through all of the input data points. If you have a large, noisy 
data set, this is probably not what you want. Instead, use the smoothing spline.
Before Interpolate2 had a smoothing spline, we recommended that you use the cubic spline to interpolate 
through a decimated version of your input data. The pre-averaging feature was designed to make this easy.
Because Interpolate2 now supports the smoothing spline, the pre-averaging feature is no longer necessary. 
However, we still support it for backward compatibility.
When you turn pre-averaging on, Interpolate2 creates a temporary copy of your input data and reduces it 
by decimation to a smaller number of points, called nodes. Interpolate2 then usually adds nodes at the very 
start and very end of the data. Finally, it does an interpolation through these nodes.
Identical Or Nearly Identical X Values
This section discusses a degenerate case that is of no concern to most users.
Input data that contains two points with identical X values can cause interpolation algorithms to produce 
unexpected results. To avoid this, if Interpolate2 encounters two or more input data points with nearly 
identical X values, it averages them into one value before doing the interpolation. This behavior is separate 
from the pre-averaging feature. This is done for the cubic and smoothing splines except when the Dest X 
Coords mode is is Log Spaced or From Dest Wave. It is not done for linear interpolation.
Two points are considered nearly identical in X if the difference in X between them (dx) is less than 0.01 
times the nominal dx. The nominal dx is computed as the X span of the input data divided by the number 
of input data points.
Destination X Coordinates from Destination Wave
This mode, which we call "X From Dest" mode for short, takes effect if you choose From Dest Wave from 
the Dest X Coords pop-up menu in the Interpolate2 dialog or use the Interpolate2 /I=3 flag. In this mode the 
number of output points is determined by the destination wave and the /N flag is ignored.
In X From Dest mode, the points at which the interpolation is done are determined by the destination wave. 
The destination may be a waveform, in which case the interpolation is done at its X values. Alternatively
