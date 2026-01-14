# ReorderTraces

ReorderTraces
V-798
ReorderImages generates an error if the same trace is in the list twice.
In Igor7 or later, anchorImage can be _front_ or _back_. To move A to the front, you can write:
ReorderImage _front_, {A}
See Also
The ReorderTraces operation.
ReorderTraces 
ReorderTraces [/W=winName /L[=axisName] /R[=axisName]] anchorTrace, {traceA, 
traceB, …}
The ReorderTraces operation changes the ordering of graph traces to that specified in the braces.
Flags
Details
Igor keeps a list of traces in a graph and draws the traces in the listed order. The first trace drawn is consequently 
at the bottom. All other traces are drawn on top of it. The last trace is the top one; no other trace obscures it.
ReorderTraces works by removing the traces in the braces from the list and then reinserting them at the location 
specified by anchorTrace. If anchorTrace is not in the braces, the traces in braces are placed before anchorTrace.
If the list of traces is A, B, C, D, E, F, G and you execute the command
ReorderTraces F, {B,C}
traces B and C are placed just before F: A, D, E, B, C, F, G.
The result of
ReorderTraces E, {D,E,C}
is to reorder C, D and E and put them where E was. Starting from the initial ordering results in A, B, D, E, 
C, F, G.
ReorderTraces generates an error if the same trace is in the list twice.
In Igor7 or later, anchorImage can be _front_ or _back_. To move A to the front, you can write:
ReorderTraces _front_, {A}
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
The ReorderImages operation.
/W=winName
Reorders traces in the named graph window or subwindow. When omitted, action 
will affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/L[=axisName]
/R[=axisName]
Moves traces to a newor existing axis. This feature was added in Igor Pro 8.00.
To reference the built-in left or right axes, you can use /L or /R without specifying the 
axis name. To reference a free axis, you must specify the axis name.
If the specified axis does not already exist, a new axis is created by cloning the axis 
controlling traceA.
If the move results in no traces assigned to an axis, then that axis is deleted.
Reordering is optional. Specify _none_ for anchorTrace for no reordering.
You can move a trace manually by right-clicking a trace and choosing Move to 
Opposite Axis.
