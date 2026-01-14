# RenameDataFolder

RemovePath
V-796
offset is optional and requires Igor Pro 7.00 or later. If omitted it defaults to 0. The search begins offset bytes 
into listStr. When iterating through lists containing large numbers of items, using the offset parameter 
provides dramatically faster execution. For an example using the offset parameter, see StringFromList.
Details
RemoveListItem differs from RemoveFromList in that it specifies the item to be removed by index and 
removes only that item, while RemoveFromList specifies the item to be removed by value, and removes all 
matching items.
If index less than 0 or greater than ItemsInList(listStr) - 1, or if listSepStr is "" then listStr is returned 
unchanged (unless listStr contains only list separators, in which case an empty string is returned).
If the resulting string contains only listSepStr characters, then an empty string ("") is returned.
Examples
Print RemoveListItem(1, "wave0;wave1;w2;")
// Prints "wave0;w2;"
See Also
The AddListItem, FindListItem, FunctionList, ItemsInList, RemoveByKey, RemoveFromList, 
StringFromList, StringList, TraceNameList, VariableList, WaveList, and WhichListItem functions.
RemovePath 
RemovePath [/A/Z] pathName
The RemovePath operation removes a path from the list of symbolic paths. RemovePath is an old name for 
the new KillPath operation, which we recommend you use instead.
Rename 
Rename oldName, newName
The Rename operation renames waves, strings, or numeric variables from oldName to newName.
Parameters
oldName may be a simple object name or a data folder path and name. newName must be a simple object name.
Details
You can not rename an object using a name that already exists. The following will result in an error:
Make wave0, wave1
// Rename wave0 and overwrite wave1.
Rename wave0, wave1
// This will not work.
However, you can achieve the desired effect as follows:
Make wave0, wave1
Duplicate/O wave0, wave1; KillWaves wave0
See Also
The Duplicate operation.
RenameDataFolder 
RenameDataFolder sourceDataFolderSpec, newName
The RenameDataFolder operation changes the name of the source data folder to the new name.
sourceDataFolderSpec can be just the name of a child data folder in the current data folder, a partial path 
(relative to the current data folder) and name or an absolute path (starting from root) and name.
newName is just the new name for the data folder, without any path.
Details
RenameDataFolder generates an error if the new name is already in use as a data folder contained within 
the source data folder.
Examples
RenameDataFolder root:foo,foo2
// Change name of foo to foo2
