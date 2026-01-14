# Dir

DimDelta
V-160
Reference
Wood, D.C. (June 1992). "The Computation of Polylogarithms. Technical Report 15-92". Canterbury, UK: 
University of Kent Computing Laboratory.
The function based on an algorithm by Didier Clamond.
DimDelta 
DimDelta(waveName, dimNumber)
The DimDelta function returns the scale factor delta of the given dimension.
Use dimNumber=0 for rows, 1 for columns, 2 for layers and 3 for chunks. 
If dimNumber=0 this is identical to deltax(waveName).
See Also
DimOffset, DimSize, SetScale, WaveUnits, ScaleToIndex
For an explanation of waves and wave scaling, see Changing Dimension and Data Scaling on page II-68.
DimOffset 
DimOffset(waveName, dimNumber)
The DimOffset function returns the scaling offset of the given dimension.
Use dimNumber=0 for rows, 1 for columns, 2 for layers, and 3 for chunks. 
If dimNumber=0 this is identical to leftx(waveName).
See Also
DimDelta, DimSize, SetScale, WaveUnits, ScaleToIndex
For an explanation of waves and wave scaling, see Changing Dimension and Data Scaling on page II-68.
DimSize 
DimSize(waveName, dimNumber)
The DimSize function returns the size of the given dimension.
Use dimNumber=0 for rows, 1 for columns, 2 for layers, and 3 for chunks. 
For a 1D wave, DimSize(waveName,0) is identical to numpnts(waveName).
See Also
DimDelta, DimOffset, SetScale, WaveUnits
Dir 
Dir [dataFolderSpec]
The Dir operation returns a listing of all the objects in the specified data folder.
Parameters
If you omit dataFolderSpec then the current data folder is used.
If present, dataFolderSpec can be just the name of a child data folder in the current data folder, a partial path 
(relative to the current data folder) and name or an absolute path (starting from root) and name.
Details
The format of the printed information is the same as the format used by the string function DataFolderDir. 
Igor programmers may find it more convenient to use CountObjects and GetIndexedObjName.
Usually it is easier to use the Data Browser (Data menu). However, Dir is useful when you want to copy a 
name into the command line or when you want to document the current state of the folder in the history.
See Also
Chapter II-8, Data Folders.
