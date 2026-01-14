# IgorMenuHook

Chapter IV-10 — Advanced Topics
IV-291
If IgorBeforeQuitHook returns 1, then the normal save-and-quit process is aborted and Igor quits 
immediately. The current experiment, notebooks, and procedures are not saved, no dialogs are presented 
to the user, and IgorQuitHook is not called.
If IgorBeforeQuitHook returns 2, then the normal save-and-quit process is aborted and Igor does not quit. 
The current experiment, notebooks, and procedures are not saved, no dialogs are presented to the user, and 
IgorQuitHook is not called. This return value was first supported in Igor Pro 8.05.
See Also
IgorQuitHook and SetIgorHook.
IgorMenuHook
IgorMenuHook(isSelection, menuStr, itemStr, itemNo, activeWindowStr, wType)
IgorMenuHook is a user-defined function that Igor calls just before and just after menu selection, whether 
by mouse or keyboard.
Parameters
isSelection is 0 before a menu item has been selected and 1 after a menu item has been selected.
When isSelection is 1, menuStr is the name of the selected menu. It is always in English, regardless of the 
localization of Igor. When isSelection is 0, menuStr is "".
When isSelection is 1, itemStr is the name of the selected menu item. When isSelection is 0, itemStr is "".
When isSelection is 1, itemNo is the one-based item number of the selected menu item. When isSelection is 0, 
itemNo is 0.
activeWindowStr identifies the active window. See details below.
wType identifies the kind of window that activeWindowStr identifies. It returns the same values as the 
WinType function.
activeWindowStr Parameter
activeWindowStr identifies the window to which the menu selection will apply. It can be a window name, 
window title, or special keyword, as follows:
See Window Names and Titles on page II-45 for a discussion of the distinction.
Details
IgorMenuHook is called with isSelection set to 0 after all the menus have been enabled and before a mouse 
click or keyboard equivalent is handled.
The return value should normally be 0. If the return value is nonzero (1 is usual) then the active window’s 
hook function (see SetWindow operation on page V-865) is not called for the enablemenu event.
IgorMenuHook is called with isSelection set to 1 after the menu has been selected and before Igor has acted 
on the selection.
If the IgorMenuHook function returns 0, Igor proceeds to call the active window’s hook function for the 
menu event. (If the window hook function exists and returns nonzero, Igor ignores the menu selection. 
Otherwise Igor handles the menu selection normally.)
If the IgorMenuHook function returns nonzero (1 is recommended), Igor does not call the remaining hook 
functions and Igor ignores the menu selection.
Window
activeWindowStr
Target window
Window name.
The target window is that top graph, table, page layout, notebook, 
control panel, Gizmo plot, or XOP target window.
Command window
kwCmdHist (as used with GetWindow).
Procedure window
Window title as shown in the window’s title bar. The built-in 
procedure window is “Procedure”.
XOP non-target window
The window title as shown in the window’s title bar.
