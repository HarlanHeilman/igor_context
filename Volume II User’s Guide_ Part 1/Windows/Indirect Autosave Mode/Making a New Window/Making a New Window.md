# Making a New Window

Chapter II-4 — Windows
II-45
command line, including commands that do not apply to the target window. Igor will apply the command 
to the top window of the correct type.
Sometimes the top window isn’t a target window, but it causes the menu bar to change. For example, if you 
activate a procedure window, the Procedure menu appears in the menu bar.
Window Names and Titles
Each graph, table, page layout, control panel, notebook, and Gizmo has a title and a name.
The title is what you see at the top of the window frame and in the Windows menu. Its purpose is to help 
you visually identify the window, and is usually descriptive of its contents or purpose.
The window name is not the same as the title. The purpose of the name is to allow you to refer to the window 
from a command, such as the DoWindow or AppendToGraph operations.
When you first create one of these windows, Igor gives it a name like Graph0, Table0, Layout0 or Panel0, 
and a title based on the name and window contents. You can change the window’s title and name to some-
thing more descriptive using the Window Control dialog (WindowsControl submenu). Among other 
things, it renames and retitles the target window.
The Window Control dialog is also a good way to discover the name of the top window, since the window 
shows only the window title.
The command window, procedure windows, and help windows have only a title. The title is the name of 
the file in which they are stored. These windows do not have names because they can not be affected by 
command line operations.
Allowable Window Names
A window name is used for commands and therefore must follow the standard rules for naming Igor objects:
•
The name must start with a letter.
•
Additional characters can be alphanumeric or the underscore character.
•
No other characters, including spaces, are allowed in standard Igor object names.
•
No more than 255 bytes are allowed.
•
The name must not conflict with other object names (you see a message if it does).
Prior to Igor Pro 8.00, window names were limited to 31 bytes. If you use long window names, your exper-
iments will require Igor Pro 8.00 or later.
For more information, see Object Names on page III-501.
The Open File Submenu 
The File menu contains the Open File submenu for opening an existing file as a notebook, Igor help 
window, or procedure window.
When you choose an item from the submenu, the Open File dialog appears for you to select a file.
The Windows Menu
You can use the Windows menu for making new windows, and for showing, arranging and closing (either 
hiding or “killing”) windows. You can also execute “window recreation macros” that recreate windows 
that have been killed and “style macros” that modify an existing window’s appearance.
Making a New Window
You can use the various items in the Windows menu and WindowsNew submenu to create new win-
dows. Most of these items invoke dialogs which produce commands that Igor executes to create the win-
dows.
