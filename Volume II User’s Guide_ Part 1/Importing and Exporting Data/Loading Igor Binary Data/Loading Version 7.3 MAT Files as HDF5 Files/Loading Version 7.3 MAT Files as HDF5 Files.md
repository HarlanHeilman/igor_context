# Loading Version 7.3 MAT Files as HDF5 Files

Chapter II-9 — Importing and Exporting Data
II-165
When loading Matlab string data into an Igor wave, the Igor wave will be of dimension one less than the 
Matlab data set. This is because each element in a Matlab string data set is a single byte whereas each 
element in an Igor string wave is a string (any number of bytes).
MLLoadWave does not support loading of the following types of Matlab data: cell arrays, structures, sparse 
data sets, objects, 64 bit integers.
Numeric Data Loading Modes
The Load Matlab MAT File dialog presents a popup menu that controls how numeric data is loaded into 
Igor. The items in the menu are:
* Starting with Igor Pro 8.00, after loading a matrix that results in an Mx1 2D wave, MLLoadWave automat-
ically redimensions the wave as an M-row 1D wave.
When loading data of dimension 3 or 4, the first three modes treat each layer (“page” in Matlab terminol-
ogy) as a separate matrix. For 3D Matlab data, this gives the following behavior:
When loading 3D or 4D data sets, the term "matrix" in the last two modes is not really appropriate. MLLoad-
Wave loads the entire 3D or 4D data set into a 3D or 4D Igor wave.
Loading Version 7.3 MAT Files as HDF5 Files
In 2006 Matlab added version 7.3 of their MAT file format. A version 7.3 MAT file is an HDF5 file with 512 
bytes of Matlab-specific information at the start of the file. The HDF5 library allows applications to prepend 
application-specific data, so version 7.3 MAT files can be loaded as HDF5 files.
You may find it useful to load such files as HDF5 files because Igor has better HDF5 support than MAT-file 
support, because you don't have Matlab on your machine, or because Igor's Matlab support does not work 
with your Matlab installation. See Igor HDF5 Guide on page II-183 for information on Igor's HDF5 support.
A version 7.3 MAT file contains an HDF5 signature at byte offset 512. The HDF5 signature is an 8-byte 
pattern described at https://support.hdfgroup.org/HDF5/doc/H5.format.html.
Load columns into 1D wave
Each column of the Matlab matrix is loaded into a separate 1D 
Igor wave.
Load rows into 1D wave
Each row of the Matlab matrix is loaded into a separate 1D Igor 
wave.
Load matrix into one 1D wave
The entire Matlab matrix is loaded into a single 1D Igor wave.
Load matrix into matrix
The Matlab matrix is loaded into an Igor multi-dimensional 
wave*.
Load matrix into transposed matrix
The Matlab matrix is loaded into an Igor multi-dimensional 
wave* but the rows and columns are transposed.
Load columns into 1D wave
Each column of each layer of the Matlab data set is loaded into 
a separate 1D Igor wave.
Load rows into 1D wave
Each row of each layer of the Matlab data set is loaded into a 
separate 1D Igor wave.
Load matrix into one 1D wave
The layer of the Matlab data set is loaded into a 1D Igor wave.
Load matrix into matrix
The Matlab 3D data set is loaded into an Igor 3D wave.
Load matrix into transposed matrix
The Matlab 3D data set is loaded into an Igor 3D wave but the 
rows and columns are transposed.
