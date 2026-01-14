# BeforeFileOpenHook

Chapter IV-10 — Advanced Topics
IV-287
Before Igor Pro 9.00, refNum was always -1.
fileNameStr contains the name of the file.
pathNameStr contains the name of the symbolic path. pathNameStr is not the value of the path. Use the 
PathInfo operation to determine the path’s value.
fileTypeStr contains the Macintosh file type, if applicable. File type codes are obsolete. Use the file name 
extension to determine if you want to handle the file. You can use ParseFilePath to obtain the extension 
from fileNameStr
fileCreatorStr contains the Macintosh creator code, if applicable. Creator codes are obsolete so ignore this 
parameter.
Variable fileKind is a number that identifies what kind of file Igor will be saving: 
Details
You can determine the full directory and file path of the experiment by calling the PathInfo operation with 
$pathNameStr.
Example
This example prints the full file path of the about-to-be-saved experiment to the history area, and deletes 
all unused symbolic paths.
#pragma rtGlobals=1
// treat S_path as local string variable
Function BeforeExperimentSaveHook(rN,fileName,path,type,creator,kind)
Variable rN,kind
String fileName,path,type,creator
PathInfo $path
// puts path value into (local) S_path
Printf "Saved \"%s\" experiment\r",S_path+fileName
KillPath/A/Z
// Delete all unneeded symbolic paths
End
See Also
The SetIgorHook operation.
BeforeFileOpenHook
BeforeFileOpenHook(refNum, fileNameStr, pathNameStr, fileTypeStr, 
fileCreatorStr, fileKind)
BeforeFileOpenHook is a user-defined function that Igor calls when a file is about to be opened because the 
user dragged it onto the Igor icon or into Igor or double-clicked it.
BeforeFileOpenHook is not called when a file is opened via a menu.
Windows system files with .bin, .com, .dll, .exe, and .sys extensions aren’t passed to the hook functions.
The value returned by BeforeFileOpenHook informs Igor whether the hook function handled the open 
event and therefore Igor should not perform its default action. In some cases, this return value is ignored, 
and Igor performs the default action anyway.
Parameters
refNum is the file reference number. You use this number with file I/O operations to read from the file. Igor 
closes the file when the user-defined function returns, and refNum becomes invalid. The file is opened for 
read-only; if you want to write to it, you must close and reopen it with write access. refNum will be -1 for 
experiment files and XOPs. In this case, Igor has not opened the file for you.
fileNameStr contains the name of the file.
pathNameStr contains the name of the symbolic path. pathNameStr is not the value of the path. Use the 
PathInfo operation to determine the path’s value.
Kind of File
fileKind 
Igor Experiment, packed* 
*
Including stationery experiment files.
1
Igor Experiment, unpacked*
2

Chapter IV-10 — Advanced Topics
IV-288
fileTypeStr contains the Macintosh file type, if applicable. File type codes are obsolete. Use the file name 
extension to determine if you want to handle the file. You can use ParseFilePath to obtain the extension 
from fileNameStr
fileCreatorStr contains the Macintosh creator code, if applicable. Creator codes are obsolete so ignore this 
parameter.
fileKind is a number that identifies what kind of file Igor thinks it is. Values for fileKind are listed in the next 
section.
BeforeFileOpenHook fileKind Parameter
This table describes the BeforeFileOpenHook function fileKind parameter. 
Details
BeforeFileOpenHook must return 1 if Igor is not to take action on the file (it won’t be opened), or 0 if Igor 
is permitted to take action on the file. Igor ignores the return value for fileKind values of 3, 12, and 13. The 
hook function is not called for Igor experiments (fileKind values of 1 and 2).
Igor always closes the file when the user-defined function returns, and refNum becomes invalid (don’t store 
the value of refNum in a global for use by other routines, since the file it refers to has been closed).
Example
This example checks the first line of the file about to be opened to determine whether it has a special, 
presumably user-specific, format. If it does, then LoadMyFile (another user-defined function) is called to 
load it. LoadMyFile presumably loads this custom data file, and returns 1 if it succeeded. If it returns 0 then 
Igor will open it using the Default Action from the above table.
Function BeforeFileOpenHook(refNum,fileName,path,type,creator,kind)
Variable refNum,kind
String fileName,path,type,creator
Variable handledOpen=0
if( CmpStr(type,"TEXT")==0 )
// text files only
String line1
FReadLine refNum, line1 // First line (and carriage return)
if( CmpStr(line1[0,4],"XYZZY") == 0 )
// My special file
Kind of File
fileKind 
Default Action, if Any
Unknown
0
Igor Experiment, packed *
*
Including stationery experiment files.
1
(Hook not called)
Igor Experiment, unpacked*
2
(Hook not called)
Igor XOP
3
Igor Binary Wave File
4
Data loaded
Igor Text (data and commands)
5
Data loaded, commands executed
Text, no numbers detected in first 
two lines
6
Opened as unformatted notebook
General Numeric text (no tabs)
7
Data loaded as general text
Numeric text
Tab-Separated-Values
8
Data loaded as delimited text
Numeric text
Tab-Separated-Values, MIME
9
Display loaded data in a new table and 
a new graph.
Text, with tabs
10
Opened as unformatted notebook
Igor Notebook
(unformatted or formatted)
11
Opened as notebook
Igor Procedure
12
Always opened as procedure file
Igor Help
13
Always opened as help file
