# IgorBeforeQuitHook

Chapter IV-10 — Advanced Topics
IV-290
Returning non-zero prevents the pending change to the text from taking effect for changeCode = 1, 2, or 3, 
though only when procedures are already compiled.
The returned value is ignored for other values of changeCode.
BeforeUncompiledHook is not called before a new experiment is opened, before the experiment is reverted, 
or before Igor quits. Use IgorBeforeNewHook and IgorBeforeQuitHook for those scenarios.
See Also
User-Defined Hook Functions on page IV-280, SetIgorHook, AfterCompiledHook, Operation Queue on 
page IV-278.
HDF5SaveDataHook
HDF5SaveDataHook(s)
HDF5SaveDataHook is a user-defined function that Igor calls when saving a wave to an HDF5 file. It allows 
advanced users to control compression of the dataset written for the wave.
HDF5SaveDataHook was added in Igor Pro 9.00.
NOTE: HDF5SaveDataHook is an experimental feature for advanced users only. The feature may be 
changed or removed. If you find it useful, please let us know, and send your function and an explanation 
of what purpose it serves.
Parameters
s is an HDF5SaveDataHookStruct.
Details
See Using HDF5SaveDataHook on page II-215 for details.
IgorBeforeNewHook
IgorBeforeNewHook(igorApplicationNameStr)
IgorBeforeNewHook is a user-defined function that Igor calls before a new experiment is opened in 
response to the New Experiment, Revert Experiment, or Open Experiment menu items in the File menu.
You can use IgorBeforeNewHook to clean up the current experiment, or to avoid losing unsaved data even 
if the user chooses to not save the current experiment.
Igor ignores the value returned by IgorBeforeNewHook.
Parameters
igorApplicationNameStr contains the name of the currently running Igor Pro application.
See Also
IgorStartOrNewHook and SetIgorHook.
IgorBeforeQuitHook
IgorBeforeQuitHook(unsavedExp,unsavedNotebooks,unsavedProcedures)
IgorBeforeQuitHook is a user-defined function that Igor calls just before Igor is about to quit, before any 
save-related dialogs have been presented.
Parameters
unsavedExp is 0 if the experiment is saved, non-zero if unsaved.
unsavedNotebooks is the count of unsaved notebooks.
unsavedProcedures is the count of unsaved procedures.
The save state of packed procedure and notebook files is part of unsavedExp, not unsavedNotebooks or 
unsavedProcedures. This applies to adopted procedure and notebook files and new procedure and notebook 
windows that have never been saved.
Details
IgorBeforeQuitHook should normally return 0. In this case, Igor presents the “Do you want to save” dialog, 
and if the user approves, proceeds with the quit, which includes calling IgorQuitHook.
