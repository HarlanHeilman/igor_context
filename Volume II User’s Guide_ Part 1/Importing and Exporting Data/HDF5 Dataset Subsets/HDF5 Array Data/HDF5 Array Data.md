# HDF5 Array Data

Chapter II-10 — Igor HDF5 Guide
II-207
Advanced HDF5 Data Types
This section is mostly of interest to advanced HDF5 users.
HDF5 Variable-Length Data
Most HDF5 files do not use variable-length datatypes so most users do not need to know this information.
Variable-length data consists of an array where each element is a 1D set of elements of another datatype, 
called the "base" datatype. The number of elements of the base datatype in each set can be different. For 
example, a 5 element variable-length dataset whose base type is H5T_STD_I32LE contains 5 1D sets of 32-
bit, little-endian integers and the length of each set is independent.
HDF5LoadData loads variable-length datasets where the base type is integer or float only. The data for each 
element is loaded into a separate wave.
When loading most types of data, HDF5LoadData creates just one wave. When loading a variable-length 
dataset or attribute, one wave is created for each loaded element. If more than one element is to be loaded, 
the proposed name for the wave (the name of the dataset or attribute being loaded or a name specified by 
/N=name ) is treated as a base name. For example, if the dataset or attribute has three elements and name 
is test and the /O flag is used, waves named test0, test1 and test2 are created. If the /O flag is not used, names 
of the form test<n> are created where <n> is a number chosen to make the wave names unique.
HDF5LoadData operation supports loading a subset of a variable-length dataset. You do this by supplying 
a slab wave using the HDF5LoadData /SLAB flag. In the example from the previous paragraph, if you 
loaded just one element, its name would be test, not test0. If you loaded two elements, they would be named 
test0 and test1, regardless of which two elements you loaded.
This function demonstrates loading one element of a variable-length dataset. We assume that a symbolic 
path named Data and a file named "Vlen.h5" exist and that the file contains a 1D variable-length dataset 
named TestVlen that contains at least two elements. The function loads the second variable-length element 
into a wave named TestWave.
Function DemoVlenLoad()
Variable fileID
HDF5OpenFile /P=Data /R fileID as "Vlen.h5"
HDF5MakeHyperslabWave("root:slab", 1)
// In HDF5 Utilities.ipf
Wave slab = root:slab
slab[0][%Start] = 1
// Start at second vlen element
slab[0][%Stride] = 1
// Use a stride of 1
slab[0][%Count] = 1
// Load 1 block
slab[0][%Block] = 1
// Set block size to 1
HDF5LoadData /N=TestWave /O /SLAB=slab fileID, "TestVlen"
HDF5CloseFile fileID
End
HDF5 Array Data
Most HDF5 files do not use array datatypes so most users do not need to know this information.
An HDF5 dataset (or attribute) consists of elements organized in one or more dimensions. Each element can 
be an atomic datatype, such as an unsigned short or a double-precision float, or it can be a composite data-
type, such as a structure or an array. Thus, an HDF5 dataset can be an array of unsigned shorts, an array of 
doubles, an array of structures or an array of arrays. This section discusses loading this last type - an array 
of arrays.
In this case, the class of the dataset is H5T_ARRAY. The type of the dataset is something like "5 x 4 array of 
signed long" and "signed long" is said to be the "base type" of the array datatype. If the dataset itself is 1D
