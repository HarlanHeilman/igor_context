# Saving a Window as a Recreation Macro

Chapter II-4 — Windows
II-47
Killing a window that represents a file on disk does not delete the file. You can also kill a window with a 
KillWindow command.
“Hiding” a window simply means the window is made invisible, but is still part of the experiment and uses 
the same amount of memory. It can be made visible again by choosing its title from the Windows menu.
The command window and the built-in procedure window can be hidden but not killed. All other built-in 
windows can be hidden or killed.
When you create a window from a procedure, you can control what happens when the user clicks the close 
button using the /K=<num> flag in the command that creates the window.
You can hide a window programmatically using the DoWindow/HIDE=1 operation.
Saving the Window Contents
Notebooks and procedure windows can be saved either in their own file, or in a packed experiment file with 
everything else. You can tell which is the case by choosing NotebookInfo or ProcedureInfo. When you 
kill a notebook or a procedure window that contains unsaved information, a dialog will allow you to save 
it before killing the window.
Graph, table, control panel, page layout, and Gizmo windows are not saved as separate files, and are lost 
when you kill them unless you save a window recreation macro which you can execute to later recreate the 
window. Killing these windows and saving them as window recreation macros (stored in the built-in pro-
cedure window) frees up memory and reduces window clutter without losing any information. You can 
think of window recreation macros as “freeze-dried windows”.
Close Window Dialogs
When you close a graph, table, layout or control panel, or Gizmo window, Igor presents a Close dialog.
If you click the Save button Igor creates a window recreation macro in the main procedure window. It sets 
the macro’s subtype to Graph, Table, Layout, Panel, or Gizmo, so the name of the macro appears in the 
appropriate Macros submenu of the Windows menu. You can recreate the window using this menu.
If you don’t plan to use the window again, you should click the No Save button and no window recreation 
macro will be created.
If you have previously created a recreation macro for the window then the dialog will have a Replace button 
instead of a Save button. Clicking Replace replaces the old window recreation macro with a new one. If you 
know that you won’t need to recreate the window, you can delete the macro (see Saving a Window as a 
Recreation Macro on page II-47).
When you close a notebook or procedure window (other than the built-in procedure window), Igor pres-
ents a “hide or kill dialog”.
To hide a window, press Shift while clicking the close button.
To kill a graph, table, layout, control panel, or Gizmo window without the Close dialog, press Option (Mac-
intosh) or Alt (Windows) while clicking the close button.
If you create a window programmatically using the Display, Edit, NewLayout, NewPanel, NewNotebook, 
or NewGizmo operation, you can modify the behavior of the close button using the /K flag.
Saving a Window as a Recreation Macro
When you close a window that can be saved as a recreation macro, Igor offers to create one by displaying 
the Close Window dialog. Igor stores the window recreation macro in the main procedure window of the 
current experiment. The macro uses much less memory than the window, and reduces window clutter. You 
can invoke the window recreation macro later to recreate the window. You can also create or update a 
window recreation macro using the Window Control dialog.
