# hermite

HDF5SaveGroup
V-345
HDF5SaveGroup
HDF5SaveGroup [flags] dataFolderSpec, locationID, nameStr
The HDF5SaveGroup operation saves the contents of an Igor data folder in an HDF5 file.
Documentation for the HDF5SaveGroup operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5SaveGroup"
HDF5SaveImage
HDF5SaveImage [flags] keyword [=value]
The HDF5SaveImage operation saves an image dataset and in some cases a palette dataset in an HDF5 file 
using the format specified in the HDF5 Image and Palette Specification version 1.2.
Documentation for the HDF5SaveImage operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5SaveImage"
HDF5TypeInfo
HDF5TypeInfo(locationID, datasetOrGroupNameStr, attributeNameStr, memberName, 
options, dti) 
The HDF5TypeInfo function stores information about the datatype of a dataset or attribute in the 
HDF5DataTypeInfo structure referenced by dti.
Documentation for the HDF5TypeInfo function is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5TypeInfo"
HDF5UnlinkObject
HDF5UnlinkObject [/Z] locationID, nameStr
The HDF5UnlinkObject operation unlinks the specified object (a group, dataset, datatype or link) from the 
HDF5 file.
Documentation for the HDF5UnlinkObject operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "HDF5UnlinkObject"
hermite 
hermite(n, x)
The hermite function returns the Hermite polynomial of order n:
The first few polynomials are:
See Also
The hermiteGauss function.
Hn(x) = (−1)n exp x2
(
) d n
dxn exp −x2
(
).
1
2x
4x2 −2
8x3 −12x
