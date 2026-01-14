# Searching the Command Window

Chapter II-2 — The Command Window
II-11
carbon copy notebook, it always applies the Command ruler to commands. It applies the Result ruler to 
results if the current ruler is Normal, Command or Result. You must create the Command and Result rulers 
if you want Igor to use them when sending text to the history carbon copy.
This function creates a formatted history carbon copy notebook with the Command and Result rulers used 
automatically by Igor as well as an Error ruler which we will use for our custom error messages:
Function CreateHistoryCarbonCopy()
NewNotebook /F=1 /N=HistoryCarbonCopy /W=(50,50,715,590)
Notebook HistoryCarbonCopy backRGB=(0,0,0)// Set background to black
Notebook HistoryCarbonCopy showRuler=0
// Define ruler to govern commands.
// Igor will automatically apply this to commands sent to history carbon copy.
Notebook HistoryCarbonCopy newRuler=Command,
rulerDefaults={"Geneva",10,0,(65535,65535,0)}
// Define ruler to govern results.
// Igor will automatically apply this to results sent to history carbon copy.
Notebook HistoryCarbonCopy newRuler=Result,
rulerDefaults={"Geneva",10,0,(0,65535,0)}
// Define ruler to govern user-generated error messages.
// We will apply this ruler to error messages that we send
// to history carbon copy via Print commands.
Notebook HistoryCarbonCopy newRuler=Error, 
rulerDefaults={"Geneva",10,0,(65535,0,0)}
End
If the current ruler is not Normal, Command or Result, it is assumed to be a custom ruler that you want to 
use for special messages sent to the history using the Print operation. In this case, Igor does not apply the 
Result ruler but rather allows your custom ruler to remain in effect.
This function sends an error message to the history using the custom Error ruler in the history carbon copy 
notebook:
Function PrintErrorMessage(message)
String message
Notebook HistoryCarbonCopy, ruler=Error
Print message
// Set ruler back to Result so that Igor's automatic use of the Command
// and Result rulers will take effect for subsequent commands.
Notebook HistoryCarbonCopy, ruler=Result
End
XOP programmers can use the XOPNotice3 XOPSupport routine to control the color of text sent to the 
History Carbon Copy notebook.
Searching the Command Window
You can search the command line or the history by choosing Find from the Edit menu or by using the key-
board shortcuts as shown in the Edit menu. This displays the find bar.
Searching the command line is most often used to modify a previously executed command before reexecuting 
it. For example, you might want to replace each instance of a particular wave name with another wave name.
