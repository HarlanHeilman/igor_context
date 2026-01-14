# Crashes

Chapter IV-10 — Advanced Topics
IV-340
The Option key (Macintosh) or Alt key (Windows) is not represented because it prevents the hook from being 
called.
The YPOINT keyword and value are present only when the cursor is attached to a two-dimensional item 
such as an image, contour, or waterfall plot or when the cursor is free.
If cursor is free, POINT and YPOINT values are fractional relative positions (see description in Cursor oper-
ation on page V-121). If TNAME is empty, fields POINT, ISFREE and YPOINT are not present.
This example hook function simply prints the information in the history area:
Function CursorMovedHook(info)
String info
Print info
End
Whenever any cursor on any graph is moved, this CursorMovedHook function will print something like 
the following in the history area:
GRAPH:Graph0;CURSOR:A;TNAME:jack;MODIFIERS:0;ISFREE:0;POINT:6; 
Cursor Globals
On older technique involving globals named S_CursorAInfo and S_CursorBInfo is no longer recom-
mended. For details, see the “Cursor Globals” subtopic in the Igor6 help files.
Profiling Igor Procedures
You can find bottlenecks in your procedures using profiling.
Profiling is supported by the FunctionProfiling.ipf file. To use it, add this to your procedures:
#include <FunctionProfiling
Then choose WindowsProceduresFunctionProfiling.ipf and read the instructions in the file.
Crashes
A crash results from a software bug and prevents a program from continuing to run. Crashes are highly 
annoying at best and, at worst, can cause you to lose valuable work.
WaveMetrics uses careful programming practices and extensive testing to make Igor as reliable and bug-
free as we can. However in Igor as in any complex piece of software it is impossible to exterminate all bugs. 
Also, crashes can sometimes occur in Igor because of bugs in other software, such as printer drivers, video 
drivers or system extensions.
We are committed to keeping Igor a solid and reliable program. If you experience a crash, we would like to 
know about it.
When reporting a crash to WaveMetrics, please start by choosing Help-Contact Support. This provides us 
with important information such as your Igor version and your OS version.
Please include the following in your report:
•
A description of what actions preceded the crash and whether it is reproducible.
•
A recipe for reproducing the crash, if possible.
•
A crash log (described below), if possible.
In most cases, to fix a crash, we need to be able to reproduce it.
