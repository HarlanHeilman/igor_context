# SaveGraphCopy

SaveGizmoCopy
V-821
See Also
Saving Experiments on page II-16, ExperimentInfo
SaveGizmoCopy 
SaveGizmoCopy [flags][as fileNameStr]
The SaveGizmoCopy operation saves a Gizmo window and its waves in an Igor packed experiment file.
SaveGizmoCopy was added in Igor Pro 8.00.
Parameters
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
The main uses for saving as a packed experiment are to save an archival copy of data or to prepare to merge data 
from multiple experiments (see Merging Experiments on page II-19). The resulting experiment file preserves 
the data folder hierarchy of the waves displayed in the Gizmo window starting from the root data folder. Only 
the Gizmo window, its waves as well as the objects on Gizmo's object list and attribute list are saved in the 
packed experiment file. Associated procedures including hook functions are not saved.
SaveGizmoCopy does not know about dependencies. If a Gizmo window contains a wave, wave0, that is 
dependent on another wave, wave1 which is not used in the Gizmo window, SaveGizmoCopy will save 
wave0 but not wave1. When the saved experiment is open, there will be a broken dependency.
SaveGizmoCopy sets the variable V_flag to 0 if the operation completes normally, to -1 if the user cancels, 
or to another nonzero value that indicates that an error occurred. If you want to detect the user canceling 
an interactive save, use the /Z flag and check V_flag after calling SaveGizmoCopy.
See Also
SaveGraphCopy, SaveTableCopy, SaveData, Merging Experiments on page II-19
SaveGraphCopy 
SaveGraphCopy [flags][as fileNameStr]
The SaveGraphCopy operation saves a graph and its waves in an Igor packed experiment file.
/I
Presents a dialog from which you can specify file name and folder.
/O
Overwrites file if it exists already.
/P=pathName
Specifies the folder to store the file in. pathName is the name of an existing symbolic path.
/T=saveType
/W= winName
winName is the name of the Gizmo window to be saved. If /W is omitted or if winName 
is "", the top Gizmo window is saved.
/Z
Errors are not fatal and error dialogs are suppressed. See Details.
Specifies the file format of the saved file.
The /T flag was added in Igor Pro 9.00.
saveType=0:
Packed experiment file.
saveType=1:
HDF5 packed experiment file. If fileNameStr is specified the file 
name extension must be ".h5xp".

SaveGraphCopy
V-822
Parameters
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
The main uses for saving as a packed experiment are to save an archival copy of data or to prepare to merge data 
from multiple experiments (see Merging Experiments on page II-19). The resulting experiment file preserves 
the data folder hierarchy of the waves displayed in the graph starting from the “top” data folder, which is the 
data folder that encloses all waves displayed in the graph. The top data folder becomes the root data folder of 
the resulting experiment file. Only the graph, its waves, dashed line settings, and any pictures used in the graph 
are saved in the packed experiment file, not procedures, variables, strings or any other objects in the experiment.
SaveGraphCopy does not work well with graphs containing controls. First, the controls may depend on 
waves, variables or FIFOs (for chart controls) that SaveGraphCopy will not save. Second, controls typically 
rely on procedures which are not saved by SaveGraphCopy.
SaveGraphCopy does not know about dependencies. If a graph contains a wave, wave0, that is dependent 
on another wave, wave1 which is not in the graph, SaveGraphCopy will save wave0 but not wave1. When 
the saved experiment is open, there will be a broken dependency.
SaveGraphCopy sets the variable V_flag to 0 if the operation completes normally, to -1 if the user cancels, 
or to another nonzero value that indicates that an error occurred. If you want to detect the user canceling 
an interactive save, use the /Z flag and check V_flag after calling SaveGraphCopy.
The SaveData operation also has the ability to save data from a graph to a packed experiment file. SaveData 
is more complex but a bit more flexible than SaveGraphCopy.
Examples
This function saves all graphs in the experiment to individual packed experiment files.
Function SaveAllGraphsToPackedFiles(pathName)
String pathName
// Name of an Igor symbolic path.
String graphName
Variable index
index = 0
do
graphName = WinName(index, 1)
if (strlen(graphName) == 0)
break
endif
/I
Presents a dialog from which you can specify file name and folder.
/O
Overwrites file if it exists already.
/P=pathName
Specifies the folder to store the file in. pathName is the name of an existing symbolic path.
/T=saveType
/W= winName
winName is the name of the graph to be saved. If /W is omitted or if winName is "", the 
top graph is saved.
/Z
Errors are not fatal and error dialogs are suppressed. See Details.
Specifies the file format of the saved file.
The /T flag was added in Igor Pro 9.00.
saveType=0:
Packed experiment file.
saveType=1:
HDF5 packed experiment file. If fileNameStr is specified the file 
name extension must be ".h5xp".
