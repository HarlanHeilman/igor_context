# CloseMovie

Close
V-71
See Also
Object Names on page III-501, Programming with Liberal Names on page IV-168, 
CreateDataObjectName, CheckName, UniqueName
Close 
Close [/A] fileRefNum
The Close operation closes a file previously opened by the Open operation or closes all such files if /A is used.
Parameters
fileRefNum is the file reference number of the file to close. This number comes from the Open operation. If 
/A is used, fileRefNum should be omitted.
Flags
CloseHelp
CloseHelp [ /ALL /FILE=fileNameStr /NAME=helpNameStr /P=pathName ]
The CloseHelp operation closes a help window.
The CloseHelp operation was added in Igor Pro 7.00.
Flags
Details
You must provide one of the following flags: /ALL, /FILE, /NAME.
See Also
OpenHelp
CloseMovie 
CloseMovie
The CloseMovie operation closes the currently open movie. You must close a movie before you can play it.
Flags 
Output Variables
/A
Closes all files. Mainly useful for cleaning up after an error during procedure 
execution occurs so that the normal Close operation is never executed.
/ALL
Closes all open help windows.
/FILE=fileNameStr
Identifies the help window to close using the help file's location on disk. The file 
is specified by fileNameStr and /P=pathName where pathName is the name of an 
Igor symbolic path. fileNameStr can be a full path to the file, in which case /P is not 
needed, a partial path relative to the folder associated with pathName, or the name 
of a file in the folder associated with pathName.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 
for details on forming the path.
/NAME=helpNameStr
Identifies the help window to close using the window's title as specified by 
helpNameStr. This is the text that appears in the help window title bar.
/P=pathName
Specifies the folder to look in for the file specified by /FILE. pathName is the name 
of an existing Igor symbolic path.
/Z
Suppresses error reporting. If you use /Z, check the V_Flag output variable to see 
if the operation succeeded.
V_Flag
Set to 0 if the operation succeeded or to a non-zero error code.
V_Flag is set only if you use the /Z flag.
