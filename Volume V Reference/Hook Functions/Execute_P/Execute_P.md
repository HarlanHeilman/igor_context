# Execute/P

Execute
V-204
See Also
FindPeak
Execute 
Execute [/Z] cmdStr
The Execute operation executes the contents of cmdStr as if it had been typed in the command line.
The most common use of Execute is to call a macro or an external operation from a user-defined function. 
This is necessary because Igor does not allow you to make such calls directly.
When the /Z flag is used, an error code is placed in V_flag.The error code will be -1 if a missing parameter 
style macro is called and the user clicks Quit Macro, or zero if there was no error.
Flags
Details
Because the command line and command buffer are limited to 2500 bytes on a single line, cmdStr is likewise 
limited to a maximum of 2500 executable bytes.
Do not reference local variables in cmdStr. The command is not executed in the local environment provided 
by a macro or user-defined function.
Execute can accept a string expression containing a macro. The string must start with Macro, Proc, or 
Window, and must follow the normal rules for macros. All lines must be terminated with carriage returns 
including the last line. The name of the macro is not important but must exist. Errors will be reported except 
when using the /Z flag, which will assign V_Flag a nonzero number in an error condition.
Examples
It is a good idea to compose the command to be executed in a local string variable and then pass that string 
to the Execute operation. This prints the string to the history for debugging:
String cmd
sprintf cmd, "GBLoadWave/P=%s/S=%d \"%s\"", pathName, skipCount, fileName
Print cmd
// For debugging
Execute cmd
// Execute with a macro:
Execute "Macro junk(a,b)\rvariable a=1,b=2\r\rprint \"hello from macro\",a,b\rEnd\r"
See Also
The Execute Operation on page IV-201 for other uses.
Execute/P 
Execute/P [/Q/Z] cmdStr
Execute/P is similar to Execute except the command string, cmdStr, is not immediately executed but rather 
is posted to an operation queue. Items in the operation queue execute only when nothing else is happening. 
Macros and functions must not be running and the command line must be empty.
/E=bothEdgesWave
bothEdgesWave specifies an already-existing output wave. It must have a length of 
at least npks*2. The point coordinates of the i-th peak edges are stored in 
bothEdgesWave[i*2] and bothEdgesWave[i*2+1].
If the X values increase with point number, bothEdgesWave[i*2] will be greater than 
bothEdgesWave[i*2+1], which may defy expectations.
/X=xWave
xWave supplies the X coordinates for the corresponding points in peakWave and 
baseWave. It must be of the same length as peakWave and must be monotonically 
increasing or decreasing.
/Z
Errors are not fatal and error dialogs are suppressed.
