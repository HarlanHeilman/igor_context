# WinName

WinName
V-1100
or a bitwise combination of the above for more than one type of inclusion.
You can combine the WIN, INCLUDE and INDEPENDENTMODULE options by separating them with a comma.
When the INDEPENDENTMODULE option is used, the title of any procedure window that is part of an 
independent module will be followed by " [<independent module name>]".
For example, if a procedure file contains:
#pragma IndependentModule=myIndependentModule
#include <Axis Utilities>
A call to WinList like this:
String list = WinList("* [myIndependentModule]", ";", "INDEPENDENTMODULE:1")
will store "Axis Utilities.ipf [myIndependentModule];" in the list string, along with any other procedure 
windows that are part of that independent module.
When the INDEPENDENTMODULE option is omitted, the returned procedure window titles do not include 
any independent module name suffix, and the procedure files "visible" to WinList depend on the setting of 
SetIgorOption independentModuleDev (which must be done after opening the experiment):
Examples 
See Also
Independent Modules on page IV-238. The ChildWindowList and WinType functions.
WinName 
WinName(index, windowTypes [, visibleWindowsOnly [, floatKind]])
The WinName function returns a string containing the name of the indexth window of the specified type, or 
an empty string ("") if no window fits the parameters.
If the optional visibleWindowsOnly parameter is nonzero, only visible windows are considered. Otherwise 
both visible and hidden windows are considered.
If the optional floatKind parameter is 1, only floating windows created with NewPanel/FLT=1 are 
considered. If floatKind is 2, only NewPanel/FLT=2 windows are considered. windowTypes must contain at 
least 64 (panels).
If floatKind is omitted or is 0 only non-floating ("normal") windows are considered.
Procedure windows don’t have names. WinName returns the procedure window title instead.
4:
Procedure windows included by #include <someFileName>.
SetIgorOption 
independentModuleDev=0
Consider procedure windows only if they are not part of 
any independent module and if they are not hidden 
(using #pragma hide, for example).
SetIgorOption 
independentModuleDev=1
Consider all procedure windows including those in 
independent modules or hidden.
Command
Returned List
WinList("*",";","")
All existing non-floating windows.
WinList("*", ";","WIN:3")
All graph and table windows.
WinList("Result_*", ";", "WIN:1")
Graphs whose names start with “Result_”.
WinList("*", ";","WIN:64,FLT:1,FLT:2")
All floating panel windows.
WinList("*", ";","INCLUDE:6")
All #included procedure windows.
WinList("*", ";","WIN:1,INCLUDE:6")
All graphs and #included procedure windows.
