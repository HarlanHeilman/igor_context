# TraceNameList

TraceNameList
V-1044
String yRange= StringByKey("YRANGE", TraceInfo("","",0))
Print yRange
// prints "[30,40:2]"
yRange= ReplaceString(":", yRange, ";")
Print yRange
// prints "[30,40;2]"
The next example shows the trace information for the second instance of the wave “data” (which has an 
instance number of 1) displayed in the top graph:
Make/O data=x;Display/L/T data,data
// two instances of data: 0 and 1
Print TraceInfo("","data",1)[0,64]
Print TraceInfo("","data",1)[65,128]
Prints the following in the history area:
XWAVE:;YAXIS:left;XAXIS:top;AXISFLAGS:/T;AXISZ:NaN;XWAVEDF:;YRANG
E:[*];XRANGE:;TYPE:0;ERRORBARS:;RECREATION:zColor(x)=0;zColorMax
Following is a function that returns the marker code from the given instance of a named wave in the top 
graph. This example uses the convenient GetNumFromModifyStr() function provided by the #include 
<Readback ModifyStr> procedures, which are useful for parsing strings returned by TraceInfo.
#include <Readback ModifyStr>
Function MarkerOfWave(wv,instance)
Wave wv
Variable instance
Variable marker
String info = TraceInfo("",NameOfWave(wv),instance)
marker = GetNumFromModifyStr(info,"marker","",0)
return marker
End
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
The Execute operation.
TraceNameList 
TraceNameList(graphNameStr, separatorStr, optionsFlag)
The TraceNameList function returns a string containing a list of trace names in the graph window or 
subwindow identified by graphNameStr.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
The parameter separatorStr should contain a single ASCII character such as “,” or “;” to separate the names.
Details
The bits of optionsFlag have the following meanings:
See Setting Bit Parameters on page IV-12 for details about bit settings.
A trace name is defined as the name of the Y wave that defines the trace with an optional #ddd suffix that 
distinguishes between two or more traces that have the same wave name. It may also be a user-defined trace 
name. Since the trace name has to be parsed, it is quoted if necessary.
Bit Number
Bit Value
Meaning
0
1
Include normal graph traces
1
2
Include contour traces
2
4
Omit hidden traces (the default is to list even hidden traces)
3
8
Include box plot traces
4
16
Include violin plot traces
