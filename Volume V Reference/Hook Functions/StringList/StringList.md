# StringList

StringList
V-999
// Do something with item
offset += strlen(item) + separatorLen
endfor
End
See Also
The AddListItem, ItemsInList, FindListItem, RemoveListItem, RemoveFromList, WaveList, 
WhichListItem, StringByKey, ListMatch, ControlNameList, TraceNameList, StringList, VariableList, 
and FunctionList functions.
StringList 
StringList(matchStr, separatorStr [, dfr ])
The StringList function returns a string containing a list of global string variables selected based on the 
matchStr parameter. The string variables listed are all in the current data folder or the data folder specified 
by dfr.
Details
For a string variable name to appear in the output string, it must match matchStr. separatorStr is appended 
to each string variable name as the output string is generated.
The name of each string variable is compared to matchStr, which is some combination of normal characters 
and the asterisk wildcard character that matches anything. For example:
The returned list contains names only, without data folder paths. Thus, they are not suitable for accessing 
string variables outside the current or specified data folder.
matchStr may begin with the ! character to return items that do not match the rest of matchStr. For example:
The ! character is considered to be a normal character if it appears anywhere else, but there is no practical 
use for it except as the first character of matchStr.
dfr is an optional data folder reference: a data folder name, an absolute or relative data folder path, or a 
reference returned by, for example, GetDataFolderDFR. The dfr parameter requires Igor Pro 9.00 or later.
Examples
See Also
VariableList, WaveList, DataFolderList
"*"
Matches all string variable names
"xyz"
Matches name xyz only
"*xyz"
Matches names which end with xyz
"xyz*"
Matches names which begin with xyz
"*xyz*"
Matches names which contain xyz
"abc*xyz"
Matches names which begin with abc and end with xyz
"!*xyz"
Matches variable names which do not end with xyz
StringList("*",";")
Returns a list of all string variables in the current data folder.
StringList("S_*", ";")
Returns a list of all string variables in the current data folder 
whose names begin with “S_”.
