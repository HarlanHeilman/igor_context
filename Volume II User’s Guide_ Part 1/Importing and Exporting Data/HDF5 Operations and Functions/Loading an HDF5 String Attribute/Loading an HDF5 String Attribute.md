# Loading an HDF5 String Attribute

Chapter II-10 — Igor HDF5 Guide
II-199
if (V_flag != 0)
Print "HDF5OpenFile failed"
return -1
endif
Variable groupID
// HDF5 group ID will be stored here
HDF5OpenGroup /Z fileID, groupPath, groupID
if (V_flag != 0)
Print "HDF5OpenGroup failed"
HDF5CloseFile fileID
return -1
endif
HDF5LoadData /O /A=attributeName /TYPE=(objectType) /N=tempAttributeWave /Q 
/Z groupID, objectName
result = V_flag
// 0 if OK or non-zero error code
if (result == 0)
Wave tempAttributeWave
if (WaveType(tempAttributeWave) == 0)
attributeValue = NaN
// Attribute is string, not numeric
result = -1
else
attributeValue = tempAttributeWave[0]
endif
KillWaves/Z tempAttributeWave
endif
// Close the HDF5 group
HDF5CloseGroup groupID
// Close the HDF5 file
HDF5CloseFile fileID
return result
End
Loading an HDF5 String Attribute
This function illustrates how to load a string attribute of a group or dataset. The function result is an error 
code. The value of the attribute is returned via the pass-by-reference attributeValue string parameter.
Function LoadHDF5StringAttribute(pathName, filePath, groupPath, objectName, 
objectType, attributeName, attributeValue)
String pathName
// Symbolic path name - or ""
String filePath
// File name, relative path or full path
String groupPath
// Path to group, such as "/", "/metadata_group"
String objectName
// Name of group or dataset
Variable objectType
// 1=group, 2=dataset
String attributeName
// Name of attribute
String& attributeValue
// Output - pass-by-reference parameter
attributeValue = ""
Variable result = 0
// Open the HDF5 file
Variable fileID
// HDF5 file ID will be stored here
HDF5OpenFile /P=$pathName /R /Z fileID as filePath
if (V_flag != 0)
Print "HDF5OpenFile failed"
