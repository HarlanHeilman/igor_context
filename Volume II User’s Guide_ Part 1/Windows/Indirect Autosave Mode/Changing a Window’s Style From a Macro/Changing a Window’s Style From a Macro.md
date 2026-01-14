# Changing a Window’s Style From a Macro

Chapter II-4 — Windows
II-48
The window recreation macro contains all the necessary commands to reconstruct the window provided 
the underlying data is still present. For instance, a graph recreation macro contains commands to append 
waves to the graph, but does not contain any wave data. Similarly, a page layout recreation macro does not 
contain graphs or tables or the commands to create them. The macros refer to waves, graphs and tables in 
the current experiment by name.
Here is how you would use recreation macros to keep a graph handy, but out of your way:
The window recreation macro is evaluated in the context of the root data folder. This detail is of conse-
quence only to programmers. See Data Folders and Commands on page II-111 for more information.
You can create or replace a window recreation macro without killing the window using The Window 
Control Dialog described on page II-49. The most common reason to replace a window recreation macro is 
to keep the macro consistent with the window that it creates.
When Igor displays the Close Window dialog, the proposed name of the window recreation macro is the 
same as the name of the window. You can save the window recreation macro under a different name, if you 
want, by entering the new name in the dialog. If you do this, Igor creates a new macro and leaves the orig-
inal macro intact. You can run the new macro to create a new version of the window or you can run the old 
macro to recreate the old version. This way you can save several versions of a window, while displaying 
only the most recent one.
Window recreation macros stay in an experiment’s procedure window indefinitely. If you know that you 
won’t need to recreate a window for which a window recreation macro exists, you can delete the macro.
To locate a window recreation macro quickly:
•
Activate any procedure window, press Option (Macintosh) or Alt (Windows), and choose the 
window recreation macro name from the appropriate macro submenu in the Windows menu.
To delete the macro, if you’re sure you won’t want it again, simply select all the text from the Macro decla-
ration line to the End line. Press Delete to remove the selected text.
See Saving and Recreating Graphs on page II-350 for details specific to graphs.
Window Macros Submenus
The Windows menu has submenus containing graph, table, page layout, control panel, and Gizmo recre-
ation macros. These menus also include graph, table, and page layout style macros.
Window recreation macros are created by the Close Window and Window Control dialogs, and by the DoWin-
dow/R command. Style macros are created by the Window Control dialog and the DoWindow/R/S command.
Igor places macros into the appropriate macro submenu by examining the macro’s subtype. The subtypes 
are Graph, Table, Layout, Panel, Gizmo, GraphStyle, TableStyle and LayoutStyle. See Procedure Subtypes 
on page IV-204 for details.
When you choose the name of a recreation macro from a macro submenu, the macro runs and recreates the 
window. Choosing a style macro runs the macro which changes the target window’s appearance (its “style”).
However, if a procedure window is the top window and you press Option (Macintosh) or Alt (Windows) and 
then choose the name of any macro, Igor displays that macro but does not execute it.
The Name of a Recreated Window
When you run a window recreation macro, Igor recreates the window with the same name as the macro 
that created it unless there is already a window by that name. In this case, Igor adds an underscore followed 
by a digit (e.g. _1) to the name of the newly created window to distinguish it from the preexisting window.
Changing a Window’s Style From a Macro
When you run a style macro by invoking it from the Windows menu, from the command line or from 
another macro, Igor applies the commands in the macro to the top window. Usually these commands
