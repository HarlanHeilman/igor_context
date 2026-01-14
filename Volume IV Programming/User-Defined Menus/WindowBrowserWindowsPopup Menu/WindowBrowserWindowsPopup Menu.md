# WindowBrowserWindowsPopup Menu

Chapter IV-5 — User-Defined Menus
IV-140
int twoNumericWavesSelected = GetWave1AndWave2(w1, w2, reverse)
if (twoNumericWavesSelected)
Display w1 vs w2
endif
End
WindowBrowserWindowsPopup Menu
Igor Pro 9.00 and later have a contextual menu named "WindowBrowserWindowsPopup". When you right 
click the list of windows in the Window Browser, Igor displays the WindowBrowserWindowsPopup menu.
You can add items to this menu with a WindowBrowserWindowsPopup menu definition. If necessary, you 
can use GetLastUserMenuInfo to get information about which menu was selected by the user and GetWin-
dowBrowserSelection to determine which windows, if any, are currently selected in the Window Browser.
For example, the following code adds a menu item to the WindowBrowserWindowsPopup contextual 
menu if the Window Browser has one graph window selected. The text of the menu item is different 
depending on whether or not a modifier key is pressed when the menu is shown. Clicking on the menu item 
copies the selected graph to the clipboard as either PNG or SVG format, depending on whether or not a 
modifier key was pressed.
Menu "WindowBrowserWindowsPopup", dynamic
// If a single graph is selected in the Window Browser, if the shift
// key is pressed, this adds "Copy <graph> as SVG".
// If a single graph is selected in the Window Browser, if the shift
// key is not pressed, this adds "Copy <graph> as PNG".
// Otherwise it adds no menu items.
CopySelectedGraphToClipMenuString(0),/Q,CopySelectedGraphToClip(0)
CopySelectedGraphToClipMenuString(1),/Q,CopySelectedGraphToClip(1)
End
// If the Window Browser is open, and exactly one item is selected, and that
// item is a graph, the name of the graph is returned. Otherwise an empty string
// is returned.
Function/S GetSingleSelectedGraphName()
Variable dummy
// GetWindowBrowserSelection generates an error if the Window Browser is not
// open. If the Debugger's Stop on Error setting is enabled, the error causes
// the debugger to break on this statement. Calling GetRTError(1) on the same
// line clears the error and prevents the debugger from breaking here.
String selectedList = GetWindowBrowserSelection(0); dummy = GetRTError(1)
if (ItemsInList(selectedList,";") == 1)
String name = StringFromList(0, selectedList, ";")
if (WinType(name) == 1)
return name
// It is a graph
endif
endif
return ""
// Nothing selected or not a graph
End
// If doSVG is false and the shift key is not key pressed, return
// "Copy Graph as PNG". If doSVG is true and the shift key is pressed,
// return "Copy Graph as SVG".
Function/S CopySelectedGraphToClipMenuString(Variable doSVG)
int shiftKeyPressed = (GetKeyState(0) & 4) != 0
if (doSVG && !shiftKeyPressed)
return ""
// Caller wants SVG menu item but shift key is not pressed
