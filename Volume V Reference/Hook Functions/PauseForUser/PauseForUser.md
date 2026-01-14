# PauseForUser

PathList
V-738
The path returned is a colon-separated path which can be used on Macintosh or Windows. See Path 
Separators on page III-451 for details.
Flags
Details
The use of PathInfo in a preemptive thread requires Igor Pro 8.00 or later.
Examples
// The following lines perform equivalent actions:
PathInfo/S myPath;Open refNum
Open/P=myPath refNum
// Show Igor's Preferences folder in the Finder/Windows Explorer.
String fullpath= SpecialDirPath("Preferences",0,0,0)
NewPath/O/Q tempPathName, fullpath
PathInfo/SHOW tempPathName
See Also
Symbolic Paths on page II-22.
The NewPath, GetFileFolderInfo, ParseFilePath and SpecialDirPath operations.
PathList 
PathList(matchStr, separatorStr, optionsStr)
The PathList function returns a string containing a list of symbolic paths selected based on the matchStr 
parameter.
Details
For a path name to appear in the output string, it must match matchStr. separatorStr is appended to each path 
name as the output string is generated.
PathList works like the WaveList function, except that the optionsStr parameter is reserved for future use. 
Pass "" for it.
Examples
When a new experiment is created there is only one path:
Print PathList("*",";","")
Prints the following in the history area:
Igor;
See Also
The WaveList function for an explanation of the matchStr and separatorStr parameters and for examples. See 
also Symbolic Paths on page II-22 for an explanation of symbolic paths.
PauseForUser 
PauseForUser [/C] mainWindowName [, targetWindowName]
The PauseForUser operation pauses function execution to allow the user to manually interact with a 
window. For example, you can call PauseForUser from a loop to allow the user to move the cursors on a 
graph. In this scenario, targetWindowName would be the name of the graph and mainWindowName would be 
the name of a control panel containing a message telling the user to adjust the cursors and then click, for 
example, the Continue button.
If targetWindowName is omitted then mainWindowName plays the role of target window.
PauseForUser works with graph, table, and panel windows only.
/S
Presets the next otherwise undirected open or save file dialog to the given disk folder. 
This flag is ignored when PathInfo is called from a preemptive thread.
/SHOW
Shows the folder, if it exists, in the Finder (Mac OS X) or Windows Explorer 
(Windows). This flag is ignored when PathInfo is called from a preemptive thread.
