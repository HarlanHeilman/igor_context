# CloseProc

CloseProc
V-72
See Also
Movies on page IV-245, NewMovie
CloseProc 
CloseProc /NAME=procNameStr [flags]
CloseProc /FILE=fileNameStr [flags]
The CloseProc operation closes a procedure window. You cannot call CloseProc on the main Procedure 
window.
CloseProc provides a way to programmatically create and alter procedure files. You might do this in order 
to make a user-defined menu-bar menu with contents that change.
Note:
CloseProc alters procedure windows so it cannot be called while functions or macros are 
running. If you want to call it from a function or macro, use Execute/P.
Warning:
If you close a procedure window that has no source file or without specifying a destination file, 
the window contents will be permanently lost.
Flags
Details
CloseProc cannot be called from a macro or function. Call it from the command line or via Execute/P (see 
Operation Queue on page IV-278).
/COMP[=compile]
/D[=delete]
/FILE=fileNameStr
Identifies the procedure window to close using the file name and path to the file 
given by fileNameStr. The string can be just the file name if /P is used to specify a 
symbolic path name of the enclosing folder. It can be a partial path if /P points to 
a folder enclosing the start of the partial path. It can also be a full path the file.
/NAME=procNameStr
Identifies the procedure window to close with the string expression procNameStr. 
This is the same text that appears in the window title. If the procedure window is 
associated with a file, it will be the file name and extension.
To close a procedure file that is part of an independent module, you must include 
the independent module name in procNameStr. For example:
CloseProc /NAME="GraphBrowser.ipf [WM_GrfBrowser]"
Note that there is a space after the file name followed by the independent module 
name in brackets.
/P=pathName
Specifies the folder to look in for the file specified by /FILE. pathName is the name 
of an existing symbolic path.
/SAVE[=savePathStr]
Saves the procedure before closing the window. If the flag is used with no 
argument, it saves any changes to the procedure window to its source file before 
closing it. If savePathStr is present, it must be a full path naming a file in which to 
save the procedure window contents. The /P flag is not used with savePathStr so it 
must be a full path.
Specifies whether procedures should be compiled after closing the procedure 
window.
compile=1:
Compiles procedures (same as /COMP only).
compile=0:
Leaves procedures in an uncompiled state.
Specifies whether the procedure file should be deleted after closing the procedure 
window.
delete=1:
Deletes procedure file (same as /D only).
Warning: You cannot recover any file deleted this way.
delete=0:
Leaves any associated file unaffected.
