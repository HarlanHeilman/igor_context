# WaveMeanStdv

WaveMax
V-1077
To list the actual waves used in a graph, or to distinguish two or more instances of the same named wave 
in a graph, use TraceNameList. This function can be used in conjunction with TraceNameToWaveRef, and 
XWaveRefFromTrace.
Use ContourNameList to list contour plots in a given window and ContourNameToWaveRef to access the 
waves used to generate the contour plot.
To list the contour traces (that is, the contour lines themselves) use TraceNameList with the appropriate option.
Use ImageNameList to list images in a given window and ImageNameToWaveRef to access the waves 
used to generate the images.
Processing Lists of Waves
Contrary to what you might expect, you can not use the output of WaveList directly with operations that have a 
list of waves as their parameters. See Processing Lists of Waves on page IV-198 for ways of dealing with this.
Examples
// Returns a list of all waves in the current data folder.
WaveList("*",";","")
// Returns a list of all waves in the current data folder and displayed in the top table or graph.
WaveList("*", ";","WIN:")
// Returns a list of waves in the current data folder whose names
// end in “_bkg” and which are displayed in Graph0 as 1D traces.
WaveList("*_bkg", ";", "WIN:Graph0")
// Returns a list of waves in the current data folder whose names do not
// end in “X” and which are displayed in Graph0 as 1D traces or as one
// of the X, Y, and Z waves of an AppendXYZContour plot.
WaveList("!*X", ";", "WIN:Graph0,DIMS:1")
// Returns a list of waves in the root:Packages:MyPackage data folder
WaveList("*", ";", "", root:Packages:MyPackage)
See Also
Chapter II-6, Multidimensional Waves.
Execute, ContourNameList, ImageNameList, TraceNameList, and WaveRefIndexed.
WaveMax 
WaveMax(waveName [, x1, x2])
The WaveMax function returns the maximum value in the wave for points between x=x1 to x=x2, inclusive.
Details
If x1 and x2 are not specified, they default to -inf and +inf, respectively.
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x2. To use point indexing, 
replace x1 with pnt2x(waveName,pointNumber1), and a similar expression for x2.
If the points nearest to x1 or x2 are not within the point range of 0 to numpnts(waveName)-1, WaveMax limits 
them to the nearest of point 0 or point numpnts(waveName)-1.
NaN values in the wave are ignored.
See Also
WaveMin, WaveMinAndMax, WaveStats
WaveMeanStdv 
WaveMeanStdv srcWave binSizeWave
The WaveMeanStdv operation calculates the standard deviation of the means for the specified bin 
distribution saving the result in the wave W_MeanStdv.
For each entry in binSizeWave, srcWave is divided into the specified number of bins. Values in each bin are 
averaged and then the mean and standard deviation of the averages (among all bins) are calculated. The 
value of the standard deviation of the bin averages divided by the mean is then stored in W_MeanStdv 
corresponding to the bin size entry in binSizeWave.
All entries in binSizeWave must be positive integers.
