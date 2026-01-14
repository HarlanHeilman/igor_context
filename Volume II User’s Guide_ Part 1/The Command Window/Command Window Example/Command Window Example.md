# Command Window Example

Chapter II-2 — The Command Window
II-8
Overview
You can control Igor using menus and dialogs or using commands that you execute from the command 
window. Some actions, for example waveform assignments, are much easier to perform by entering a com-
mand. Commands are also convenient for trying variations on a theme — you can modify and reexecute a 
command very quickly. If you use Igor regularly, you may find yourself using commands more and more 
for those operations that you frequently perform.
In addition to executing commands in the Command window, you can also execute commands in a note-
book, procedure or help window. These techniques are less commonly used than the command window. 
See Notebooks as Worksheets on page III-4 for more information.
This chapter describes the command window and general techniques and shortcuts. See Chapter IV-1, 
Working with Commands, for details on command usage and syntax.
The command window consists of a command line and a history area. When you enter commands in the 
command line and press Return (Macintosh) or Enter (Windows and Macintosh), the commands are executed. 
Then they are saved in the history area for you to review. If a command produces text output, that output 
is also saved in the history area. A bullet character is prepended to command lines in the history so that you 
can easily distinguish command lines from output lines.
The Command window includes a help button just below the History area scroll bar. Clicking the button dis-
plays the Help Browser window.
The total length of a command on the command line is limited to 2500 bytes. A command executed in the 
command line must fit in one line.
Command Window Example
Here is a quick example designed to illustrate the power of commands and some of the shortcuts that make 
working with commands easy.
1.
Choose New Experiment from the File menu.
2.
Execute the following command by typing in the command line and then pressing Return or Enter.
Make/N=100 wave0; Display wave0
This displays a graph.
3.
Press Command-J (Macintosh) or Ctrl+J (Windows).
This activates the command window.
4.
Execute
SetScale x, 0, 2*PI, wave0; wave0 = sin(x)
The graph shows the sine of x from 0 to 2.
Now we are going to see how to quickly retrieve, modify and reexecute a command.
5.
Press the Up Arrow key.
This selects the command that we just executed.
6.
Press Return or Enter.
This transfers the selection back into the command line.
7.
Change the “2” to “4”.
The command line should now contain:
SetScale x, 0, 4*PI, wave0; wave0 = sin(x)
8.
Press Return or Enter to execute the modified command.
This shows the sine of x from 0 to 4.
9.
While pressing Option (Macintosh) or Alt (Windows), click the last command in the history.
This is another way to transfer a command from the history to the command line. The command line 
should now contain:
SetScale x, 0, 4*PI, wave0; wave0 = sin(x)
