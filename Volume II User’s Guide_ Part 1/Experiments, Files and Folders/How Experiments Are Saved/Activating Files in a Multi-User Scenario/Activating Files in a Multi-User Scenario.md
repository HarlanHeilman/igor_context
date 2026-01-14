# Activating Files in a Multi-User Scenario

Chapter II-3 — Experiments, Files and Folders
II-33
You can load a WaveMetrics procedure file from another procedure file using a #include statement. See 
Including a Procedure File on page III-401 for details.
There is no WaveMetrics Procedures folder in the Igor Pro User Files folder.
Activating Additional WaveMetrics Files
The following sections explain how to activate additional Igor Pro features.
Activating WaveMetrics Procedure Files
To activate a WaveMetrics-supplied procedure file that you want to be available in all experiments:
1.
Press the shift key and choose HelpShow Igor Pro Folder and User Files. This displays the Igor Pro 
Folder and the Igor Pro User Files folder on the desktop.
2.
Open the WaveMetrics Procedures folder in the Igor Pro Folder and identify the WaveMetrics proce-
dure file that you want to activate.
3.
Make an alias/shortcut for the file and put it in "Igor Pro User Files/Igor Procedures" folder. This causes 
Igor to automatically load the procedure file the next time Igor is launched.
4.
Restart Igor.
The activated procedure file appears in the WindowsProcedure Windows submenu.
Activating WaveMetrics XOPs
To activate a WaveMetrics-supplied XOP (a plug-in also called an "extension") :
1.
Press the shift key and choose HelpShow Igor Pro Folder and User Files. This displays the Igor Pro 
Folder and the Igor Pro User Files folder on the desktop.
2.
Open the "More Extensions (64-bit)" folder in the Igor Pro Folder and identify the XOP that you want 
to activate. (If you are running IGOR32 on Windows, open the "More Extensions" folder.)
3.
Make an alias/shortcut for the XOP file and put it in "Igor Pro User Files/Igor Extensions" folder. This 
causes Igor to automatically load the XOP the next time Igor is launched.
4.
Restart Igor.
The activated XOP adds its operations and/or functions to the Igor Help browser and they are available for 
programmatic use. Some XOPs also add menu items.
Activating Other Files
You may create an Igor package or receive a package from a third party. You should store each package in 
its own folder in the Igor Pro User Files folder or elsewhere, at your discretion. You should not store such 
files in the Igor Pro Folder because it complicates backup and updating.
To activate files from the package, create aliases/shortcuts for the package files and put them in the appro-
priate subfolder of the Igor Pro User Files folder.
If you have a single procedure file or a single Igor extension that you want to activate, you may prefer to 
put it directly in the appropriate subfolder of the Igor Pro User Files folder.
Activating Files in a Multi-User Scenario
Our recommendation is that you activate files using the special subfolders in the Igor Pro User Files folder, 
not in the Igor Pro Folder. An exception to this is the multi-user scenario where multiple users are running 
the same copy of Igor from a server. In this case, if you want to activate a file for all users, put the file or an 
alias/shortcut for it in the appropriate subfolder of the Igor Pro Folder. Users will have to restart Igor for the 
change to take effect.
