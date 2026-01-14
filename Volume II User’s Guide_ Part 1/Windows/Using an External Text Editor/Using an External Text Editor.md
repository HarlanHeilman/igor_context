# Using an External Text Editor

Chapter II-4 — Windows
II-56
You can limit the replacement by selecting a subset of the found text items and clicking the Replace Selected 
button. Click a found text item to select it. Shift-click another item to select all items between that item and 
the one previously clicked. To select non-contiguous items, Command-click (Macintosh) or Ctrl-click (Win-
dows). You can also click and drag over multiple items. It is still a good idea to save before replacing.
Home Versus Shared Text Files
A text file that is stored in a packed experiment file, or in the experiment folder for an unpacked experiment, 
is a "home" text file. Otherwise it is a "shared" text file.
Home text files are typically intended for use by their owning experiment only. Shared text files are typi-
cally intended for use by by multiple experiments.
When you create a text file in a packed experiment, it saved by default in the packed experiment file and is 
a home text file. It becomes a shared text file only if you explicitly save it to a standalone file.
When you create a text file in an unpacked experiment, it saved by default in the experiment folder and is 
a home text file. It becomes a shared text file only if you explicitly save it to a standalone file outside of its 
experiment folder.
When you save a packed experiment as unpacked, home text files are stored in the experiment folder.
When you save an unpacked experiment as packed, home text files are saved in the packed experiment file.
You can use the File Information dialog, which you access by choosing ProcedureInfo or NotebookInfo, 
to determine if a text file is shared. For shared text files, the dialog says "This file is stored separate from the 
experiment file" for packed and unpacked experiments. For home text, the dialog says "This file is stored in 
packed form in the experiment file" for packed experiments and "This file is in the experiment folder" for 
unpacked experiments. 
You can convert a shared text file to a home text file by adopting it. See Adopting Notebook and Procedure 
Files on page II-25 for details.
Using an External Text Editor
Igor supports the use of external editors for editing Igor procedure files and plain text notebooks. This 
allows you to use your favorite text editor rather than Igor for editing plain text files if you prefer. This is 
mostly intended for use by advanced programmers who are accustomed to using external editors in other 
programming environments.
Prior to Igor7, Igor kept plain text files open as long as the corresponding procedure or notebook window 
was open in Igor. This interfered with the use of external editors.
Now a procedure or plain text notebook window opens its file just long enough to read the text into 
memory and then close it. If you modify the text in Igor and do a save, Igor reopens the file, writes the mod-
ified text to it, and closes the file.
If you modify the file using an external text editor instead of Igor, Igor notices the change, reopens the file, 
reloads the modified text into memory, and closes the file.
Supporting external editors creates issues that Igor must deal with:
•
If you modify the file in an external editor, the text is now out of sync with the text in Igor's window. 
In this case, Igor notices that the file has been changed and either reloads the text into memory or 
notifies you, depending on your external editor miscellaneous settings.
•
If you save modifications to the file in an external editor and also edit the document in Igor, the text 
in Igor is in conflict with the external file. In this case Igor informs you of the conflict and lets you 
choose which version to keep.
•
If you move the disk file to new location, delete the file or rename it, Igor's information about the
