# Calling an External Operation From a User-Defined Function

Chapter IV-7 — Programming Techniques
IV-202
When Execute runs, it is as if you typed a command in the command line. Local variables in macros and 
functions are not accessible. The example in Calling an External Operation From a User-Defined Function 
on page IV-202 shows how to use the sprintf operation to solve this problem.
Using a Macro From a User-Defined Function
A macro can not be called directly from a user function. To do so, we must use Execute. This is a trivial 
example for which we would normally not resort to Execute but which clearly illustrates the technique.
Function Example()
Make wave0=enoise(1)
Variable/G V_avg
// Create a global
Execute "MyMacro(\"wave0\")"
// Invokes MyMacro("wave0")
return V_avg
End
Macro MyMacro(wv)
String wv
WaveStats $wv
// Sets global V_avg and 9 other local vars
End
Execute does not supply good error messages. If the macro generates an error, you may get a cryptic mes-
sage. Therefore, debug the macro before you call it with the Execute operation.
Calling an External Operation From a User-Defined Function
Prior to Igor Pro 5, external operations could not be called directly from user-defined functions and had to be 
called via Execute. Now it is possible to write an external operation so that it can be called directly. However, 
very old XOPs that have not been updated still need to be called through Execute. This example shows how 
to do it.
If you attempt to directly use an external operation which does not support it, Igor displays an error dialog 
telling you to use Execute for that operation.
The external operation in this case is VDTWrite which sends text to the serial port. It is implemented by the 
VDT XOP (no longer shipped as of Igor7).
Function SetupVoltmeter(range)
Variable range
// .1, .2, .5, 1, 2, 5 or 10 volts
String voltmeterCmd
sprintf voltmeterCmd, "DVM volts=%g", range
String vdtCmd
sprintf vdtCmd "VDTWrite \"%s\"\r\n", voltmeterCmd
Execute vdtCmd
End
In this case, we are sending the command to a voltmeter that expects something like:
DVM volts=.2<CR><LF>
to set the voltmeter to the 0.2 volt range.
The parameter that we send to the Execute operation is:
VDTWrite "DVM volts=.2\r\n"
The backslashes used in the second sprintf call insert two quotation marks, a carriage return, and a linefeed 
in the command about to be executed.
A newer VDT2 XOP exists which includes external operations that can be directly called from user-func-
tions. Thus, new programming should use the VDT2 XOP and will not need to use Execute.
