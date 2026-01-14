# CsrWave

CsrInfo
V-116
CsrInfo 
CsrInfo(cursorName [, graphNameStr])
The CsrInfo function returns a keyword-value pair list of information about the specified cursor 
(cursorName is A through J) in the top graph or graph specified by graphNameStr. It returns "" if the cursor 
is not in the graph.
Details
The returned string contains information about the cursor in the following format:
TNAME:traceName; ISFREE:freeNum;POINT:xPointNumber;[YPOINT:yPointNumber;] 
RECREATION:command;
The traceName value is the name of the graph trace or image to which it is attached or which supplies the x 
(and y) values even if the cursor isn’t attached to it.
If TNAME is empty, fields POINT, ISFREE, and YPOINT are not present.
The freeNum value is 1 if the cursor is not attached to anything, 0 if attached to a trace or image.
The POINT value is the same value pcsr returns.
The YPOINT keyword and value are present only when the cursor is attached to a two-dimensional item such 
as an image, contour, or waterfall plot or when the cursor is free. Its value is the same as returned by qcsr.
If cursor is free, POINT and YPOINT values are fractional relative positions (see description in the Cursor 
command).
The RECREATION keyword contains the Cursor commands (including /W) necessary to regenerate the 
current settings.
Examples
Variable aExists= strlen(CsrInfo(A)) > 0
// A is a name, not a string
Variable bIsFree= NumberByKey("ISFREE",CsrInfo(B,"Graph0"))
See Also
Programming With Cursors on page II-321.
Cursors — Moving Cursor Calls Function on page IV-339.
Trace Names on page II-282, Programming With Trace Names on page IV-87.
CsrWave 
CsrWave(cursorName [, graphNameStr [, wantTraceName]])
The CsrWave function returns a string containing the name of the wave the specified cursor (A through J) 
is on in the top (or named) graph. If the optional wantTraceName is nonzero, the trace name is returned. A 
trace name is the wave name with optional instance notation (see ModifyGraph (traces)).
Details
The name of a wave by itself is not sufficient to identify the wave because it does not specify what data 
folder contains the wave. Thus, if you are calling CsrWave for the purpose of passing the wave name to 
other procedures, you should use the CsrWaveRef function instead. Use CsrWave if you want the name of 
the wave to use in an annotation or a notebook.
Examples
String waveCursorAIsOn = CsrWave(A)
// not CsrWave("A")
String waveCursorBIsOn = CsrWave(B,"Graph0")
// in specified graph
String traceCursorBIsOn = CsrWave(B,"",1)
// trace name in top graph
See Also
Programming With Cursors on page II-321.
Trace Names on page II-282, Programming With Trace Names on page IV-87.
