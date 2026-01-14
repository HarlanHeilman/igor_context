# GetSelection

GetScrapText
V-315
Print "Routines in calling chain: " + GetRTStackInfo(0)
End
Function Calling()
Called()
End
Macro StartItUp()
Calling()
End
// Executing StartItUp() prints:
 Called by Calling()
 Routines in calling chain: StartItUp;Calling;Called;
MultiThread Example
Macro BeginMultiThread(code)
Variable code=3
BeginMultiThreadFunc(code)
End
Function BeginMultiThreadFunc(Variable code)
Make/O/N=4/T/FREE textWave
MultiThread textWave = tsworker(code)
Print textWave[0]
End
ThreadSafe Function/S tsworker(Variable code)
String str= tssubr(code)
return str
End
ThreadSafe Function/S tssubr(Variable code)
String str= GetRTStackInfo(code)
return str
End
// Executing BeginMultiThread(3) prints details for only the two threaded routines:
tsworker,TSExample,16;tssubr,TSExample,21;
See Also
The Stack and Variables Lists, ThreadSafe Functions and Multitasking, GetRTError
GetScrapText 
GetScrapText()
The GetScrapText function returns a string containing any plain text on the Clipboard (aka “scrap”). This 
is the text that would be pasted into a text document if you used Paste in the Edit menu.
See Also
The PutScrapText and LoadPICT operations.
GetSelection 
GetSelection winType, winName, bitflags
The GetSelection operation returns information about the current selection in the specified window.
Parameters
winType is one of the following keywords:
graph, panel, table, layout, notebook, procedure
winName is the name of a window of the specified type.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
If winType is procedure then winName is actually a procedure window title inside a $"" wrapper, such as:
GetSelection procedure $"DemoLoader.ipf", 3
bitflags is a bitwise parameter that is used in different ways for different window types, as described in Details. 
You should use 0 for undefined bits. Setting Bit Parameters on page IV-12 for further details about bit settings.
