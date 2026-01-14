# CtrlNamedBackground

CtrlNamedBackground
V-119
See Also
The BackgroundInfo, SetBackground, CtrlNamedBackground, KillBackground, and SetProcessSleep 
operations, and Background Tasks on page IV-319.
CtrlNamedBackground 
CtrlNamedBackground taskName, keyword = value [, keyword = value …]
The CtrlNamedBackground operation creates and controls named background tasks.
We recommend that you see Background Tasks on page IV-319 for an orientation before working with 
background tasks.
Parameters
period=deltaTicks
Sets the minimum number of ticks that must pass between invocations of the 
background task.
start[=startTicks]
Starts the background task (designated by SetBackground) when the tick count 
reaches startTicks. If you omit startTicks the task starts immediately.
stop
Stops the background task.
taskName
taskName is the name of the background task or _all_ to control all named background 
tasks. You can use any valid standard Igor object name as the background task name.
burst [= b]
Enable burst catch up mode (off by default, b=0). When on (b=1), the task is called at 
the maximum rate if a delay misses normal run times.
dialogsOK [= d]
Use dialogsOK=1 to allow the background task to run when a dialog window is 
active. By default, dialogsOK=0 is in effect. See Background Tasks and Dialogs on 
page IV-321 for details. 
kill [= k]
Stops and releases task memory for reuse (k=1; default) or continues (k=0).
noEvent=mode
Controls Igor's event processing while a background task function is executing. The 
noEvents keyword was added in Igor Pro 8.04.
If your background task function uses a large fraction of available processor time, you 
may find that it is difficult to type on the command line or anywhere else. That is 
because Igor normally discards events that arrive while a user-defined function is 
running, causing events to be lost. This is the default mode of operation and 
corresponds to noEvents=0.
Using noEvents=1 causes Igor to postpone event handling until after the background 
task function returns which improves the reliability of the user interface. A 
consequence of using noEvents=1 is that you can not abort a rogue background task 
function using User Abort Key Combinations.
The noEvents keyword applies to all background tasks, including the unnamed 
background task. You should use _all_ for the taskName parameter.
mode defaults to 0 when Igor starts. The mode set using noEvents remains in effect 
until Igor quits.
period=deltaTicks 
Sets the minimum number of ticks (deltaTicks) that must pass between background 
task invocations. deltaTicks is truncated to an integer and clipped to a value greater 
than zero. See Background Task Period on page IV-320 for details.
proc=funcName 
Specifies name of a background user function (see Details).
start [=startTicks]
Starts when the tick count reaches startTicks. A task starts immediately without 
startTicks.
status
Returns background task information in the S_info string variable.
stop [= s]
Stops the background task (s=1; default) or continues (s=0).
