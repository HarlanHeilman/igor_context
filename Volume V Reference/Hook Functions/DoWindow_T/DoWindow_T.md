# DoWindow/T

DoWindow/T
V-170
The /R and /N flags do nothing when executed while a macro or function is running. This is necessary 
because changing procedures while they are executing causes unpredictable and undesirable results. 
However you can use the Execute/P operation to cause the DoWindow command to be executed after 
procedures are finished running. For example:
Function SaveWindowMacro(windowName)
String windowName
// "" for top graph or table
if (strlen(windowName) == 0)
windowName = WinName(0, 3)
// Name of top graph or table
endif
String cmd
sprintf cmd, "DoWindow/R %s", windowName
Execute/P cmd
End
You can use the /D flag in conjunction with the /K flag to kill a notebook window and delete its associated 
file, if any. /D has no effect on any other type of window and has no effect if the /K flag is not present.
Examples
DoWindow Graph0
// Set V_flag to 1 if Graph0 window exists.
DoWindow/F Graph0
// Make Graph0 the top/target window.
DoWindow/C MyGraph
// Target window (Graph0) renamed MyGraph.
DoWindow/H/B
// Put the command window in back.
DoWindow/D/K Notebook2
// Kill Notebook2, delete its file.
See Also
RenameWindow, MoveWindow, MoveSubwindow, SetActiveSubwindow, KillWindow
HideProcedures, IgorInfo
DoWindow/T 
DoWindow /T windowName, windowTitleStr
The DoWindow/T operation sets the window title for the named window to the specified title.
Details
The title is shown in the window’s title bar, and listed in the appropriate Windows submenu. The window 
name is still used to manipulate the window, so, for example, the window name (if windowName is a graph 
or table) is listed in the New Layout dialog; not the title.
You can check both the name and the title using the Window Control dialog (in the Control submenu of the 
Windows menu).
windowName is the name of the window or a special keyword, kwTopWin or kwFrame.
If windowName is kwTopWin, DoWindow retitles the top target window.
If windowName is kwFrame, DoWindow retitles the “frame” or “application” window that Igor has only 
under Windows. This is the window that contains Igor’s menus and status bar. On Macintosh, kwFrame is 
allowed, but the command does nothing.
The Window Control dialog does not support kwFrame. The frame title persists until Igor quits or until it 
is restored as shown in the example. Setting windowTitleStr to "" will restore the normal frame title.
Examples
DoWindow/T MyGraph, "My Really Neat Graph"
DoWindow/T kwFrame, "My Igor-based Application"
DoWindow/T kwFrame, ""
// restore normal frame title
