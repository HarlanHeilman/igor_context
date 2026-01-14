# GetWavesDataFolderDFR

GetWavesDataFolder
V-317
You set user data on a window or subwindow using the userData keyword of the SetWindow operation. 
You set it on a graph trace using the userData keyword of the ModifyGraph operation. You set it on a 
control using the userData keyword of the various control operations.
Parameters
winName may specify a window or subwindow name. Use "" for the top window.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
objID is a string specifying the name of a control or graph trace. Use "" for a window or subwindow.
userdataName is the name of the user data or "" for the default unnamed user data.
See Also
The ControlInfo, GetWindow, and SetWindow operations.
GetWavesDataFolder 
GetWavesDataFolder(waveName, kind)
The GetWavesDataFolder function returns a string containing the name of a data folder containing the 
wave named by waveName. Variations on the theme are selected by kind.
The most common use for this is in a procedure, when you want to create a wave or a global variable in the 
data folder containing a wave passed as a parameter.
GetWavesDataFolderDFR is preferred.
Details
Kinds 2 and 4 are especially useful in creating command strings to be passed to Execute.
Examples
Function DuplicateWaveInDataFolder(w)
Wave w
DFREF dfSav = GetDataFolderDFR()
SetDataFolder GetWavesDataFolder(w,1)
Duplicate/O w, $(NameOfWave(w) + "_2")
SetDataFolder dfSav
End
See Also
Chapter II-8, Data Folders.
GetWavesDataFolderDFR 
GetWavesDataFolderDFR(waveName)
The GetWavesDataFolderDFR function returns a data folder reference for the data folder containing the 
specified wave.
GetWavesDataFolderDFR is the same as GetWavesDataFolder except that it returns a data folder reference 
instead of a string containing a path.
See Also
Data Folders on page II-107, Data Folder References on page IV-78, Built-in DFREF Functions on page 
IV-81.
kind 
GetWavesDataFolder Returns
0
Only the name of the data folder containing waveName.
1
Full path of data folder containing waveName, without wave name.
2
Full path of data folder containing waveName, including possibly quoted wave name.
3
Partial path from current data folder to the data folder containing waveName.
4
Partial path including possibly quoted wave name.
