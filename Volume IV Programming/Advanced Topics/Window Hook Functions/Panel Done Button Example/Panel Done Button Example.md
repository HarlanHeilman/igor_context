# Panel Done Button Example

Chapter IV-10 — Advanced Topics
IV-302
EarlyKeyboard Events
The earlyKeyboard event was added in Igor Pro 9.00.
The earlyKeyboard event is like the keyboard event but is sent, to graph and control panel windows only, 
before other components of those windows get the keyboard event. Its purpose is to let you filter key 
presses in graphs and panels before they reach a control.
The keycode, specialKeyCode, and keyText fields work the same as with the keyboard event.
The earlyKeyboard event sets the focusCtrl field which was added in Igor Pro 9.00.
If the event is earlyKeyboard and the window or its subwindows have a control with keyboard focus, the 
focusCtrl field is set to the name of the control and the winName field is set to the path of the window or 
subwindow that contains the control. If you return a non-zero result from the hook function when it 
receives the earlyKeyboard event, you prevent the control from receiving the keyboard event.
Only graphs and control panels receive earlyKeyboard events. Other window types receive normal key-
board events before any use is made of the keyboard events, making the earlyKeyboard event redundant.
Setting the Mouse Cursor
An advanced programmer can use a named window hook function to change the mouse cursor.
You might want to do this, for example, if your window hook function intercepts mouse events on certain 
items (e.g., waves) and performs custom actions. By setting a custom mouse cursor you indicate to the user 
that clicking the items results in different-from-normal actions.
See the Mouse Cursor Control example experiment - in Igor choose FileExample Experi-
mentsProgrammingMouse Cursor Control.
Panel Done Button Example
This example uses a window hook and button action procedure to implement a panel dialog with a Done 
button such that the panel can't be closed by clicking the panel's close widget, but can be closed by the Done 
button's action procedure:
Proc ShowDialog()
PauseUpdate; Silent 1
// building window...
NewPanel/N=Dialog/W=(225,105,525,305) as "Dialog"
Button done,pos={119,150},size={50,20},title="Done"
Button done,proc=DialogDoneButtonProc
TitleBox warning,pos={131,83},size={20,20},title=""
TitleBox warning,anchor=MC,fColor=(65535,16385,16385)
SetWindow Dialog hook(dlog)=DialogHook, hookevents=2
EndMacro
Function DialogHook(s)
STRUCT WMWinHookStruct &s
Variable statusCode= 0
strswitch( s.eventName )
case "killVote":
TitleBox warning win=$s.winName, title="Press the Done button!"
Beep
statusCode=2
// prevent panel from being killed.
break
case "mousemoved":
// to reset the warning
TitleBox warning win=$s.winName, title=""
break
endswitch
return statusCode
End
