# ProcedureVersion

ProcedureVersion
V-780
You can use procedureWinTitleStr to select one of several static functions with identical names among 
different procedure windows, even if they do not use a #pragma moduleName=myModule statement.
Advanced Parameters
If SetIgorOption IndependentModuleDev=1, procedureWinTitleStr can also be a title followed by a 
space and, in brackets, an independent module name. In such cases ProcedureText retrieves function text 
from the specified procedure window and independent module. (See Independent Modules on page 
IV-238 for independent module details.)
For example, in a procedure file containing:
#pragma IndependentModule=myIM
#include <Axis Utilities>
A call to ProcedureText like this:
String text=ProcedureText("HVAxisList",0,"Axis Utilities.ipf [myIM]")
will return the text of the HVAxisList function located in the Axis Utilities.ipf procedure window, which 
is normally a hidden part of the myIM independent module.
You can see procedure window titles in this format in the WindowsProcedure Windows menu when 
SetIgorOption IndependentModuleDev=1 and when an experiment contains procedure windows 
that comprise an independent module, as does #include <New Polar Graphs>.
procedureWinTitleStr can also be just an independent module name in brackets to retrieve function text from 
any procedure window that belongs to the named independent module:
String text=ProcedureText("HVAxisList",0,"[myIM]")
See Also
Regular Modules on page IV-236 and Independent Modules on page IV-238.
The WinRecreation and FunctionList functions.
ProcedureVersion
ProcedureVersion(macroOrFunctionNameStr [, procedureWinTitleStr ])
The ProcedureVersion function returns the version number as specified by the first #pragma 
version=versionNum in the procedure file containing the named macro, function. Alternatively it can 
returh the version number of a specified procedure window.
The ProcedureVersion function was added in Igor Pro 9.01.
Parameters
macroOrFunctionNameStr identifies the macro or function. It may be just the name of a global (nonstatic) 
procedure, or it may include a module name, such as "MyModule#MyFunction" to specify the static 
function MyFunction in a procedure window that contains a #pragma ModuleName=MyModule statement.
If macroOrFunctionNameStr is "" and procedureWinTitleStr is not specified then the value of the first #pragma 
version statement in the procedure window containing the currently running macro or function is returned.
If macroOrFunctionNameStr is "" and procedureWinTitleStr is specified then the value of the first #pragma 
version statement in that procedure window is returned.
Details
The return value is rounded to a multiple of 0.001.
The returned value is 0 if the #pragma version statement is absent or the procedure window is "invisible" 
because the function is an independent module but SetIgorOption IndependentModule=0.
Example
#pragma version=1.2345
// 1 more digit than recommended
...
Function Test()
Variable version = ProcedureVersion("") // Version of procedure file containing test
Print version
// 1.234
End
See Also
ProcedureText, FunctionList, MacroList
