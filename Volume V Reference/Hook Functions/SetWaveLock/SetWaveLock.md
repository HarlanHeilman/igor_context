# SetWaveLock

SetVariableControl
V-858
Flags
Details
The target window must be a graph or panel.
SetVariable Action Procedure
The action procedure for a SetVariable control takes a predefined WMSetVariableAction structure as a 
parameter to the function:
Function ActionProcName(SV_Struct) : SetVariableControl
STRUCT WMSetVariableAction &SV_Struct
…
return 0
End
The “: SetVariableControl” designation tells Igor to include this procedure in the Procedure pop-up 
menu in the SetVariable Control dialog.
See WMSetVariableAction for details on the WMSetVariableAction structure.
Although the return value is not currently used, action procedures should always return zero.
You may see an old format SetVariable action procedure in old code:
Function procName(ctrlName,varNum,varStr,varName) : SetVariableControl
String ctrlName
Variable varNum
// value of variable as number
String varStr
// value of variable as string
String varName
// name of variable
…
return 0
End
This old format should not be used in new code.
Examples
Executing the commands:
Variable/G globalVar=99
SetVariable setvar0 size={120,20}
SetVariable setvar0 font="Helvetica", value=globalVar
creates a SetVariable control that displays the value of globalVar.
See Also
The printf operation for an explanation of formatStr, and SetVariable on page III-417.
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The GetUserData function for retrieving named user data.
The ControlInfo operation for information about the control.
SetVariableControl 
SetVariableControl
SetVariableControl is a procedure subtype keyword that identifies a macro or function as being an action 
procedure for a user-defined SetVariable control. See Procedure Subtypes on page IV-204 for details. See 
SetVariable for details on creating a SetVariable control.
SetWaveLock 
SetWaveLock lockVal, waveList
The SetWaveLock operation locks a wave or waves and protects them from modification. Such protection 
is not absolute, but it should prevent most common attempts to change or kill a wave.
Parameters
lockVal can be 0, to unlock, or 1, to lock the wave(s).
/Z
No error reporting.
