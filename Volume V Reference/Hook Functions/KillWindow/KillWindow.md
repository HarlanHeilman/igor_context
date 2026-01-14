# KillWindow

KillStrings
V-471
See Also
See Pictures on page III-509 for general information on how Igor handles pictures.
KillStrings 
KillStrings [/A/Z] [stringName [, stringName]…]
The KillStrings operation discards the named global strings.
Flags
KillVariables 
KillVariables [/A/Z] [variableName [, variableName]…]
The KillVariables operation discards the named global numeric variables.
Flags
KillWaves 
KillWaves [flags] waveName [, waveName]…
The KillWaves operation destroys the named waves.
Flags
Details
The memory the waves occupied becomes available for other uses. You can’t kill a wave used in a graph or 
table or which is reserved by an XOP.
XOPs reserve a wave by sending the OBJINUSE message.
For functions compiled with the obsolete rtGlobals=0 setting, you also can't kill a wave referenced from a 
user-defined function.
Examples
KillWaves/A/Z
// kill waves not in use in current data folder
KillWindow 
KillWindow [flags] winName
The KillWindow operation kills or closes a specified window or subwindow without saving a recreation macro.
Parameters
winName is the name of an existing window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
/A
Kills all global strings in the current data folder. If you use /A, omit stringName.
/Z
Does not generate an error if a global string to be killed does not exist. To kill all global 
strings in the current data folder, use KillStrings/A/Z.
/A
Kills all global variables in the current data folder. If you use /A, omit variableName.
/Z
Does not generate an error if a global variable to be killed does not exist. To kill all global 
variables in the current data folder, use KillVariables/A/Z.
/A
Kills all waves in the current data folder. If you use /A, omit waveNames.
/F
Deletes the Igor binary wave file from which waveName was loaded.
/Z
Does not generate an error if a wave to be killed is in use or does not exist.
