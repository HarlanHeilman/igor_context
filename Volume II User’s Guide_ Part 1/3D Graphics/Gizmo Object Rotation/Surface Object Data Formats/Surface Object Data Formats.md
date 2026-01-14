# Surface Object Data Formats

Chapter II-17 — 3D Graphics
II-451
See AppendToGizmo and ModifyGizmo for programming details.
Gizmo Wave Data Formats
Objects like surface plots, path plots, isosurfaces and voxelgrams are based on the data in a wave and are 
therefore called "wave-based data objects" or "data objects" for short. The wave supplying the data is called 
the "data wave" or the "source wave".
The following sections describe the data format requirements for the different data objects.
Scatter, Path, and Ribbon Data Formats
Scatter and path plots require a triplet wave, which is a 2D wave containing 3 columns for the X, Y, and Z 
coordinates of each vertex. A color wave for a scatter or path plot is a 2D wave in which each row specifies 
the color of the corresponding vertex in the data wave. The color wave has 4 columns which specify RGBA 
entries in the range of [0,1].
A ribbon plot also requires a triplet wave. A color wave for ribbon plot is the same as for scatter or path 
plots with one row of RGBA values per vertex. See also ModifyGizmo with the keyword pathToRibbon 
and Ribbon Plots on page II-462.
Surface Object Data Formats
The data wave format depends on the type of surface plot.
A simple surface plot is created from a 2D wave also known as a "matrix" or "matrix of Z values". The color 
wave for this type of surface plot is a 3D RGBA wave where the four layers in the wave contain the R, G, B 
and A components in the range of [0,1].
