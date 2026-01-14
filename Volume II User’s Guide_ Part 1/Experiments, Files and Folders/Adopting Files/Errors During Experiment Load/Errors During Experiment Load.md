# Errors During Experiment Load

Chapter II-3 — Experiments, Files and Folders
II-27
For a packed experiment, the process is the same except that all of the data, including the experiment rec-
reation procedures, is packed into the experiment file.
Experiment Initialization Commands
After executing the experiment recreation procedures and loading your procedures into the procedure window, 
Igor checks the contents of the procedure window. Any commands that precede the first macro, function or 
menu declaration are considered initialization commands. If you put any initialization commands in your pro-
cedure window then Igor executes them. This mechanism initializes an experiment when it is first loaded.
Savvy Igor programmers can also define a function that is executed whenever Igor opens any experiment. 
See User-Defined Hook Functions on page IV-280.
Errors During Experiment Load
It is possible for the experiment loading process to fail to run to a normal completion. This occurs most often 
when you move or rename a file or folder. It also happens if you move an experiment to a different com-
puter and forget to also move referenced files or folders. See References to Files and Folders on page II-24 
for details.
When a file is missing, Igor presents a dialog giving you several options:
If you elect to abort the experiment load, Igor will alert you that the experiment is in an inconsistent state. 
It displays some diagnostic information that might help you understand the problem and changes the 
experiment to Untitled. You should choose New Experiment or Open Experiment from the File menu to 
clear out the partially loaded experiment.
If you elect to skip loading a wave file, you may get another error later, when Igor tries to display the wave 
in a graph or table. In that case, you will see a dialog like this:
In this example, Igor is executing the Graph0 macro from the experiment recreation procedures in an 
attempt to recreate a graph. Since you elected to skip loading wave0, Igor can’t display it.
