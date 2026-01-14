# IgorStartOrNewHook

Chapter IV-10 — Advanced Topics
IV-292
Example
This example invokes the Export Graphics menu item when Command-C (Macintosh) or Ctrl+C (Windows) 
is selected for all graphs, preventing Igor from performing the usual Copy.
Function IgorMenuHook(isSel, menuStr, itemStr, itemNo, activeWindowStr, wt)
Variable isSel
String menuStr, itemStr
Variable itemNo
String activeWindowStr
Variable wt
Variable handled= 0
if( Cmpstr(menuStr,"Edit") == 0 && CmpStr(itemStr,"Copy") == 0 )
if( wt == 1 )
// graph
// DoIgorMenu would cause recursion, so we defer execution
Execute/P/Q/Z "DoIgorMenu \"Edit\", \"Export Graphics\""
handled= 1
endif
endif
return handled
End
See Also
SetWindow, Execute, and SetIgorHook.
IgorQuitHook
IgorQuitHook(igorApplicationNameStr)
IgorQuitHook is a user-defined function that Igor calls when Igor is about to quit.
The value returned by IgorQuitHook is ignored.
Parameters
igorApplicationNameStr contains the name of the currently running Igor Pro application (including the .exe 
extension under Windows).
Details
You can determine the full directory and file path of the Igor application by calling the PathInfo operation 
with the Igor path name. See the example in IgorStartOrNewHook on page IV-292.
See Also
IgorBeforeQuitHook and SetIgorHook.
IgorStartOrNewHook
IgorStartOrNewHook(igorApplicationNameStr)
IgorStartOrNewHook is a user-defined function that Igor calls when starting up and when creating a new 
experiment. It is also called if Igor is launched as a result of double-clicking a saved Igor experiment.
Igor ignores the value returned by IgorStartOrNewHook.
Parameters
igorApplicationNameStr contains the name of the currently running Igor Pro application (including the .exe 
extension under Windows).
Details
You can determine the full directory and file path of the Igor application by calling the PathInfo operation 
with the Igor path name.
Example
This example prints the full path of Igor application whenever Igor starts up or creates a new experiment:
Function IgorStartOrNewHook(igorApplicationNameStr)
String igorApplicationNameStr
PathInfo Igor
// puts path value into (local) S_path
printf "\"%s\" (re)starting\r", S_path + igorApplicationNameStr
End
