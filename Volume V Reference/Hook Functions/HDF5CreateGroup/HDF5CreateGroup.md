# HDF5CreateGroup

HDF5AttributeInfo
V-341
HDF5AttributeInfo
HDF5AttributeInfo(locationID, objectNameStr, objectType, attributeNameStr, 
options, di)
The HDF5AttributeInfo function stores information about the attribute such as its rank, dimension sizes 
and type in the HDF5DataInfo structure pointed to by di.
Documentation for the HDF5AttributeInfo function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5AttributeInfo"
HDF5CloseFile
HDF5CloseFile [/A /Z] fileID
The HDF5CloseFile operation closes an HDF5 file previously opened by HDF5OpenFile or 
HDF5CreateFile.
Documentation for the HDF5CloseFile operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5CloseFile"
HDF5CloseGroup
HDF5CloseGroup [/Z] groupID
The HDF5CloseGroup operation closes an HDF5 group that you opened via HDFCreateGroup or 
HDF5OpenGroup.
Documentation for the HDF5CloseGroup operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5CloseGroup"
HDF5Control
HDF5Control [ keyword=value [, keyword=value] ]
The HDF5Control HDF5Control provides control of aspects of Igor’s use of the HDF5 file format.
Documentation for the HDF5CreateFile operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5Control"
HDF5CreateFile
HDF5CreateFile [/I /O /P=pathName /Z] fileID as fileNameStr
The HDF5CreateFile operation creates a new HDF5 file or overwrites an existing HDF5 file.
Documentation for the HDF5CreateFile operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5CreateFile"
HDF5CreateGroup
HDF5CreateGroup [/Z] locationID, nameStr, groupID
The HDF5CreateGroup operation creates an HDF5 group in the HDF5 file. It returns a group ID via 
groupID.
Documentation for the HDF5CreateGroup operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5CreateGroup"
