# median

max
V-586
max 
max(num1, num2 [, num3, ... num200])
The max function returns the greatest value of num1, num2, ... num200.
If any parameter is NaN, the result is NaN.
Details
In Igor7 or later, you can pass up to 200 parameters. Previously max was limited to two parameters.
See Also
min, limit, WaveMin, WaveMax, WaveMinAndMax
mean 
mean(waveName [, x1, x2])
The mean function returns the arithmetic mean of the wave for points from x=x1 to x=x2.
Details
If x1 and x2 are not specified, they default to - and +, respectively.
The wave values from x1 to x2 are summed, and the result divided by the number of points in the range.
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x2. To use point indexing, 
replace x1 with pnt2x(waveName,pointNumber1), and a similar expression for x2.
If the points nearest to x1 or x2 are not within the point range of 0 to numpnts(waveName)-1, mean limits 
them to the nearest of point 0 or point numpnts(waveName)-1.
If any values in the point range are NaN, mean returns NaN.
The function returns NaN if the input wave has zero points.
Unlike the area function, reversing the order of x1 and x2 does not change the sign of the returned value.
The mean function is not multidimensional aware. See Chapter II-6, Multidimensional Waves, particularly 
Chapter II-6, Analysis on Multidimensional Waves for details.
Examples
Make/O/N=100 data; SetScale/I x 0,Pi,data
data=sin(x)
Print mean(data,0,Pi)
// the entire point range, and no more
Print mean(data)
// same as -infinity to +infinity
Print mean(data,Inf,-Inf)
// +infinity to -infinity
The following is printed to the history area:
Print mean(data,0,Pi)
// the entire point range, and no more
0.630201
Print mean(data)
// same as -infinity to +infinity
0.630201
Print mean(data,Inf,-Inf)
// +infinity to -infinity
0.630201
See Also
Variance, WaveStats, median, APMath
The figure “Comparison of area, faverage and mean functions over interval (12.75,13.32)”, in the Details 
section of the faverage function.
median
median(waveName [, x1, x2])
The median function returns the median value of the wave for points from x=x1 to x=x2.
The median function was added in Igor Pro 7.00.
Details
If you omit x1 and x2, they default to -INF and +INF, respectively.
