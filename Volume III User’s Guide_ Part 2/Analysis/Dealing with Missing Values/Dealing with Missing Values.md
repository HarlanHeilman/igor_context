# Dealing with Missing Values

Chapter III-7 — Analysis
III-112
Choosing “_auto_” for Y Destination auto-names the destination wave by appending “_L” to the name of 
the input “Y data” wave. Choosing “_none_” as the “X destination” creates a waveform from the input XY 
pair rather than a new XY pair.
Here is a rewrite of the XYToWave1 function that uses the Interpolate2 operation rather than the interp 
function.
Function XYToWave2(xWave, yWave, wWaveName, numPoints)
Wave xWave
// X wave in the XY pair
Wave yWave
// Y wave in the XY pair
String wWaveName
// Name to use for new waveform wave
Variable numPoints
// Number of points for waveform
Interpolate2/T=1/N=(numPoints)/E=2/Y=$wWaveName xWave, yWave
End
Blanks in the input data are ignored.
For details on Interpolate2, see The Interpolate2 Operation on page III-115.
Dealing with Missing Values
A missing value is represented in Igor by the value NaN which means “Not a Number”. A missing value 
is also called a “blank”, because it appears as a blank cell in a table.
When a NaN is combined arithmetically with any value, the result is NaN. To see this, execute the command:
Print 3+NaN, NaN/5, sin(NaN)
By definition, a NaN is not equal to anything. Consequently, the condition in this statement:
if (myValue == NaN)
is always false.
The workaround is to use the numtype function:
if (NumType(myValue) == 2) 
// Is it a NaN?
