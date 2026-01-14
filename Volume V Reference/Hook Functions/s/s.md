# s

round
V-811
If rotPoints is negative then values are rotated from the end of the wave toward the start and rotPoints values 
from the start of a wave wrap around to the end of the wave.
Details
The X scaling of the named waves is changed so that the X values for the Y values remains the same except 
for the points that wrap around.
The Rotate operation is not multidimensional aware. To rotate rows or columns of 2D waves, see the 
rotateRows, rotateCols, rotateLayers and rotateChunks keywords for MatrixOp and the rotateRows and 
rotateCols keywords for ImageTransform.
For general information about multidimensional analysis, see Analysis on Multidimensional Waves on 
page II-95.
See Also
The shift parameter of the WaveTransform operation.
round 
round(num)
The round function returns the integer value closest to num.
The rounding method is “away from zero”.
The result for INF and NAN is undefined.
See Also
The ceil, floor, and trunc functions.
rtGlobals 
#pragma rtGlobals = 0, 1, 2, or 3
#pragma rtglobals=<n> is a compiler directive that controls compiler and runtime behaviors for the 
procedure file in which it appears.
This statement must be flush against the left edge of the procedure file with no indentation. It is usually 
placed at the top of the file.
#pragma rtglobals=0 turns off runtime creation of globals. This is obsolete.
#pragma rtglobals=1 is a directive that turns on runtime lookup of globals. This is the default behavior 
if #pragma rtGlobals is omitted from a given procedure file.
#pragma rtGlobals=2 turns off compatibility mode. This is mostly obsolete. See Legacy Code Issues on 
page IV-113 for details.
#pragma rtglobals=3 turns on runtime lookup of globals, strict wave reference mode and wave index 
bounds checking.
rtGlobals=3 is recommended.
See The rtGlobals Pragma on page IV-52 for a detailed explanation of rtGlobals.
s 
s
The s function returns the current chunk index of the destination wave when used in a multidimensional 
wave assignment statement. The corresponding scaled chunk index is available as the t function.
Details
Unlike p, outside of a wave assignment statement, s does not act like a normal variable.
See Also
Waveform Arithmetic and Assignments on page II-74.
For other dimensions, the p, r, and q functions.
For scaled dimension indices, the x, y, z and t functions.
