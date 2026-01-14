# DataFolderRefStatus

DataFolderRefChanges
V-143
DataFolderRefChanges
DataFolderRefChanges(dfr, changeType)
The DataFolderRefChanges function returns the number of changes to the data folder specified by the data 
folder reference dfr.
Use DataFolderRefChanges to decide when to update something that depends on the data folder's state by 
comparing the current number of changes to the change count when your previous update was done. 
DataFolderRefChanges is not thread-safe so this must be done in the main thread.
Changes to the data folder and its contents are tracked by incrementing a count specific to kind of change. 
The changeType parameter select one of those counts.
The DataFolderRefChanges function was added in Igor Pro 9.00.
Parameters
dfr is a data folder reference.
changeType is one of the following values:
Details
The definition of a "change" depends on the object.
For data folders, a "change" is when a child data folder is created, killed, or renamed.
For waves, a "change" is when a wave is created, killed, renamed, locked, or modified.
For string or numeric values, a "change" is when they are created, killed, renamed, or modified.
The change counts are reset to 0 when the experiment is reopened.
Examples
Variable oldWaveChanges = DataFolderRefChanges(GetDataFolderDFR(),1)
Make/O/N=10 aWave = p
Variable newWaveChanges = DataFolderRefChanges(GetDataFolderDFR(),1)
Variable dif = newWaveChanges - oldWaveChanges
Print dif 
// Prints 2: 1 for Make, 1 for aWave=p
See Also
Data Folders on page II-107, Data Folder References on page IV-78, Built-in DFREF Functions on page 
IV-81.
DataFolderRefsEqual
DataFolderRefsEqual(dfr1, dfr2)
The DataFolderRefsEqual function returns the truth the two data folder references are the same.
See Also
Data Folders on page II-107, Data Folder References on page IV-78, Built-in DFREF Functions on page 
IV-81.
DataFolderRefStatus 
DataFolderRefStatus(dfr)
The DataFolderRefStatus function returns the status of a data folder reference.
Details
DataFolderRefStatus returns zero if the data folder reference is invalid or non-zero if it is valid.
0:
Changes to any to the data folder's waves, numeric variables, strings, or child data folders.
1:
Changes to the data folder's waves.
2:
Changes to the data folder's numeric variables.
3:
Changes to the data folder's string variables.
4:
Changes to the data folder's child data folders.
