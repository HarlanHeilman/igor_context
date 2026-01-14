# CheckName

CheckDisplayed
V-68
CheckDisplayed 
CheckDisplayed [/A/W] waveName [, waveName]…
The CheckDisplayed operation determines if named waves are displayed or otherwise used in a host 
window or subwindow.
Flags
Details
If neither /A nor /W are used, CheckDisplayed checks only the top graph, table, page layout, panel, or 
Gizmo window.
CheckDisplayed sets a bit in the variable V_flag for each wave that is displayed.
Waves that are not directly displayed in a window can still be used by it. For example, CheckDisplayed 
returns 1 for the following cases: waves associated with hidden traces, color index waves, waves used to 
specify error bars, and waves used to draw polygons in page layouts and control panels as well as in 
graphs.
Example
// Checks Graph0 to see if aWave, bWave, and cWave are displayed in it.
// Sets bit 0 of V_flag if aWave is displayed.
// Sets bit 1 of V_flag if bWave is displayed.
// Sets bit 2 of V_flag if cWave is displayed.
CheckDisplayed/W=Graph0 aWave,bWave,cWave
See Also
Setting Bit Parameters on page IV-12 for information about bit settings.
CheckName 
CheckName(nameStr, objectType [, windowNameStr])
The CheckName function returns a number which indicates if the specified name is legal and unique 
among objects in the namespace of the specified object type.
In Igor Pro 9.00 or later, you can use the CreateDataObjectName function as a replacement for some 
combination of CheckName, CleanupName, and UniqueName to create names of waves, global variables, 
and data folders.
Waves, global numeric variables, and global string variables are all in the same namespace and need to be 
unique only within the data folder containing them. However, they also need to be distinct from names of 
Igor operations and functions and from names of user-defined procedures.
Data folders are in their own namespace and need to be unique only among other data folders at the same 
level of the data folder hierarchy.
windowNameStr is optional. If missing, it is taken to be the top graph, panel, layout, or notebook according 
to the value of objectType.
Details
A result of zero indicates that the name is legal and unique within its namespace. Any nonzero result 
indicates that the name is illegal or not unique. You can use the CleanupName and UniqueName functions 
to guarantee legality and uniqueness.
nameStr should contain an unquoted name (i.e., no single quotes for liberal names), such as you might 
receive from the user through a dialog or control panel.
objectType is one of the following:
The windowNameStr argument is used only with objectTypes 14, 15, and 16. The nameStr is checked for 
uniqueness only within the named window (other windows might have objects with the given name). If a 
named window is given but does not exist, any valid nameStr is permitted
/A
Checks all graphs, tables, page layout, panels, and Gizmo windows.
/W=winName
Checks only the named window
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
