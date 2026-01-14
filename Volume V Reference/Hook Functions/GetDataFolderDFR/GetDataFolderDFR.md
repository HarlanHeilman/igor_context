# GetDataFolderDFR

GetBrowserSelection
V-296
Documentation for the GetBrowserLine function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "GetBrowserLine"
GetBrowserSelection
GetBrowserSelection(index [, mode])
The GetBrowserSelection function returns a string containing the full path, quoted if necessary, to a selected 
Data Browser item.
Documentation for the GetBrowserSelection function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "GetBrowserSelection"
GetCamera 
GetCamera [flags] [keywords]
The GetCamera operation provides information about a camera window.
Documentation for the GetCamera operation is available in the Igor online help files only. In Igor, execute:
DisplayHelpTopic "GetCamera"
GetDataFolder 
GetDataFolder(mode [, dfr])
The GetDataFolder function returns a string containing the name of or full path to the current data folder 
or, if dfr is present, the specified data folder.
GetDataFolderDFR is preferred.
Parameters
If mode=0, it returns just the name of the data folder.
If mode=1, GetDataFolder returns a string containing the full path to the data folder.
dfr, if present, specifies the data folder of interest.
Details
GetDataFolder can be used to save and restore the current data folder in a procedure. However 
GetDataFolderDFR is preferred for that purpose.
Examples
String savedDataFolder = GetDataFolder(1)
// Save
SetDataFolder root:
Variable/G gGlobalRootVar
SetDataFolder savedDataFolder
// and restore
See Also
Chapter II-8, Data Folders.
The SetDataFolder operation and GetDataFolderDFR function.
GetDataFolderDFR 
GetDataFolderDFR()
The GetDataFolderDFR function returns the data folder reference for the current data folder.
Details
GetDataFolderDFR can be used to save and restore the current data folder in a procedure. It is like 
GetDataFolder but returns a data folder reference rather than a string.
Example
DFREF saveDFR = GetDataFolderDFR()
// Save
SetDataFolder root:
Variable/G gGlobalRootVar
SetDataFolder saveDFR
// and restore
