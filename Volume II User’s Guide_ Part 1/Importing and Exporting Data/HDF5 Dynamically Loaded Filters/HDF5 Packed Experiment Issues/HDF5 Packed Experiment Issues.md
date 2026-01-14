# HDF5 Packed Experiment Issues

Chapter II-10 — Igor HDF5 Guide
II-226
of each element of a DFREF wave is the data folder ID for the referenced data folder. A data folder ID of 
zero indicates a null data folder reference. On loading the experiment, Igor restore each element of each 
DFREF wave so that it points to the appropriate data folder.
Writing and restoring wave waves and DFREF waves is complicated and tricky. If your program writes 
HDF5 packed experiment files, we recommend that you not attempt to write these objects. If your program 
loads HDF5 packed experiment files, we recommend that you ignore ignore wave waves (IGORWave-
Type=16384) and DFREF waves (IGORWaveType=256).
Free Waves and Free Data Folders
Igor writes representations of Free Waves and Free Data Folders to HDF5 packed experiment files and 
restores free waves and free data folders when the experiment is loaded.
Each free wave is written as a dataset in the Free Waves group. For a free wave to exist, it must be referenced 
by a wave wave in the experiment.
Each free root data folder and its descendents are written as a group and subgroups in the Free Data Folders 
group. For a free root data folder to exist, it must be referenced by a DFREF wave in the experiment.
Writing and restoring free waves and free data folders is a complicated and tricky. If your program writes 
HDF5 packed experiment files, we recommend that you not attempt to write these objects. If your program 
loads HDF5 packed experiment files, we recommend that you ignore the Free Waves and Free Data Folders 
groups.
HDF5 Packed Experiment Issues
In rare cases, Igor experiments can not be written in HDF5 packed format because of name conflicts. For 
details, see Object Name Conflicts and HDF5 Files on page III-505.
