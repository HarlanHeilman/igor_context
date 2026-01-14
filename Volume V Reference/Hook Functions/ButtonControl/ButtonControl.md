# ButtonControl

ButtonControl
V-57
Details
The target window must be a graph or panel.
Button Action Procedure
The action procedure for a Button control takes a predefined structure WMButtonAction as a parameter 
to the function:
Function ActionProcName(B_Struct) : ButtonControl
STRUCT WMButtonAction &B_Struct
…
return 0
End
The “: ButtonControl” designation tells Igor to include this procedure in the Procedure pop-up menu 
in the Button Control dialog.
See WMButtonAction for details on the WMButtonAction structure.
Although the return value is not currently used, action procedures should always return zero.
You may see an old format button action procedure in old code:
Function procName(ctrlName) : ButtonControl
String ctrlName
…
return 0
End
This old format should not be used in new code.
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The ControlInfo operation for information about the control.
The GetUserData function for retrieving named user data.
ButtonControl 
ButtonControl
ButtonControl is a procedure subtype keyword that identifies a macro or function as being an action 
procedure for a user-defined button control. See Procedure Subtypes on page IV-204 for details. See Button 
for details on creating a button control.
userdata(UDName)
=UDStr
Sets the unnamed user data to UDStr. Use the optional (UDName) to create named 
user data.
Names starting with “WM_” are reserved for WaveMetrics.
userdata(UDName)
+=UDStr
Appends UDStr to the current unnamed user data. Use the optional (UDName) to 
append to the named UDStr.
Names starting with “WM_” are reserved for WaveMetrics.
valueColor=(r,g,b[,a])
Sets initial color of the button's text (title). r, g, b, and a specify the color and optional 
opacity as RGBA Values. The default is opaque black.
To further change the color of the title text, use escape sequences as described for 
title=titleStr.
win=winName
Specifies which window or subwindow contains the named button control. If not 
given, then the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
