# Experiment Recreation Procedures

Chapter II-3 — Experiments, Files and Folders
II-26
Saving All Standalone Files
Programmers may sometimes edit multiple procedure files while working on a given task. You can save all 
modified standalone procedure files in one step by choosing FileSave All Standalone Procedure Files. 
This saves standalone procedure files only, not packed procedure files including the built-in procedure 
window or new procedure windows that have not yet been saved to a file. The Save All Standalone Proce-
dure Files menu item is available only when the active window is a procedure window.
Likewise you can save all modified notebook windows in one step by choosing FileSave All Standalone 
Notebook Files. This saves standalone notebook files only, not packed notebook files or new notebook 
windows that have not yet been saved to a file. The Save All Notebook Procedure Files menu item is avail-
able only when the active window is a notebook window.
How Experiments Are Loaded
It is not essential to know how Igor stores your experiment or how Igor recreates it. However, understand-
ing this may help you avoid some pitfalls and increase your overall understanding of Igor.
Experiment Recreation Procedures
When you save an experiment, Igor creates procedures and commands, called “experiment recreation pro-
cedures” that Igor will execute the next time you open the experiment. These procedures are normally not 
visible to you. They are stored in the experiment file.
The experiment file of an unpacked experiment contains plain text, but its extension is not “.txt”, so you 
can’t open it with most word processors or editors.
As an example, let’s look at the experiment recreation procedures for a very simple unpacked experiment:
// Platform=Macintosh, IGORVersion=8.000, ...
// Creates the home symbolic path
NewPath home ":Unpacked Experiment Folder:"
// Reads the experiment variables from the "variables" file
ReadVariables
// Loads the experiment's waves
LoadWave/C /P=home "wave0.ibw"
LoadWave/C /P=home "wave1.ibw"
LoadWave/C /P=home "wave2.ibw"
DefaultFont "Helvetica"
MoveWindow/P 5,62,505,335
// Positions the procedure window
MoveWindow/C 2,791,1278,1018
// Positions the command window
Graph0()
// Recreates the Graph0 window
// Graph recreation macro for Graph0
Window Graph0() : Graph
PauseUpdate; Silent 1
// building window...
Display /W=(35,44,430,252) wave0,wave1,wave2
EndMacro
When you open the experiment, Igor reads the experiment recreation procedures from the experiment file into 
the procedure window and executes them. The procedures recreate all of the objects and windows that con-
stitute the experiment. Then the experiment recreation procedures are removed from the procedure window 
and your own procedures are loaded from the experiment’s procedure file into the procedure window.
