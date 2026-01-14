# default

DebuggerOptions
V-146
DebuggerOptions 
DebuggerOptions [enable=en, debugOnAbort=doa, debugOnError=doe, 
NVAR_SVAR_WAVE_Checking=nvwc]
The DebuggerOptions operation programmatically changes the user-level debugger settings. These are the 
same three settings that are available in the Procedure menu (and the debugger source pane contextual menu)
Parameters
All parameters are optional. If none are specified, no action is taken, but the output variables are still set.
Output Variables
DebuggerOptions sets the following variables to indicate the Debugger settings that are in effect after the 
command is executed. A value of zero means the setting is off, nonzero means the setting is on.
V_enable, V_debugOnError, V_debugOnAbort, V_NVAR_SVAR_WAVE_Checking
See Also
The Debugger on page IV-212 and the Debugger operation.
default 
default:
The default flow control keyword is used in switch and strswitch statements. When none of the case labels 
in the switch or strswitch match the evaluation expression, execution will continue with code following the 
default label, if it is present.
See Also
Switch Statements on page IV-43.
enable=en
Turns the debugger on (en=1) or off (en=0).
If the debugger is disabled then the other settings are cleared even if other settings 
are on.
debugOnAbort=doa
debugOnError=doe
NVAR_SVAR_WAVE_Checking=nvwc
Turns Debugging On Abort on or off.
The Debug on Abort feature was added in Igor Pro 9.00. See Debugging on 
Abort on page IV-214 for details.
doa=0:
Disables Debugging On Abort.
doa=1:
Enables Debugging On Abort and also enables the debugger 
(implies enable=1).
Turns Debugging On Error on or off.
See Debugging on Error on page IV-213 for details.
doe=0:
Disables Debugging On Error.
doe=1:
Enables Debugging On Error and also enables the debugger 
(implies enable=1).
Turns NVAR, SVAR, and WAVE checking on or off.
nvwc=0:
Disables “NVAR SVAR WAVE Checking”. See Accessing 
Global Variables and Waves on page IV-65 for more details.
nvwc=1:
Enables this checking and also enables the debugger (implies 
enable=1).
