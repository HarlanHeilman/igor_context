# MoveDataFolder

ModuleName
V-658
ModuleName 
#pragma ModuleName = modName
The ModuleName pragma assigns a name, which must be unique among all procedure files, to a procedure 
file so that you can use static functions and Proc Pictures in a global context, such as in the action procedure 
of a control or on the Command Line.
Using the ModuleName pragma involves at least two steps. First, within the procedure file assign it a name 
using #pragma ModuleName=modName, and then access objects in the named file by preceding the object 
name with the name of the module and the # character, such as or example: ModName#StatFuncName().
See Also
The Regular Modules on page IV-236, Static, Picture, and #pragma.
MoveDataFolder 
MoveDataFolder [ /O=options /Z ] sourceDataFolderSpec, destDataFolderPath
The MoveDataFolder operation removes the source data folder (and everything it contains) and places it at 
the specified location with the original name.
Parameters
sourceDataFolderSpec can be just the name of a child data folder in the current data folder, a partial path 
(relative to the current data folder) and name or an absolute path (starting from root) and name.
destDataFolderPath can be a partial path (relative to the current data folder) or an absolute path (starting 
from root).
Flags
Details
MoveDataFolder generates an error if a data folder of the same name already exists at the destination unless 
the /O flag is used. When the /O flag is non-zero and the destination data folder already exists, 
MoveDataFolder is equivalent to DuplicateDataFolder followed by a KillDataFolder on the source.
Output Variables
MoveDataFolder sets the following output variable:
/O=options
Overwrites the destination data folder if it already exists.
The /O flag was added in Igor Pro 8.00.
options=1: Completely overwrites the destination data folder. If the destination data 
folder exists, MoveDataFolder first deletes it if possible. If it can not be deleted, for 
example because it contains a wave that is in use, MoveDataFolder generates an error. 
If the deletion succeeds, MoveDataFolder then copies the source to the destination. 
Then the source data folder is deleted.
options=2: Merges the source data folder into the destination data folder. If an item in 
the source data folder exists in the destination data folder, MoveDataFolder 
overwrites it. Otherwise it copies it. Items in the destination data folder that do not 
exist in the source data folder remain in the destination data folder. Then the source 
data folder is deleted.
options=3: Merges the source data folder into the destination data folder and then 
deletes items that are not in the source data folder if possible. If an item in the source 
data folder does not exist in the destination data folder, MoveDataFolder attempts to 
delete it from the destination data folder. If it can not be deleted because it is in use, 
no error is generated. Then the source data folder is deleted.
/Z
Errors are not fatal - if an error occurs, procedure execution continues. You can check 
the V_flag output variable to see if an error occurred.
V_flag
0 if the operation succeeded or a non-zero error code. The V_flag output variable was 
added in Igor Pro 8.00.
