# faverageXY

faverage
V-218
See Also
MatrixOp, MatrixMultiply and MatrixMultiplyAdd for additional efficient matrix operations.
MultiThread
faverage 
faverage(waveName [, x1, x2])
The faverage function returns the trapezoidal average value of the named wave from x=x1 to x=x2.
If your data are in the form of an XY pair of waves, see faverageXY.
Details
If x1 and x2 are not specified, they default to - and +, respectively.
If x1 or x2 are not within the X range of waveName, faverage limits them to the nearest X range limit of waveName.
faverage returns the area divided by (x2-x1). In other words, the X scaling of waveName is eliminated when 
computing the average.
If any Y values in the specified X range are NaN, faverage returns NaN.
Unlike the area function, reversing the order of x1 and x2 does not change the sign of the returned value.
The faverage function is not multidimensional aware. See Analysis on Multidimensional Waves on page 
II-95 for details.
The faverage function returns a complex result for a complex inpt wave. The real part of the result is the 
average of the real components in the input wave and the imaginary part of the result is the average of the 
imaginary components.
Examples
Comparison of area, faverage and mean functions over interval (12.75,13.32) 
See Also
Integrate, area, areaXY, faverageXY and Poly2D Example 3
faverageXY 
faverageXY(XWaveName, YWaveName [, x1, x2])
The faverageXY function returns the trapezoidal average value of YWaveName from x=x1 to x=x2, using X 
values from XWaveName.
This function operates identically to faverage, except that it uses an XY pair of waves for X and Y values 
and it does not work with complex waves.
Details
If x1 and x2 are not specified, they default to - and +, respectively.
area(wave,12.75,13.32)
= 0.05 · (43+55) / 2
+ 0.20 · (55+88) / 2
+ 0.20 · (88+100) / 2
+ 0.12 · (100+92.2) / 2
= 47.082
// first trapezoid
// second trapezoid
// third trapezoid
// fourth trapezoid
faverage(wave,12.75,13.32)
= area(wave,12.75,13.32) / (13.32-12.75)
= 47.082/0.57 = 82.6
mean(wave,12.75,13.32)
= (55+88+100+87)/4 = 82.5
120
80
40
0
13.6
13.4
13.2
13.0
12.8
12.6
0.05
0.2
0.2
0.12
43
92.2
55
88
100
7
87
