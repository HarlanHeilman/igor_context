# SaveExperiment

SaveExperiment
V-819
DFREF savedDF = GetDataFolderDFR()
NewDataFolder/O/S :TempTransfer
// Load all data from the unpacked folder.
LoadData/D/Q/R/P=$path1 folderName
// Save all data to the packed file.
SaveData/R/P=$path2 fileName
KillDataFolder :
// Kill TempTransfer
SetDataFolder savedDF
End
See Also
The LoadData and SaveGraphCopy operations; the SpecialDirPath function. Saving Package Preferences 
on page IV-251; Exporting Data on page II-177; The Data Browser on page II-114.
SaveExperiment 
SaveExperiment [flags] [as fileName]
The SaveExperiment operation saves the current experiment.
Warning:
SaveExperiment overwrites any previously-existing file named fileName.
Parameters
The optional fileName string contains the name of the experiment to be saved. fileName can be the currently 
open experiment, in which case it overwrites the experiment file.
If fileName and pathName are omitted and the experiment is Untitled, you will need to locate where the 
experiment file will be saved interactively via a dialog.
If you use a full or partial path for pathName, see Path Separators on page III-451 for details on forming the path.
Flags
Details
SaveExperiment acts like the Save menu command in the File menu. If the experiment is associated with an 
already saved file, then SaveExperiment with no parameters will simply save the current experiment. If the 
experiment resides only in memory and has not yet been saved, then a dialog will be presented unless the 
path and file name are specified.
/C
Saves an experiment copy (valid only when fileName or pathName is provided or both 
if experiment is Untitled).
/COMP={minWaveElements, gzipLevel, shuffle}
Specifies that compression is to be applied to numeric waves saved when saving as 
an HDF5 packed experiment file. The /COMP flag was added in Igor Pro 9.00.
minWaveElements is the minimum number of elements that a numeric wave must have 
to be eligible for compression. Waves with fewer than this many total elements are not 
compressed.
gzipLevel is a value from 0 to 9. 0 means no GZIP compression.
shuffle is 0 to turn shuffle off or 1 to turn shuffle on.
When compression is applied by SaveExperiment, the entire wave is saved in one 
chunk. See HDF5 Layout Chunk Size on page II-214 for background information and 
SaveExperiment Compression on page II-214 for details.
/F={format, unpackedExpFolderNameStr, unpackedExpFolderMode}
Specifies the experiment file format.
See Experiment File Format below for details.
/P=pathName
Specifies folder in which to save the experiment. pathName is the name of an existing 
symbolic path.

SaveExperiment
V-820
If you use a full path in the name you will not need the /P flag. If instead you use /P=pathName, note that it 
is the name of an Igor symbolic path, created via NewPath. It is not a file system path like “hd:Folder1:” 
or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
Experiment File Format
For background information on experiment file formats, see Experiments on page II-16.
The /F flag provides control of the file format of a previously-unsaved experiment independent of the user's 
preferences as set in the Experiment Settings section of the Miscellaneous Settings dialog. It also allows you 
to save a previously-saved experiment using a different experiment file format.
If you just want to save the current experiment in its current format, you don't need to use /F.
If you use /F, you must fully-specify the location of the experiment file through the /P flag and the fileName 
parameter or through fileName alone if it contains a full path.
The format parameter controls the experiment file format used by SaveExperiment:
If /F is omitted or if format is -1 then the experiment is saved in its current format or, if it was never saved 
to disk, as a packed experiment file (.pxp).
If format = 0, the experiment is saved in unpacked experiment file format. fileName must end with ".uxp" or 
".uxt".
If format = 1, the experiment is saved in packed experiment file format. fileName must end with ".pxp" or 
".pxt".
If format = 2, the experiment is saved in HDF5 packed experiment file format. fileName must end with ".h5xp" 
or ".h5xt". This format requires Igor Pro 9.00 or later.
Unpacked Experiment Folder
The unpacked experiment folder is the folder in which wave files, the history file, the variables file, and 
other experiment files are stored for an unpacked experiment. See Saving as an Unpacked Experiment File 
on page II-17 for details.
The /F unpackedExpFolderNameStr parameter specifies the name of the experiment folder for an unpacked 
experiment. It contains a folder name, not a full or partial path. It is ignored unless saving in unpacked 
experiment format.
The unpacked experiment folder is created in the same directory as the experiment file.
If /F=0 is used and unpackedExpFolderNameStr is "" then the experiment folder name is the same as the 
experiment file name with the extension removed and a space and "Folder" added.
If the specified unpacked experiment folder already exists and is the current experiment's unpacked 
experiment folder, it is reused. "Reuse" means that SaveExperiment saves files in the unpacked experiment 
folder, possibly overwriting files already in it, but does not delete any files or folders already in it.
The unpackedExpFolderMode parameter controls what happens if the folder to be used as the unpacked 
experiment folder already exists and is not the current experiment's unpacked experiment folder:
format =-1:
Default format
format =0:
Unpacked experiment file
format =1:
Packed experiment file
format =2:
HDF5 packed experiment file
unpackedExpFolderMode=0 :
SaveExperiment returns an error.
unpackedExpFolderMode=1 :
SaveExperiment displays a dialog asking the user if it is OK to 
reuse the folder. If the user answers yes, the operation proceeds. 
Otherwise, it returns an error.
unpackedExpFolderMode=2 :
SaveExperiment reuses the folder without asking the user.
Warning:
If you pass 2 for unpackedExpFolderMode, files and folders in the unpacked experiment 
folder may be overwritten without the user's express permission.
