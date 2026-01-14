# History Area

Chapter II-2 — The Command Window
II-9
10. Press Command-K (Macintosh) or Ctrl+K (Windows).
This “kills” the contents of the command line.
Now let’s see how you can quickly reexecute a previously executed command.
11. With Command and Option (Macintosh) or Ctrl and Alt (Windows) pressed, click the second-to-last 
command in the history.
This reexecutes the clicked command (the 2*PI command).
Repeat this step a number of times, clicking the second-to-last command each time. This will alternate 
between the 2*PI command and the 4*PI command.
12. Execute
WaveStats wave0
Note that the WaveStats operation has printed its results in the history where you can review them. You 
can also copy a number from the history to paste into a notebook or an annotation.
There is a summary of all command window shortcuts at the end of this chapter.
The Command Buffer
The command line shows the contents of the command buffer.
Normally the command buffer is either empty or contains just one line of text. However you can copy mul-
tiple lines of text from any window and paste them in the command buffer and you can enter multiple lines 
by pressing Shift-Return or Shift-Enter to enter a line break. You can drag the red divider line up to show 
more lines or down to show fewer lines.
You can clear the contents of the command buffer by choosing the Clear Command Buffer item in the Edit 
menu or by pressing Command-K (Macintosh) or Ctrl+K (Windows).
When you invoke an operation from a typical Igor dialog, the dialog puts a command in the command buffer 
and executes it. The command is then transferred to the history as if you had entered the command manually.
If an error occurs during the execution of a command, Igor leaves it in the command buffer so you can edit 
and reexecute it. If you don’t want to fix the command, you should remove it from the command buffer by 
pressing Command-K (Macintosh) or Ctrl+K (Windows).
Because the command buffer usually contains nothing or one command, we usually think of it as a single 
line and use the term “command line”.
Command Window Title
The title of the command window is the name of the experiment that is currently loaded. When you first 
start Igor or if you choose New from the File menu, the title of the experiment and therefore of the command 
window is “Untitled”.
When you save the experiment to a file, Igor sets the name of the experiment to the file name minus the file 
extension. If the file name is “An Experiment.pxp”, the experiment name is “An Experiment”. Igor displays 
“An Experiment” as the command window title.
For use in procedures, the IgorInfo(1) function returns the name of the current experiment.
History Area
The history area is a repository for commands and results.
Text in the history area can not be edited but can be copied to the clipboard or to the command line. Copying 
text to the clipboard is done in the normal manner. To copy a command from the history to the command 
buffer, select the command in the history and press Return or Enter. An alternate method is to press Option 
(Macintosh) or Alt (Windows) and click in the history area.
