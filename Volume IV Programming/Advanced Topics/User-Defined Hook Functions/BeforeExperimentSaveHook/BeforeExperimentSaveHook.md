# BeforeExperimentSaveHook

Chapter IV-10 — Advanced Topics
IV-286
Parameters
param is one of the following values:
Details
This function is not called on Macintosh.
Resizing the MDI frame by the top left corner calls AfterMDIFrameSizedHook twice: first for the move 
(param = 3) and then for the normal resize (param = 0).
Igor currently ignores the value returned by AfterMDIFrameSizedHook. Return 0 in case Igor uses this 
value in the future.
See Also
SetWindow, GetWindow, SetIgorHook, and User-Defined Hook Functions on page IV-280.
AfterWindowCreatedHook
AfterWindowCreatedHook(windowNameStr, winType)
AfterWindowCreatedHook is a user-defined function that Igor calls when a target window is first created.
AfterWindowCreatedHook can be used to set a window hook on target windows created by the user or by 
other procedures.
Parameters
windowNameStr contains the name of the created window.
winType is the type of the window, the same value as returned by WinType.
Details
“Target windows” are graphs, tables, layout, panels, and notebook windows.
AfterWindowCreatedHook is not called when an Igor experiment is being opened.
Igor ignores the value returned by AfterWindowCreatedHook.
See Also
SetWindow, SetIgorHook, and User-Defined Hook Functions on page IV-280.
BeforeExperimentSaveHook
BeforeExperimentSaveHook(refNum, fileNameStr, pathNameStr, fileTypeStr, 
fileCreatorStr, fileKind)
BeforeExperimentSaveHook is a user-defined function that Igor calls when an experiment is about to be 
saved by Igor.
Igor ignores the value returned by BeforeExperimentSaveHook.
Parameters
refNum identifies what is causing the experiment to be saved:
Size Event
param
Normal resize
0
Minimized
1
Maximized
2
Moved
3
Cause
refNum
Save Experiment (File menu or SaveExperiment)
1
Save Experiment As (File menu or SaveExperiment)
2
Save Experiment Copy (File menu or SaveExperiment/C)
3
Autosave Experiment (direct mode)
17 (0x10 + 1)
Autosave Experiment Copy (indirect mode)
19 (0x10 + 3)
