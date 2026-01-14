# OpenNotebook

OpenNotebook
V-722
Details
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like "hd:Folder1:" or "C:\\Folder1\\". See Symbolic Paths on page II-22 for details.
If the specified file is already open but not as a help window (for example as a notebook), OpenHelp returns 
an error.
If the /W or /V flag is used, or both, the window size and position and visibility are set as specified even if 
the file itself is already open, so long as the file is already opened as a help window.
Output Variables
The OpenHelp operation returns information in the following variables:
See Also
CloseHelp
OpenNotebook 
OpenNotebook [flags] [fileNameStr]
The OpenNotebook operation opens a file for reading or writing as an Igor notebook.
Unlike the Open operation, OpenNotebook will not create a file if the specified file does not exist. To create 
a new notebook, use the NewNotebook operation.
Parameters
The file to be opened is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
/Z[=z]
/Z=1 prevents aborting procedure execution if an error occurs, for example if the file 
does not exist or if there is a compilation error. Use /Z=1 if you want to handle errors 
in your procedures rather than having execution abort.
When using /Z or /Z=1, check V_Flag to see if an error occurred.
V_Flag
Set to a non-zero value if an error occurred and to zero if no error occurred.
V_alreadyOpen
Set to 1 if the specified help file was already open as a help file or to zero otherwise.
S_pictureInfo
Scans the compiled help file for pictures and stores information about all pictures in 
a semicolon separated list into the S_pictureInfo output string. If the help file needs to 
be compiled but compilation fails, S_pictureInfo is set to "".
Controls error reporting.
/Z=0:
Report errors normally. /Z=0 is the same as omitting /Z altogether. 
This is the default behavior if /Z is omitted.
/Z=1:
Suppresses normal error reporting.
/Z alone has the same effect as /Z=1.

OpenNotebook
V-723
Flags
Details
The /A (append) flag has no effect other than to move the selection to the end of the notebook after it is opened.
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
The /T=typeStr flag affects only the dialog that OpenNotebook presents if you do not specify a path and 
filename. The dialog presents only those files whose type is specified by /T=typeStr. There are two file types 
that are allowed for notebooks: 'TEXT' which is a plain text file and 'WMT0' which is a WaveMetrics 
formatted text file. Therefore, the file type, if you use it, should be either “TEXT” or “WMT0”. If /T=typeStr is 
missing, it defaults to “TEXTWMT0”. This opens either type of notebook file. On Windows, Igor considers 
files with “.txt” extensions to be of type TEXT and considers files with “.ifn” to be of type WMT0. See File 
Types and Extensions on page III-455 for details.
/A
Moves the notebook’s selection to the end of the notebook.
/ENCG=textEncoding
Specifies the text encoding of the plain text file to be opened as a notebook.
This flag was added in Igor Pro 7.00.
This is relevant for plain text notebooks only and is ignored for formatted notebooks 
because they can contain multiple text encodings. See Plain Text File Text Encodings 
on page III-466 and Formatted Text Notebook File Text Encodings on page III-472 
for details.
OpenNotebook uses the text encoding specified by /ENCG and the rules described 
under Determining the Text Encoding for a Plain Text File on page III-467 to 
determine the source text encoding for conversion to UTF-8.
Passing 0 for textEncoding acts as if /ENCG were omitted.
See Text Encoding Names and Codes on page III-490 for a list of accepted values for 
textEncoding.
/K=k
/M=messageStr
Prompt message text in the dialog used to find the file, if any.
/N=winName
Specifies the window name to be assigned to the new notebook. If omitted, it assigns 
a name like “Notebook0”.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/R
Opens the file as read only.
/T=typeStr
Specifies the type or types of files that can be opened.
/V=visible
Hides (visible= 0) or shows (visible= 1; default) the notebook.
/W=(left,top,right,bottom)
Specifies window size and position. Coordinates are in points.
/Z
Suppresses error generation. Use this to check if a file exists. If you use /Z, 
OpenNotebook sets the variable V_flag to 0 if the notebook was opened or to nonzero 
if there was an error, usually because the specified file does not exist.
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.
