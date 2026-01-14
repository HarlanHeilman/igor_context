# Using the XY Pair to Waveform Panel

Chapter III-7 — Analysis
III-109
Converting XY Data to a Waveform
Sometimes the best way to analyze XY data is to make a uniformly-spaced waveform representation of it 
and analyze that instead. Most analysis operations are easier with waveform data. Other operations, such 
as the FFT, can be done only on waveform data. Often your XY data set is nearly uniformly-spaced so a 
waveform version of it is a very close approximation.
In fact, often XY data imported from other programs has an X wave that is completely unnecessary in Igor 
because the values in the X wave are actually a simple "series" (values that define a regular intervals, such 
as 2.2, 2.4, 2.6, 2.8, etc), in which case conversion to a waveform is a simple matter of assigning the correct 
X scaling to the Y data wave, using SetScale (or the Change Wave Scaling dialog):
SetScale/P x, xWave[0], xWave[1]-xWave[0], yWave
Now the X wave is superfluous and can be discarded:
KillWaves/Z xWave
The XY Pair to Waveform panel can be used to set the Y wave's X scaling when it detects that the X wave 
contains series data. See Using the XY Pair to Waveform Panel on page III-109.
If your X wave is not a series, then to create a waveform representation of XY data you need to use interpolation. 
To create a waveform representation of XY data you need to do interpolation. Interpolation creates a waveform 
from an XY pair by sampling the XY pair at uniform intervals.
The diagram below shows how the XY pair defining the upper curve is interpolated to compute the uniformly-
spaced waveform defining the lower curve. Each arrow indicates an interpolated waveform value:
Igor provides three tools for doing this interpolation: The XY Pair to Waveform panel, the built-in interp 
function and the Interpolate2 operation. To illustrate these tools we need some sample XY data. The fol-
lowing commands make sample data and display it in a graph:
Make/N=100 xData = .01*x + gnoise(.01)
Make/N=100 yData = 1.5 + 5*exp(-((xData-.5)/.1)^2)
Display yData vs xData
This creates a Gaussian shape. The x wave in our XY pair has some noise in it so the data is not uniformly 
spaced in the X dimension.
The x data goes roughly from 0 to 1.0 but, because our x data has some noise, it may not be monotonic. This 
means that, as we go from one point to the next, the x data usually increases but at some points may 
decrease. We can fix this by sorting the data.
Sort xData, xData, yData
This command uses the xData wave as the sort key and sorts both xData and yData so that xData always 
increases as we go from one point to the next.
Using the XY Pair to Waveform Panel
The XY Pair to Waveform panel creates a waveform from XY data using the SetScale or Interpolate2 oper-
ations, based on an automatic analysis of the X wave's data.
XY Data
Waveform Data
