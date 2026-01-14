# HDF5 Operations and Functions

Chapter II-10 — Igor HDF5 Guide
II-197
HDF5 Browser Dump Technical Details
The dump notebook displays a dump of the selected group, dataset or attribute in "Data Description Lan-
guage" (DDL) format. For most purposes you will not need the dump window. It is useful for experts who 
are trying to debug a problem or for people who are trying to understand the nuts and bolts of HDF5.
Sometimes strings in HDF5 files contain a large number of trailing nulls. These are not displayed in the 
dump window.
Sometimes strings in HDF5 files contain the literal strings "\r", "\n" and "\t" to represent carriage return, 
linefeed and tab. To improve readability, in the dump window these literal strings are displayed as actual 
carriage returns, linefeeds and tabs.
HDF5 Operations and Functions
This section lists Igor's HDF5-related operations and functions:
HDF5CreateFile
Creates a new HDF5 file or overwrites an existing file.
HDF5OpenFile
Opens an HDF5 file, returning a file ID that is passed to other operations and 
functions.
HDF5CloseFile
Closes an HDF5 file or all open HDF5 files.
HDF5FlushFile
Flushes an HDF5 file or all open HDF5 files.
HDF5CreateGroup
Creates a group in an HDF5 file, returning a group ID that can be passed to 
other operations and functions.
HDF5OpenGroup
Opens an existing HDF5 group, returning a group ID that can be passed to 
other operations and functions.
HDF5ListGroup
Lists all objects in a group.
HDF5CloseGroup
Closes an HDF5 group.
HDF5LinkInfo
Returns information about an HDF5 link.
HDF5ListAttributes
Lists all attributes associated with a group, dataset or datatype.
HDF5AttributeInfo
Returns information about an HDF5 attribute.
HDF5DatasetInfo
Returns information about an HDF5 dataset.
HDF5LoadData
Loads data from an HDF5 dataset or attribute into Igor.
HDF5LoadImage
Loads an image written according to the HDF5 Image and Palette 
Specification.
HDF5LoadGroup
Loads an HDF5 group and its datasets into an Igor Pro data folder.
HDF5SaveData
Saves Igor waves in an HDF5 file.
HDF5SaveImage
Saves an image in the HDF5 Image and Palette Specification format.
HDF5SaveGroup
Saves an Igor data folder in an HDF5 group.
HDF5TypeInfo
Returns information about an HDF5 datatype.
HDF5CreateLink
Creates a new hard, soft or external link.
HDF5UnlinkObject
Unlinks an object (a group, dataset, datatype or link) from an HDF5 file. This 
deletes the object from the file's hierarchy but does not free up the space in 
the file used by the object.
HDF5DimensionScale
Supports the creation and querying of HDF5 dimension scales.
