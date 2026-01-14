# Long Object Names With Old Igor Versions

Chapter III-17 — Miscellany
III-503
•
Global picture names
•
Page setup names
•
FIFOs
•
FIFO channels
If you do not create objects with names longer than 31 bytes, wave and experiment files that you create will 
be compatible with earlier versions of Igor. However, if you do create objects with long names, older ver-
sions of Igor will report errors when opening wave and experiment files containing long names.
NOTE:
If you use long names, your wave and experiment files will require Igor Pro 8.00 or later and will 
return errors when opened by earlier versions of Igor.
You can choose FileExperiment Info to determine if the current experiment uses long object names or has 
waves with long dimension labels. You can also use the ExperimentInfo operation programmatically. 
These check only wave, variable, data folder, target window, and symbolic path names, and wave dimen-
sion labels. They do not check axis, annotation, control, procedure or other names.
If you attempt to save an experiment file that uses long wave, variable, data folder, target window or sym-
bolic path names, or that has waves with long dimension labels, Igor displays a warning dialog telling you 
that the experiment will require Igor Pro 8.00 or later. The warning dialog is presented only when you save 
an experiment interactively, not if you save it programmatically using SaveExperiment. You can suppress 
the dialog by clicking the "Do not show this message again" checkbox.
Global picture names (see The Picture Gallery on page III-510) are limited to 31 bytes but names of Proc 
Pictures (Proc Pictures on page IV-56) are not.
Page setup names are used behind the scenes to save a page setup record for each page layout window. The 
experiment file format limits the name of a page setup record to 31 bytes. If a layout window name exceeds 
31 bytes, when you save the experiment, the page setup record for that window is not written to the exper-
iment file. When you reopen the experiment, the layout window receives a default page setup. Since long 
page layout names are rare and page setups affect printing but not the dimensions of the page (see Page 
Layout Page Sizes on page II-478), this issue will have little impact.
An XOP name is the name of the XOP file without the ".xop" extension. In Igor8, XOP names can be up to 
255 bytes. However, if an XOP name exceeds 31 bytes, Igor does not send the SAVESETTINGS message to 
the XOP. Most XOP names are shorter than 31 bytes and most XOPs do not save experiment settings, so this 
is not likely to cause a problem.
Long Object Names With Old Igor Versions
If you use long names, your wave and experiment files will require Igor Pro 8.00 or later and will return 
errors when opened by earlier versions of Igor.
You can choose FileExperiment Info to determine if the current experiment uses long object names or has 
waves with long dimension labels. You can also use the ExperimentInfo operation programmatically.
If you open an experiment file that uses long wave, variable, data folder, window or symbolic path names 
while running Igor Pro 7.xx, where xx is 01 or later, the old Igor version displays an error dialog explaining 
that the experiment requires Igor Pro 8.00 or later. This mechanism for informing you that a later version 
of Igor is required works for long wave, variable, data folder, window and symbolic path names only. It 
does not work for long axis, annotation, control, special character, procedure or XOP names. For those 
object types, you will get an error later, when the old version of Igor first encounters the long name.
If you open an experiment file that uses long names of any kind in Igor Pro 7.00 or before, you will get an 
error such as "name too long" or "incompatible Igor binary version" or some other error.
In Igor Pro 6.38 and Igor Pro 7.01, a bug was fixed that cause Igor to crash if you load a file containing long 
wave names and the file contains wave reference waves or data folder reference waves. You are very 
unlikely to have such files.
