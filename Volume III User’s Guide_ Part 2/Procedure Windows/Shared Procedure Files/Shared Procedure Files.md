# Shared Procedure Files

Chapter III-13 — Procedure Windows
III-400
Igor opens global procedure files with write-protection on since they presumably contain procedures that you 
have already debugged and which you don’t want to inadvertently modify. If you do want to modify a global 
procedure file, click the write-protect icon (pencil in lower-left corner of the window). You can turn this 
default write-protection off via the Text Encoding section of the Miscellaneous Settings dialog.
When you create a new experiment or open an existing one, Igor normally closes any open procedure files, 
but it leaves global procedure files open. You can explicitly close a global procedure window at any time and 
then you can manually reopen it. Igor will not automatically reopen it until the next time Igor is launched.
Although its procedures can be used by the current experiment, a global procedure file is not part of the 
current experiment. Therefore, Igor does not save a global procedure file or a reference to a global proce-
dure file inside an experiment file.
Note:
There is a risk in using global procedure files. If you copy an experiment that relies on a global 
procedure file to another computer and forget to also copy the global procedure file, the 
experiment will not work on the other computer.
Saving Global Procedure Files
If you modify a global procedure file, Igor will save it when you save the current experiment even though 
the global procedure file is not part of the current experiment. However, you might want to save the pro-
cedure file without saving the experiment. For this, use the FileSave Procedure menu item.
Shared Procedure Files
You may develop procedures that you want to use in several but not all of your experiments. You can facil-
itate this by creating a shared procedure file. This is a procedure file that you save in its own file, separate 
from any experiment. Such a file can be opened from any experiment.
There are two ways to open a shared procedure file from an experiment:
•
By explicitly opening it, using the FileOpen File submenu or by double-clicking it or by drag-and-
drop
•
By adding an include statement to your experiment procedure window
The include method is preferred and is described in detail under Including a Procedure File on page 
III-401.
When Igor encounters an include statement, it searches for the included file in "Igor Pro Folder/User Proce-
dures" and in "Igor Pro User Files/User Procedures" (see Igor Pro User Files on page II-31 for details). The 
Igor Pro User Files folder is the recommended place for storing user files. You can locate it by choosing 
HelpShow Igor Pro User Files.
You can store your shared procedure procedure file directly in "Igor Pro User Files/User Procedures" or you 
can store it elsewhere and put an alias (Macintosh) or shortcut (Windows) for it in "Igor Pro User Files/User 
Procedures". If you have many shared procedure files you can put them all in your own folder and put an 
alias/shortcut for the folder in "Igor Pro User Files/User Procedures".
When you explicitly open a procedure file using the Open File submenu, by double-clicking it, or by drag-
and-drop, you are adding it to the current experiment. When you save the experiment, Igor saves a reference 
to the procedure file in the experiment file. When you close the experiment, Igor closes the procedure file. 
When you later reopen the experiment, Igor reopens the procedure file.
When you use an include statement, the included file is not considered part of the experiment but is still 
referenced by the experiment. Igor automatically opens the included file when it hits the include statement 
during procedure compilation.
Note:
There is a risk in sharing procedure files among experiments. If you copy the experiment to 
another computer and forget to also copy the shared files, the experiment will not work on the 
other computer. See References to Files and Folders on page II-24 for more explanation.
