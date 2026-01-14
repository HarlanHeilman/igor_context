# HDF5 Compression for Saving Experiment Files

Chapter II-3 — Experiments, Files and Folders
II-16
Experiments
An experiment is a collection of Igor objects, including waves, variables, graphs, tables, page layouts, note-
books, control panels and procedures. When you create or modify one of these objects you are modifying 
the current experiment.
You can save the current experiment by choosing FileSave Experiment. You can open an experiment by 
double-clicking its icon on the desktop or choosing FileOpen Experiment.
Saving Experiments
There are two formats for saving an experiment on disk:
•
As a packed experiment file. A packed experiment file has the extension .pxp.
All waves, procedure windows, and notebooks are saved packed into the experiment file unless you 
explicitly save them separately.
•
As an experiment file and an experiment folder (unpacked format). An unpacked experiment file 
has the extension .uxp.
All waves, procedure windows, and notebooks are saved in separate files.
The packed format is recommended for most purposes. The unpacked format is useful for experiments that 
include very large numbers of waves (thousands or more).
Saving as a Packed Experiment File
In the packed experiment file, all of the data for the experiment is stored in one file. This saves space on disk 
and makes it easier to copy experiments from one disk to another. For most work, we recommend that you use 
the packed experiment file format.
The folder containing the packed experiment file is called the home folder.
To save a new experiment in the packed format, choose Save Experiment from the File menu.
Saving as an HDF5 Packed Experiment File
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
Programmers who want to read or write HDF5 packed experiment files from other programs can find tech-
nical details under HDF5 Packed Experiment Files on page II-223.
HDF5 Compression for Saving Experiment Files
If you are just starting with Igor, we recommend that you skip this section until you have more familiarity 
with it.
