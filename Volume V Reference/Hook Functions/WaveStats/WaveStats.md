# WaveStats

WaveStats
V-1082
Example
Function Test()
SetDataFolder root:
Make/O/FREE aaa
Make/O bbb
Make/O/WAVE/N=3 wr
Wr[0]=aaa
 
// Wr[1] is null by initialization.
wr[2]=bbb
Print WaveRefWaveToList(wr,0)
End
// Executing Test() gives:
 ;;root:bbb;
The first empty string corresponds to the free wave 'aaa' and the second empty string corresponds to the 
null entry in the wave reference wave.
See Also
ListToWaveRefWave, ListToTextWave, Wave References on page IV-71
WaveStats 
WaveStats [flags] waveName
The WaveStats operation computes several statistics on the named wave.
Flags
/ALPH=val
Sets the significance level for the confidence interval of the mean (default val=0.05).
/C=method
Calculates statistics for complex waves only. Does not affect real waves.
You can use method in various combinations to process the real, imaginary, 
magnitude, and phase of the wave. The result is stored in the wave M_WaveStats (see 
Details for format).
/CCL
When computing per-column statistics using /PCST, /CCL tells Igor to copy the 
column dimension labels of the input to the corresponding columns of M_WaveStats. 
/CCL was added in Igor Pro 9.00.
If you use a single method the results are stored both in M_WaveStats and in the 
standard variables (e.g., V_avg, etc.). If you specify method as a combination of more 
than one binary field then the variables reflect the results for the lowest chosen field 
and all results are stored in the wave M_WaveStats.
For example, if you use /C=12, the variables will be set for the statistics of the 
magnitude and M_WaveStats will contain columns corresponding to the magnitude 
and to the phase.
In this mode V_numInfs will always be zero.
Note: If you invoke this operation and M_WaveStats already exists in the current data 
folder, it will be either overwritten or initialized to NaN.
method is defined as follows:
method=0:
Default; ignores the imaginary part of waveName. Use /W to also 
store statistics in M_WaveStats.
method=1:
Calculates statistics for real part of waveName and stores it in 
M_WaveStats.
method=2:
Calculates statistics for imaginary part of waveName and stores the 
result in M_WaveStats.
method=4:
Calculates statistics for magnitude of waveName, i.e., 
sqrt(real^2 +imag^2), and stores the result in M_WaveStats.
method=8:
Calculate statistics for phase of waveName using 
atan2(imag,real).

WaveStats
V-1083
/M=moment
Calculates statistical moments.
/Q
Prevents results from being printed in history.
/P
Causes WaveStats to set the location output variables in terms of unscaled index 
values instead of the default scaled index values. The location output variables are:
V_minRowLoc, V_maxRowLoc, V_minColLoc, V_maxColLoc
V_minLayerLoc, V_maxLayerLoc, V_minChunkLoc, V_maxChunkLoc
For 1D waves, V_minRowLoc and V_maxRowLoc are always unscaled.
/P requires Igor Pro 8.03 or later.
/PCST
Computes the statistics on a per-column basis for a real valued wave of two or more 
dimensions. The results are saved in the wave M_WaveStats which has the same 
number of columns, layers and chunks as the input wave and where the rows, 
designated by dimension labels, contain the standard WaveStats statistics. All the V_ 
variables are set to NaN. Note that this flag is not compatible with the flags /C, /R, 
/RMD.
The /PCST flag was added in Igor Pro 7.00.
/R=(startX,endX)
Specifies an X range of the wave to evaluate.
/R=[startP,endP]
Specifies a point range of the wave to evaluate.
If you specify the range as /R=[startP] then the end of the range is taken as the end of 
the wave. If /R is omitted, the entire wave is evaluated.
/RMD=[firstRow,lastRow][firstColumn,lastColumn][firstLayer,lastlayer][firstChunk,lastChunk]
Designates a contiguous range of data in the source wave to which the operation is to 
be applied. This flag was added in Igor Pro 7.00.
You can include all higher dimensions by leaving off the corresponding brackets. For 
example:
/RMD=[firstRow,lastRow]
includes all available columns, layers and chunks.
You can use empty brackets to include all of a given dimension. For example:
/RMD=[][firstColumn,lastColumn]
means "all rows from column A to column B".
You can use a * to specify the end of any dimension. For example:
/RMD=[firstRow,*]
means "from firstRow through the last row".
/W
Stores results in the wave M_WaveStats in addition to the various V_ variables when /C=0.
/Z
No error reporting.
/ZSCR
Computes z scores
which are saved in W_ZScores.
moment is defined as follows:
moment=1:
Calculates only lower moments: V_avg, V_npnts, V_numInfs, and 
V_numNaNs. Use it if you do not need the higher moments.
moment=2:
Default; calculates both lower moments and higher order 
quantities: V_sdev, V_rms, V_adev, V_skew, and v_kurt.
zi = Yi −Y
σ
,

