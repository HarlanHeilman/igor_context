# IGOR64 Experiment Files

Chapter II-3 — Experiments, Files and Folders
II-35
For example, if you last opened a text file as an unformatted notebook, selecting the file from Recent Files 
will again open the file as an unformatted notebook. If you loaded it as a general text data file, Igor will load 
it as data again.
Igor does not remember all the details of how you originally load a data file, however. If you load a text 
data file with all sorts of fiddly tweaks about the format, Igor won’t load it using the those same tweaks. To 
guarantee that Igor does load the data correctly, use the appropriate Load Data dialog.
Selecting an experiment or file while pressing Shift displays the Open or Load File dialog in which you can 
choose how Igor will open or load that file.
Desktop Drag and Drop
On Macintosh, you can drag and drop one or more files of almost any type onto the Igor icon in the dock 
or onto an alias for the Igor application on the desktop. On Windows, you must drag and drop files into an 
Igor window. One use for this feature is to load multiple data files at once.
If a dropped file was opened or loaded recently, it is listed in the Recent Files or Recent Experiments menu. 
In this case, Igor reopens or reloads it the same way.
If you press Shift while dropping a file on Igor, Igor displays the Open or Load File dialog in which you can 
choose how the file is to be handled.
Advanced programmers can customize Igor to handle specific types of files in different ways, such as auto-
matically loading files with an XOP. See User-Defined Hook Functions on page IV-280.
IGOR64 Experiment Files
The 64 bit version of Igor can store waves larger than the 32-bit limit in packed experiment files but not in 
unpacked experiments. Huge wave storage uses a 64-bit capable wave record and is supported only for 
numeric waves.
The 32-bit versions of Igor, starting with version 6.20, supports 64-bit capable wave records. By default, 
IGOR32 attempts to read new these records and generates a lack of memory warning if they can not be 
loaded.
The rest of this section describes features for advanced users.
You can control some aspects of how Igor deals with 64-bit capable wave records using SetIgorOption. 
Remember that SetIgorOption settings last only until you quit Igor. 
SetIgorOption UseNewDiskHeaderBytes = bytes
When bytes is non-zero, if the size of the wave data exceeds this value, the 64-bit capable wave record type 
is used. In IGOR32, the default value for bytes is 0 (off). In IGOR64, the default value for bytes is 100E6. If 
you want the 64-bit capable wave record type to be used only when absolutely necessary, use 2E9. 
SetIgorOption UseNewDiskHeaderCompress = bytes
When bytes is non-zero, if the size of the wave data exceeds this value and if the 64-bit capable wave record 
type is used, the data is written compressed. The default value is 0 (off) because, although you can get sub-
stantial file size reduction for some kinds of data, there is also a substantial speed penalty when saving the 
experiment. In many cases, the compression actually results in a larger size than the original. If this occurs, 
Igor writes the original data instead of the compressed data. 
SetIgorOption MaxBytesReadingWave = bytes
SetIgorOption BigWaveLoadMode = mode
These two options control how IGOR32 acts when loading experiments with the 64-bit capable wave record 
types.
