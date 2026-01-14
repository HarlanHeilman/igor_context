# Working with the Built-in Procedure Window

Chapter III-13 — Procedure Windows
III-396
Overview
This chapter explains what procedure windows are, how they are created and organized, and how you work 
with them. It does not cover programming. See Chapter IV-2, Programming Overview for an introduction.
A procedure window is where Igor procedures are stored. Igor procedures are the macros, functions and 
menu definitions that you create or that Igor creates automatically for you.
The content of a procedure window is stored in a procedure file. In the case of a packed Igor experiment, 
the procedure file is packed into the experiment file.
Types of Procedure Files
There are four types of procedure files:
•
The experiment procedure file, displayed in the built-in procedure window
•
Global procedure files, displayed in auxiliary procedure windows
•
Shared procedure files, displayed in auxiliary procedure windows
•
Auxiliary experiment procedure files, displayed in auxiliary procedure windows
The built-in procedure window holds experiment-specific procedures of the currently open experiment. 
This is the only procedure window that beginning or casual Igor users may need.
All other procedure windows are called auxiliary to distinguish them from the built-in procedure window. 
You create an auxiliary procedure window using WindowsNewProcedure. You can then save it to a 
standalone file, using FileSave Procedure As, or allow Igor to save it as part of the current experiment.
A global procedure file contains procedures that you might want to use in any experiment. It must be saved 
as a standalone file in the "Igor Procedures" folder of your Igor Pro User Files folder. Procedure files in "Igor 
Procedures" are automatically opened by Igor at startup and left open until Igor quits. This is the easiest 
way to make procedures available to multiple experiments.
A shared procedure file contains procedures that you want to use in more than one experiment but that you 
don't want to be open all of the time. It must be saved as a standalone file. The recommended location is the 
"User Procedures" folder of your Igor Pro User Files folder.
An auxiliary experiment procedure file contains procedures that you want to use in a single experiment but 
want to keep separate from the built-in procedure window for organizational purposes. In a packed exper-
iment it is saved as a packed file within the experiment file. In an unpacked experiment it is saved as a 
standalone file in the experiment folder.
Working with the Built-in Procedure Window
Procedures that are specific to the current experiment are usually stored in the built-in procedure window. 
Also, when Igor automatically generates procedures, it stores them in the built-in procedure window.
To show the built-in procedure window, choose WindowsProcedure WindowsProcedure Window or 
press Command-M (Macintosh) or Ctrl+M (Windows). To hide it, click the close button or press Command-
W (Macintosh) or Ctrl+W (Windows).
To create a procedure, just type it into the procedure window.
The contents of the built-in procedure window are automatically stored when you save the current Igor 
experiment. For unpacked experiments, the contents are stored in a file called “procedure” in the experi-
ment folder. For packed experiments, the contents are stored in the packed experiment file. When you open 
an experiment Igor loads its procedures back into the built-in procedure window.
