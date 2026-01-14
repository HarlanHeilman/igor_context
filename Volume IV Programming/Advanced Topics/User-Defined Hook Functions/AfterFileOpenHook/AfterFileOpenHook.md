# AfterFileOpenHook

Chapter IV-10 — Advanced Topics
IV-282
AfterFileOpenHook
AfterFileOpenHook(refNum, fileNameStr, pathNameStr, fileTypeStr, 
fileCreatorStr, fileKind)
AfterFileOpenHook is a user-defined function that Igor calls after it has opened a file because the user 
dragged it onto the Igor icon or into Igor or double-clicked it.
AfterFileOpenHook is not called when a file is opened via a menu.
Windows system files with .bin, .com, .dll, .exe, and .sys extensions aren’t passed to the hook functions.
The parameters contain information about the file, which has already been opened for read-only access.
AfterFileOpenHook’s return value is ignored unless fileKind is 9. If the returned value is zero, the default 
action is performed.
Parameters
refNum is the file reference number. You use this number with file I/O operations to read from the file. Igor 
closes the file when the user-defined function returns, and refNum becomes invalid. The file is opened for 
read-only; if you want to write to it, you must close and reopen it with write access. refNum will be -1 for 
experiment files and XOPs. In this case, Igor has not opened the file for you.
fileNameStr contains the name of the file.
pathNameStr contains the name of the symbolic path. pathNameStr is not the value of the path. Use the 
PathInfo operation to determine the path’s value.
fileTypeStr contains the Macintosh file type, if applicable. File type codes are obsolete. Use the file name 
extension to determine if you want to handle the file. You can use ParseFilePath to obtain the extension 
from fileNameStr.
fileCreatorStr contains the Macintosh creator code, if applicable. Creator codes are obsolete so ignore this 
parameter.

Chapter IV-10 — Advanced Topics
IV-283
fileKind is a number that identifies what kind of file Igor thinks it is. Values for fileKind are listed in the next 
section.
AfterFileOpenHook fileKind Parameter
This table describes the AfterFileOpenHook function fileKind parameter.
If the user’s AfterFileOpenHook function returns 0, Igor performs the default action listed in the table:
Details
AfterFileOpenHook’s return value is ignored, except when fileKind is 9 (Numeric text, Tab-Separated-
Values, MIME). If you return a value of 0, Igor executes the default action, which displays the loaded data 
in a table and a graph. If you return a value of 1, Igor does nothing.
Another way to disable the MIME-TSV default action is define a global variable named 
V_no_MIME_TSV_Load (in the root data folder) and set its value to 1. In this case any file of fileKind = 9 is 
reassigned a fileKind of 8.
The default action for fileKind = 9 makes Igor a MIME-TSV document Helper Application for Web browsers 
such as Netscape or Internet Explorer.
The exact criteria for Igor to consider a file to be of kind 9 are:
•
fileTypeStr must be “TEXT” or “WMT0” (that’s a zero, not an oh).
•
Either the first line of the file must begin with a # character, or the name of the file must end with 
“.tsv” in either lower or upper case.
•
The first line must contain one or more column titles. If the line starts with a # character, the first 
column title must not start with “include”, “pragma” or the ! character. Spaces are allowed in the 
titles, but if two or more title columns are present, they must be separated by one tab character.
•
The second line must contain one or more numbers. If two or more numbers, they must be separated 
by one tab character, and the first line’s words must also be separated by tabs.
When the MIME-TSV file contains one column of data, it is graphed as a series of Y values.
Short columns (less than 50 values) are graphed with lines and markers, longer columns with lines only. 
Preferences are turned on when the graph is made.
Kind of File
fileKind 
Default Action, if Any
Unknown
0
Igor Experiment, packed
(stationery, too)
1
Igor Experiment, unpacked
(stationery, too)
2
Igor XOP
3
Igor Binary Wave File
4
Igor Text (data and commands)
5
Text, no numbers detected in first 
two lines
6
General Numeric text (no tabs)
7
Numeric text
Tab-Separated-Values
8
Numeric text
Tab-Separated-Values, MIME
9
Display loaded data in a new table 
and a new graph.
Text, with tabs
10
Igor Notebook
(unformatted or formatted)
11
Igor Procedure
12
Igor Help
13
