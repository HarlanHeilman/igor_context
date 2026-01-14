# MoveWave

MoveVariable
V-665
MoveVariable 
MoveVariable sourceVar, destDataFolderPath [newname]
The MoveVariable operation removes the source numeric variable and places it in the specified location 
optionally with a new name.
Parameters
sourceVar can be just the name of a numeric variable in the current data folder, a partial path (relative to the 
current data folder) and variable name or an absolute path (starting from root) and variable name.
destDataFolderPath can be a partial path (relative to the current data folder) or an absolute path (starting 
from root).
Details
An error is issued if a variable or wave of the same name already exists at the destination.
Examples
MoveVariable :foo:v1,:bar:
// Move v1 into data folder bar
MoveVariable :foo:v1,:bar:vv1
// Move v1 into bar with new name vv1
See Also
The MoveString, MoveWave, and Rename operations; and Chapter II-8, Data Folders.
MoveWave 
MoveWave sourceWave,[destDataFolderPath:] [newName]
The MoveWave operation removes the source wave and places it in the specified location optionally with 
a new name.
If you want to rename a wave without moving it, use Rename instead.
Parameters
sourceWave can be just the name of a wave in the current data folder, a partial path (relative to the current 
data folder) and wave name, an absolute path (starting from root) and wave name, or a wave reference 
variable in a user-defined function.
destDataFolderPath can be a partial path (relative to the current data folder), an absolute path (starting from 
root), or a data folder reference (DFREF) in a user-defined function. If the destination is a null DFREF, the 
wave is moved to the current data folder.
Details
An error is issued if a variable or wave of the same name already exists at the destination.
MoveWave Destination
Depending on the syntax you use, MoveWave may move sourceWave to another data folder, rename 
sourceWave, or both. To explain this, we show examples below which call this setup function:
Function Setup()
SetDataFolder root:
KillDataFolder root:
// clear out any previous stuff
NewDataFolder/O root:DF0
Make/O root:wave0
End
The Setup function gives you a data hierarchy like this:
root (<- current data folder)
wave0
DF0
// 1. Simple dest name: Renames wave0 as wave1
Function Demo1()
Setup()
Wave w = root:wave0
MoveWave w, wave1
// Use Rename instead
End
// 2. Dest path with trailing colon: Moves wave0 without renaming
Function Demo2()
Setup()
