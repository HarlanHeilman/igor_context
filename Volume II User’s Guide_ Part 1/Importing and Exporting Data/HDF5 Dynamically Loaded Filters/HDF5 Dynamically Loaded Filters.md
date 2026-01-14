# HDF5 Dynamically Loaded Filters

Chapter II-10 — Igor HDF5 Guide
II-217
This prevents Igor from calling the hook function via HDF5SaveData and HDF5SaveGroup operations and 
when saving an HDF5 packed experiment file.
You can re-enable calling the hook function by executing:
SetIgorOption HDF5SaveDataHook=1
HDF5 Compression References
This section lists documents that discuss HDF5 filtering and compression that may be of interest to 
advanced HDF5 users.
Using Compression in HDF5
Chunking in HDF5
HDF5 Advanced Topics:Chunking in HDF5
Dataset Chunking Issues
HDF5 Compression Demystified #1
HDF5 Compression Demystified #2
Improving I/O Performance When Working with HDF5 Compressed Datasets
HDF5 Compression Troubleshooting
HDF5 Dynamically Loaded Filters
The HDF5 library can use third-party dynamically loaded filter plugins which are used for forms of com-
pression that are not built into the library itself. "Dynamically loaded" means that the filter plugins are not 
compiled into the HDF5 library but reside in separate library files. The HDF5 library looks for these plugins 
and, if it finds them, loads them, and their features become available. (For HDF5 experts, dynamically 
loaded filter plugins are described at https://portal.hdfgroup.org/display/HDF5/HDF5+Dynami-
cally+Loaded+Filters.)
The default locations where the HDF5 libraries look for filter plugins are:
Macintosh: /usr/local/hdf5/lib/plugin
Windows: %ALLUSERSPROFILE%/hdf5/lib/plugin
(%ALLUSERSPROFILE% is C:\ProgramData on most systems)
The user can override the default locations by setting the HDF5_PLUGIN_PATH environment variable to 
the path to the user's plugins prior to launching Igor.
Starting with Igor Pro 9.01, Igor Pro ships with the plugins provided by The HDF Group at 
https://www.hdfgroup.org/downloads/hdf5. These plugins include:
BLOSC, BSHUF, BZ2, JPEG, LZ4, LZF, and ZFP
Igor supports decoding datasets written with these filters. It does not yet support encoding with these fil-
ters. Also, this is supported with the 64 bit version of Igor, not with the 32 bit version because we have not 
found 32 bit filter plugin libraries.
On Macintosh, the filter libraries as provided by The HDF Group's download page (https://www.hdf-
group.org/downloads/hdf5) do not work with Igor Pro. The filter libraries that ship with Igor are tweaked 
to allow them to work with Igor Pro. (For Macintosh programming experts, this is explained at 
https://forum.hdfgroup.org/t/dynamically-loaded-filters-on-mac-os/9159/2.)
On Macintosh, the filters are shipped in "Igor64.app/MacOS/hdf5plugins". On Windows they are shipped 
in "IgorBinaries_x64/hdf5plugins". When Igor starts, it tells the HDF5 library to look in these locations first
