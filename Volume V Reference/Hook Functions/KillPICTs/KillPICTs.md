# KillPICTs

KillFreeAxis
V-470
KillFreeAxis 
KillFreeAxis [/W=winName] axisName
The KillFreeAxis operation removes a free axis specified by axisName from a graph window or subwindow.
Flags
Details
Only an axis created by NewFreeAxis can be killed and only if no traces or images are attached to the axis.
See Also
The NewFreeAxis operation.
KillPath 
KillPath [/A/Z] pathName
The KillPath operation removes a path from the list of symbolic paths. KillPath is a newer name for the 
RemovePath operation.
Flags
Details
You can’t kill the built-in paths “home” and “Igor”.
A symbolic path is "in use" if the current experiment contains shared waves or notebooks loaded from the 
associated disk folder.
Prior to Igor Pro 9.00, the KillPath operation prevented killing a symbolic path used to a load shared wave 
if the shared wave file was in the current data folder. It now prevents killing a symbolic path used to load 
a shared wave in any data folder. Use the /Z flag to suppress error reporting if this change creates problems 
for you.
See Also
Symbolic Paths on page II-22, NewPath
KillPICTs 
KillPICTs [/A/Z] [PICTName [, PICTName]…]
The KillPICTs operation removes one or more named pictures from the current Igor experiment.
Flags
Details
You can not kill a picture that is used in a graph or page layout.
/W=winName
Kills the free axis in the named graph window or subwindow. If /W is omitted, it acts 
on the top graph window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/A
Kills all symbolic paths in the experiment except for the built-in paths. Omit pathName 
if you use /A.
/Z
Does not generate an error if a path to be killed is a built-in path or does not exist or 
is in use. To kill all paths in the experiment, use KillPath/A/Z.
/A
Kills all pictures in the experiment.
/Z
Does not generate an error if a picture to be killed is in use or does not exist. To kill all 
pictures in the experiment, use KillPICTs/A/Z.
Warning:
You can kill a picture that is referenced from a graph or layout recreation macro. If you do, 
the graph or layout can not be completely recreated. Use the Find dialog (Edit menu) to 
locate references in the procedure window to a named picture you want to kill.
