# StructFill

strswitch-case-endswitch
V-1002
Print strsearch(str,"is",3)
// prints 5
Print strsearch(str,"is",Inf,1)
// prints 15
See Also
sscanf, FindListItem, ReplaceString, Character-by-Character Operations
See Setting Bit Parameters on page IV-12 for details about bit settings.
strswitch-case-endswitch 
strswitch(<string expression>)
case <literal><constant>:
<code>
[break]
[default:
<code>]
endswitch
A strswitch-case-endswitch statement evaluates a string expression and compares the result to the case 
labels using a case-insensitive comparison. If a case label matches string expression, then execution proceeds 
with code following the matching case label. When none of the cases match, execution will continue at the 
default label, if it is present, or otherwise the strswitch will be exited with no action taken. Note that 
although the break statement is optional, in almost all case statements it will be required for the strswitch 
to work correctly.
See Also
Switch Statements on page IV-43, default and break for more usage details.
STRUCT 
STRUCT structureName localName
STRUCT is a reference that creates a local reference to a Structure accessed in a user-defined function. When 
a Structure is passed to a user function, it can only be passed by reference, so in the declaration within the 
function you must use &localStructName to define the function input parameter.
See Also
Structures in Functions on page IV-99 for further information.
See the Structure keyword for creating a Structure definition.
StructFill
StructFill [ /AC=createFlags /SDFR=dfr ] structVar
StructFill is a programmer-convenience operation that initializes NVAR, SVAR and WAVE fields in a 
structure. At run time, it scans through the fields in the specified structure and attempts to set all null 
NVAR, SVAR and WAVE fields by looking up corresponding same-named globals in the current data 
folder or in the specified data folder.
StructFill was added in Igor Pro 8.00.
Parameters
structVar is the name of a STRUCT variable.
