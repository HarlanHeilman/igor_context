# Autosave

Chapter II-3 — Experiments, Files and Folders
II-36
mode can be 0 (default) for no special action. Igor attempts to read all the records.
If mode is 1, then any waves with data size exceeding bytes are silently skipped.
If mode is 2, then any waves with data size exceeding bytes are downgraded to a smaller size and only that 
portion of the data is loaded. Such partial waves are marked as locked and bit 1 of the lock flag is also set. 
In addition, the wave note contains the text "**PARTIAL LOAD**" and a warning dialog is presented after 
the experiment loads.
The default value for bytes is 500E6 in IGOR32.
Autosave
Igor can autosave files while you work. This is of use in the event that Igor crashes or some other catastro-
phe occurs before you save.
If your habit is to save anytime you have made non-trivial changes that you want to keep then you don't 
need autosave. If your habit is to do a significant amount of work without saving, which is inherently risky, 
then autosave may prevent loss of work in the event of a crash.
Autosave is not foolproof and can cause confusing and unpredictable behavior if multiple users modify the 
same file or if you modify a file in multiple instance of Igor. For these and other reasons, you should con-
sider autosave a last resort and always save when you have made progress and back up any work that 
would be painful to lose.
Autosave is turned off by default. You can turn it on and fine-tune how it works by choosing MiscMis-
cellaneous Settings and clicking the Autosave icon in the lefthand list to display the Autosave pane of the 
Miscellaneous Settings dialog. The heart of it looks like this:
You turn autosave on by checking the Run Autosave checkbox. If turned on, autosave runs at the interval 
in minutes that you specify. Autosave runs when Igor is idling and not while procedures are running or if 
a modal dialog is displayed.
Alternatives to automatically autosaving include:
•
Manually saving by choosing FileSave Experiment when you know the experiment is in good 
shape
•
Running autosave manually when you know the experiment is in good shape by choosing 
FileRun Autosave Now
•
Manually saving modified procedure files only using FileSave All Standalone Procedure Files
Igor can display information in its status bar showing the status of autosave. You can turn the autosave 
information on or off using the Show Status checkbox in the autosave pane of the Miscellaneous Settings 
dialog or by right-clicking the status bar. If autosave is enabled, the status bar information shows the time 
of the next autosave run. “Run” means “check if there are any files to be autosaved and autosave them if 
so.”
