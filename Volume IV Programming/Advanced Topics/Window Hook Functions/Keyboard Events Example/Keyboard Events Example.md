# Keyboard Events Example

Chapter IV-10 — Advanced Topics
IV-301
Keyboard Events Example
This example illustrates the use of the various keyboard event fields in the WMWinHookStruct structure. 
It requires Igor Pro 7 or later.
Function KeyboardWindowHook(s)
STRUCT WMWinHookStruct &s
Variable hookResult = 0
// 0 if we do not handle event, 1 if we handle it.
String message = ""
switch(s.eventCode)
case 11:
// Keyboard event
String keyCodeInfo
sprintf keyCodeInfo, "s.keycode = 0x%04X", s.keycode
if (strlen(message) > 0)
message += "\r"
endif
message +=keyCodeInfo
message += "\r"
String specialKeyCodeInfo
sprintf specialKeyCodeInfo, "s.specialKeyCode = %d", s.specialKeyCode
message +=specialKeyCodeInfo
message += "\r"
String keyTextInfo
sprintf keyTextInfo, "s.keyText = \"%s\"", s.keyText
message +=keyTextInfo
String text = "\\Z24" + message
Textbox /C/N=Message/W=KeyboardEventsGraph/A=MT/X=0/Y=15 text
hookResult = 1
// We handled keystroke
break
endswitch
return hookResult // If non-zero, we handled event and Igor will ignore it.
End
Function DemoKeyboardWindowHook()
DoWindow/F KeyboardEventsGraph
// Does graph exist?
if (V_flag == 0)
// Create graph
Display /N=KeyboardEventsGraph as "Keyboard Events"
// Install hook
SetWindow KeyboardEventsGraph, hook(MyHook)=KeyboardWindowHook
String text = "\\Z24" + "Press a key"
Textbox /C/N=Message/W=KeyboardEventsGraph/A=MT/X=0/Y=15 text
endif
End
Print
402
Not supported
SysReq
403
Not supported
Key
specialKeyCode
keyCode
Note
