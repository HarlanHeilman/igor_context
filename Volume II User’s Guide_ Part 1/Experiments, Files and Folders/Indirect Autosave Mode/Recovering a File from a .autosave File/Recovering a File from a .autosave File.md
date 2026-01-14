# Recovering a File from a .autosave File

Chapter II-3 — Experiments, Files and Folders
II-40
Now assume that you are editing a standalone procedure window that you previously saved to a file 
named "Proc0.ipf".
Every two minutes, Igor checks to see if there are autosaveable files that have been modified since the pre-
vious autosave. This check is performed when Igor is idling and not while procedures are running or if a 
modal dialog is displayed. If you have modified "Proc0.ipf" since the last autosave, Igor autosaves the file 
by writing its current contents to a file named "Proc0.ipf.autosave".
When you save "Proc0.ipf", close it without saving, or revert it, Igor deletes the corresponding 
"Proc0.ipf.autosave" file if it exists.
Recovering a File from a .autosave File 
If Igor crashes or some other catastrophe occurs and Igor's indirect autosave routine executed before Igor 
was terminated, you will be left with the original file, "Proc0.ipf", and the .autosave file, 
"Proc0.ipf.autosave". If you attempt to open the original file, either manually or programmatically, Igor dis-
plays a dialog that looks like this:
NOTE: We recommend that you back up the original and autosave files before proceeding.
We recommend backing up in case you inadvertenly choose to open the wrong file.
If you click Cancel
The open operation is canceled and the original and autosave files are left unchanged.
If you click Open Original File
Igor opens the original file (e.g., "Proc0.ipf").
Igor then moves the autosave file (e.g., "Proc0.ipf.autosave") to the trash (Macintosh) or recycle bin (Win-
dows). However, if the autosave file is open in Igor, it is not moved to the trash but may be overwritten by 
a subsequent autosave.
