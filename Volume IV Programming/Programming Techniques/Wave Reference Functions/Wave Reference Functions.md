# Wave Reference Functions

Chapter IV-7 — Programming Techniques
IV-197
Wave Reference Functions
It is common to write a user-defined function that operates on all of the waves in a data folder, on the waves 
displayed in a graph or table, or on a wave identified by a cursor in a graph. For these purposes, you need 
to use wave reference functions.
Wave reference functions are built-in Igor functions that return a reference that can be used in a user-
defined function. Here is an example that works on the top graph. Cursors are assumed to be placed on a 
region of a trace in the graph.
Function WaveAverageBetweenCursors()
WAVE/Z w = CsrWaveRef(A)
if (!WaveExists(w))
// Cursor is not on any wave.
return NaN
endif
Variable xA = xcsr(A)
Variable xB = xcsr(B)
Variable avg = mean(w, xA, xB)
return avg
End
CsrWaveRef returns a wave reference that identifies the wave a cursor is on.
An older function, CsrWave, returns the name of the wave the cursor is on. It would be tempting to use this 
to determine the wave the cursor is on, but it would be incorrect. The name of a wave by itself does not 
uniquely identify a wave because it does not specify the data folder in which the wave resides. For this 
reason, we usually need to use the wave reference function CsrWaveRef instead of CsrWave.
This example uses a wave reference function to operate on the waves displayed in a graph:
Function SmoothWavesInGraph()
String list = TraceNameList("", ";", 1)
String traceName
Variable index = 0
do
traceName = StringFromList(index, list)
if (strlen(traceName) == 0)
break
// No more traces.
endif
WAVE w = TraceNameToWaveRef("", traceName)
Smooth 5, w
index += 1
while(1)
End
Use WaveRefIndexedDFR to iterate over the waves in a given data folder.
Here are the wave reference functions. See Chapter V-1, Igor Reference, for details on each of them.
Function
Comment
CsrWaveRef
Returns a reference to the Y wave to which a cursor is attached.
CsrXWaveRef
Returns a reference to the X wave when a cursor is attached to an XY pair.
WaveRefIndexedDFR
Returns a reference to a wave in the specified data folder.
WaveRefIndexed
Returns a reference to a wave in a graph or table or to a wave in the current 
data folder.
XWaveRefFromTrace
Returns a reference to an X wave in a graph. Used with the output of 
TraceNameList.
