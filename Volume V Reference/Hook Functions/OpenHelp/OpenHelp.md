# OpenHelp

OpenHelp
V-721
FGetPos, FSetPos, FStatus
fprintf, wfprintf
Displaying an Open File Dialog on page IV-148, Displaying a Multi-Selection Open File Dialog on page 
IV-149, Open File Dialog File Filters on page IV-149
Displaying a Save File Dialog on page IV-150, Save File Dialog File Filters on page IV-151
Using Open in a Utility Routine on page IV-151
OpenHelp
OpenHelp [flags] fileNameStr
The OpenHelp operation opens the specified help file.
The OpenHelp operation was added in Igor Pro 7.00.
Parameters
The help file to be opened is specified by fileNameStr and /P=pathName where pathName is the name of an 
Igor symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path 
relative to the folder associated with pathName, or the name of a file in the folder associated with pathName. 
If OpenHelp can not determine the location of the file from fileNameStr and pathName, it returns an error.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
/INT[=interactive]
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing Igor 
symbolic path.
/PICT
Scans the compiled help file for pictures and stores information about all pictures in 
a semicolon separated list into the S_pictureInfo output string. If the help file needs to 
be compiled but compilation fails, S_pictureInfo is set to "".
/V=visible
/W=(left,top,right,bottom)
Specifies window size and position. Coordinates are in points.
Controls whether opening the help file is interactive or not.
/INT=1:
If the help file being opened needs to be compiled, OpenHelp 
presents a dialog asking the user whether the file should be compiled. 
During the compile, a progress dialog is displayed. Any errors are 
presented to the user in an error dialog. This is the default behavior if 
/INT is omitted.
/INT=0:
If the help file being opened needs to be compiled, OpenHelp 
compiles it without presenting a dialog. Compilation errors are not 
presented to the user but are reflected in the V_Flag output variable.
Controls help window visibility.
visible=0:
The help window will be initially hidden.
visible=1:
The help window will be initially visible. This is the default if /V is 
omitted.
