# Smoothing Spline Algorithm

Chapter III-7 — Analysis
III-118
For both the X and the Y destination waves, if the wave already exists, Interpolate2 overwrites it. If it does 
not already exist, Interpolate2 creates it.
The destination waves will be double-precision unless they already exist when Interpolate2 is invoked. In 
this case, Interpolate2 leaves single-precision destination waves as single-precision. For any other precision, 
Interpolate2 changes the destination wave to double-precision.
The Dest X Coords pop-up menu gives you control over the X locations at which the interpolation is done. 
Usually you should choose Evenly Spaced. This generates interpolated values at even intervals over the 
range of X input values.
The Evenly Spaced Plus Input X Coords setting is the same as Evenly Spaced except that Interpolate2 makes 
sure that the output X values include all of the input X values. This is usually not necessary. This mode is 
not available if you choose _none_ for your X destination wave.
The Log Spaced setting makes the output evenly spaced on a log axis. This mode ignores any non-positive 
values in your input X data. It is not available if you choose _none_ for your X destination wave. See Inter-
polating Exponential Data on page III-118 for an alternative.
The From Dest Wave setting takes the output X values from the X coordinates of the destination wave. The 
Destination Points setting is ignored. You could use this, for example, to get a spline through a subset of 
your input data. You must create your destination waves before doing the interpolation for this mode. If 
your destination is a waveform, use the SetScale operation to define the X values of the waveform. Interpo-
late2 will calculate its output at these X values. If your destination is an XY pair, set the values of the X des-
tination wave. Interpolate2 will create a sorted version of these values and will then calculate its output at 
these values. If the X destination wave was originally reverse-sorted, Interpolate2 will reverse the output.
The End Points radio buttons apply only to the cubic spline. They control the destination waves in the first 
and last intervals of the source wave. Natural forces the second derivative of the spline to zero at the first 
and last points of the destination waves. Match 1st Derivative forces the slope of the spline to match the 
straight lines drawn between the first and second input points, and between the last and next-to-last input 
points. In most cases it doesn't much matter which of these alternatives you use.
Interpolating Exponential Data
It is common to plot data that spans orders of magnitude, such as data arising from exponential processes, 
versus log axes. To create an interpolated data set from such data, it is often best to interpolate the log of 
the original data rather than the original data itself.
The Interpolate2 Log Demo experiment demonstrates how to do such interpolation. To open the demo, 
choose FilesExample ExperimentsFeature DemosInterpolate2 Log Demo.
Smoothing Spline Algorithm
The smoothing spline algorithm is based on "Smoothing by Spline Functions", Christian H. Reinsch, Numer-
ische Mathematik 10. It minimizes
among all functions g(x) such that
where g(xi) is the value of the smooth spline at a given point, yi is the Y data at that point, i is the standard 
deviation of that point, and S is the smoothing factor.
g'' x( )
x0
xn∫
2
dx,
g(xi)−yi
σ i
⎛
⎝⎜
⎞
⎠⎟
2
≤S,
i=0
n
∑
