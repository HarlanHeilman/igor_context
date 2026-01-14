# asin

areaXY
V-41
See Also
The figure “Comparison of area, faverage and mean functions over interval (12.75,13.32)”, in the Details 
section of the faverage function.
Integrate, areaXY, faverage, faverageXY, Poly2D Example 3
areaXY 
areaXY(XWaveName, YWaveName [, x1, x2])
The areaXY function returns the signed area between the named YWaveName and the line y=0 from x=x1 to 
x=x2 using trapezoidal integration with X values supplied by XWaveName.
This function is identical to the area function except that it works on an XY wave pair and does not work 
with complex waves.
Details
If x1 and x2 are not specified, they default to - and +, respectively.
If x1 or x2 are outside the X range of XWaveName, areaXY limits them to the nearest X range limit of XWaveName.
If any values in the Y range are NaN, areaXY returns NaN.
If any values in the entire X wave are NaN, areaXY returns NaN.
The function returns NaN if the input wave has zero points.
Reversing the order of x1 and x2 changes the sign of the returned area.
If x1 or x2 are not found in XWaveName, a Y value is found by linear interpolation based on the two 
bracketing X values and the corresponding values from YWaveName.
The values in XWaveName may be increasing or decreasing. AreaXY assumes that the values in XWaveName 
are monotonic. If they are not monotonic, Igor does not complain, but the result is not meaningful. If any X 
values are NaN, the result is NaN.
See the figure “Comparison of area, faverage and mean functions over interval (12.75,13.32)”, in the Details 
section of the faverage function.
The areaXY operation is intended to work on 1D waves only.
Examples
Make/O/N=101 Xdata, Ydata
Xdata = x*pi/100
Ydata = sin(Xdata[p])
Print areaXY(Xdata, Ydata,0,Pi)
// the entire X range, and no more
Print areaXY(Xdata, Ydata)
// same as -infinity to +infinity
Print areaXY(Xdata, Ydata,Inf,-Inf)
// +infinity to -infinity
The following is printed to the history area:
Print areaXY(Xdata, Ydata,0,Pi)
// the entire X range, and no more
1.99984
Print areaXY(Xdata, Ydata)
// same as -infinity to +infinity
1.99984
Print areaXY(Xdata, Ydata,Inf,-Inf)
// +infinity to -infinity
-1.99984
The -Inf value was limited to 0, and Inf was limited to Pi to stay within the X range of data.
See Also
Integrate, area, faverage, faverageXY, Poly2D Example 3
asin 
asin(num)
The asin function returns the inverse sine of num in radians in the range [-/2,/2].
In complex expressions, num is complex, and asin returns a complex value.
See Also
sin
