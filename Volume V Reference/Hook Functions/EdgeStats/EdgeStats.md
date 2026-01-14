# EdgeStats

e
V-190
Details
If destWaveName exists, DWT overwrites it; if it does not exist, DWT creates it.
When used in a function, the DWT operation automatically creates a wave reference for the destination 
wave. See Automatic Creation of WAVE References on page IV-72 for details.
If destWaveName is not specified, the DWT operation stores the results in W_DWT for 1D waves and 
M_DWT for higher dimensions.
When working with 1D waves, the transform results are packed such that the higher half of each array 
contains the detail components and the lower half contains the smooth components and each successive 
scale is packed in the lower elements. For example, if the source wave contains 128 points then the lowest 
scale results are stored in elements 64-127, the next scale (power of 2) are stored from 32-63, the following 
scale from 16-31 etc.
Example
Make/O/N=1024 testData=sin(x/100)+gnoise(0.05)
DWT /S/N=20/V=25 testData, smoothedData
See Also
For continuous wavelet transforms use the CWT operation. See the FFT operation.
For further discussion and examples see Discrete Wavelet Transform on page III-283.
e 
e
The e function returns the base of the natural logarithm system (2.7182818…).
EdgeStats 
EdgeStats [flags] waveName
The EdgeStats operation produces simple statistics on a region of a wave that is expected to contain a single 
edge. If more than one edge exists, EdgeStats works on the first one found.
Flags
/A=avgPts
Determines startLevel and endLevel automatically by averaging avgPts points at 
centered at startX and endX. Default is /A=1.
/B=box
Sets box size for sliding average. This should be an odd number. If /B=box is omitted 
or box equals 1, no averaging is done.
/F=frac
Specifies levels 1, 2 and 3 as a fraction of (endLevel-startLevel):
level1 = frac* (endLevel-startLevel) + startLevel
level2 = 0.5 * (endLevel-startLevel) + startLevel
level3 = (1-frac) * (endLevel-startLevel) + startLevel
The default value for frac is 0.1 which makes level1 the 10% level, level2 the 50% level 
and level3 the 90% level.
frac must be between 0 and 0.5.
/L=(startLevel, endLevel)
Sets startLevel and endLevel explicitly. If omitted, they are determined automatically. 
See /A.
/P
Output edge locations (see Details) are returned as point numbers. If /P is omitted, 
edge locations are returned as X values.
/Q
Prevents results from being printed in history and prevents error if edge is not found.
/R=(startX,endX)
Specifies an X range of the wave to search. You may exchange startX and endX to 
reverse the search direction.

EdgeStats
V-191
Details
The /B=box, /T=dx, /P, and /Q flags behave the same as for the FindLevel operation.
EdgeStats considers a region of the input wave between two X locations, called startX and endX. startX and 
endX are set by the /R=(startX,endX) flag. If this flag is missing, startX and endX default to the start and end 
of the entire wave. startX can be greater than endX so that the search for an edge can proceed from the 
“right” to the “left”.
The diagram above shows the default search direction, from the “left” (lower point numbers) of the wave 
toward the “right” (higher point numbers).
The startLevel and endLevel values define the base levels of the edge. You can explicitly set these levels with 
the /L=(startLevel, endLevel) flag or you can let EdgeStats find the base levels for you by using the /A=avgPts 
flag which averages points around startX and endX.
Given startLevel and endLevel and a frac value (see the /F=frac flag) EdgeStats defines level1, level2 and level3 
as shown in the diagram above. With the default frac value of 0.1, level1 is the 10% point, level2 is the 50% 
point and level3 is the 90% point.
With these levels defined, EdgeStats searches the wave from startX to endX looking for level2. Having found 
it, it then searches for level1 and level3. It returns results via variables described below.
EdgeStats sets the following variables:
/R=[startP,endP]
Specifies a point range of the wave to search. You may exchange startP and endP to 
reverse the search direction. If /R is omitted, the entire wave is searched.
/T=dx
Forces search in two directions for a possibly more accurate result. dx controls where 
the second search starts.
V_flag
0: All three level crossings were found.
1: One or two level crossings were found.
2: No level crossings were found.
V_EdgeLoc1
X location of level1.
V_EdgeLoc2
X location of level2.
V_EdgeLoc3
X location of level3.
V_EdgeLvl0
startLevel value.
V_EdgeLvl1
level1 value.
V_EdgeLvl2
level2 value.
V_EdgeLvl3
level3 value.
V_EdgeLvl4
endLevel value.
V_EdgeAmp4_0
Edge amplitude (endLevel - startLevel).
V_EdgeDLoc3_1
Edge width (x distance between point 1 and point 3).
V_EdgeSlope3_1
Edge slope (straight line slope from point 1 and point 3).
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
