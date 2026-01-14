# Text2Bezier

TagWaveRef
V-1023
See Also
The Tag operation, the TagWaveRef function.
For a discussion of wave references, see Wave Reference Functions on page IV-197.
TagWaveRef 
TagWaveRef()
TagWaveRef is a very specialized function that is only valid when called from within the text of a tag as 
part of a \{} dynamic text escape sequence. It returns a wave reference to the wave that the tag is on and 
helps you to display information about the tagged wave. It is often used in conjunction with the TagVal 
function. You can pass the result of TagWaveRef to any function that takes a Wave parameter.
Examples
Show the name of the data folder containing the tagged wave:
Tag wave0, 0,"\\ON is in \\{\"%s\",GetWavesDataFolder(TagWaveRef(),0)}"
See Also
The Tag operation, the TagVal function
For a discussion of wave references, see Wave Reference Functions on page IV-197.
tan 
tan(angle)
The tan function returns the tangent of angle which is in radians.
In complex expressions, angle is complex, and tan(angle) returns a complex value:
See Also
atan, atan2, sin, cos, sec, csc, cot
tanh 
tanh(num)
The tanh function returns the hyperbolic tangent of num:
In complex expressions, num is complex, and tanh(num) returns a complex value.
See Also
sinh, cosh, coth
Text2Bezier
Text2Bezier[ flags ] fontNameStr, fstyle, textStr, xWaveName, yWaveName
The Text2Bezier operation creates the data for a Bezier curve corresponding to the outline of some text 
using the supplied font information. The output waves are formatted to be drawn using Igor's DrawBezier 
operation.
tan(x + iy) = sin(x+ iy)
cos(x + iy) = sin(2x) + isinh(2y)
cos(2x) + cosh(2y).
tanh(x) = ex  ex
ex + ex .
