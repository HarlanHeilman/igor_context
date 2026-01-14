# How Igor Handles Missing Folders

Chapter II-3 — Experiments, Files and Folders
II-28
You have three options at this point, as explained in the following table.
With the first two options, Igor leaves the experiment untitled so that you don’t inadvertently wipe out the 
original experiment file by doing a save.
How Igor Handles Missing Folders
When Igor saves an experiment, it stores commands in the experiment file that will recreate the experi-
ment’s symbolic paths when you reopen the experiment. The commands look something like this:
NewPath home ":Test Exp Folder:"
NewPath/Z Data1 "::Data Folder #1:"
NewPath Data2 "::Data Folder #2:"
NewPath/Z Data3 "hd:Test Runs:Data Folder #3:"
// Macintosh
NewPath/Z Data3 "C:Test Runs:Data Folder #3:"
// Windows
The location of the home folder is specified relative to the folder containing the experiment file. The loca-
tions of all other folders are specified relative to the experiment folder or, if they are on a different volume, 
using absolute paths. Using relative paths, where possible, ensures that no problems will arise if you move 
the experiment file and experiment folder together to another disk drive or another location on the same disk 
drive.
The /Z flags indicate that the experiment does not need to load any files from the Data1 and Data3 folders. 
In other words, the experiment has symbolic paths for these folders but no files need to be loaded from them 
to recreate the experiment.
When you reopen the experiment, Igor executes these NewPath commands. If you have moved or renamed 
folders, or if you have moved the experiment file, the NewPath operation will be unable to find the folder.
If the folder associated with the symbolic path is not needed to recreate the experiment, the NewPath 
command includes the /Z flag. In this case, Igor skips the creation of the symbolic path, generates no error, 
and just continues the load. The experiment will wind up without the missing symbolic path.
If the missing folder is needed to load waves, notebooks or procedure files then Igor asks if you want to look for 
the folder by displaying the Missing Folder dialog.
If you click Look for Folder, Igor presents a Choose Folder dialog in which you can locate the missing folder.
Option
Effect
Quit Macro
Stops executing the current macro but continues experiment load. In this 
example, Graph0 would not be recreated. After the experiment load Igor dis-
plays diagnostic information.
Abort Experiment Load
Aborts the experiment load immediately and displays diagnostic information.
Retry
In this example, you could fix the macro by deleting “wave0,”. You would 
then click the Retry button. Igor would create Graph0 without wave0 and 
would continue the experiment load.
