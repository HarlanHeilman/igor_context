# Debugging on Abort

Chapter IV-8 — Debugging
IV-214
Sometimes you do something that you know may cause an error and you want to handle the error yourself, 
without breaking into the debugger. One such case is attempting to access a wave or variable that may or 
may not exist. You want to test its existence without breaking into the debugger.
You can use the /Z flag to prevent the Debug on Error feature from kicking in when an NVAR, SVAR, or 
WAVE reference fails. For example:
WAVE/Z w = <path to possibly missing wave>
if (WaveExists(w))
<do something with w>
endif
In other cases where an error may occur and you want to handle it yourself, you need to temporarily disable 
the debugger and use GetRTError to get and clear the error. For example:
Function DemoDisablingDebugger()
DebuggerOptions
// Sets V_enable to 1 if debugger is enabled
Variable debuggerEnabled=V_enable
DebuggerOptions enable=0
// Disable debugger
String name = ";"
// This is an illegal wave name
Make/O $name
// So this will generate and error
DebuggerOptions enable=debuggerEnabled
// Restore
Variable err = GetRTError(1)
// Clear error
if (err != 0)
Printf "Error %d\r", err
else
Print "No error"
endif
End
Debugging on Abort
You can tell Igor to automatically open the debugger window if you interrupt command execution by 
enabling Debug On Abort. This is useful for stopping code that is taking much longer than expected. It 
pauses execution and opens the debugger so you can see what is going on.
To enable or disable this feature, choose ProcedureDebug On Abort or right-click in a procedure window 
and choose Debug On Abort from the pop-up menu.
