# WMDrawUserShapeStruct

WMDrawUserShapeStruct
V-1106
#include <CustomControl Definitions>
WMCustomControl needAction Field
The meaning of needAction depends on the event.
Events kCCE_mousemoved, kCCE_enter, kCCE_leave, and kCCE_mouseDraggedOutside set needAction 
to TRUE to force redraw, which is normally not done for these events.
Events kCCE_tab and kCCE_mousedown set needAction to TRUE to request keyboard focus (and get 
kCCE_char events).
Event kCCE_idle sets needAction to TRUE to request redraw.
WMCustomControl kbMods Field
WMDrawUserShapeStruct
See DrawUserShape for further explanation of WMDrawUserShapeStruct.
Event Code
Description
kCCE_mousedown = 1
Mouse down in control.
kCCE_mouseup = 2
Mouse up in control.
kCCE_mouseup_out = 3
Mouse up outside control.
kCCE_mousemoved = 4
Mouse moved (happens only when mouse is over the control).
kCCE_enter = 5
Mouse entered control.
kCCE_leave = 6
Mouse left control.
kCCE_mouseDraggedOuts
ide = 7
The mouse moved while it was outside the control. This event is delivered 
only after the mouse is pressed inside the control and dragged outside. 
While the mouse is inside the control, kCCE_mousemoved is delivered 
whether the mouse button is up or down.
kCCE_draw = 10
Time to draw custom content.
kCCE_mode = 11
Sent when executing CustomControl name, mode=m.
kCCE_frame = 12
Sent before drawing a subframe of a custom picture.
kCCE_dispose = 13
Sent as the control is killed.
kCCE_modernize = 14
Sent when dependency (variable or wave set by value=varName parameter) 
fires. It will also get draw events, which probably don’t need a response.
kCCE_tab = 15
Sent when user tabs into the control. If you want keystrokes (kCCE_char), 
then set needAction.
kCCE_char = 16
Sent on keyboard events. Stores the keyboard character in kbChar and 
modifiers bit field is stored in kbMods. Sets needAction if key event was 
used and requires a redraw.
kCCE_drawOSBM = 17
Called after drawing pict from picture parameter into an offscreen bitmap. 
You can draw custom content here.
kCCE_idle = 18
Idle event typically used to blink insertion points etc. Set needAction to 
force the control to redraw. Sent only when the host window is topmost.
Bit 0:
Command (Macintosh)
Bit 1:
Shift
Bit 2:
Alpha Lock. Not supported in Igor7 or later.
Bit 3:
Option (Macintosh) or Alt (Windows)
Bit 4:
Control (Macintosh ) or Windows key (Windows).
