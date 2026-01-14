# GetRTError

GetMouse
V-312
Print "The marquee has disappeared."
endif
return 0
// return value doesn't really matter
End
See Also
The SetMarquee and SetFormula operations. Setting Bit Parameters on page IV-12 for information about 
bit settings.
GetMouse
GetMouse [/W=winName]
The GetMouse operation returns information about the position of the input mouse, and the state of the 
mouse buttons.
GetMouse is useful in situations such as background tasks where the mouse position and state aren't 
available as they are in control procedures and window hook functions.
Flags
Details
GetMouse returns the mouse position in local coordinates relative to the specified window unless /W is 
omitted in which case the returned coordinates are global.
On Windows, global coordinates are actually relative to the frame window. See GetWindow wsizeDC 
kwFrameInner.
Information is returned via the following string and numeric variables:
See Also
GetWindow, GetKeyState, SetWindow, WMWinHookStruct, WMButtonAction
Background Tasks on page IV-319, Subwindow Syntax on page III-92
GetRTError 
GetRTError(flag)
The GetRTError function returns information about the error state of Igor's user-defined function runtime 
execution environment.
/W=winName
Returns the mouse position relative to the named window or subwindow. When 
identifying a subwindow with winName, see Subwindow Syntax on page III-92.
/W=kwTopWin
Returns the mouse position relative to the currently frontmost non-floating window.
/W=kwCmdHist
Returns the mouse position relative to the command window.
/W=Procedure
Returns the mouse position relative to the main Procedure window.
V_left
Horizontal mouse position, in pixels.
V_top
Vertical mouse position, in pixels.
V_flag
Mouse button state. V_flag is a bitwise value with each bit reporting the mouse 
button states:
Bit 0: 1 if the primary mouse button (usually the left) is down, 0 if it is up.
Bit 1: 1 if the secondary mouse button (usually the right) is down, 0 if it is up.
On Macintosh, the secondary mouse button can be invoked by pressing the control 
key while clicking the primary (often the only) mouse button, but GetMouse does not 
report this with bit 1 set. Use GetKeyState's bit 4 to test if the control key is pressed.
See Setting Bit Parameters on page IV-12 for details about bit settings.
S_name
Name of the window or subwindow which the position is relative to, or "" if not a 
nameable window or if /W was omitted. Most useful with /W=kwTopWin. The result 
can be kwCmdHist or Procedure, or the name of a target window.
