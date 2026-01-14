# Level Detection

Chapter III-9 — Signal Processing
III-287
Igor implements correlation with the Correlate operation (see page V-107). The Correlate dialog in the 
Analysis menu works similarly to the Convolve dialog. The source wave may also be a destination wave, 
in which case afterward it will contain the “auto-correlation” of the wave. If the source and destination are 
different, this is called “cross-correlation”.
The same considerations about combining differing types of source and destination waves applies to cor-
relation as to convolution. Correlation must also deal with end effects, and these are dealt with by the cir-
cular and linear correlation algorithm selections. See Convolution on page III-284.
Level Detection
Level detection is the process of locating the X coordinate at which your data passes through or reaches a given 
Y value. This is sometimes called “inverse interpolation”. Stated another way, level detection answers the ques-
tion: “given a Y level, what is the corresponding X value?” Igor provides two kinds of answers to that question.
One answer assumes your Y data is a list of unique Y values that increases or decreases monotonically. In this 
case there is only one X value that corresponds to a Y value. Since search position and direction don’t matter, a 
binary search is most appropriate. For this kind of data, use the BinarySearch or BinarySearchInterp functions.
The other answer assumes that your Y data varies irregularly, as it would with acquired data. In this case, 
there may be multiple X values that cross the Y level; the X value returned depends on where the search 
starts and the search direction through the data. The FindLevel, FindLevels, EdgeStats, and PulseStats oper-
ations deal with this kind of data.
12
11
10
9
0.3
0.2
0.1
0.0
Delay
12
10
8
6
4
2
0
-1.0
-0.5
0.0
0.5
1.0
0.8
0.6
0.4
0.2
1.2
1.0
0.8
0.6
0.4
0.2
0.0
 sent
 received
received_corr
 
WaveStats returns V_maxloc = 0.1
