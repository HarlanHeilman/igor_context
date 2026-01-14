# Showing, Hiding and Killing Notebook Windows

Chapter III-1 — Notebooks
III-4
Autosaving Standalone Notebook Files
Igor can automatically save modified standalone notebook files. See Autosave on page II-36 for details.
Notebooks as Worksheets
Normally you enter commands in Igor’s command line and press Return or Enter to execute them. You can 
also enter and execute commands in a notebook window. Some people may find using a notebook as a 
worksheet more convenient than using Igor’s command line.
You can also execute commands from procedure windows and from help windows. The former is some-
times handy during debugging of Igor procedures. The latter provides a quick way for you to execute com-
mands while doing a guided tour or to try example commands that are commonly presented in help files. 
The techniques described in the next paragraphs for executing commands from a notebook also apply to 
procedure and help windows.
To execute a command from a notebook, enter the command in a notebook, or select existing text, and press 
Control-Enter (Macintosh) or Ctrl-Enter (Windows). You can also select text already in the notebook and 
press Control-Enter. You can also right-click selected text and choose Execute Selection from the resulting 
pop-up menu.
When you press Control-Enter, Igor transfers text from the notebook to the command line and starts exe-
cution. Igor stores both the command and any text output that it generates in the notebook and also in the 
history area of the command window. If you don’t want to keep the command output in the notebook, just 
undo it.
Command output is never sent to a procedure window or help window.
Command output is not sent to the notebook if it is open for read only, or if you clicked the write-protect 
icon, or if you disabled it by unchecking the Copy Command Output to the Notebook checkbox in the 
Command Window section of the Miscellaneous Settings dialog.
If you don’t want to store the commands or the output in the history area, you can disable this using the 
Command Window section of the Miscellaneous Settings dialog. However, if command output to the note-
book is disabled, the command and output are sent to the history area even if you have disabled it.
Showing, Hiding and Killing Notebook Windows
Notebook files can be opened (added to the current experiment), hidden, and killed (removed from the 
experiment).
When you click the close button of a notebook window, Igor presents the Close Notebook Window dialog 
to find out what you want to do. You can save and then kill the notebook, kill it without saving, or hide it.
If you just want to hide the window, you can press Shift while clicking the close button. This skips the dialog 
and just hides the window.
Killing a notebook window closes the window and removes it from the current experiment but does not delete 
the notebook file with which the window was associated. If you want to delete the file, do this on the desktop.
The Close item of the Windows menu and the keyboard shortcut, Command-W (Macintosh) or Ctrl+W (Win-
dows), behave the same as the close button, as indicated in these tables. 
Macintosh:
Action
Modifier Key
Result
Click close button, choose Close or press Command-W
None
Displays dialog
Click close button, choose Close or press Command-W
Shift
Hides window
