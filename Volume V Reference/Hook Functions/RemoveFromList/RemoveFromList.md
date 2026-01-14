# RemoveFromList

RemoveFromLayout
V-793
Flags
Details
Up to 100 traceNames may be specified, subject to the 2500 byte command length limit.
If the axes used by the given trace are not in use after removing the trace, they will also be removed.
A string containing a trace name can be used with the $ operator to specify traceName.
Specifying $"#0" for traceName removes the first trace in the graph. $"#1" removes the second trace in the 
graph, and so on. $"" is equivalent to $"#0".
Note that removing all the contour traces from a contour plot is not the same as removing the contour plot 
itself. Use the RemoveContour operation.
Examples
The command:
Display myWave,myWave;Modify mode(myWave#1)=6
appends two instances of myWave to the graph.The first/backmost instance of myWave is instance 0, and 
its trace name is just myWave as a synonym for myWave#0. The second or frontmost instance of myWave 
is myWave#1 and it is displayed with the cityscape mode.
To remove the second instance from the graph requires the command:
RemoveFromGraph myWave#1
or
String MyTraceName="myWave#1"
RemoveFromGraph $MyTraceName
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
RemoveFromLayout 
RemoveFromLayout objectSpec [, objectSpec]…
Deprecated — use RemoveLayoutObjects.
The RemoveFromLayout operation removes the specified objects from the top layout.
Parameters
objectSpec is either an object name (e.g., Graph0) or an objectName with an instance (e.g., Graph0#1). An 
instance is needed only if the same object appears in the layout more than one time. Graph0 is equivalent 
to Graph0#0 and Graph0#1 refers to the second instance of Graph0 in the layout.
See Also
The RemoveLayoutObjects operation.
RemoveFromList 
RemoveFromList(itemOrListStr, listStr [, listSepStr [, matchCase]])
The RemoveFromList function returns listStr after removing the item or items specified by itemOrListStr. 
listStr should contain items separated by listSepStr which typically is ";".
If itemOrListStr contains multiple items, they should be separated by the listSepStr character, too.
/ALL
Removes all non-contour traces from the graph. Any trace name parameters listed are 
ignored. /ALL was added in Igor Pro 9.00.
/W=winName
Removes traces from the named graph window or subwindow. When omitted, action 
will affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
Suppresses errors if specified trace or image is not on the graph.
