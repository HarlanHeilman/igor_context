# The Delete Button

Chapter II-8 — Data Folders
II-117
The New Data Folder Button
The New Data Folder button creates a new data folder inside the current data folder. The Data Browser dis-
plays a simple dialog to ask for the name of the new data folder and tests that the name provided is valid. 
When entering liberal object names in the dialog, do not use single quotes around the name.
The Browse Expt Button
The Browse Expt button loads data objects from an Igor packed experiment file or from a folder on disk into 
the current experiment.
To browse a packed experiment file, click Browse Expt. The Data Browser displays the Open File dialog 
from which you choose the packed experiment file to browse.
To browse a folder on disk, which may contain packed experiment files, standalone Igor wave (.ibw) files, 
and other folders, press Option (Macintosh) or Alt (Windows) while clicking Browse Expt. The Data Browser 
displays the Choose Folder dialog from which you choose the folder to browse.
Once you select the packed experiment file or the folder to browse, the Data Browser displays an additional 
list to the right of the main list. The righthand list displays icons representing the data in the file or folder 
that you selected for browsing. To load data into the current experiment, select icons in the righthand list 
and drag them into a data folder in the lefthand list.
Click the Done Browsing button to close the righthand list and return to normal operating mode.
The Save Copy Button
The Save Copy button copies data objects from the current experiment to an Igor packed experiment file on 
disk or as individual files to a folder on disk. Most users will not need to do this because the data is saved 
when the current experiment is saved.
Before clicking Save Copy, select the items that you want to save. When you click Save Copy, the Data 
Browser presents a dialog in which you specify the name and location of the packed Igor experiment file 
which will contain a copy of the saved data.
If you press Option (Macintosh) or Alt (Windows) while clicking Save Copy, the Data Browser presents a 
dialog for choosing a folder on disk in which to save the data in unpacked format. The unpacked format is 
intended for advanced users with specialized applications.
When saving as unpacked, the Data Browser uses "mix-in" mode. This means that the items saved are 
written to the chosen disk folder but pre-existing items on disk are not affected unless they conflict with 
items being saved in which case they are overwritten.
When saving as unpacked, if you select a data folder in the Data Browser, it and all of its contents are 
written to disk. The name of the disk folder is the same as the name of the selected data folder except for 
the root data folder which is written with the name Data. If you don't select a data folder but just select some 
items, such as a few waves, the Data Browser writes files for those items but does not create a disk folder.
By default, objects are written to the output without regard to the state of the Waves, Variables and Strings 
checkboxes in the Display section of the Data Browser. However, there is a preference that changes this 
behavior in the Data Browser category of the Miscellaneous Settings Dialog. If you check the 'Save Copy 
saves ONLY displayed object types' checkbox, then Save Copy writes a particular type of object only if the 
corresponding Display checkbox is checked.
The Data Browser does not provide a method for adding or deleting data to or from a packed experiment 
file on disk. It can only overwrite an existing file. To add or delete, you need to open the experiment, make 
additions and deletions and then save the experiment.
The Delete Button
The Delete button is enabled whenever data objects are selected in the main list. If you click it, the Data 
Browser displays a warning listing the number of items that will be deleted.
