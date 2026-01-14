# Voxelgram Plots

Chapter II-17 — 3D Graphics
II-463
This is an example of a ribbon plot overlayed with path and scatter plots of the same data in order to show 
the positioning of data points along the ribbon edges: 
Voxelgram Plots
"Voxel" is short for "volume element".
A voxelgram is a representation of a 3D wave that uses color to indicate the wave elements containing 
certain values. You specify 1 to 5 values and, for each value, an associated RGBA color. If a given wave ele-
ment's value matches one of the specified values within a specified tolerance, Gizmo displays that element 
using the associated RGBA color. If a wave element matches none of the specified levels then it is not dis-
played at all.
Voxels can be represented by cubes or points.
The full list of available options is given under ModifyGizmo.
This example shows a voxelgram that uses two specified values:
