# Using the Interpolate2 Operation

Chapter III-7 — Analysis
III-111
First, we cloned yData and created a new wave, wData. Since we used Duplicate, wData will have the same 
number of points as yData. We could have made a waveform with a different number of points. To do this, 
we would use the Make operation instead of Duplicate.
The SetScale operation sets the X scaling of the wData waveform. In this example, we are setting the X 
values of wData to go from 0 up to and including 1.0. This means that our waveform representation will 
contain 100 values at uniform intervals in the X dimension from 0 to 1.0.
The last step uses a waveform assignment to set the data values of wData. This assignment evaluates the 
right-hand expression once for each point in wData. For each evaluation, x takes on a different value from 
0 to 1.0. The interp function returns the value of the curve yData versus xData at x. For instance, x=.40404 
(point number 40 of wData) falls between two points in the XY curve. The interp function linearly interpo-
lates between those values to estimate a data value of 3.50537:
We can wrap these calculations up into an Igor procedure that can create a waveform version of any XY pair.
Function XYToWave1(xWave, yWave, wWaveName, numPoints)
Wave/D xWave
// X wave in the XY pair
Wave/D yWave
// Y wave in the XY pair
String wWaveName
// Name to use for new waveform wave
Variable numPoints
// Number of points for waveform
Make/O/N=(numPoints) $wWaveName
// Make waveform.
Wave wWave= $wWaveName
WaveStats/Q xWave
// Find range of x coords
SetScale/I x V_min, V_max, wWave // Set X scaling for wave
wWave = interp(x, xWave, yWave)
// Do the interpolation
End
This function uses the WaveStats operation to find the X range of the XY pair. WaveStats creates the vari-
ables V_min and V_max (among others). See Accessing Variables Used by Igor Operations on page IV-123 
for details.
The function makes the assumption that the input waves are already sorted. We left the sort step out 
because the sorting would be a side-effect and we prefer that procedures not have nonobvious side effects.
To use the WaveMetrics-supplied XYToWave1 function, include the “XY Pair To Waveform” procedure 
file. See The Include Statement on page IV-166 for instructions on including a procedure file.
If you have blanks (NaNs) in your input data, the interp function will give you blanks in your output wave-
form as well. The Interpolate2 operation, discussed in the next section, interpolates across gaps in data and 
does not produce blanks in the output.
Using the Interpolate2 Operation
The Interpolate2 operation provides not only linear but also cubic and smoothing spline interpolation. Fur-
thermore, it does not require the input to be sorted and can automatically make the destination waveform 
and set its X scaling. It also has a dialog that makes it easy to use interactively.
To use it on our sample XY data, choose AnalysisInterpolate and set up the dialog as shown:
6
5
4
3
2
0.44
0.42
0.40
0.38
0.36
0.34
interp(0.40404,xData,yData) = 3.50537
x = 0.40404
 yData vs xData
 wData
