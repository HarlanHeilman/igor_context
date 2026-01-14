# Macro Execute Error: The Debug Button

Chapter IV-8 — Debugging
IV-215
When Debug On Abort is enabled, the Abort button in the status bar is labeled "Debug", instead of "Abort". 
Click Debug to enter the debugger after the currently executing line finishes.
When Debug On Abort is disabled, clicking the Abort button stops all command execution and returns Igor 
to normal interactive operation.
Debug on Abort does not affect programmed aborts using the Abort, AbortOnRTE, or AbortOnValue oper-
ations.
Normally clicking the Abort button interrupts whatever command is running. For example, you can abort 
a wave assignment statement that is taking a long time.
To avoid entering the debugger when a command is half-finished, with Debug on Abort enabled, when you 
click the Debug button, Igor waits for the current command to finish before breaking into the debugger. If 
a very length operation or assignment statement is running, you may have to wait a long time for the 
debugger to activate.
You can interrupt the currently running command and enter the debugger more quickly using the User 
Abort Key Combinations instead of clicking the Debug button. This may enter the debugger at a time when 
an assignment is only partially finished.
Some Igor code cannot be debugged. This includes thread-safe function code, hidden code, or independent 
module code (but see SetIgorOption IndependentModuleDev=1 on page IV-239). If you click the Debug 
button or use the Abort key combinations while running code that cannot be debugged, code execution is 
stopped just as if Debug on Abort was not set. For instance, this:
ThreadSafe Function Mistake()
Variable n=1
do
// forgot to increment n
while (n<10)
End
cannot be debugged. Clicking Debug or using the Abort key combinations aborts execution. To debug this 
code, temporarily remove the Threadsafe keyword from the function declaration.
Macro Execute Error: The Debug Button
When the debugger is enabled and an error occurs in a macro, Igor presents an error dialog with, in most 
cases, a Debug button. Click the Debug button to open the debugger window.
Errors in macros and procs are reported immediately after they occur.
When an error occurs in a user-defined function, Igor displays an error dialog long after the error actually 
occurred. The Debug On Error option is for programmers and displays errors in functions when they occur.
