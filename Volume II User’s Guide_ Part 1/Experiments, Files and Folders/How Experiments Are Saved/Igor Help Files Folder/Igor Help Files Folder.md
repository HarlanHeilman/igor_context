# Igor Help Files Folder

Chapter II-3 — Experiments, Files and Folders
II-31
Igor Help Files
Igor Extensions
Igor Extensions (64-bit)
Igor Procedures
User Procedures
WaveMetrics Procedures
The Igor installer puts files in the special folders. Igor searches them when looking for help files, extensions 
and procedure files. With very rare exceptions, you should not make any changes to the Igor Pro Folder.
Igor Pro User Files
At launch time, Igor creates a special folder called the Igor Pro User Files folder. By default, this folder has 
the Igor Pro major version number in its name, for example, "Igor Pro 9 User Files", but it is generically 
called the "Igor Pro User Files" folder.
On Macintosh, the Igor Pro User Files folder is created by default in:
/Users/<user>/Documents/WaveMetrics
On Windows it is created by default in:
C:\Users\<user>\Documents\WaveMetrics
You can change the location of your Igor Pro User Files folder using MiscMiscellaneous Settings but this 
should rarely be necessary.
The Igor Pro User Files folder looks like this:
You can activate additional help files, extensions and procedure files that are part of the Igor Pro installa-
tion, that you create, or that you receive from third parties. To do this, add files, or aliases/shortcuts pointing 
to files, to the special subfolders within the Igor Pro User Files folder. See Activating WaveMetrics Proce-
dure Files on page II-33 Activating WaveMetrics XOPs on page II-33 for details on activating additional 
WaveMetrics files.
You can display the Igor Pro User Files folder on the desktop by choosing HelpShow Igor Pro User Files. 
To display both the Igor Pro Folder and the Igor Pro User Files folder, which you typically want to do to 
activate a WaveMerics XOP or procedure file, press the shift key and choose HelpShow Igor Pro Folder 
and User Files.
Igor Help Files Folder
When Igor starts up, it opens any Igor help files in "Igor Pro Folder/Igor Help Files" and in "Igor Pro User 
Files/Igor Help Files". It treats any aliases, shortcuts and subfolders in "Igor Help Files" in the same way.
Standard WaveMetrics help files are pre-installed in "Igor Pro Folder/Igor Help Files".
If there is an additional help file that you want Igor to automatically open at launch time, put it or an 
alias/shortcut for it in "Igor Pro User Files/Igor Help Files".
