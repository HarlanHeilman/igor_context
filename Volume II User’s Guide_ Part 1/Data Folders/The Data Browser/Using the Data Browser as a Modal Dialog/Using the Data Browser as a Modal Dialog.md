# Using the Data Browser as a Modal Dialog

Chapter II-8 — Data Folders
II-119
The command string mechanism is sometimes convenient but somewhat kludgy. It is cleaner and more 
transparent to get the list of selected objects using the GetBrowserSelection function and then process the 
list using normal list-processing techniques.
Using the Find in Data Browser Dialog
If you choose the EditFind, the Data Browser displays the Find in Data Browser dialog. This dialog allows 
you to find waves, variables and data folders that might be buried in sub-data folders. It also provides a con-
venient way to select a number of items at one time, based on a search string. You can then use the Execute 
Cmd button to operate on the selection.
The Find in Data Browser dialog allows you to specify the text used for name matching. Any object whose 
name contains the specified text is considered a match.
You can also use the wildcard character "*" to match zero or more characters regardless of what they are. For 
example, "w*3" matches "wave3", and "w3", ""
The dialog also allows you to specify whether the search should be case sensitive, use whole word matching, 
and wrap around.
DataBrowser Pop-Up Menu
You can apply various Igor operations to objects by selecting the objects in the Data Browser, right-clicking, 
and choosing the operation from the resulting pop-up menu.
Using the Display and New Image pop-up items, you can create a new graph or image plot of the selected 
wave. You can select multiple waves, in the same or different data folders, to display together in the same 
graph.
The Copy Full Path item copies the complete data folder paths of the selected objects, quoted if necessary, 
to the clipboard.
The Show Where Object Is Used item displays a dialog that lists the dependencies in which the selected 
object is used and, for waves, the windows in which the wave is used. This item is available only when just 
one data object is selected.
The Adopt Wave item adopts a shared wave into the current experiment.
Data Browser Preferences
Various Data Browser settings are controlled from the Data Browser category of the Miscellaneous Settings 
Dialog. You access them by choosing MiscMiscellaneous Settings and clicking Data Browser in the lefthand 
list.
Programming the Data Browser
The Data Browser can be controlled from Igor procedures using the following operations and functions:
CreateBrowser, ModifyBrowser, GetBrowserSelection, GetBrowserLine
Advanced Igor programmers can use the Data Browser as an input device via the GetBrowserSelection 
function. For an example, choose FileExample ExperimentsTutorialsData Folder Tutorial.
Using the Data Browser as a Modal Dialog
You can use the Data Browser as a modal dialog to let the user interactively choose one or more objects to 
be processed by a procedure. The modal Data Browser is separate from the regular Data Browser that you 
invoke by choosing DataData Browser. The modal Data Browser normally exists only briefly, while you 
solicit user input from a procedure.
There are two methods for creating and displaying the modal Data Browser. Examples are provided in the 
help for the CreateBrowser operation.
