# Triplet Waves

Chapter II-17 — 3D Graphics
II-406
Overview
Igor can create various kinds of 3D graphics including:
•
Surface Plots
•
3D Scatter Plots
•
3D Bar Plots
•
Path Plots
•
Ribbon Plots
•
Isosurface Plots
•
Voxelgram Plots
Image Plots, Contour Plots and Waterfall Plots are considered 2D graphics and are discussed in other sec-
tions of the help.
Igor's 3D graphics tool is called "Gizmo". Most 3D graphics that you produce with Gizmo will be based on 
data stored in waves. It's important to understand what type of wave data is required for what type of 3D 
graphic, as explained in the following sections explain.
1D Waves
1D waves can not be used for 3D plots. 
If you have three 1D waves that represent X, Y and Z coordinates which you want to display as a 3D plot, 
you must convert them into a triplet wave. For example:
Concatenate {xWave,yWave,zWave}, tripletWave
Now you can plot the triplet wave using one of the methods described below.
The conversion of three 1D waves into a triplet wave is appropriate when the data are not sampled on a 
rectangular grid. If you know that your data are sampled on a rectangular grid you should convert the wave 
that contains your Z data into a 2D wave using the Redimension operation and then proceed to plot the 
surface using the 2D wave. You can perform this conversion, for example, using the commands: 
Duplicate/O zWave, zMatrixWave
Redimension/N=(numRows,numColumns) zMatrixWave
2D Waves
A 2D wave, sometimes called a "matrix of Z values", is an M-row by N-column wave where each element 
represents a scalar Z value. You can apply wave scaling (see Waveform Model of Data on page II-62) to 
associate an X value with each row and a Y value with each column.
2D waves can be displayed as 3D graphics in Surface Plots and 3D Bar Plots.
(2D waves can also be displayed as 2D graphics in Image Plots, Contour Plots, and Waterfall Plots.)
Triplet Waves
A triplet wave is an M-row by 3-column wave containing an XYZ triplet in each row. The X value appears 
in the first column, the Y value in the second and the Z value in the third. A triplet wave is a 2D wave inter-
preted as containing X, Y and Z coordinates.
Triplet waves can be displayed as 3D graphics in 3D Scatter Plots, Surface Plots, Path Plots and Ribbon 
Plots. In a surface plot the triplet wave defines triangles on a surface.
(Triplet waves can also be displayed as 2D graphics in Contour Plots.)
