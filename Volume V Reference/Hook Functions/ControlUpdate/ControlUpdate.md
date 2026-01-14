# ControlUpdate

ControlNameList
V-94
Examples
ControlInfo myChart; Print S_value
Prints the following to the history area:
FNAME:myFIFO;NCHANS:1;PPSTRIP:1100;RHSAMP:271;LHSAMP:-126229; 
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The ControlInfo operation for information about the control.
The GetUserData function for retrieving named user data.
ControlNameList 
ControlNameList(winNameStr [, listSepStr [, matchStr]])
The ControlNameList function returns a string containing a list of control names in the graph or panel 
window or subwindow identified by winNameStr.
Parameters
winNameStr can be "" to refer to the top graph or panel window.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
The optional parameter listSepStr should contain a single ASCII character such as "," or ";" to separate the 
names; the default value is ";".
The optional parameter matchStr is some combination of normal characters and the asterisk wildcard character 
that matches anything. To use matchStr, listSepStr must also be used. See StringMatch for wildcard details.
Only control names that satisfy the match expression are returned. For example, "*_tab0" matches all control 
names that end with "_tab0". The default is "*", which matches all control names.
Examples
NewPanel
Button myButton
Checkbox myCheck
Print ControlNameList("")
// prints "myButton;myCheck;"
Print ControlNameList("", ";", "*Check")
// prints "myCheck;"
See Also
The ListMatch, StringFromList and StringMatch functions, and the ControlInfo and ModifyControlList 
operations. Chapter III-14, Controls and Control Panels, for details about control panels and controls.
ControlUpdate 
ControlUpdate [/A/W=winName][controlName]
The ControlUpdate operation updates the named control or all controls in a window, which can be the top 
graph or control panel or the named graph or control panel if you use /W.
Flags
Details
ControlUpdate is useful for forcing a pop-up menu to rebuild, to update a ValDisplay control, or to forcibly 
accept a SetVariable’s currently-being-edited value.
/A
Updates all controls in the window. You must omit controlName.
/W=winName
Specifies the window or subwindow containing the control. If you omit winName it 
will use the top graph or control panel window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
