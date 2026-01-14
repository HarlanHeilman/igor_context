# WaveMetrics Procedures Folder

Chapter II-3 — Experiments, Files and Folders
II-32
Igor Extensions Folder
An Igor extension, also called an XOP (“external operation”), is a plug-in that adds functionality to Igor. 
WaveMetrics provides some extensions with Igor. Igor users and third parties can also create extensions. 
See Igor Extensions on page III-511 for details.
Igor extensions come in 32-bit and 64-bit versions. 32-bit extensions can run only with IGOR32 (the 32-bit 
version of Igor) and 64-bit extensions can run only with IGOR64 (the 64-bit version of Igor). As noted under 
Igor 32-bit and 64-bit Versions on page I-2, both IGOR32 and IGOR64 are installed on Windows but only 
IGOR64 is available on Macintosh.
When IGOR32 starts up, it searches "Igor Pro Folder/Igor Extensions" and "Igor Pro User Files/Igor Exten-
sions" for 32-bit Igor extension files. These extensions are available for use in IGOR32. It treats any aliases, 
shortcuts and subfolders in "Igor Extensions" in the same way.
When IGOR64 starts up, it searches "Igor Pro Folder/Igor Extensions (64-bit)" and "Igor Pro User Files/Igor 
Extensions (64-bit)" for 64-bit Igor extension files. These extensions are available for use in IGOR64. It treats 
any aliases, shortcuts and subfolders in "Igor Extensions (64-bit)" in the same way.
Standard WaveMetrics extensions are pre-installed in "Igor Pro Folder/Igor Extensions" and "Igor Pro 
Folder/Igor Extensions (64-bit)".
Additional WaveMetrics extensions are described in the "XOP Index" help file, which you can access 
through the HelpHelp Windows menu, and can be found in "Igor Pro Folder/More Extensions" and "Igor 
Pro Folder/More Extensions (64-bit)".
If there is an additional extension that you want to use, put it or an alias/shortcut pointing to it in "Igor Pro 
User Files/Igor Extensions" or "Igor Pro User Files/Igor Extensions (64-bit)".
Igor Procedures Folder
When Igor starts up, it automatically opens any procedure files in "Igor Pro Folder/Igor Procedures" and in 
"Igor Pro User Files/Igor Procedures". It treats any aliases, shortcuts and subfolders in "Igor Procedures" in 
the same way. Such procedure files are called "global" procedure files and are available for use from all 
experiments. See Global Procedure Files on page III-399 for details.
Standard WaveMetrics global procedure files are pre-installed in "Igor Pro Folder/Igor Procedures".
Additional WaveMetrics procedure files are described in the "WM Procedures Index" help file and can be 
found in "Igor Pro Folder/WaveMetrics Procedures". You may also create your own global procedure files 
or obtain them from third parties.
If there is an additional procedure file that you want Igor to automatically open at launch time, put it or an 
alias/shortcut pointing to it in "Igor Pro User Files/Igor Procedures".
User Procedures Folder
You can load a procedure file from another procedure file using a #include statement. This technique is 
used when one procedure file requires another. See Including a Procedure File on page III-401 for details.
When Igor encounters a #include statement, it searches for the included procedure file in "Igor Pro-
Folder/User Procedures" and in "Igor Pro User Files/User Procedures". Any aliases, shortcuts and subfold-
ers in "User Procedures" are treated the same way.
If there is an additional procedure file that you want to include from your procedure files, put it or an 
alias/shortcut pointing to it in "Igor Pro User Files/User Procedures".
WaveMetrics Procedures Folder
The "Igor Pro Folder/WaveMetrics Procedures" folder contains an assortment of procedure files created by 
WaveMetrics that may be of use to you. These files are described in the WM Procedures Index help file 
which you can access through the HelpHelp Windows menu.
