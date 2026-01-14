# MacroList

MacroList
V-524
Details
Because macros exist only in the ProcGlobal context, macroNameStr must contain a simple name, not be a 
double name in <module>#<name> format. 
The returned string contains several groups of information. Each group is prefaced by a keyword and colon, 
and terminated with the semicolon. The keywords are as follows:
See Also
Macro, Proc, Window, MacroList, MacroPath, FunctionInfo, StringByKey, NumberByKey
MacroList 
MacroList(matchStr, separatorStr, optionsStr)
The MacroList function returns a string containing a list of the names of user-defined procedures that start 
with the Proc, Macro, or Window keywords that also satisfy certain criteria. Note that if the procedures 
need to be compiled, then MacroList may not list all of the procedures.
Parameters
Only macros having names that match matchStr string are listed. See WaveList for examples.
separatorStr is appended to each macro name as the output string is generated. separatorStr is usually “;” for list 
processing (See Processing Lists of Waves on page IV-198 for details on list processing).
optionsStr is used to further qualify the macros. It is a string containing keyword-value pairs separated by 
commas. Available options are:
Keyword
Information Following Keyword
NAME
The name of the macro. Same as contents of macroNameStr in most cases.
PROCWIN
Title of procedure window containing the macro definition.
PROCLINE
Line number within the procedure window of the macro definition.
MODULE
Module containing macro definition (see Regular Modules on page IV-236). Blank if 
the procedure window lacks a #pragma moduleName definition.
KIND
Macro, Proc or Window.
N_PARAMS
Number of parameters for this macro.
SUBTYPE
The macro subtype.
KIND:nk
NPARAMS:np
Restricts the list to macros having exactly np parameters. Omitting this option lists 
macros having any number of parameters.
SUBTYPE:typeStr
Lists macros that have the type typeStr. That is, you could use ButtonControl as typeStr 
to list only macros that are action procedures for buttons.
WIN:windowNameStr
Lists macros that are defined in the named procedure window. “Procedure” is the 
name of the built-in procedure window.
Note: Because optionsStr keyword-value pairs are comma separated and procedure 
window names can have commas in them, the WIN: keyword must be the last one 
specified.
Determines the kind of procedure returned.
nk can be the sum of these values to match multiple procedure kinds. For example, 
use 3 to list both Proc and Macro procedures.
nk=1:
List Proc procedures.
nk=2:
List Macro procedures.
nk=4:
List Window procedures.