WaveStats
V-1084
Details
WaveStats uses a two-pass algorithm to produce more accurate results than obtained by computing the 
binomial expansions of the third and fourth order moments.
WaveStats returns the statistics in the automatically created variables:
V_npnts
Number of points in range excluding points whose value is NaN or INF.
V_numNans
Number of NaNs.
V_numINFs
Number of INFs.
V_avg
Average of data values.
V_sum
Sum of data values.
V_sdev
Standard deviation of data values,
“Variance” is V_sdev2.
V_sem
Standard error of the mean 
V_rms
RMS of Y values 
V_adev
Average deviation 
V_skew
Skewness 
V_kurt
Kurtosis 
V_minloc
X location of minimum data value.
V_min
Minimum data value.
V_maxloc
X location of maximum data value.
V_max
Maximum data value.
V_minRowLoc
Row containing minimum data value. See /P above for further information.
V_maxRowLoc
Row containing maximum data value. See /P above for further information.
V_minColLoc
Column containing minimum data value (2D or higher waves). See /P above for 
further information.
V_maxColLoc
Column containing maximum data value (2D or higher waves). See /P above for 
further information.
σ =
Yi −V _avg
(
)
2
∑
V _npnts −1
sem =
σ
V _npnts
=
1
V _npnts
Yi
2
∑
=
1
V _npnts
Yi −Y
i=0
V _npnts−1
∑
=
1
V _npnts
Yi −Y
σ
⎛
⎝⎜
⎞
⎠⎟
3
i=0
V _npnts−1
∑
=
1
V _npnts
Yi −Y
σ
⎛
⎝⎜
⎞
⎠⎟
4
i=0
V _npnts−1
∑
⎛
⎝⎜
⎞
⎠⎟−3

WaveStats
V-1085
WaveStats prints the statistics in the history area unless /Q is specified. The various multidimensional min 
and max location variables will only print to the history area for waves having the appropriate 
dimensionality.
The format of the M_WaveStats wave is:
meanL1 and meanL2 are the confidence intervals for the mean
 and 
where ta,v is the critical value of the Student T distribution for alpha significance and degree of freedom 
v=V_npnts-1.
V_minLayerLoc
Layer containing minimum data value (3D or higher waves). See /P above for further 
information.
V_maxLayerLoc
Layer containing maximum data value (3D or higher waves). See /P above for further 
information.
V_minChunkLoc
Chunk containing minimum data value (4D waves only). See /P above for further 
information.
V_maxChunkLoc
Chunk containing maximum data value (4D waves only). See /P above for further 
information.
V_startRow
The unscaled index of the first row included in caculating statistics.
V_endRow
The unscaled index of the last row included in caculating statistics.
V_startCol
The unscaled index of the first column included in calculating statistics. Set only when 
/RMD is used.
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
Row Statistic
Row Statistic
Row Statistic
Row Statistic
0
numPoints
9
minLoc
18
maxColLoc
27
startCol
1
numNaNs
10
min
19
maxLayerLoc
28
endCol
2
numInfs
11
maxLoc
20
maxChunkLoc
29
startLayer
3
avg
12
max
21
startRow
30
endLayer
4
sdev
13
minRowLoc
22
endRow
31
startChunk
5
rms
14
minColLoc
23
sum
32
endChunk
6
adev
15
minLayerLoc
24
meanL1
7
skew
16
minChunkLoc
25
meanL2
8
kurt
17
maxRowLoc
26
sem
MeanL1 = V _ avg −tα,v
V _ sdev
V _ npnts
,
MeanL2 = V _ avg + tα,ν
V _ sdev
V _ npnts
