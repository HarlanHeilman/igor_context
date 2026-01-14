# Autosave Is Not A Substitute for Manual Saving or for Backing Up

Chapter II-3 — Experiments, Files and Folders
II-37
Modifying the same file in different instances of Igor while autosave is on will cause confusing and unpre-
dictable behavior.
Igor programmers can query autosave settings using IgorInfo(13).
What Autosave Saves
Depending on the settings you choose, autosave can save the following types of files:
•
Entire experiment files
•
Standalone procedure files
•
Standalone notebook files
In the sections below, we refer to the types of files you have chosen to autosave as "autosaveable files".
Autosave does not work on the following:
•
Files that you have not yet saved to disk
This includes experiment files, procedure files and notebook files that you have created but not yet 
saved to disk
•
Unpacked experiment files (.uxp) in indirect mode
•
Copies of procedure files #included into independent modules
Such files should not be modified. See Independent Modules and #include on page IV-240 for 
details.
Autosave saves the following items only for packed experiments (.pxp and .h5xp) and only if the Autosave 
Entire Experiment checkbox is checked:
•
The built-in procedure window
•
Packed procedure files
•
Packed notebook files
•
Graphs, tables, page layouts, Gizmo plots, control panels and other windows
•
Data folders and waves
Autosave Is Not A Substitute for Manual Saving or for Backing Up
The purpose of autosave is to increase the chance that you can recover work if Igor or your machine crashes 
or there is a power failure. Relying on autosave as a substitute for frequent saving backing up is courting 
disaster.
Depending on the autosave settings you choose, autosave may save at the wrong time (for example, just 
after you made a mistake) or may not save all of your work (see What Autosave Saves on page II-37).
A crash or other disaster may occur after you have made important changes but before autosave automat-
ically runs.
You may realize that the work you saved today is wrong and you need to go back to yesterday's version of 
a file.
Your computer may fail catastrophically.
Your computer may be attacked by malware.
Your computer may be stolen.
Your computer may be damaged by fire, natural disaster, or some other mishap.
For these and other reasons, you should always save when you have made progress and back up any 
work that would be painful to lose. You should back up locally and also remotely for the case where your 
computer is destroyed or stolen.
