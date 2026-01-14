# Experimenting With Indirect Autosave Recovery

Chapter II-3 — Experiments, Files and Folders
II-41
If you click Open AutoSave File
Igor renames the original file by appending a ".original" extension (e.g., "Proc0.ipf" is renamed as 
"Proc0.ipf.original").
Igor then renames the autosave file using the original file name (e.g., "Proc0.ipf.autosave" is renamed as 
"Proc0.ipf").
Igor then opens the autosave file which now has the original file name (e.g., "Proc0.ipf").
Igor then moves the original file, which now has the ".original" extension (e.g., "Proc0.ipf.original") to the 
trash (Macintosh) or recycle bin (Windows).
Indirect Autosave Mode Issues
Indirect mode can create confusing situations when files are shared by multiple users or by multiple 
instances of Igor launched by a single user.
For example, if a user is editing a shared procedure file with indirect autosave mode on, Igor creates a cor-
responding .autosave file. If another user directly or indirectly (e.g., via a #include statement) opens the 
original file, the existence of the .autosave file causes Igor to display the Open Autosave File dialog dis-
cussed in the preceding section. This will confuse the second user and potentially interfere with the first 
user’s editing. A similar situation can occur with shared notebook and experiment files.
This kind of issue is mitigated by using a source code control system or by otherwise avoiding working 
directly on shared files or by turning autosave off.
Opening .autosave Files Explicitly
Normally you have no need to open an Igor .autosave file but you might want to do so to inspect it.
Igor opens procedure and notebook .autosave files for reading only. If you close a procedure or notebook 
file whose .autosave file you have also opened in Igor, Igor automatically closes the .autosave file before 
deleting it.
Igor does not allow you to open .autosave experiment files. If you want to open such a file, rename it 
without the .autosave extension before opening it in Igor.
Indirect Autosave and Unpacked Experiments
Indirect autosave of unpacked experiments is not supported.
If an unpacked experiment is open, autosaving of standalone procedure files and notebooks is still per-
formed if enabled by the corresponding checkboxes in the Autosave pane of the Miscellaneous Settings 
dialog.
For background information on unpacked experiments, see Saving as an Unpacked Experiment File on 
page II-17.
Experimenting With Indirect Autosave Recovery
If you want to familiarize yourself with how indirect autosave works, you can use this function for experi-
mentation. It writes files "Test Indirect Autosave.txt" and "Test Indirect Autosave.txt.autosave" to your Igor 
Pro User Files folder and then opens "Test Indirect Autosave.txt" as a notebook. Igor displays the "Open 
Autosave File?" dialog in which you can choose which file you want to open. The file not chosen is moved 
to the trash (Macintosh) or recycle bin (Windows). 
Function TestOpenWithIndirectAutoSaveFilePresent()
KillWindow/Z TestAutosaveNotebook
String pathName = "IgorUserFiles"

Chapter II-3 — Experiments, Files and Folders
II-42
// Create original file
String fileName = "Test Indirect Autosave.txt"
Variable refNum
Open/P=$pathName refNum as fileName
fprintf refNum, "This is a test\r\n"
Close refNum
// Create the autosave file
CopyFile /O /P=$pathName fileName as fileName + ".autosave"
// Displays "Open Autosave File?" dialog
OpenNotebook/P=$pathName/N=TestAutosaveNotebook fileName
int err = GetRTError(1)
// Returns non-zero if user cancels
Print err
End
