# FindPeak

FindPeak
V-247
See Also
FindPeak, EstimatePeakSizes
FindPeak 
FindPeak [flags] waveName
The FindPeak operation searches for a minimum or maximum by analyzing the smoothed first and second 
derivatives of the named wave. Information about the peak position, amplitude, and width are returned in 
the output variables.
Flags
Some of the flags have the same meaning as for the FindLevel operation.
Details
FindPeak sets the following variables:
FindPeak computes the sliding average of the input wave using the BoxSmooth algorithm with the box 
parameter. The peak center is found where the derivative of this smoothed result crosses zero. The peak 
edges are found where the second derivative of the smoothed result crosses zero. Linear interpolation of 
/B=box
Sets box size for sliding average.
/I
Modify the search criteria to accommodate impulses (peaks of one sample) by 
requiring only one value to exceed minLevel.
The default criteria requires that two successive values exceed minLevel for a peak to 
be found (or two successive values be less than the /M level when searching for 
negative peaks).
Impulses can also be found by omitting minLevel, in which case /I is superfluous.
/M=minLevel
Defines minimum level of a peak. /N changes this to maximum level (see Details).
/N
Searches for a negative peak (minimum) rather then a positive peak (maximum).
/P
Location output variables (see Details) are reported in terms of (floating point) point 
numbers. If /P is omitted, they are reported as X values.
/Q
Doesn’t print to history and doesn’t abort if no peak is found.
/R=(startX,endX)
Specifies X range and direction for search.
/R=[startP,endP]
Specifies point range and direction for search.
V_flag
Set only when using the /Q flag.
0: Peak was found.
Any nonzero value means the peak was not found.
V_LeadingEdgeLoc
Interpolated location of the peak edge closest to startX or startP. If you use the /P 
flag, V_LeadingEdgeLoc is a point number rather than to an X value. If the edge 
was not found, this value is NaN.
V_PeakLoc
Interpolated X value at which the peak was found. If you use the /P flag, FindPeak 
sets V_PeakLoc to a point number rather than to an X value. Set to NaN if peak 
wasn’t found.
V_PeakVal
The approximate Y value of the found peak. If the peak was not found, this value 
is NaN (Not a Number).
V_PeakWidth
Interpolated peak width. If you use the /P flag, V_PeakWidth is expressed in 
point numbers rather than as an X value. V_PeakWidth is never negative. If either 
peak edge was not found, this value is NaN.
V_TrailingEdgeLoc Interpolated location of the peak edge closest to endX or endP. If you use the /P 
flag, V_TrailingEdgeLoc is a point number rather than to an X value. If the edge 
was not found, this value is NaN.
