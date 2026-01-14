# Saving HDF5 Object Reference Data

Chapter II-10 — Igor HDF5 Guide
II-210
A dash appears between pairs of <coordinates>. The first set of coordinates of a pair specifies the starting 
coordinates of a block while the second set of coordinates of a pair specifies the ending coordinates of the 
block.
For a 2D dataset with three selected blocks, this might look like this:
3,4-6,7/11,13-15,17/21,30-37,38
which specifies these three blocks:
row 3, column 4 to row 6, column 7
row 11, column 13 to row 15, column 17
row 21, column 30 to row 37, column 38
Here is an example of a complete point dataset region info string with the additional information shown in 
red:
D:/Group1/Dataset3.REGIONTYPE=POINT;NUMDIMS=2;NUMELEMENTS=3;COORDS=3,4/11,13/2
1,30;
Here is an example of a complete block dataset region info string with the additional information shown in 
red:
D:/Group1/Dataset4.REGIONTYPE=BLOCK;NUMDIMS=2;NUMELEMENTS=3;COORDS=3,4-
6,7/11,13-15/17/21,30-37/38;
The wave returned after calling HDF5LoadData on a two-row dataset region reference dataset would 
contain two rows of text like the examples just shown. Each row in the dataset region reference dataset 
refers to one dataset and to a set of points or blocks within that dataset.
The "HDF5 Dataset Region Demo.pxp" experiment provides further information including examples and 
utilities for dealing with dataset region references.
Saving HDF5 Object Reference Data
Most HDF5 files do not use reference datatypes so most users do not need to know this information.
An HDF5 dataset or attribute can contain references to other datasets, groups and named datatypes. These 
are called "object references". You can instruct HDF5SaveData to save a text wave as an object reference 
using the /REF flag. The /REF flag requires Igor Pro 8.03 or later.
The text to save as a reference must be formatted with a prefix character identifying the type of the refer-
enced object followed by a full or partial path to the object: "G:", "D", or "T:" for groups, datatypes, and data-
sets respectively. For example:
Function DemoSaveReferences(pathName, fileName)
String pathName
// Name of symbolic path
String fileName
// Name of HDF5 file
Variable fileID
HDF5CreateFile/P=$pathName /O fileID as fileName
// Create a group to target using a reference
Variable groupID
HDF5CreateGroup fileID, "GroupA", groupID
// Create a dataset to target using a reference
Make/O/T textWave0 = {"One", "Two", "Three"}
HDF5SaveData /O /REF=(0) /IGOR=0 textWave0, groupID
// Write reference dataset to root using full paths
Make/O/T refWaveFull = {"G:/GroupA", "D:/GroupA/textWave0"}
HDF5SaveData /O /REF=(1) /IGOR=0 refWaveFull, fileID
