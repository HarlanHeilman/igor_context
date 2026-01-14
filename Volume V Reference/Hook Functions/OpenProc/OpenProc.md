# OpenProc

OpenProc
V-724
See Also
The Notebook and NewNotebook operations, and Chapter III-1, Notebooks.
OpenProc 
OpenProc [flags] [fileNameStr]
The OpenProc operation opens a file as an Igor procedure file.
Note:
This operation is used automatically to open procedure files when you open an Igor experiment. 
You can invoke OpenProc only from the command line. Do not invoke it from a procedure. To 
open procedure files from a procedure or from a menu definition, use the Execute/P operation.
Parameters
The file to be opened is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
The /A (append) flag has no effect other than to move the selection to the end of the procedure file after it 
is opened.
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
OpenProc automatically opens procedure files when you open an Igor experiment. Normally, you will have 
no use for it. You can not open a procedure file while procedures are executing. Thus, you can’t invoke 
OpenProc from within a procedure. You can only invoke it from the command line or from a user menu 
definition (actually, you may get away with it in a macro, but it’s not recommend).
See Also
Chapter III-13, Procedure Windows, Execute, CloseProc
/A
Moves the procedure window’s selection to the end of the window.
/ENCG=textEncoding
Specifies the text encoding of the plain text file to be opened as a procedure file.
This flag was added in Igor Pro 7.00.
OpenProc uses the text encoding specified by /ENCG and the rules described under 
Determining the Text Encoding for a Plain Text File on page III-467 to determine the 
source text encoding for conversion to UTF-8.
Passing 0 for textEncoding acts as if /ENCG were omitted.
See Text Encoding Names and Codes on page III-490 for a list of accepted values for 
textEncoding.
/M=messageStr
Prompt message text in the dialog used to find the file, if any.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/R
The file is opened read only.
/T=typeStr
Specifies the type or types of files that can be opened.
/V=visible
Hides (visible= 0) or shows (visible= 1; default) the procedure window.
/Z
Suppresses error generation if the specified file does not exist.
