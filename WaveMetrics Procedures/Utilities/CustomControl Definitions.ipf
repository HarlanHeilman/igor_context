#pragma rtGlobals=1		// Use modern global access method.

// CustomControl struct WMCustomControlAction eventCode definitions

Constant kCCE_mousedown = 1					// Mouse down in control.
Constant kCCE_mouseup = 2					// Mouse up in control.
Constant kCCE_mouseup_out = 3				// Mouse up outside control.
Constant kCCE_mousemoved = 4				// Mouse moved (happens only when mouse is over the control).
Constant kCCE_enter = 5						// Mouse entered control.
Constant kCCE_leave = 6						// Mouse left control.
Constant kCCE_mouseDraggedOutside = 7	// Mouse moved outside the control with button down (mouse down must have been inside the control)
Constant kCCE_draw = 10						// Time to draw custom content.
Constant kCCE_mode = 11						// Sent when executing CustomControl name, mode=m.
Constant kCCE_frame = 12						// Sent before drawing a subframe of a custom picture.
Constant kCCE_dispose = 13					// Sent as the control is killed.
Constant kCCE_modernize = 14				// Sent when dependency (variable or wave set by value=varName  parameter) fires. It will also get draw events, which probably don't need a response.
Constant kCCE_tab = 15						// Sent when user tabs into the control. If you want keystrokes (kCCE_char), then set needAction.
Constant kCCE_char = 16						// Sent on keyboard events. Stores the keyboard character in kbChar and modifiers bit field is stored in kbMods. Sets needAction if key event was used and requires a redraw.
Constant kCCE_drawOSBM = 17					// Called after drawing pict from picture parameter into an offscreen bitmap. You can draw custom content here.
Constant kCCE_idle = 18						// Idle event typically used to blink insertion points etc. Set needAction to force the control to redraw. Sent only when the host window is topmost.
