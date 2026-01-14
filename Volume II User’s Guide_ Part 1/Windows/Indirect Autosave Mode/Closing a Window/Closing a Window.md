# Closing a Window

Chapter II-4 — Windows
II-46
You can also create windows by typing these commands yourself directly in the command line. For exam-
ple,
Display yData vs xData
creates a graph of the wave named yData on the Y axis, versus xData on the X axis.
You can create a new window by selecting the name of a window recreation macro from the Windows 
menu. See Window Macros Submenus on page II-48.
You can also create a window using the FileOpen File submenu.
Activating Windows
To activate a window, click it, or choose an item from Windows menu or its submenus.
The Recent Windows submenu shows windows recently activated. This information is saved when you 
save an experiment to disk and restored when you later reopen the experiment.
By default, just the window’s title is displayed in the Windows menu. You can choose to display the title or 
the name for target windows using the Windows Menu Shows pop-up menu in the Miscellaneous section 
of the Miscellaneous Settings dialog. 
Showing and Hiding Windows
All types of Igor windows can be hidden.
To hide a window, press Shift and choose WindowsHide or use the keyboard shortcut Command-Shift-
W (Macintosh) or Ctrl+Shift+W (Windows). You can also hide a window by pressing Shift and clicking the 
close button.
You can hide multiple windows at once using the WindowsHide submenu. For example, to hide all 
graphs, choose WindowsHideAll Graphs. If you press Shift while clicking the Windows menu, the 
sense of the menu items changes. For example, HideAll Graphs changes to HideAll Except Graphs.
The command window is not included in mass hides of any kind. If you want to hide it you must do so 
manually.
Similarly, you can show multiple windows at once using the WindowsShow submenu. For example, to 
show all graphs, choose WindowsShowAll Graphs. If you press Shift while clicking the Windows menu, 
the sense of the menu items changes. For example, ShowAll Graphs changes to ShowAll Except Graphs.
The Show All Except menu items do not show procedure windows and help files because there are so many 
of them that it would be counterproductive.
The WindowsShowRecently Hidden Windows item shows windows recently hidden by a mass hide 
operation, such as HideAll Graphs, or windows recently hidden manually (one-at-a-time using the close 
button or Command-Shift-W or Ctrl+Shift+W). In the case of manually hidden windows, “recently hidden” 
means within the last 30 seconds.
XOP windows do participate in Hide All XOP Windows and Show All XOP Windows only if XOP program-
mers specifically support these features.
Closing a Window
You can close a window by either choosing the WindowsClose menu item or by clicking in the window’s 
close button. Depending on the top window’s type, this will either kill or hide the window, possibly after a 
dialog asking for confirmation.
Killing Versus Hiding
“Killing” a window means the window is removed from the experiment. The memory used by the window 
is released and available for other purposes. The window’s title is removed from the Windows menu.
