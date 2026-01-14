# Correlate

CopyScales
V-107
Details
You can use only /P=pathName (without srcFolderStr) to specify the source folder to be copied.
Folder paths should not end with single Path Separators. See the Details section for MoveFolder.
See Also
Open, MoveFile, DeleteFile, MoveFolder, NewPath, and IndexedDir operations, and Symbolic Paths on 
page II-22.
CopyScales 
CopyScales [/I/P] srcWaveName, waveName [, waveName]…
The CopyScales operation copies the x, y, z, and t scaling, x, y, z, and t units, the data Full Scale and data 
units from srcWaveName to the other waves.
Flags
Details
Normally the x, y, z, and t (dimension) scaling is copied in min/max format. However, if you use /P, the 
dimension scaling is copied in slope/intercept format so that if srcWaveName and the other waves have 
differing dimension size (number of points if the wave is a 1D wave), then their dimension values will still 
match for the points they have in common. Similarly, /I uses the inclusive variant of the min/max format. 
See SetScale for a discussion of these dimension scaling formats.
If a wave has only one point, /I mode reverts to /P mode.
CopyScales copies scales only for those dimensions that srcWaveName and waveName have in common.
See Also
x, y, z, and t scaling functions.
Correlate 
Correlate [/AUTO/C/NODC] srcWaveName, destWaveName [, destWaveName]…
The Correlate operation correlates srcWaveName with each destination wave, putting the result of each 
correlation in the corresponding destination wave.
Flags
Details
Note:
To compute a single-value correlation number use the StatsCorrelation function which returns 
the Pearson's correlation coefficient of two same-length waves.
Correlate performs linear correlation unless the /C flag is used.
/I
Copies the x, y, z, and t scaling in inclusive format.
/P
Copies the x, y, z, and t scaling in slope/intercept format (x0, dx format).
/AUTO
Auto-correlation scaling. This forces the X scaling of the destination wave's center point to be 
x=0, and divides the destination wave by the center point's value so that the center value is 
exactly 1.0.
If srcWaveName and destWaveName do not have the same number of points, this flag is 
ignored.
/AUTO is not compatible with /C.
/C
Circular correlation. (See Compatibility Note.)
/NODC
Removes the mean from the source and destination waves before computing the correlations. 
Removing the mean results in the un-normalized auto- or cross-covariance.
"DC" is an abbrevation of "direct current", an electronics term for the non-varying average 
value component of a signal.

Correlate
V-108
Depending on the type of correlation, the length of the destination may increase. srcWaveName is not altered 
unless it also appears as a destination wave.
If the source wave is real-valued, each destination wave must be real-valued and if the source wave is 
complex, each destination wave must be complex, too. Double and single precision waves may be freely 
intermixed; calculations are performed in the higher precision.
The linear correlation equation is:
where N is the number of points in the longer of destWaveIn and srcWave.
For circular correlation, the index [p +m] is wrapped around when it exceeds the range of 
[0,numpnts(destWaveIn)-1]. For linear correlation, when [p +m] exceeds the range a zero value is 
substituted for destWaveIn[p +m]. When m exceeds numpnts(srcWave)-1, 0 is used instead of srcWave[m].
Comparing this with the Convolve operation, which is the linear convolution:
you can see that the only difference is that for correlation the source wave is not reversed before shifting and 
combining with the destination wave.
The Correlate operation is not multidimensional aware. For details, see Analysis on Multidimensional 
Waves on page II-95 and in particular Analysis on Multidimensional Waves on page II-95.
Compatibility Note
Prior to Igor Pro 5, Correlate/C scaled and rotated the results improperly (the result was often rotated left 
by one and the X scaling was entirely negative).
Now the destination wave’s X scaling is unaltered and it does not rotate the result. You can force the old 
behavior for compatibility with old procedures that depend on the old behavior by setting 
root:V_oldCorrelationScaling=1.
A better way to get identical Correlate/C results with all versions of Igor Pro is to use this code, which 
rotates the result so that x=0 is always the first point in destWave, no matter which Igor Pro version runs this 
code (currently, it doesn’t change anything and runs extremely quickly because it does no rotation):
Correlate/C srcWave, destWave
Variable pointAtXEqualZero= x2pnt(destWave,0)
// 0 for Igor Pro 5
Rotate -pointAtXEqualZero,destWave
SetScale/P x, 0, DimDelta(destWave,0), "", destWave
Applications
A common application of correlation is to measure the similarity of two input signals as they are shifted by 
one another.
Often it is desirable to normalize the correlation result to 1.0 at the maximum value where the two inputs 
are most similar. To normalize destWaveOut, compute the RMS values of the input waves and the number 
of points in each wave:
WaveStats/Q srcWave
Variable srcRMS = V_rms
Variable srcLen = numpnts(srcWave)
WaveStats/Q destWave
Variable destRMS = V_rms
Variable destLen = numpnts(destWave)
Correlate srcWave, destWave
// overwrites destWave
// now normalize to max of 1.0
destWave /= (srcRMS * sqrt(srcLen) * destRMS * sqrt(destLen))
destWaveOut[p] =
srcWave[m]destWaveIn[p + m]
m=0
N1

destWaveOut[p] =
destWaveIn[m]srcWave[p  m]
m=0
N1

