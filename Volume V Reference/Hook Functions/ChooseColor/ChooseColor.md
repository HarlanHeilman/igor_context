# ChooseColor

ChildWindowList
V-69
CheckName Thread Safety
As of Igor Pro 8.00, you can call CheckName from an Igor preemptive thread but only if objectType is 1 
(wave), 3 (global numeric variable), 4, (global string variable), 11 (data folder), or 12 (symbolic path). For 
any other value of objectType, CheckName returns a runtime error.
Examples
Variable waveNameIsOK = CheckName(proposedWaveName, 1) == 0
Variable annotationNameIsOK = CheckName("text0", 14, "Graph0") == 0
// Create a valid and unique wave name
Function/S CreateValidAndUniqueWaveName(proposedName)
String proposedName
String result = proposedName
if (CheckName(result,1) != 0)
// 1 for waves
result = CleanupName(result, 1)
// Make sure it's valid
result = UniqueName(result, 1, 0) 
// Make sure it's unique
endif
return result
End
See Also
Object Names on page III-501, Programming with Liberal Names on page IV-168, 
CreateDataObjectName, CleanupName, UniqueName
ChildWindowList 
ChildWindowList(hostNameStr)
The ChildWindowList function returns a string containing a semicolon-separated list of immediate 
subwindow window names of the specified host window or subwindow.
Parameters
hostNameStr is a string or string expression containing the name of an existing host window or subwindow.
When identifying a subwindow with hostNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
Error if the host does not exist or if it is not an allowed host type.
See Also
WinList and WinType functions.
ChooseColor 
ChooseColor [/A[=a]/C=(r,g,b[,a])]
The ChooseColor operation displays a dialog for choosing a color.
The color initially shown is black unless you specify a different color with /C.
1:
Wave.
9:
Control panel window.
2:
Reserved.
10:
Notebook window.
3:
Global numeric variable.
11:
Data folder.
4:
Global string variable.
12:
Symbolic path.
5:
XOP target window.
13:
Picture.
6:
Graph window.
14:
Annotation in the named or topmost graph or layout.
7:
Table window.
15:
Control in the named topmost graph or panel.
8:
Layout window.
16:
Notebook action character in the named or 
topmost notebook.
