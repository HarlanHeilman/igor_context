# Trace Name Parameters

Chapter IV-3 — User-Defined Functions
IV-88
The name of a trace is, by default, the same as the name of the wave that it represents, but this is not always 
the case. For example, if you display the same wave twice in a given graph, the two trace names will be 
unique. Also, for programming convenience, an Igor programmer can create a trace whose name has no 
relation to the represented wave.
Trace names are used when changing traces in graphs, when accessing waves associated with traces in 
graphs, and when getting information about traces in graphs. See Trace Names on page II-282 for a general 
discussion.
These operations take trace name parameters:
ModifyGraph (traces), ErrorBars, RemoveFromGraph, ReplaceWave, ReorderTraces, GraphWaveEdit
Tag, TextBox, Label, Legend
These operations return trace names:
GetLastUserMenuInfo
These functions take trace name parameters:
GetUserData, TraceInfo, TraceNameToWaveRef, XWaveRefFromTrace
These functions return trace names:
TraceNameList, CsrInfo, CsrWave, TraceFromPixel
Trace Name Parameters
A trace name is not the same as a wave. An example may clarify this subtle point:
Function Test()
Wave w = root:FolderA:wave0
Display w
ModifyGraph rgb(w) = (65535,0,0)
// WRONG
End
This is wrong because ModifyGraph is looking for the name of a trace in a graph and w is not the name of 
a trace in a graph. The name of the trace in this case is wave0. The function should be written like this:
Function Test()
Wave w = root:FolderA:wave0
Display w
ModifyGraph rgb(wave0) = (65535,0,0)
// CORRECT
End
In the next example, the wave is passed to the function as a parameter so the name of the trace is not so obvious:
Function Test(w)
Wave w
Display w
ModifyGraph rgb(w) = (65535,0,0)
// WRONG
End
This is wrong for the same reason as the first example: w is not the name of the trace. The function should 
be written like this:
Function Test(w)
Wave w
Display w
String name = NameOfWave(w)
ModifyGraph rgb($name) = (65535,0,0)
// CORRECT
End
