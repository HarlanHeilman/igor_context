# Igor Pro Folder

Chapter II-3 — Experiments, Files and Folders
II-30
Experiment Save Errors
There are many reasons why an error may occur during the save of an experiment. For example, you may run 
out of disk space, the server volume you are saving to might be disconnected, or you may have a hardware 
failure, but these are uncommon.
The most common reason for a save error is that you cannot get write access to the file because:
1.
The file is locked (Macintosh Finder) or marked read-only (Windows desktop).
2.
You don't have permission to write to the folder containing the file.
3.
You don't have permission to write to this specific file.
4.
The file has been opened by another application. This could be a virus scanner, an anti-spyware 
program or an indexing program such as Apple's Spotlight.
Here are some troubleshooting techniques.
Macintosh File Troubleshooting
Open the file's Get Info window and verify that the file is not marked as locked. Also check the lock setting of 
the folder containing the file.
Next try doing a Save As to a folder for which you know you have write access, for example, to your home 
folder (e.g., "/Users/<user>" where <user> is your user name). If this works, the problem may be that you did 
not have sufficient permissions to write to the original folder or to the original file. Use the Finder Get Info 
window Sharing and Permissions section to make sure that you have read/write access for the file and folder.
If you are able to save a file to a new location but get an error when you try to resave the file, which overwrites 
the original file, then this may be an issue of another program opening the file at an inopportune time.
Windows File Troubleshooting
Open the file's Properties window and uncheck the read-only checkbox if it is checked. Do the same for the 
folder containing the file.
Next try doing a Save As to a folder for which you know you have write access, for example, to your Docu-
ments folder. If this works, the problem may be that you did not have sufficient permissions to write to the 
original folder or to the original file. This would happen, for example, if the folder was inside the Program 
Files folder and you are not running as an administrator.
If you think you should be able to write to the original file location, you will need to investigate permissions. 
You may want to enlist the help of a local expert as this can get complicated and works differently in different 
versions of Windows.
If you are able to save a file to a new location but get an error when you try to resave the file, which overwrites 
the original file, then this may be an issue of another program opening the file at an inopportune time. This 
typically happens in step 3 of the safe-save technique described above. Try disabling your antivirus software. 
For a technical explanation of this problem, see http://support.microsoft.com/kb/316609.
Special Folders
This section describes special folders that Igor automatically searches when looking for help files, Igor 
extensions (plug-ins that are also called XOPs) and procedure files.
Igor Pro Folder
The Igor Pro folder is the folder containing the Igor application on Macintosh and the IgorBinaries folder on 
Windows. By default, this folder has the Igor Pro major version number in its name, for example, “Igor Pro 
9 Folder”, but it is generically called the “Igor Pro Folder”.
Igor looks inside the Igor Pro Folder for these special subfolders:
