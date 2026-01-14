# Peak Measurement

Chapter III-9 — Signal Processing
III-290
EdgeStats is based on the same principles as FindLevel. EdgeStats does not work on an XY pair. See Con-
verting XY Data to a Waveform on page III-109.
Pulse Statistics
The PulseStats operation (see page V-783) produces simple statistics (measurements) on a region of a wave 
that is expected to contain three edges as shown below. If more than three edges exist, PulseStats works on 
the first three edges it finds. PulseStats handles two other cases in which there are only one or two edges. 
The pulse statistics are stored in special variables which are described in the PulseStats reference.
PulseStats is based on the same principles as EdgeStats. PulseStats does not work on an XY pair. See Con-
verting XY Data to a Waveform on page III-109.
Peak Measurement
The building block for peak measurement is the FindPeak operation. You can use it to build your own peak 
measurement procedures or you can use procedures provided by WaveMetrics.
Our Multipeak Fitting package provides a powerful GUI and programming interface for curve fitting to 
peak data. It can fit a number of peak shapes and baseline functions. A demo experiment provides an intro-
duction - choose FileExample ExperimentsCurve FittingMultipeak Fit Demo.
We have created several peak finding and peak fitting Technical Notes. They are described in a summary Igor 
Technical Note, TN020s-Choosing a Right One.ifn in the Technical Notes folder. There is also an example 
experiment, called Multi-peak Fit, that does fitting to multiple Gaussian, Lorentzian and Voigt peaks. Multi-
peak Fit is less comprehensive but easier to use than Tech Note 20.
The FindPeak operation (see page V-247) searches a wave for a minimum or maximum by analyzing the 
smoothed first and second derivatives of the wave. The smoothing and differentiation is done on a copy of 
the input wave (so that the input wave is not modified). The peak maximum is detected at the smoothed 
first derivative zero-crossing, where the smoothed second derivative is negative. The position of the 
minimum or maximum is returned in the special variable V_PeakLoc. This and other special variables set 
by FindPeak are described in the operation reference.
The following describes the process that FindPeak goes through when it executes a command like this:
FindPeak/M=0.5/B=5 peakData
// 5 point smoothing, min level = 0.5
point 1
point 2
level 3
point 3
x1 x2 x3
endX
point 4
point 0
level 1
level 2
startLevel
endLevel
startX
point 1
point 3
level 1
level 2
startLevel
endLevel
point 2
level 3
startX
endX
point 4
point 0
Case 1: 3 edges.

Chapter III-9 — Signal Processing
III-291
The box smoothing is performed first:
Then two central-difference differentiations are performed to find the first and second derivatives:
If you use the /M=minLevel flag, FindPeak ignores peaks that are lower than minLevel (i.e., the Y value of a 
found peak must exceed minLevel). The minLevel value is compared to the smoothed data, so peaks that appear 
to be large enough in the raw data may not be found if they are very near minLevel. If /N is also specified 
(search for minimum or “negative peak”), FindPeak ignores peaks whose amplitude is greater than minLevel 
(i.e., the Y value of a found peak will be less than minLevel). For negative peaks, the peak minimum is at the 
smoothed first derivative zero-crossing, where the smoothed second derivative is positive.
This command shows an example of finding a negative peak:
FindPeak/N/M=0.5/B=5 negPeakData
// 5 point smoothing, max level=0.5
1.0
0.8
0.6
0.4
0.2
0.0
-0.2
0.6
0.4
0.2
0.0
minLevel
Raw peak data
1.0
0.8
0.6
0.4
0.2
0.0
-0.2
0.6
0.4
0.2
0.0
V_PeakLoc
Smoothed peak data
40
30
20
10
0
-10
0.6
0.5
0.4
0.3
0.2
0.1
0.0
V_PeakLoc
Smoothed and Differentiated
2000
1000
0
-1000
-2000
0.6
0.4
0.2
0.0
V_PeakLoc
Smoothed and Twice Differentiated
