# DataFolderList

DataFolderExists
V-142
DataFolderExists 
DataFolderExists(dataFolderNameStr)
The DataFolderExists function returns the truth that the specified data folder exists.
dataFolderNameStr can bea a full path or partial path relative to the current data folder.
If dataFolderNameStr is empty (“”), DataFolderExists returns 1 because, for historical reasons, an empty data 
folder path is taken to refer to the current data folder.
See Also
Chapter II-8, Data Folders.
DataFolderList
DataFolderList(matchStr, separatorStr [, dfr ] )
The DataFolderList function returns a string containing a list of data folder names selected based on the 
matchStr parameter. The data folders listed are all within the current data folder or the folder specified by 
dfr.
The DataFolderList function was added in Igor Pro 9.00.
Details
For a data folder name to appear in the output string, it must match matchStr. separatorStr is appended to 
each data folder name as the output string is generated.
The name of each data folder is compared to matchStr, which is some combination of normal characters and 
the asterisk wildcard character that matches anything. For example:
matchStr may begin with the "!" character to return items that do not match the rest of matchStr. For example:
The "!" character is considered to be a normal character if it appears anywhere else.
dfr is an optional data folder reference: a data folder name, an absolute or relative data folder path, or a 
reference returned by, for example, GetDataFolderDFR.
The returned list contains data folder names only, without data folder paths. Use GetDataFolder to get the 
data folder path prefix.
Liberal data folder names are quoted if necessary; see Liberal Object Names on page III-501.
Examples
NewDataFolder/O aSubDataFolder
NewDataFolder/O 'Another quoted subfolder'
// Print the list of data folders in the current data folder whose names begin with a or A
Print DataFolderList("a*",";")
 aSubDataFolder;'Another quoted subfolder';
// Print the list of all data folders in the root:Packages data folder.
Print DataFolderList("*",";", root:Packages)
 WM_MedianXY;WM_WaveSelectorList;WindowCoordinates;
See Also
Data Folders on page II-107, GetDataFolderDFR, GetIndexedObjName, StringList, StringFromList, 
VariableList, WaveList, PossiblyQuoteName
"*"
Matches all data folder names.
"xyz"
Matches data folder name xyz only.
"*xyz"
Matches data folder names which end with xyz.
"xyz*"
Matches data folder names which begin with xyz.
"*xyz*"
Matches data folder names which contain xyz.
"abc*xyz"
Matches data folder names which begin with abc and end with xyz.
"!*xyz"
Matches data folder names which do not end with xyz.
