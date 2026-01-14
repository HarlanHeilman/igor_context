# CopyFolder

CopyFolder
V-105
Variables
The CopyFile operation returns information in the following variables:
Examples
Copy a file within the same folder using a new name:
CopyFile/P=myPath "afile.txt" as "destFile.txt"
Copy a file into subfolder using the original name (using /P):
CopyFile/D/P=myPath "afile.txt" as ":subfolder"
Print S_Path
// prints "Macintosh HD:folder:subfolder:afile.txt"
Copy file into subfolder using the original name (using full paths):
CopyFile/D "Macintosh HD:folder:afile.txt" as "Server:archive"
Copy a file from one folder to another, assigning the copy a new name:
CopyFile "Macintosh HD:folder:afile.txt" as "Server:archive:destFile.txt"
Copy user-selected file in any folder as destFile.txt in myPath folder (prompt to save even if destFile.txt 
doesn’t exist):
CopyFile/I=2/P=myPath as "destFile.txt"
Copy user-selected file in any folder as destFile.txt in any folder:
CopyFile as "destFile.txt"
See Also
The Open, MoveFile, DeleteFile, and CopyFolder operations. The IndexedFile function. Symbolic Paths 
on page II-22.
CopyFolder 
CopyFolder [flags][srcFolderStr] [as destFolderStr]
The CopyFolder operation copies a folder (and its contents) on disk.
Parameters
srcFolderStr can be a full path to the folder to be copied (in which case /P is not needed), a partial path relative 
to the folder associated with pathName, or the name of a folder inside the folder associated with pathName.
If Igor can not determine the location of the folder from srcFolderStr and pathName, it displays a dialog 
allowing you to specify the source folder.
If /P=pathName is given, but srcFolderStr is not, then the folder associated with pathName is copied.
destFolderStr can be a full path to the output (destination) folder (in which case /P is not needed), or a partial 
path relative to the folder associated with pathName.
An error is returned if the destination folder would be inside the source folder.
V_flag
Set to zero if the file was copied, to -1 if the user cancelled either the Open File or Save File 
dialogs, and to some nonzero value if an error occurred, such as the specified file does not 
exist.
S_fileName
Stores the full path to the file that was copied. If an error occurred or if the user cancelled, 
it is set to an empty string.
S_path
Stores the full path to the file copy. If an error occurred or if the user cancelled, it is set to 
an empty string.
Warning:
The CopyFolder command can destroy data by overwriting another folder and contents!
When overwriting an existing folder on disk, CopyFolder will do so only if permission is 
granted by the user. The default behavior is to display a dialog asking for permission. The user 
can alter this behavior via the Miscellaneous Settings dialog’s Misc category.
If permission is denied, the folder will not be copied and V_Flag will return 1088 (Command 
is disabled) or 1275 (You denied permission to overwrite a folder). Command execution will 
cease unless the /Z flag is specified.

CopyFolder
V-106
If Igor can not determine the location of the destination folder from destFolderStr and pathName, it displays 
a dialog allowing you to specify or create the destination folder.
If you use a full or partial path for either folder, see Path Separators on page III-451 for details on forming 
the path.
Flags
Variables
The CopyFolder operation returns information in the following variables:
/D
Interprets destFolderStr as the name of (or path to) an existing folder (or directory) to 
copy the source folder into. Without /D, destFolderStr is interpreted as the name of (or 
path to) the copied folder.
If destFolderStr is not a full path to a folder, it is relative to the folder associated with 
pathName.
/I [=i]
/M=messageStr
Specifies the prompt message in the Select (source) Folder dialog. If /S is not used, then 
messageStr will be used for the Select Folder dialog and for the Create Folder dialog.
/O
Overwrite existing destination folder, if any.
On Macintosh, a Macintosh-style overwrite-move is performed in which the source 
folder completely replaces the destination folder.
On Windows, a Windows-style mix-in move is performed in which the contents of the 
source folder are moved into the destination folder, replacing any same-named files 
but leaving other files in place.
/P=pathName
Specifies the folder to look in for the source folder. pathName is the name of an existing 
symbolic path.
If srcFolderStr is not specified, the folder associated with pathName is copied.
Using /P means that srcFolderStr (if specified) and destFolderStr must be either simple 
folder names or paths relative to the folder specified by pathName.
/S=saveMessageStr
Specifies the prompt message in the Create Folder dialog.
/Z [=z]
V_flag
Set to zero if the folder was copied, to -1 if the user cancelled either the Select Folder or 
Create Folder dialogs, and to some nonzero value if an error occurred, such as the 
specified file does not exist.
S_fileName
Stores the full path to the folder that was copied, with a trailing colon. If an error occurred 
or if the user cancelled, it is set to an empty string.
S_path
Stores the full path to the folder copy, with a trailing colon. If an error occurred or if the 
user cancelled, it is set to an empty string.
Specifies the level of user interactivity.
/I=0:
Interactive only if the source or destination folder is not specified or 
if the source folder is missing. (Same as if /I was not specified.)
/I=1:
Interactive even if the source folder is specified and it exists.
/I=2:
Interactive even if destFolderStr is specified.
/I=3:
Interactive even if the source folder is specified, the source folder 
exists, and destFolderStr is specified. Same as /I only.
Prevents procedure execution from aborting if it attempts to copy a file that does 
not exist. Use /Z if you want to handle this case in your procedures rather than 
aborting execution.
/Z=0:
Same as no /Z.
/Z=1:
Copies a folder only if it exists. /Z alone has the same effect as /Z=1.
/Z=2:
Copies a folder if it exists or displays a dialog if it does not exist.
