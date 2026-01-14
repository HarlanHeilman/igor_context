# MakeIndex

MakeIndex
V-527
Wave Data Types
You can use /Y=(numType) to set the data type instead of the /B, /C, /D, /I, /L, /R, /T, /U, and /W data type 
flags. See WaveType function for numType values. The /Y flag overrides other type flags. You still need to 
use the explicit data type flags to control the automatic wave reference created by the compiler if you use 
the wave in an assignment statement in the same function; see WAVE Reference Types on page IV-73 for 
details.
Details
The maximum allowed number of elements (rows*columns*layers*chunks) in a wave depends on whether 
you are using the 64-bit version of Igor (max is 214,700,000,000) or the 32-bit version (max is 2,147,000,000).
Unless overridden by the flags, the created waves have the default length, type, precision, units and scaling. 
The factory defaults are:
The maximum allowed number of elements (rows*columns*layers*chunks) in a wave is 214,700,000,000.
See Also
The SetScale, Duplicate, and Redimension operations.
MakeIndex 
MakeIndex [/A/C/R] sortKeyWaves, indexWave
The MakeIndex operation sets the data values of indexWave such that they give the ordering of 
sortKeyWaves.
For simple sorting problems, MakeIndex is not needed. Just use the Sort operation.
Parameters
sortKeyWaves is either the name of a single wave, to use a single sort key, or the name of multiple waves in 
braces, to use multiple sort keys.
indexWave must specify an existing numeric wave.
All waves must be of the same length and must not be complex.
/WAVE
Wave holds wave references.
See Wave References on page IV-71 for more discussion.
/Y=type
See Wave Data Types below.
Property
Default
Number of points
128
Precision
Single precision floating point
Type
Real
dimensions
1
x, y, z, and t scaling
offset=0, delta=1 (“point scaling”)
x, y, z, and t units
"" (blank)
Data Full Scale
0, 0
Data units
"" (blank)
Note:
The preferred precision set by the Miscellaneous Settings dialog only presets the Make 
Waves dialog checkbox and determines the precision of imported waves. It does not affect 
the Make operation.
