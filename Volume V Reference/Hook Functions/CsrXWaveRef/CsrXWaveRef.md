# CsrXWaveRef

CsrWaveRef
V-117
CsrWaveRef 
CsrWaveRef(cursorName [, graphNameStr])
The CsrWaveRef function returns a wave reference to the wave the specified cursor (A through J) is on in 
the top (or named) graph.
Details
The wave reference can be used anywhere Igor is expecting the name of a wave (not a string containing the 
name of a wave).
CsrWaveRef should be used in place of the CsrWave() string function to work properly with data folders.
Examples
Print CsrWaveRef(A)[50]
// not CsrWaveRef("A")
Print CsrWaveRef(B,"Graph0")[50]
// in specified graph
See Also
Programming With Cursors on page II-321.
Wave Reference Functions on page IV-197.
CsrXWave 
CsrXWave(cursorName [, graphNameStr])
The CsrXWave function returns a string containing the name of the wave supplying the X coordinates for 
an XY plot of the Y wave the specified cursor (A through J) is attached to in the top (or named) graph.
Details
CsrXWave returns an empty string ("") if the wave the cursor is on is not plotted versus another wave 
providing the X coordinates (that is, if the wave was not plotted with a command such as Display 
theWave vs anotherWave).
The name of a wave by itself is not sufficient to identify the wave because it does not specify what data 
folder contains the wave. Thus, if you are calling CsrXWave for the purpose of passing the wave name to 
other Igor procedures, you should use the CsrXWaveRef function instead. Use CsrXWave if you want the 
name of the wave to use in an annotation or a notebook.
Examples
Display ywave vs xwave
ywave supplies the Y coordinates and xwave supplies the X coordinates for this XY plot.
Cursor A ywave,0
Print CsrXWave(A)
// prints xwave
See Also
Programming With Cursors on page II-321.
CsrXWaveRef 
CsrXWaveRef(cursorName [, graphNameStr])
The CsrXWaveRef function returns a wave reference to the wave supplying the X coordinates for an XY plot 
of the Y wave the specified cursor (A through J) is attached to in the top (or named) graph.
Details
The wave reference can be used anywhere Igor is expecting the name of a wave (not a string containing the 
name of a wave).
CsrXWaveRef returns a null reference (see WaveExists) if the wave the cursor is on is not plotted versus 
another wave providing the X coordinates (that is, if the wave was not plotted with a command such as 
Display theWave vs anotherWave). CsrXWaveRef should be used in place of the CsrXWave string 
function to work properly with data folders.
Examples
Display ywave vs xwave
ywave supplies the Y coordinates and xwave supplies the X coordinates for this XY plot.
