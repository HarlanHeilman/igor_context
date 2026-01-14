# HDF5 Packed Experiment File Organization

Chapter II-10 — Igor HDF5 Guide
II-223
To restore Igor to normal operation, execute:
SetIgorOption HDF5LibVerLowBound=1
The effect of SetIgorOption lasts only until you restart Igor.
Typically, if you need to set HDF5LibVerLowBound at all, you would do this once at startup. Do not call 
SetIgorOption to set HDF5LibVerLowBound while an Igor preemptive thread is making HDF5 calls.
Writing to Old HDF5 Files
The HDF5 documentation does not spell out all of the myriad compatibility issues between various HDF5 
library versions. The information in this section is based on our empirical testing.
See HDF5 Compatibility Terminology on page II-222 for a definition of terms used in this section.
If you use Igor to open an old HDF5 file and write a dataset to it, the new dataset is not readable by old 
HDF5 programs. Also, the group containing the new dataset can not be listed by old HDF5 programs. In 
other words, writing to an old file in new format makes the old file at least partially unreadable by old soft-
ware.
If you have old HDF5 files and you rely on old HDF5 programs to read them, open such files for read only, 
not for read/write. Also make sure the files are thoroughly backed up.
HDF5 Packed Experiment Files
In Igor Pro 9 and later, you can save an Igor experiment in an HDF5 file. The main advantage is that the 
data is immediately accessible to a wide array of programs that support HDF5. The main disadvantage is 
that you will need Igor Pro 9 or later to open the file in Igor. Also HDF5 is considerably slower than PXP 
for experiments with very large numbers of waves.
To save an experiment in HDF5 packed experiment format, choose FileSave Experiment As. In the result-
ing Save File dialog, choose "HDF5 Packed Experiment Files (*.h5xp)" from the pop-up menu under the list 
of files. Then click Save.
If you want to make HDF5 packed experiment format your default format for saving new experiments, 
choose MiscMiscellaneous Settings. In the resulting dialog, click the Experiment category on the left. 
Then choose "HDF5 Packed (.h5xp)" from the Default Experiment Format pop-up menu.
For normal use you don't need to know the details of how Igor stores data in HDF5 packed experiment files, 
but, if you are curious, you can get a sense by opening such a file using the HDF5 Browser (DataLoad 
WavesNew HDF5 Browser).
The rest of this topic is for the benefit of programmers who want to read or write HDF5 packed experiment 
files from other programs. It is assumed that you are an experienced Igor and HDF5 user.
HDF5 Packed Experiment File Organization
An HDF5 packed experiment file has the following general organization:
/
History
History
// Contents of the history area window
Packed Data
<Waves, variables and data folders here>
Shared Data
<Paths to shared wave files here>
Free Waves
<Free waves here>
Free Data Folders
<Free data folders here>
