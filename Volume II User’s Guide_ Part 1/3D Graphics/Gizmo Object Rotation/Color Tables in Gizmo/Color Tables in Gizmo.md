# Color Tables in Gizmo

Chapter II-17 — 3D Graphics
II-431
The required color wave format depends on the format of the data wave that describes the object to which 
the color is to be applied. This table shows some of the various data wave formats with their corresponding 
color wave formats. Dimensionality is indicated in parenthesis:
Color Tables in Gizmo
You can use Igor's built-in color tables to specify the colors of surface, scatter, path and ribbon objects. Iso-
surface, voxelgram, 3D bar chart, and image objects do not support the use of color tables.
For surface, scatter, path and ribbon objects, you can select the color table in the properties dialog for a given 
type of object. To see a list of available color tables, see CTabList and for more information, see Color Table 
Details on page II-395.
When you choose a color table you can also set related options. In the properties dialog you set these 
options using the Details button which displays a subdialog that looks like this:
The Color Table Alpha setting applies to all colors in the color table. If you want to apply a variable alpha, 
set the object color using a color wave where you specify the alpha value for each data point. Color waves 
are not supported for isosurface objects. Remember that alpha effects require that blending is enabled and 
that there is a blend function on the display list - see Transparency and Translucency for details.
The Color Table Span setting determines the numeric quantity used to select a color from the color table. 
For a scatter plot the most common choice is Global Z Range. By default this means that the lowest Z value 
displayed in the plot is mapped to the first color and the highest Z value is mapped to the last color. The 
color for a specific scatter element is chosen based on that element's Z value.
This mapping can be tweaked using the First Color and Last Color settings. If you enable First Color and 
enter a corresponding data value then that data value is mapped to the first color in the color table and any 
scatter element whose data value is less than the entered value is displayed using the color selected from 
the color pop-up menu below. If you enable Last Color and enter a corresponding data value then that data 
Data Wave
Color Wave
Triplet (Mx3)
Used in path, ribbon and scatter plots
(Mx4) with RGBA in successive columns
Matrix of Z values (MxN)
Used in surface and 3D bar chart plots
(MxNx4) with RGBA in successive layers
Sequential Quads (Mx4x3)
Used in parametric surface plots
(Mx4x4) with RGBA in successive layers
Disjoint Quads (Mx12)
Used in parametric surface plots
(Mx4x4) with RGBA in successive layers
Triangles (Mx3)
Used in parametric surface plots
(Mx4) with RGBA in successive columns
Parametric (MxNx3)
Used in parametric surface plots
(MxNx4) with RGBA in successive layers
