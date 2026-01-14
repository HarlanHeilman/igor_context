# WaveMinAndMax

WaveMin
V-1078
Details
When the number of points in srcWave does not divide evenly into the bin size entry from binSizeWave, the 
last bin will have a smaller number of data points. In order not to skew the results the values corresponding 
to the last bin will be dropped. If your data set is small compared to the bin size you might want to pad 
srcWave with additional values (e.g., duplicate values from the beginning of the wave).
This operation does not support NaNs. If you get a NaN as an entry in the output wave then there is either 
a NaN in srcWave or something is wrong with the calculation for that entry.
WaveMin 
WaveMin(waveName [, x1, x2])
The WaveMin function returns the minimum value in the wave for points between x=x1 to x=x2, inclusive.
Details
If x1 and x2 are not specified, they default to -inf and +inf, respectively.
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x2. To use point indexing, 
replace x1 with pnt2x(waveName,pointNumber1), and a similar expression for x2.
If the points nearest to x1 or x2 are not within the point range of 0 to numpnts(waveName)-1, WaveMin limits 
them to the nearest of point 0 or point numpnts(waveName)-1.
NaN values in the wave are ignored.
See Also
WaveMax, WaveMinAndMax, WaveStats
WaveMinAndMax
WaveMinAndMax(wave [, x1, x2])
The WaveMinAndMax function returns the minimum and maximum values in the wave for points 
between x=x1 to x=x2, inclusive.
WaveMinAndMax must be called from a function, not from the command line, because it uses multiple 
return syntax as shown in the example below.
WaveMinAndMax was added in Igor Pro 9.00.
Details
If x1 and x2 are omitted, they default to -inf and +inf.
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x2. To use point indexing, 
replace x1 with "pnt2x(wave,pointNumber1)", and a similar expression for x2. The resulting point numbers 
are clipped to the range 0..n where n is the numpnts(wave )-1.
NaN values in the wave are ignored.
Example
Function DemoWaveMinAndMax()
Make/FREE wave0 = p
wave0[0] = NaN
// NaN values are ignored
SetScale/P x, 0, 0.1, "s", wave0
double minValue, maxValue
[minValue, maxValue] = WaveMinAndMax(wave0)
Printf "Entire wave: min=%g, max=%g\r", minValue, maxValue
[minValue, maxValue] = WaveMinAndMax(wave0, 5, 10)
Printf "From x=5 to x=10: min=%g, max=%g\r", minValue, maxValue
End
See Also
WaveMin, WaveMax, WaveStats
