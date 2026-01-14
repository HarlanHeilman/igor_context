# Other File– and Folder–Related Operations and Functions

Chapter IV-7 — Programming Techniques
IV-195
Before working with a file, you must use the Open operation to obtain a file reference number that you use 
with all the remaining commands. The Open operation creates new files, appends data to an existing file, 
or reads data from an existing file. There is no facility to deal with the resource fork of a Macintosh file.
Sometimes you may write a procedure that uses the Open operation and the Close operation but, because 
of an error, the Close operation never gets to execute. You then correct the procedure and want to rerun it. 
The file will still be open because the Close operation never got a chance to run. In this case, execute:
Close/A
from the command line to close all open files.
Finding Files
Two functions are provided to help you to determine what files exist in a particular folder:
•
TextFile
•
IndexedFile
IndexedFile is a more general version of TextFile.
You can also use the Open operation with the /D flag to present an open dialog.
Other File– and Folder–Related Operations and Functions
Igor Pro also supports a number of operations and functions for file or folder manipulation:
Warning: Use caution when writing code that deletes or moves files or folders. These actions are not undoable.
Because the DeleteFolder, CopyFolder and MoveFolder operations have the potential to do a lot of damage 
if used incorrectly, they require user permission before overwriting or deleting a folder. The user controls 
the permission process using the Miscellaneous Settings dialog (Misc menu).
wfprintf
Writes wave data as formatted text to an open file.
FGetPos
Gets the position at which the next file read or write will be done.
FSetPos
Sets the position at which the next file read or write will be done.
FStatus
Given a file reference number, returns miscellaneous information about the file.
FBinRead
Reads binary data from a file into an Igor string, variable or wave. This is used mostly 
to read nonstandard file formats.
FBinWrite
Writes binary data from an Igor string, variable or wave. This is used mostly to write 
nonstandard file formats.
FReadLine
Reads a line of text from a text file into an Igor string variable. This can be used to parse 
an arbitrary format text file.
Close
Closes a file opened by the Open operation.
CopyFile
CopyFolder
DeleteFile
DeleteFolder
GetFileFolderInfo
SetFileFolderInfo
MoveFile
MoveFolder
CreateAliasShortcut
NewPath
PathInfo
ParseFilePath
Operation
What It Does
