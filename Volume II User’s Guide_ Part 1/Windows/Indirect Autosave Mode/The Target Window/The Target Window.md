# The Target Window

Chapter II-4 — Windows
II-44
Windows
This section describes Igor’s windows in general terms, the Windows menu, and window recreation 
macros.
Detailed information about each type of window can be found in these chapters:
The Command Window
When Igor first starts, the command window appears at the bottom of the screen.
Commands are automatically entered and executed in the command window’s command line when you 
use the mouse to “point-and-click” your way through dialogs. You may optionally type the commands 
directly and press Return or Enter. Igor preserves a history of executed commands in the history area.
For more about the command window, see Chapter II-2, The Command Window, and Chapter IV-1, 
Working with Commands.
The Rest of the Windows
There are also a number of additional windows which are initially hidden:
•
The main procedure window
•
The Igor Help Browser
•
Help windows for files in "Igor Pro Folder/Igor Help Files" and "Igor Pro User Files/Igor Help Files"
You can create additional windows for graphs, tables, page layouts, notebooks, control panels, Gizmos (3D 
plots), and auxiliary procedure windows, as well as more help windows.
The Target Window
Igor commands and menus operate on the target window. The target window is the top graph, table, page 
layout, notebook, control panel or XOP target window. The term “target” comes from the fact that these 
windows can be the target of command line operations such as ModifyGraph, ModifyTable and so on. The 
command window, procedure windows, help windows and dialogs can not be targets of command line 
operations and thus are not target windows.
Prior to version 4, Igor attempted to draw a special icon to indicate which window was the target. However, 
this special target icon is no longer drawn because of operating system conflicts.
The menu bar changes depending on the top window and the target window. For instance, if a graph is the 
target window the menu bar contains the Graph menu. However, you may type any command into the 
Window Type
Chapter
Command window
Chapter II-2, The Command Window
Chapter IV-1, Working with Commands
Procedure windows
Chapter III-13, Procedure Windows
Help windows
Chapter II-1, Getting Help
Graphs
Chapter II-13, Graphs
Tables
Chapter II-12, Tables
Layouts
Chapter II-18, Page Layouts
Notebooks
Chapter III-1, Notebooks
Control panels
Chapter III-14, Controls and Control Panels
Gizmo windows
Chapter II-17, 3D Graphics
Camera windows
NewCamera on page V-678
