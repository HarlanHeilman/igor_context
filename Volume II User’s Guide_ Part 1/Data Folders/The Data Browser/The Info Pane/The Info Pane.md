# The Info Pane

Chapter II-8 — Data Folders
II-115
The Main List
The main list occupies most of the Data Browser when it is first invoked.
At the top of the data tree is the root data folder which by default appears expanded. By double-clicking a 
data folder icon you can change the display so that the tree is displayed with your selection as the top data 
folder instead of root. You can use the pop-up menu above the main list to change the current top data 
folder to another data folder in the hierarchy.
Following the top data folder are all the data objects that it contains. Objects are grouped by type and by 
default are listed in creation order. You can change the sort order using the gear icon. You can filter the list 
using the filter textbox.
You can select data objects with the mouse. You can select multiple contiguous data objects by shift-clicking. 
You can select multiple discontiguous data objects by Command-clicking (Macintosh) or Ctrl-clicking (Win-
dows).
Note:
Objects remain selected even when they are hidden inside collapsed data folders. If you select a 
wave, collapse its data folder, Shift-select another wave, and drag it to another data folder, both 
waves will be moved there.
However, when a selected object is hidden by deselecting the relevant Display checkbox, actions, 
such as deletion and duplication, are not taken upon it.
You can rename data objects by clicking the name of the object and editing the name.
The Data Browser also supports icon dragging to move or copy data objects from one data folder to another. 
You can move data objects from one data folder to another by dragging them. You can copy data objects from 
one data folder to another by pressing Option (Macintosh) or Alt (Windows) while dragging.
You can duplicate data objects within a data folder by choosing Duplicate from the Edit menu or by press-
ing Command-D (Macintosh) or Ctrl+D (Windows).
You can copy the full paths of all selected data objects, quoted if necessary, to the command line by drag-
ging the objects onto the command line.
You can select one or more waves in the list and drag them into an existing graph or table window to 
append them to the target window. See Appending Traces by Drag and Drop on page II-280 for details.
The Current Data Folder
The “current data folder” is the data folder that Igor uses by default for storing newly-created variables, 
strings, waves and other data folders. Commands that create or access data objects operate in the current 
data folder unless you use data folder paths to specify other data folders.
Above the main list there is a textbox that shows the full path to the current data folder. The main list dis-
plays a red arrow overlayed on the icon of the current data folder. When the current data folder is contained 
inside another data folder, a white arrow indicator is overlayed on the icons of the ancestors of the current 
data folder.
To set the current data folder, right-click any data folder and select Set Current Data Folder. You can also 
set the current data folder by dragging the red arrow or by Option-clicking (Macintosh) or Alt-clicking (Win-
dows) a data folder icon.
The Display Checkboxes
The Display checkbox group lets you control which object types are shown in the main list. Data folders are 
always shown. They also allow you to show or hide the info pane and the plot pane.
The Info Pane
To view the info pane, check the Info checkbox.
