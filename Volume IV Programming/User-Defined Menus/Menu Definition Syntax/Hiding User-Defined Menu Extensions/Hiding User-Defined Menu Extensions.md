# Hiding User-Defined Menu Extensions

Chapter IV-5 — User-Defined Menus
IV-128
Built-in Menus That Can Be Extended
The titles of the built-in menus that you can extend using user-defined menus are listed below.
These menu titles must appear in double quotes when used in a menu definition.
Use these menu titles to identify the menu to which you want to append items even if you are working with 
a version of Igor translated into a language other than English.
All other Igor menus, including menus added by XOPs, can not accept user-defined items.
Main Menu Bar Menus That You Can Extend
You can extend the following main menu bar menus using user-defined menus:
Contexual Menus That You Can Extend
Contextual menus are also called pop-up menus. You can extend the following contextual menus using 
user-defined menus:
See Marquee Menus on page IV-137, Trace Menus on page IV-137, TablePopup Menu, DataBrowserOb-
jectsPopup Menu on page IV-138, and xxx for more information about these items.
Hiding User-Defined Menu Extensions
The HideIgorMenus operation (see page V-346) and the ShowIgorMenus operation (see page V-869) hide 
or show most of the built-in main menus (but not the Marquee and Popup menus). User-defined menus 
that add items to built-in menus are normally not hidden or shown by these operations. When a built-in 
menu is hidden, the user-defined menu items create a user-defined menu with only user-defined items. For 
example, this user-defined menu:
Menu "Table"
"Append Columns to Table...", DoIgorMenu "Table", "Append Columns to Table"
End
will create a Table menu with only one item in it after the HideIgorMenus "Table" command is executed.
To have your user-defined menu items hidden along with the built-in menu items, add the hideable 
keyword after the Menu definition:
Menu "Table", hideable
"Append Columns to Table...", DoIgorMenu "Table", "Append Columns to Table"
End
Add Controls
Analysis
Append to Graph
Control
Data
Edit
File
Gizmo
Graph
Help
Layout
Load Waves
Macros
Misc
Statistics
New
Notebook
Open File
Panel
Procedure
Save Waves
Table
AllTracesPopup
GraphMarquee
DataBrowserObjectsPopup
GraphPopup
LayoutMarquee
TablePopup
TracePopup
WindowBrowserWindowsPopup
