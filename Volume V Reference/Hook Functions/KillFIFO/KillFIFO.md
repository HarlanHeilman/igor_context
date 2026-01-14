# KillFIFO

KillDataFolder
V-469
Flags
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
KillDataFolder 
KillDataFolder [/Z] dataFolderSpec
The KillDataFolder operation kills the specified data folder and everything in it including other data folders.
However, if dataFolderSpec is the name of a data folder reference variable that refers to a free data folder, the 
variable is cleared and the data folder is killed only if this is the last reference to that free data folder.
Flags
Parameters
dataFolderSpec can be just the name of a child data folder in the current data folder, a partial path (relative 
to the current data folder) and name or an absolute path (starting from root) and name.
Details
If specified data folder is the current data folder or contains the current data folder then Igor makes its 
parent the new current data folder.
For legacy reasons, a null data folder is taken to be the current data folder. This can happen when using a 
$ expression where the string might possibly evaluate to "".
It is legal to kill the root data folder. In this case the root data folder itself is not killed but everything in it 
is killed.
KillDataFolder generates an error if any of the waves involved are in use. In this case, nothing is killed.
KillDataFolder generates an error if any of the waves involved are in use. In this case, nothing is killed. 
Execution ceases unless /Z is specified.
The variable V_flag is set to 0 when there is no error, otherwise it is an error code.
Examples
KillDataFolder foo
// Kills foo in the current data folder.
KillDataFolder :bar:foo
// Kills foo in bar in current data folder.
String str= "root:foo"
KillDataFolder $str 
// Kills foo in the root data folder.
See Also
Chapter II-8, Data Folders and the KillStrings, KillVariables, and KillWaves operations.
KillFIFO 
KillFIFO FIFOName
The KillFIFO operation discards the named FIFO.
Details
FIFOs are used for data acquisition.
If there is an output or review file associated with the FIFO, KillFIFO closes the file. If the FIFO is used by 
an XOP, you should call the XOP to release the FIFO before killing it.
See Also
See FIFOs and Charts on page IV-313 for information about FIFOs and data acquisition.
/W=winName
Looks for the control in the named graph or panel window or subwindow. If /W is 
omitted, KillControl looks in the top graph or panel window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
No error reporting (except for setting V_flag). Does not halt function execution.
