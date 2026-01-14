# SetFileFolderInfo

SetFileFolderInfo
V-845
Parameters
Details
The environment of Igor's process is composed of a set of key=value pairs that are known as environment 
variables. Any child process created by calling ExecuteScriptText inherits the environment variables of 
Igor's process.
SetEnvironmentVariable changes the environment variables present in Igor's process and any future 
process created by ExecuteScriptText but does not affect any other processes already created.
On Windows, environment variable names are case-insensitive. On other platforms, they are case-sensitive.
Examples
Variable result
result = SetEnvironmentVariable("SOME_VARIABLE", "15")
result = SetEnvironmentVariable("SOME_OTHER_VARIABLE", "string value") 
See Also
GetEnvironmentVariable, UnsetEnvironmentVariable
SetFileFolderInfo 
SetFileFolderInfo [flags][fileOrFolderNameStr]
The SetFileFolderInfo operation changes the properties of a file or folder.
Parameters
fileOrFolderNameStr specifies the file or folder to be changed.
If you use a full or partial path for fileOrFolderNameStr, see Path Separators on page III-451 for details on 
forming the path.
Folder paths should not end with single Path Separators. See the MoveFolder Details section.
If Igor can not determine the location of the file or folder from fileOrFolderNameStr and /P=pathName, it 
displays a dialog allowing you to specify the file to be deleted. Use /D to select a folder in this event, 
otherwise Igor prompts your for a file.
Flags
At least one of the seven following flags is required, or nothing is actually accomplished:
varName
The name of an environment variable which does not need to actually exist. It must 
not be an empty string and may not contain an equals sign (=).
varValue
The new contents for the variable.
On Windows, if varValue is an empty string, the variable is removed. On other 
platforms, the variable is always set to varValue.
/CDAT=cdate
Specifies the number of seconds since midnight January 1, 1904 when the file or folder 
was first created. cDate is interpreted as local time or UTC depending on the /UTC 
flag.
/INV[=inv]
/MDAT=mDate
Specifies the number of seconds since midnight January 1, 1904 when the file or folder 
was modified most recently. mDate is interpreted as local time or UTC depending on 
the /UTC flag.
/RO[=ro]
Sets the visibility of a file.
inv=0:
File is visible.
inv=1:
Default; file is invisible (Macintosh) or Hidden (Windows).
Sets the read/write state of a file or folder.
ro=0:
File or folder is writable.
ro=1:
File or folder is locked (default).

SetFileFolderInfo
V-846
If fileOrFolderNameStr refers to a file (not a folder), SetFileFolderInfo updates the file properties to reflect 
values given with the following keywords:
Optional Flags
Variables
On Macintosh, locking the file or folder is equivalent to setting the locked property 
manually using the Get Info window in the Finder.
On Windows, locking the file or folder is equivalent to setting the read-only property 
manually using the Properties window in Windows Explorer.
/CRE8=creatorStr
Sets the four-character creator code string, such as 'IGR0' (Igor Pro creator code).
Ignored on Windows, where files have no “creator code”; instead file extensions are 
“registered” or “owned” by one, and only one, application. You cannot change that 
ownership from Igor Pro.
/FTYP=fTypeStr
Sets the four-character file type code, such as 'TEXT' or 'IGsU' (packed experiment).
Ignored on Windows. Use MoveFile to change the file extension.
/STA[=st]
/D
Uses the Select Folder dialog rather than Open File dialog when pathName and 
fileOrFolderNameStr do not specify an existing file or folder.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/R[=r]
/UTC[=u]
If you include /UTC or /UTC=1, SetFileFolderInfo interprets the creation and 
modification dates as UTC (coordinated universal time). If you omit /UTC or specify 
/UTC=0, SetFileFolderInfo interprets the creation and modification dates as local time.
The default, used if you omit /UTC, is local time.
The /UTC flag was added in Igor Pro 9.00.
/Z[=z]
Specifies whether the file is a stationery file or not.
Ignored on Windows. Use MoveFile to change the file extension.
st=1:
Stationery file (default).
st=0:
Normal file.
Recursively applies change(s) to all files or folders in the folder specified by 
/P=pathName or fileOrFolderNameStr, and the folder itself:
/R requires /D and a folder specification.
r=0:
No recursion. Same as no /R.
r=1:
Recursively apply changes to files.
r=2:
Recursively apply changes to folders, including the folder specified 
by pathName or fileOrFolderNameStr.
r=3:
Recursively apply changes to both files and folders (default).
Prevents procedure execution from aborting if SetFileFolderInfo tries to set 
information about a file or folder that does not exist. Use /Z if you want to handle 
this case in your procedures rather than having execution abort.
/Z=0:
Same as no /Z at all.
/Z=1:
Used for setting information for a file or folder only if it exists. /Z 
alone has the same effect as /Z=1.
/Z=2:
Used for setting information for a file or folder if it exists and 
displaying a dialog if it does not exist.
