# Captured Preferences

Chapter III-18 — Preferences
III-516
Overview
Preferences affect the creation of new graphs, panels, tables, layouts, notebooks, and procedure windows, 
and the appending of traces to graphs and columns to tables. In addition, preferences affect the command 
window, and default font for graphs.
You can turn preferences off or on using the Misc menu. Normally you will run with preferences on.
Preferences are automatically off while a procedure is running so that the effects of the procedure will be 
the same for all users. See the Preferences operation (see page V-768) for further information.
When preferences are off, factory default values are used for settings such as graph size, position, line style, 
size and color. When preferences are on, Igor applies your preferred values for these settings.
Preferences differ from settings, as set in the Miscellaneous Settings dialog, in that settings generally take effect 
immediately, while preferences are used when something is created.
Igor Preferences Directory
Igor preferences are stored in a per-user directory. The location of this directory depends on your operating 
system. You generally don’t need to access your Igor preferences directory, but you can open it in the 
desktop by pressing the Shift key while choosing HelpShow Igor Preferences Folder.
You can also determine the location of your Igor preferences directory by executing this command:
Print SpecialDirPath("Preferences", 0, 0, 0)
For technical reasons, most of the built-in preferences are stored not in the Igor preferences directory but 
rather one level up in a file named “Igor Pro 9.ini”.
Deleting the preferences directory and the “Igor Pro 9.ini” file effectively reverts all preferences to factory 
defaults. You should use the Capture Prefs dialogs, described in Captured Preferences operation on page 
III-516, to revert preferences more selectively.
Other information is stored in preferences, such as the screen position of dialogs, a few dialog settings, 
colors recently selected in the color palette, window stacking and tiling information, page setups, font sub-
stitution settings, and dashed line settings.
How to Use Preferences
Preferences are always on when Igor starts up. You can turn preferences off by choosing Preferences Off in 
the Misc menu.
You can also turn preferences on and off with the Preferences operation (see page V-768).
Preferences are set by Capture Preferences dialogs, the Tile or Stack Windows dialog, and some dialogs 
such as the Dashed Lines dialog.
In general, preferences are applied only when something new is created such as a new graph, a new trace in a 
graph, a new notebook, a new column in a table, and then only if preferences are on.
Preferences are normally in effect only for manual (“point-and-click”) operation, not for user-programmed 
operations in Igor procedures. See Procedures and Preferences on page IV-203.
Captured Preferences
You set most preference values by capturing the current settings of the active window with the Capture 
Prefs item in the menu for that window. (The dialog to capture the Command Window preferences is found 

Chapter III-18 — Preferences
III-517
in the Command/History Settings submenu of the Misc menu.) The dialogs are described in more detail in 
the chapter that discusses each type of window. For instance, see Graph Preferences on page II-348.

Chapter III-18 — Preferences
III-518
