# z

XWaveRefFromTrace
V-1119
XWaveRefFromTrace 
XWaveRefFromTrace(graphNameStr, traceNameStr)
The XWaveRefFromTrace function returns a wave reference to the wave supplying the X coordinates 
against which the named trace is displayed in the named graph window or subwindow.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
XWaveRefFromTrace returns a null reference (see WaveExists) if the wave is not plotted versus an X wave.
graphNameStr and traceNameStr are strings, not names.
Examples
Display ywave vs xwave
// XY graph
Print XWaveRefFromTrace("","ywave")[50] // prints value of xwave at point 50
See Also
For other commands related to waves and traces: WaveRefIndexed, TraceNameToWaveRef, 
TraceNameList, CsrWaveRef, and CsrXWaveRef.
For a description of traces: ModifyGraph.
For a discussion of contour traces see Contour Traces on page II-370.
For commands referencing other waves in a graph: ImageNameList, ImageNameToWaveRef, 
ContourNameList, and ContourNameToWaveRef.
For a discussion of wave references, see Wave Reference Functions on page IV-197.
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
y 
y
The y function returns the Y value for the current column of the destination wave when used in a 
multidimensional wave assignment statement. Y is the scaled column index whereas q is the column index itself.
Details
Unlike x, outside of a wave assignment statement, y does not act like a normal variable.
See Also
x, z, and t functions for other dimensions.
p, q, r, and s functions for the scaled indices.
z 
z
The z function returns the Z value for the current layer of the destination wave when used in a 
multidimensional wave assignment statement. z is the scaled layer index whereas r is the layer index itself.
Details
Unlike x, outside of a wave assignment statement, z does not act like a normal variable.
See Also
x, y, and t functions for other dimensions.
p, q, r, and s functions for the scaled indices.
