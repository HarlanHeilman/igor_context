# Wave Reference Waves and Data Folder Reference Waves

Chapter II-10 — Igor HDF5 Guide
II-225
Storage of Plain Text in HDF5 Packed Experiment Files
Several kinds of plain text items are stored in experiment files, including:
•
The contents of the built-in procedure window
•
The contents of the built-in history window
•
The contents of packed procedure files
•
The contents of packed plain text notebook files
•
Text data contents of text waves
•
Text properties of numeric waves (e.g., units, wave note, dimension labels)
•
String variables
Igor stores such text as strings (HDF5 class H5T_STRING) using UTF-8 text encoding (H5T_CSET_UTF8) 
when writing an HDF5 packed experiment file.
Occasionally an item that is expected to be valid UTF-8 will contain byte sequences that are invalid in UTF-
8 or contain null bytes. Examples include text waves and string variables that are being used to carry binary 
rather than text data. Such data is still written as UTF-8 string datasets.
Plain Text Files
"Plain text files" in this context refers to history text, recreation procedures, procedure files, and plain text 
notebooks. Igor writes plain text files as UTF-8 string datasets.
Waves
Igor writes text waves as UTF-8 string datasets. For details, see HDF5 Wave Text Encoding on page II-221.
String Variables
Igor writes string variables as UTF-8 fixed-length string datasets. For details, see HDF5 String Variable 
Text Encoding on page II-221.
Writing HDF5 Packed Experiments
This section is for programmers who want to write HDF5 packed experiment files from programs other 
than Igor. This section assumes that you understand the information presented in the preceding sections of 
HDF5 Packed Experiment Files on page II-223.
If you open an HDF5 packed experiment using the HDF5 Browser you will see that the file (top-level group 
displayed as "root" in the HDF5 file) has a number of attributes. The only required attribute is the IGORRe-
quiredVersion attribute which specifies the minimum version of Igor required to open the experiment. 
Write 9.00 for this attribute, or a larger value if your HDF5 packed experiment requires a later version of 
Igor.
Waves in HDF5 Files
Igor writes waves to HDF5 files as datasets with attributes representing wave properties. For example, the 
IGORWaveType attribute represents the data type of the wave - see WaveType for a list of data types. See 
the discussion of the /IGOR flag of the HDF5SaveData operation for a list of HDF5 wave attributes.
Wave Reference Waves and Data Folder Reference Waves
A wave reference wave (see Wave Reference Waves on page IV-77), or "wave wave" for short, is a wave 
whose elements are references to other waves. Each wave referenced by a wave wave has an IGORWaveID 
attribute that specifies the wave ID of the referenced wave. The contents of each element of a wave wave is 
the wave ID for the referenced wave. A wave ID of zero indicates a null wave reference. On loading the 
experiment, Igor restore each element of each wave wave so that it points to the appropriate wave.
A data folder reference wave (see Data Folder Reference Waves on page IV-82), or "DFREF wave" for short, 
is a wave whose elements are references to data folders. Each data folder referenced by a DFREF wave has 
an IGORDataFolderID attribute that specifies the data folder ID of the referenced data folder. The contents
