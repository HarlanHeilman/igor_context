# CopyFile

CopyFile
V-104
CopyFile 
CopyFile [flags][srcFileStr] [as destFileOrFolderStr]
The CopyFile operation copies a file on disk.
Parameters
srcFileStr can be a full path to the file to be copied (in which case /P is not needed), a partial path relative to 
the folder associated with pathName, or the name of a file in the folder associated with pathName.
If Igor can not determine the location of the source file from srcFileStr and pathName, it displays a dialog 
allowing you to specify the source file.
destFileOrFolderStr is interpreted as the name of (or path to) an existing folder when /D is specified, 
otherwise it is interpreted as the name of (or path to) a possibly existing file.
If destFileOrFolderStr is a partial path, it is relative to the folder associated with pathName.
If /D is specified, the source file is copied inside the folder using the source file’s name.
If Igor can not determine the location of the destination file from pathName, srcFileStr, and 
destFileOrFolderStr, it displays a Save File dialog allowing you to specify the destination file (and folder).
If you use a full or partial path for either srcFileStr or destFileOrFolderStr, see Path Separators on page III-451 
for details on forming the path.
Folder paths should not end with single Path Separators. See the Details section for MoveFolder.
Flags
/D
Interprets destFileOrFolderStr as the name of (or path to) an existing folder (or 
“directory”). Without /D, destFileOrFolderStr is interpreted as the name of (or path to) 
a file.
If destFileOrFolderStr is not a full path to a folder, it is relative to the folder associated 
with pathName.
/I [=i]
/M=messageStr
Specifies the prompt message in the Open File dialog. If /S is not used, then messageStr 
will be used for both Open File and for Save File dialogs.
/O
Overwrites any existing destination file.
/P=pathName
Specifies the folder to look in for the source file, and the folder into which the file is 
copied. pathName is the name of an existing symbolic path.
Using /P means that both srcFileStr and destFileOrFolderStr must be either simple file 
or folder names, or paths relative to the folder specified by pathName.
/S=saveMessageStr
Specifies the prompt message in the Save File dialog.
/Z [=z]
Specifies the level of user interactivity.
/I=0:
Interactive only if one or srcFileStr or destFileOrFolderStr is not 
specified or if the source file is missing. (Same as if /I was not 
specified.)
/I=1:
Interactive even if srcFileStr is specified and the source file exists.
/I=2:
Interactive even if destFileOrFolderStr is specified.
/I=3:
Interactive even if srcFileStr is specified, the source file exists, and 
destFileOrFolderStr is specified. Same as /I only.
Prevents procedure execution from aborting if it attempts to copy a file that does not 
exist. Use /Z if you want to handle this case in your procedures rather than aborting 
execution.
/Z=0:
Same as no /Z.
/Z=1:
Copies a file only if it exists. /Z alone has the same effect as /Z=1.
/Z=2:
Copies a file if it exists or displays a dialog if it does not exist.
