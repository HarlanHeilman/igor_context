# Debugging on Error

Chapter IV-8 — Debugging
IV-213
Igor displays the debugger window when one of the following events occurs:
1.
A breakpoint that you previously set is hit
2.
An error occurs, and you have enabled debugging on that kind of error
3.
An error dialog is presented, and you click the Debug button
4.
The Debugger command is executed
The debugger can not be used with threadsafe code. See Debugging ThreadSafe Code on page IV-225 for 
details.
Setting Breakpoints
When you want to observe a particular routine in action, set a breakpoint on the line where you want the 
debugger to appear. To do this, open the procedure window which contains the routine, and click in the left 
“breakpoint margin”. The breakpoint margin appears only if the debugger has been enabled. These graph-
ics show the procedure windowwith the debugger disabled (left) and enabled (right):
The red dot denotes a breakpoint that you have set.
When a line of code marked with a breakpoint is about to execute, Igor displays the debugger window.
Click the red dot again to clear the breakpoint. Control-click (Macintosh) or right-click (Windows) and use the pop-
up menu to clear all breakpoints or disable a breakpoint on the currently selected line of the procedure window.
Debugging on Error
You can automatically open the debugger window when an error occurs. There are two categories of errors 
to choose from:
We recommend that Igor programmers turn both of these options on to get timely information about errors.
Use the Procedure or contextual menus to enable or disable both error categories. If the selected error 
occurs, Igor displays the debugger with an error message in its status area. The error message was gener-
ated by the command indicated by a round yellow icon, in this example the Print str command:
Debug On Error
Any runtime error except failed NVAR, SVAR, or WAVE references.
NVAR SVAR WAVE Checking
Failed NVAR, SVAR, or WAVE references.
