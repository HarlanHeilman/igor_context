# HDF5 Packed Experiment File Hierarchy

Chapter II-10 — Igor HDF5 Guide
II-224
Packed Procedure Files
Procedure
// Contents of the built-in procedure window
<Zero or more packed procedure files>
Shared Procedure Files
<Paths to shared procedure files>
Packed Notebooks
<Packed notebook files>
Shared Notebooks
<Paths to shared notebook files>
Symbolic Paths
<Paths to folders associated with symbolic paths>
Recreation
Recreation Procedures
// Experiment recreation procedures
Miscellaneous
Dash Settings (dataset)
Recent Windows Settings (dataset)
Running XOPs (dataset)
Pictures
<Picture datasets here>
Page Setups
Page Setup for All Graphs (dataset)
Page Setup for All Tables (dataset)
Page Setup for Built-in Procedure Window (dataset)
<Datasets for page layout page setups here>
XOP Settings
<XOP settings datasets here>
Any of the top-level groups can be omitted if it is not needed. For example, if the experiment has no free 
waves, Igor writes no Free Waves group.
The Shared Data group contains datasets containing full paths to Igor binary wave (.ibw) files referenced 
by the experiment. The paths are expressed as Posix paths on Macintosh, Windows paths on Windows.
The Shared Procedure Files group contains datasets containing full paths to procedure (.ipf) files referenced 
by the experiment. The paths are expressed as Posix paths on Macintosh, Windows paths on Windows. 
Global procedure files and #included procedure files are not part of the expeirment and are not included.
The Shared Notebooks group contains datasets containing full paths to notebook (.ifn or any plain text file 
type) files referenced by the experiment. The paths are expressed as Posix paths on Macintosh, Windows 
paths on Windows.
The Symbolic Paths group includes only user-created symbolic paths, not the built-in symbolic paths Igor, 
IgorUserFiles, or home which by definition points to the folder containing the packed experiment file. The 
paths are expressed as Posix paths on Macintosh, Windows paths on Windows. If there are no user-created 
symbolic paths, Igor writes no Symbolic Paths group.
The Recreation Procedures dataset contains the experiment recreation procedures written by Igor to recre-
ate the experiment.
The Miscellaneous group contains datasets and subgroups. Any of these objects can be omitted if not 
needed. The format of the data in the Miscellaneous group is subject to change and not documented. If your 
program reads or writes HDF5 packed experiment files, we recommend that you not attempt to read or 
write these objects.
HDF5 Packed Experiment File Hierarchy
An HDF5 file is a "directed graph" rather than a strict hierarchy. This means that it is possible to create 
strange relationships between objects, such as a group being a child of itself, or a dataset being a child of 
more than one group. Such strange relationships are not allowed for HDF5 packed experiment files - they 
must constitute a strict hierarchy.
