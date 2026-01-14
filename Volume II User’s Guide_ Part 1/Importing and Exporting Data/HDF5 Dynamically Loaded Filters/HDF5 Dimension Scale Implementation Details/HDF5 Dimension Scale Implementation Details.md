# HDF5 Dimension Scale Implementation Details

Chapter II-10 — Igor HDF5 Guide
II-218
for plugins, before looking in the default filter location or in the locations specified by the HDF5_PLUGIN_-
PATH environment variable if it exists. This means that the HDF5 library will find the filter plugins that 
ship with Igor, not those in other locations.
There are other "registered filtered plugins" besides the ones listed above. A comprehensive list can be 
found at https://portal.hdfgroup.org/display/support/Registered+Filter+Plugins. It is unlikely that you will 
need other filter plugins. If you do, you can put them in the default location or the location specified by the 
HDF5_PLUGIN_PATH environment variable. The HDF5 library will look for them there after not finding 
them in Igor's hdf5plugins folder.
As noted above, filter plugin libraries on Macintosh need to be tweaked to work with Igor. Consequently, 
on Macintosh, other filter plugins will probably not work no matter where you put them.
HDF5 Dimension Scales
The HDF5 library supports dimension scales through the H5DS API. A dimension scale is a dataset that 
provides coordinates for another dataset. A dimension scale for dimension 0 of a dataset is analogous to an 
X wave in an Igor XY pair. The analogy applies to higher dimensions also.
Dimension scales are primarily of use in connection with the netCDF-4 format which is based on HDF5. 
Most Igor users do not need to know about dimension scales.
In the netCDF file format, the term "variable" is used like the term "dataset" in HDF5. Each variable of 
dimension n is associated with n named dimensions. Another variable, called a "coordinate variable", can 
supply values for the indices of a dimension, like an X wave supplies values for an XY pair in Igor.
The association between a variable and its coordinate variables is established when the variable is created. 
A given coordinate variable typically provides values for a given dimension of multiple variables. For 
example, a netCDF file may define coordinate variables named "latitude" and "longitude" and multiple 2D 
variables (images) whose X and Y dimensions are associated with "latitude" and "longitude".
The netCDF-4 file format is implemented using HDF5. The netCDF library uses the HDF5 dimension scale 
feature to implement coordinate variables and their associations with variables.
HDF5 Dimension Scale Support in Igor
The HDF5DimensionScale operation supports the creation and querying of HDF5 dimension scales. It was 
added in Igor Pro 9.00.
The operation is implemented using keyword=value syntax for setting parameters and simple keywords 
without values for invoking an action. For example, these commands convert a particular dataset into a 
dimension scale and then attach that dimension scale to another dataset:
// Convert a dataset named XScale into a dimension scale with name "X"
HDF5DimensionScale dataset={fileID,"XScale"}, dimName="X", setScale
// Attach dimension scale XScale to dimension 0 of dataset Data0
HDF5DimensionScale scale={fileID,"XScale"}, dataset={fileID,"Data0"},
dimIndex=0, attachScale
For details, see HDF5DimensionScale in Igor’s online help.
HDF5 Dimension Scale Implementation Details
If you view netCDF-4 files using Igor's HDF5 Browser, this section will help you to understand what you 
see in the browser.
The H5DS (dimension scale) API, which is part of the HDF5 "high-level" library, uses attributes to designate 
a dataset as a dimension scale, to associate a dimension scale with other datasets, and to keep track of the 
associations.
