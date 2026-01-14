# Global Procedure Files

Chapter III-13 — Procedure Windows
III-399
If you have more than one procedure window, you can cycle to the next procedure window by pressing 
Command-Option-M (Macintosh) or Ctrl+Alt+M (Windows). Pressing Command-Shift-Option-M (Macin-
tosh) or Ctrl+Shift+Alt+M (Windows) hides the active procedure window and shows the next one.
You can also show a procedure window by choosing a menu item added by that window while pressing 
Option (Macintosh) or Alt (Windows). This feature works only if the top window is a procedure window.
You can show all procedure windows and hide all procedure windows using the WindowsShow and 
WindowsHide submenus.
Hiding and Killing Procedure Windows
The built-in procedure window always exists as part of the current experiment. You can hide it by clicking 
the close button, pressing Command-W (Macintosh) or Ctrl+W (Windows) or by choosing Hide from the 
Windows menu. You can not kill it.
Auxiliary procedure files can be opened (added to the experiment), hidden and killed (removed from the 
experiment). This leads to a difference in behavior between auxiliary procedure windows and the built-in 
procedure window.
When you click the close button of an auxiliary procedure file, Igor presents the Close Procedure Window 
dialog to find out what you want to do.
If you just want to hide the window, you can press Shift while clicking the close button. This skips the dialog 
and just hides the window.
Killing a procedure window closes the window and removes it from the current experiment but does not 
delete or otherwise affect the procedure file with which the window was associated. If you have made 
changes or the procedure was not previously saved, you will be presented with the choice of saving the file 
before killing the procedure.
The Close item of the Windows menu and the equivalent, Command-W (Macintosh) or Ctrl+W (Windows), 
behave the same as the close button.
Saving All Standalone Procedure Files
When a procedure window is active, you can save all modified standalone procedure files at once by choos-
ing FileSave All Standalone Procedure Files. This saves only standalone procedure files. It does not save 
the built-in procedure window, packed procedure files, or procedure windows that were just created and 
never saved to disk; these are saved when you save the experiment.
Autosaving Standalone Procedure Files
Igor can automatically save modified standalone procedure files. See Autosave on page II-36 for details.
Global Procedure Files
Global procedure files contain procedures that you want to be available in all experiments. They differ from 
other procedure files in that Igor opens them automatically and never closes them. Configuring a procedure 
file as a global procedure file is the easiest way to make it widely available.
When Igor starts running, it searches "Igor Pro Folder/Igor Procedures" and "Igor Pro User Files/Igor Proce-
dures" (see Igor Pro User Files on page II-31 for details), as well as files and folders referenced by aliases or 
shortcuts. Igor opens any procedure file that it finds during this search as a global procedure file.
You should save your global procedure files in "Igor Pro User Files/Igor Procedures". You can locate this 
folder by choosing HelpShow Igor Pro User Files.
