# HDF5 Dataset Subsets

Chapter II-10 — Igor HDF5 Guide
II-202
objectName
if (V_flag != 0)
if (printErrors)
Print "HDF5LoadData failed"
endif
result = -1
break
endif
if (printRoutine)
Printf "Loaded attribute %d, name=%s\r", i, attributeNameStr
endif
endfor
// Close the HDF5 group
HDF5CloseGroup groupID
// Close the HDF5 file
HDF5CloseFile fileID
return result
End
HDF5 Dataset Subsets
It is possible, although usually not necessary, to load a subset of an HDF5 dataset using a "hyperslab". To 
use this feature, you must have a good understanding of hyperslabs which are explained in the HDF5 doc-
umentation. The examples below assume that you have read and understood that documentation.
HDF5 does not support loading a subset of an attribute.
To load a subset of a dataset, use the /SLAB flag of the HDF5LoadData operation. The /SLAB flag takes as 
its parameter a "slab wave". This is a two-dimensional wave containing exactly four columns and at least 
as many rows as there are dimensions in the dataset you are loading.
The four columns of the slab wave correspond to the start, stride, count and block parameters to the HDF5 
H5Sselect_hyperslab routine from the HDF5 library.
The following examples illustrate how to use a hyperslab. The examples use a sample file provided by 
NCSA and stored in Igor's HDF5 Samples directory.
Create an Igor symbolic path (MiscNew Symbolic Path) named HDF5Samples which points to the folder 
containing the i32le.h5 file (Igor Pro X Folder:Examples:Feature Demos:HDF5 Samples).
In the first example, we load a 2D dataset named "TestArray" which has 6 rows and 5 columns. We start by 
loading the entire dataset without using a hyperslab.
Variable fileID
HDF5OpenFile/P=HDF5Samples /R fileID as "i32le.h5"
HDF5LoadData /N=TestWave fileID, "TestArray"
Edit TestWave
Now we create a slab wave and set its dimension labels to make it easier to remember which column holds 
which type of information. We will use a utility routine in the automatically-loaded "HDF5 Utiliies.ipf" pro-
cedure file which is automatically loaded when Igor is launched:
HDF5MakeHyperslabWave("root:slab", 2
)
// In HDF5 Utilities.ipf
Edit root:slab.ld
Now we set the values of the slab wave to give the same result as before, that is, to load the entire dataset, 
and then we load the data again using the slab.
