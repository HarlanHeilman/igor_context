# Data Browser Command String Limitations

Chapter II-8 — Data Folders
II-118
To skip the warning, press Option (Macintosh) or Alt (Windows) when clicking in the Delete button.
Warning: Use this skip feature with great care. If you accidentally delete something, you cannot undo it 
except by reverting the entire experiment to its last saved state.
Clicking the Delete button when the root data folder is selected deletes all data objects in the current exper-
iment.
Warning: If you accidentally delete something, you cannot undo it except by reverting the entire 
experiment to its last saved state.
If you try to delete an object that cannot be deleted, such as a wave used in a graph or table, Igor displays 
a warning message that some objects could not be deleted. Click the Show Details button in this dialog to 
get a list of objects that were not deleted.
The Execute Cmd Button
The Execute Cmd button provides a shortcut for executing a command on selected items in the Data 
Browser window. When you click the Execute Cmd button, Igor displays a dialog in which you can specify 
the command to be executed and the execution mode. Once you have set the command, you can skip the 
dialog and just execute the command by pressing Option (Macintosh) or Alt (Windows) while clicking the 
button.
The format of the command is the same as other Igor commands except that you use %s where the selection 
is to be inserted. For example: 
Display %s
For the case where the command to be executed exceeds the maximum length for an Igor command, you 
can specify a secondary command. For example:
AppendToGraph %s
When 'Execute for each selected item' is enabled, Igor executes the primary command once for each selected 
item, substituting the full path to the item in place of %s. So, for example, if you select wave0, wave1 and 
wave2 in the root data folder, Igor executes:
Display root:wave0
Display root:wave1
Display root:wave2
When 'Execute once for all selected items' is enabled, Igor executes the primary command once, like this:
Display root:wave0, root:wave1, root:wave2
If the command would exceed the maximum length of the command line, Igor executes the primary and 
secondary commands, like this:
Display root:wave0, root:wave1
AppendToGraph root:wave2
Data Browser Command String Limitations
The command strings set in the Execute Cmd dialog, as well as those set via the ModifyBrowser operation, 
must be shorter than the maximum command length of 2500 bytes and may not contain "printf", "sprintf" 
or "sscanf".
When executing the command on all selected objects at once, the primary and secondary command strings 
may contain at most one "%s" token.
The commands must not close the Data Browser window.
