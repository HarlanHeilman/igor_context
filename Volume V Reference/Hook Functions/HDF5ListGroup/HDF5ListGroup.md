# HDF5ListGroup

HDF5FlushFile
V-343
HDF5FlushFile
HDF5FlushFile [/A /Z] fileID
The HDF5FlushFile operation flushes an HDF5 file previously opened by HDF5OpenFile or 
HDF5CreateFile.
Documentation for the HDF5FlushFile operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5FlushFile"
HDF5LibraryInfo
HDF5LibraryInfo(options) 
The HDF5LibraryInfo function returns information about the HDF5 library used by the currently-running 
version of Igor.
Documentation for the HDF5LibraryInfo function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5LibraryInfo"
HDF5LinkInfo
HDF5LinkInfo(locationID, pathStr, options, li) 
The HDF5LinkInfo function stores information about an HDF5 link in the HDF5LinkInfoStruct structure 
pointed to by li.
Documentation for the HDF5LinkInfo function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5LinkInfo"
HDF5LinkInfoStruct
The HDF5LinkInfoStruct structure is used with the HDF5LinkInfo function.
Documentation for the HDF5LinkInfoStruct structure is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5LinkInfoStruct"
HDF5ListAttributes
HDF5ListAttributes [/TYPE=type /Z] locationID, nameStr
The HDF5ListAttributes operation returns a semicolon-separated list of attributes associated with the object 
specified by locationID and nameStr.
Documentation for the HDF5ListAttributes operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5ListAttributes"
HDF5ListGroup
HDF5ListGroup [flags] locationID, nameStr
The HDF5ListGroup operation returns a semicolon-separated list of the names of objects in the HDF5 file 
or group specified by locationID and nameStr.
Documentation for the HDF5ListGroup operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5ListGroup"
