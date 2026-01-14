# FindLevels

FindLevels
V-244
FindLevel and Multidimensional Waves
The FindLevel operation is not multidimensional aware. See Analysis on Multidimensional Waves on 
page II-95 for details.
See Also
The EdgeStats, FindLevels, FindValue, and PulseStats operations and the BinarySearch and 
BinarySearchInterp functions.
FindLevels 
FindLevels [flags] waveName, level
The FindLevels operation searches the named wave to find one or more X values at which the specified Y 
level is crossed.
To find where the wave is equal to a given value, use FindValue instead.
Flags
Details
The algorithm for finding a level crossing is the same one used by the FindLevel operation.
If FindLevels finds maxLevels crossings or can not find another level crossing, it stops searching.
/B=box
Sets box size for sliding average. See the FindLevel operation.
/D=destWaveName
Specifies wave into which FindLevels is to store the level crossing values. If /D and /DEST 
are omitted, FindLevels creates a wave named W_FindLevels to store the level crossing 
values in.
/DEST=destWaveName
Same as /D. Both /D and /DEST create a real wave reference for the destination wave 
in a user function. See Automatic Creation of WAVE References on page IV-72 for 
details.
/EDGE=e
/M=minWidthX
Sets the minimum X distance between level crossings. This determines where 
FindLevels searches for the next crossing after it has found a level crossing. The search 
starts minWidthX X units beyond the crossing. The default value for minWidthX is 0.
/N=maxLevels
Sets a maximum number of crossings that FindLevels is to find. The default value for 
maxLevels is the number of points in the specified range of waveName.
/P
Compute crossings in terms of points. See the FindLevel operation.
/Q
Doesn’t print to history and doesn’t abort if no levels are found.
/R=(startX,endX)
Specifies X range. See the FindLevel operation.
/R=[startP,endP]
Specifies point range. See the FindLevel operation.
/T=dx
Search for two level crossings. dx must be less than minWidthX, so you must also 
specify /M if you use /T. (FindLevels limits dx so that second search start isn’t beyond 
where the first search for next edge will be.) See FindLevel for more about /T.
Specifies searches for either increasing or decreasing level crossing.
e=1:
Searches only for crossings where the Y values are increasing as level 
is crossed from wave start towards wave end.
e=2:
Searches only for crossings where the Y values are decreasing as level 
is crossed from wave start towards wave end.
e=0:
Same as no /EDGE flag (searches for both increasing and decreasing 
level crossings).
