# DeleteFile

DeleteFile
V-155
for(i=0; i<n; i+=1)
String child = StringFromList(i, children)
numDeleted += DeleteAnnotationsInWin(child) // Recurse
endfor
return numDeleted
End
See Also
TextBox, StringFromList, AnnotationList
DeleteFile 
DeleteFile [flags] [fileNameStr]
The DeleteFile operation deletes a file on disk.
Parameters
fileNameStr can be a full path to the file to be deleted (in which case /P is not needed), a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName.
If Igor can not locate the file from fileNameStr and pathName, it displays a dialog allowing you to specify the 
file to be deleted.
If you use a full or partial path for either file, see Path Separators on page III-451 for details on forming the path.
Flags
Variables
The DeleteFile operation returns information in the following variables:
See Also
DeleteFolder, MoveFile, CopyFile, NewPath, and Symbolic Paths on page II-22.
/I
Interactive mode displays the Open File dialog even if fileNameStr is specified and the 
file exists.
/M=messageStr
Specifies the prompt message for the Open File dialog.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/Z[=z]
V_flag
Set to zero if the file was deleted, to -1 if the user cancelled the Open File dialog, and 
to some nonzero value if an error occurred, such as the specified file does not exist.
S_path
Stores the full path to the file that was deleted. If an error occurred or if the user 
cancelled, it is set to an empty string.
Prevents procedure execution from aborting if it attempts to delete a file that does 
not exist. Use /Z if you want to handle this case in your procedures rather than 
having execution abort.
/Z=0:
Same as no /Z.
/Z=1:
Deletes a file only if it exists. /Z alone has the same effect as /Z=1.
/Z=2:
Deletes a file if it exists or displays a dialog if it does not exist.
