# AxisList

AxisLabel
V-44
// Get a numeric value from the RECREATION keyword nested keyword values
String info = AxisInfo("","left")
String key = ";RECREATION:"
Variable index = strsearch(info,key,0)
String recreation = info[index+strlen(key),inf]
Print recreation
// Prints catGap(x)=0.1;barGap(x)=0.1;...
Print NumberByKey("barGap(x)",recreation,"=")
// Prints 0.1
See Also
GetAxis, SetAxis, AxisLabel, StringByKey, NumberByKey
The "Readback ModifyStr" procedure file is useful for parsing strings returned by AxisInfo.
AxisLabel
AxisLabel(graphNameStr, axisNameStr [, escapeBackslashes])
The AxisLabel function returns a string containing the axis label for the named axis in the named graph 
window or subwindow. The string returned is suitable for use with the Label operation. The AxisLabel 
function is primarily intended for copying the label from one axis to another.
The AxisLabel function was added in Igor Pro 9.00.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow via graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
axisNameStr is the name of the axis.
escapeBackslashes is an optional parameter which defaults to 0 (false). 
Details
Specify escapeBackslashes=1 when using the result to create a command passed to the Execute operation. 
Otherwise omit escapeBackslashes or specify escapeBackslashes=0.
The "Axis Utilities.ipf" WaveMetrics procedure contains an AxisLabelText function that is very similar to 
AxisLabel. If you use AxisLabelText, you can replace it with AxisLabel for use with Igor Pro 9 or later.
Examples
// Label Graph0 left axis with something that has a backslash in it
Make/O data=x
Display/N=Graph0 data
Label/W=Graph0 left, "Area \\E (UV*Sec)"
// Reuse the left axis label from Graph0 for Graph1
Display/N=Graph1 data
String lblStr = AxisLabel("Graph0","left")
Label/W=Graph1 left, lblStr
See Also
AxisInfo, Label, Backslashes in Annotation Escape Sequences on page III-58
AxisList 
AxisList(graphNameStr)
The AxisList function returns a semicolon-separated list of axis names from the named graph window or 
subwindow.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Examples
Make/O data=x;Display/L/T data
Print AxisList("")
// prints left;top;
