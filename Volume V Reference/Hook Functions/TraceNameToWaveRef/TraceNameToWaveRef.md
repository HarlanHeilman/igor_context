# TraceNameToWaveRef

TraceNameToWaveRef
V-1045
Commands that take a trace name as a parameter or in a keyword can use a string containing a trace name 
with the $ operator to specify traceName. For instance, to change the display mode of a wave, you might use
ModifyGraph mode(myWave#1)=3
but
String myTraceName="myWave#1"
ModifyGraph mode($myTraceName)=3
will also work.
Examples
Make/O jack,'jack # 2';Display jack,jack,'jack # 2','jack # 2'
Print TraceNameList("",";",1)
Prints: jack;jack#1;'jack # 2';'jack # 2'#1;
// Generate a list of hidden traces
Make/O jack,jill,joy;Display jack,jill,joy
ModifyGraph hideTrace(joy)=1// hide joy
// (hidden + visible) - visible = hidden
String visibleTraces=TraceNameList("",";",1+4)// only visible normal traces
String allNormalTraces=TraceNameList("",";",1)// hidden + visible normal traces
String hiddenTraces= RemoveFromList(visibleTraces,allNormalTraces)
Print hiddenTraces
// Prints: joy;
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87, User-defined Trace Names 
on page IV-89.
For other commands related to waves and traces: WaveRefIndexed, XWaveRefFromTrace, 
TraceNameToWaveRef, CsrWaveRef, and CsrXWaveRef.
For a description of traces: ModifyGraph. For a discussion of contour traces: Contour Traces on page 
II-370.
For commands referencing other waves in a graph: ImageNameList, ImageNameToWaveRef, 
ContourNameList, and ContourNameToWaveRef.
ModifyGraph (traces) and Instance Notation on page IV-20 for discussions of trace names and instance 
notation.
TraceNameToWaveRef 
TraceNameToWaveRef(graphNameStr, traceNameStr)
The TraceNameToWaveRef function returns a wave reference to the Y wave corresponding to the given 
trace in the graph window or subwindow named by graphNameStr.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
The trace is identified by the string in traceNameStr, which could be a string determined using 
TraceNameList. Note that the same trace name can refer to different waves in different graphs.
Use Instance Notation (see page IV-20) to choose from traces in a graph that represent waves of the same 
name. For example, if traceNameStr is “myWave#2”, it refers to the third instance of wave “myWave” in the 
graph (“myWave#0” or just “myWave” is the first instance).
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
For other commands related to waves and traces: WaveRefIndexed, XWaveRefFromTrace, 
TraceNameList, CsrWaveRef, and CsrXWaveRef.
For a description of traces: ModifyGraph. For a discussion of contour traces, see Contour Traces on page 
II-370.
For a discussion of wave references, see Wave Reference Functions on page IV-197.
