# RemoveImage

RemoveFromTable
V-794
Use RemoveFromList to remove item(s) from a string containing a list of items separated by a string (usually a 
single ASCII character), such as those returned by functions like TraceNameList or AnnotationList, or a line 
from a delimited text file.
If all items in itemOrListStr are not found or if any of the arguments is "" then listStr is returned unchanged 
(unless listStr contains only list separators, in which case an empty string is returned).
listSepStr and matchCase are optional; their defaults are ";" and 1 respectively.
Details
itemStr may have any length.
listStr is searched for an instance of the item string(s) bound by listSepStr on the left and right. All instances 
of the item(s) and any trailing listSepStr (if any) are removed from the returned string.
If the resulting string contains only listSepStr characters, then an empty string ("") is returned.
listStr is treated as if it ends with a listSepStr even if it doesn’t.
Searches for listSepStr are case-sensitive. Searches for items in itemOrListStr are usually case-sensitive. 
Setting the optional matchCase parameter to 0 makes the comparisons case insensitive.
In Igor6, only the first byte of listSepStr was used. In Igor7 and later, all bytes are used.
If matchCase is specified, then listSepStr must also be specified.
Examples
Print RemoveFromList("wave1", "wave0;wave1;")
// prints "wave0;"
Print RemoveFromList("wave1", ";wave1;;;;")
// prints ""
Print RemoveFromList("KEY=joy", "AX=3,KEY=joy", ",")
// prints "AX=3,"
Print RemoveFromList("fred", "fred\twilma", "\t")
// prints "wilma"
Print RemoveFromList("fred;barney","fred;wilma;barney")// prints "wilma;"
Print "X"+RemoveFromList("",";;;;")+"Y" 
// prints "XY"
Print RemoveFromList("FRED", "fred;wilma")
// prints "fred;wilma"
Print RemoveFromList("FRED", "fred;wilma", ";", 0)
// prints "wilma"
See Also
The FindListItem, FunctionList, ItemsInList, RemoveByKey, RemoveListItem, StringFromList, 
StringList, TraceNameList, UpperStr, VariableList, and WaveList functions.
RemoveFromTable 
RemoveFromTable [/W=winName] columnSpec [, columnSpec]…
The RemoveFromTable operation removes the specified columns from the top table.
Parameters
columnSpecs are the same as for the Edit operation; usually they are just the names of waves.
Flags
See Also
Edit about columnSpecs, and AppendToTable.
RemoveImage 
RemoveImage [/W=winName/Z] imageInstance [, imageInstance]…
The RemoveImage operation removes the given image from the target or named graph.
Parameters
imageInstance is usually simply the name of a wave. More precisely, imageInstance is a wave name, optionally 
followed by the # character and an instance number to identify which image of a given wave is to be removed.
/W=winName
Removes columns from the named table window or subwindow. When omitted, 
action will affect the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
