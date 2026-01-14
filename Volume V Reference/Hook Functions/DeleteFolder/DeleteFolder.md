# DeleteFolder

DeleteFolder
V-156
DeleteFolder 
DeleteFolder [flags] [folderNameStr]
The DeleteFolder operation deletes a disk folder and all of its contents.
Parameters
folderNameStr can be a full path to the folder to be deleted, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a folder within the folder associated with pathName.
If Igor can not determine the location of the folder from folderNameStr and pathName, it displays a Select 
Folder dialog allowing you to specify the folder to be deleted.
If /P=pathName is given, but folderNameStr is not, then the folder associated with pathName is deleted.
If you use a full or partial path for either folder, see Path Separators on page III-451 for details on forming 
the path.
Folder paths should not end with single Path Separators. See the MoveFolder Details section.
Flags
Variables
The DeleteFolder operation returns information in the following variables:
Details
You can use only /P=pathName (without folderNameStr) to specify the source folder to be deleted.
Folder paths should not end with single Path Separators. See the Details section for MoveFolder.
See Also
The DeleteFile, MoveFolder, CopyFolder, NewPath, and IndexedDir operations. Symbolic Paths on page 
II-22.
Warning:
The DeleteFolder command destroys data! The deleted folder and the contents are not moved 
to the Trash or Recycle Bin.
DeleteFolder will delete a folder only if permission is granted by the user. The default 
behavior is to display a dialog asking for permission. The user can alter this behavior via 
the Miscellaneous Settings dialog’s Misc category.
If permission is denied, the folder will not be deleted and V_Flag will return 1088 
(Command is disabled) or 1276 (You denied permission to delete a folder). Command 
execution will cease unless the /Z flag is specified.
/I
Interactive mode displays a Select Folder dialog even if folderNameStr is specified and 
the folder exists.
/M=messageStr
Specifies the prompt message for the Select Folder dialog.
/P=pathName
Specifies the folder to look in for the folder. pathName is the name of an existing 
symbolic path.
/Z[=z]
V_flag
Set to zero if the folder was deleted, to -1 if the user cancelled the Select Folder dialog, 
and to some nonzero value if an error occurred, such as the specified folder does not 
exist.
S_path
Stores the full path to the folder that was deleted, with a trailing colon. If an error 
occurred or if the user cancelled, it is set to an empty string.
Prevents procedure execution from aborting if it attempts to delete a folder that does 
not exist. Use /Z if you want to handle this case in your procedures rather than 
having execution abort.
/Z=0:
Same as no /Z.
/Z=1:
Deletes a folder only if it exists. /Z alone has the same effect as /Z=1.
/Z=2:
Deletes a folder if it exists or displays a dialog if it does not exist.
