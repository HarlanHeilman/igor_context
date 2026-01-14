# Gizmo Image Plots

Chapter II-17 — 3D Graphics
II-458
In a basic 3D bar plot, the bars all start at zero and extend in the positive Z direction. Here is an example:
The basic 3D bar plot represents a 2D matrix of positive values. Each value is displayed as a zero-based bar 
according to its row/column in the matrix. All bars have the same width.
In a refined bar plot, bars can be drawn at arbitrary positions and all bar dimensions are under your control. 
Here is an example:
The refined 3D Bar plot displays requires a 6-column input wave where each row represents a single bar 
and the columns contain the following information:
Using the refined mode it is possible to create stacked and overlapping 3D bars plots as well as bars of 
varying sizes.
To find out more open the 3D Bar Plot Demo experiment.
Gizmo Image Plots
A Gizmo Image is a form of a quad object that is internally textured by image data.
The image source wave can be in one of three formats:
Column 0:
The X center of the bar
Column 1:
The Y center of the bar
Column 2:
The lower Z value
Column 3:
The upper Z value
Column 4:
The width of the bar in the X direction
Column 5:
The width of the bar in the Y direction
