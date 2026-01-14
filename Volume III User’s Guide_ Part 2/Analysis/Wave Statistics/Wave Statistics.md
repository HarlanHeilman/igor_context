# Wave Statistics

Chapter III-7 — Analysis
III-122
One problem with these functions is that they can not be used if the given range of data has missing values 
(NaNs). See Dealing with Missing Values on page III-112 for details.
X Ranges and the Mean, faverage, and area Functions
The X range input for the mean, faverage and area functions are optional. Thus, to include the entire wave 
you don’t have to specify the range:
Make/N=10 wave=2; Edit wave.xy
// X ranges from 0 to 9
Print area(wave)
// entire X range, and no more
18
Sometimes, in programming, it is not convenient to determine whether a range is beyond the ends of a 
wave. Fortunately, these functions also accept X ranges that go beyond the ends of the wave.
Print area(wave, 0, 9)
// entire X range, and no more
18
You can use expressions that evaluate to a range beyond the ends of the wave:
Print leftx(wave),rightx(wave)
0 10
Print area(wave,leftx(wave),rightx(wave))
// entire X range, and more
18
or even an X range of ±×:
Print area(wave, -Inf, Inf) // entire X range of the universe
18
Finding the Mean of Segments of a Wave
Under Analysis Programming on page III-170 is a function that finds the mean of segments of a wave 
where you specify the length of the segments. It creates a new wave to contain the means for each segment.
Area for XY Data
To compute the area of a region of data contained in an XY pair of waves, use the areaXY function (see page 
V-41). There is also an XY version of the faverage function; see faverageXY on page V-218.
In addition you can use the AreaXYBetweenCursors WaveMetrics procedure file which contains the 
AreaXYBetweenCursors and AreaXYBetweenCursorsLessBase procedures. For instructions on loading the 
procedure file, see WaveMetrics Procedures Folder on page II-32. Use the Info Panel and Cursors to 
delimit the X range over which to compute the area. AreaXYBetweenCursorsLessBase removes a simple 
trapezoidal baseline - the straight line between the cursors.
Wave Statistics
The WaveStats operation (see page V-1082) computes various descriptive statistics relating to a wave and 
prints them in the history area of the command window. It also stores the statistics in a series of special vari-
ables or in a wave so you can access them from a procedure.
The statistics printed and the corresponding special variables are:
Variable
Meaning
V_npnts
Number of points in range excluding points whose value is NaN or INF.
V_numNaNs
Number of NaNs.
V_numINFs
Number of INFs.
V_avg
Average of data values.

Chapter III-7 — Analysis
III-123
V_sum
Sum of data values.
V_sdev
Standard deviation of data values, 
“Variance” is V_sdev2.
V_sem
Standard error of the mean 
V_rms
V_adev
V_skew
V_kurt
V_minloc
X location of minimum data value.
V_min
Minimum data value.
V_maxloc
X location of maximum data value.
V_max
Maximum data value.
V_minRowLoc
Row containing minimum data value.
V_maxRowLoc
Row containing maximum data value.
V_minColLoc
Column containing minimum data value (2D or higher waves).
V_maxColLoc
Column containing maximum data value (2D or higher waves).
V_minLayerLoc
Layer containing minimum data value (3D or higher waves).
V_maxLayerLoc
Layer containing maximum data value (3D or higher waves).
V_minChunkLoc
Chunk containing minimum v value (4D waves only).
V_maxChunkLoc
Chunk containing maximum data value (4D waves only).
V_startRow
The unscaled index of the first row included in caculating statistics.
V_endRow
The unscaled index of the last row included in caculating statistics.
V_startCol
The unscaled index of the first column included in calculating statistics. Set only when 
/RMD is used.
Variable
Meaning

1
V_npnts
1
–
----------------------------
Yi
V_avg
–

2

=
sem =
σ
V _npnts
RMS (Root Mean Square) of Y values
1
V_npnts
-------------------
Yi
2





=
Average deviation
1
V_npnts
-------------------
xi
x
–
i
0
=
V_npnts
1
–

=
Skewness
1
V_npnts
-------------------
xi
x
–

------------
3
i
0
=
V_npnts
1
–

=
Kurtosis
1
V_npnts
-------------------
xi
x
–

------------
4
3
–
i
0
=
V_npnts
1
–

=

Chapter III-7 — Analysis
III-124
To use the WaveStats operation, choose Wave Stats from the Statistics menu.
Igor ignores NaNs and INFs in computing the average, standard deviation, RMS, minimum and maximum. 
NaNs result from computations that have no defined mathematical meaning. They can also be used to rep-
resent missing values. INFs result from mathematical operations that have no finite value.
This procedure illustrates the use of WaveStats. It shows the average and standard deviation of a source 
wave, assumed to be displayed in the top graph. It draws lines to indicate the average and standard devi-
ation.
Function ShowAvgStdDev(source)
Wave source
// source waveform
Variable left=leftx(source),right=rightx(source)
// source X range
WaveStats/Q source
SetDrawLayer/K ProgFront
SetDrawEnv xcoord=bottom,ycoord=left,dash= 7
DrawLine left, V_avg, right, V_avg
// show average
SetDrawEnv xcoord=bottom,ycoord=left,dash= 7
DrawLine left, V_avg+V_sdev, right, V_avg+V_sdev
// show +std dev
SetDrawEnv xcoord=bottom,ycoord=left,dash= 7
DrawLine left, V_avg-V_sdev, right, V_avg-V_sdev
// show -std dev
SetDrawLayer UserFront
End 
You could try this function using the following commands.
Make/N=100 wave0 = gnoise(1)
Display wave0; ModifyGraph mode(wave0)=2, lsize(wave0)=3
ShowAvgStdDev(wave0)
When you use WaveStats with a complex wave, you can choose to compute the same statistics as above for 
the real, imaginary, magnitude and phase of the wave. By default WaveStats only computes the statistics 
for the real part of the wave. When computing the statistics for other components, the operation stores the 
results in a multidimensional wave M_WaveStats.
V_endCol
The unscaled index of the last column included in calculating statistics. Set only when 
/RMD is used.
V_startLayer
The unscaled index of the first layer included in calculating statistics. Set only when 
/RMD is used.
V_endLayer
The unscaled index of the last layer included in calculating statistics. Set only when 
/RMD is used.
V_startChunk
The unscaled index of the first chunk included in calculating statistics. Set only when 
/RMD is used.
V_endChunk
The unscaled index of the last chunk included in calculating statistics. Set only when 
/RMD is used.
Variable
Meaning
2
1
0
-1
-2
80
60
40
20
0
