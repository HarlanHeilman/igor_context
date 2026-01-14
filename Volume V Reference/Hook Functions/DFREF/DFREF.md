# DFREF

DeletePoints
V-157
DeletePoints 
DeletePoints [/M=dim] startElement, numElements, waveName 
[, waveName]…
The DeletePoints operation deletes numElements elements from the named waves starting from element 
startElement.
Flags
Details
A wave may have any number of points, including zero. Removing all elements from any dimension 
removes all points from the wave, leaving a 1D wave with zero points.
Except for the case of removing all elements, DeletePoints does not change the dimensionality of a wave. 
Use Redimension for that.
See Also
The Redimension operation.
deltax 
deltax(waveName)
The deltax function returns the named wave’s dx value. deltax works with 1D waves only.
Details
This is equal to the difference of the X value of point 1 minus the X value of point 0.
See Also
The leftx and rightx functions.
When working with multidimensional waves, use the DimDelta function.
For an explanation of waves and wave scaling, see Changing Dimension and Data Scaling on page II-68.
DFREF 
DFREF localName [= path or dfr], [localName1 [= path or dfr]]
DFREF is used to define a local data folder reference variable or input parameter in a user-defined function.
The syntax of the DFREF is:
DFREF localName [= path or dfr ][, localName1 [= path or dfr ]]...
where dfr stands for "data folder reference". The optional assignment part is used only in the body of a 
function, not in a parameter declaration.
Unlike the WAVE reference, a DFREF in the body without the assignment part does not do any lookup. It 
simply creates a variable whose value is null.
Examples
Function Test(dfr)
DFREF dfr
Variable dfrStatus = DataFolderRefStatus(dfr)
if (dfrStatus == 0)
Print "Invalid data folder reference"
return -1
endif
/M=dim
If /M is omitted, DeletePoints deletes from the rows dimension.
dim specifies the dimension from which elements are to be deleted. Values are:
0:
Rows.
1:
Columns.
2:
Layers.
3:
Chunks.
