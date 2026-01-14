# Column Titles

Chapter II-12 — Tables
II-254
There is a shortcut for changing a setting for all columns at once without using the dialog: Press Shift while 
choosing an item from the Table menu, from the Table pop-up menu, or from the contextual menu.
Tables are primarily intended for on-screen data editing. You can use a table for presentation purposes by 
exporting it to another program as a picture or by including it in a page layout. However, it is not ideal for 
this purpose. For example, there no way to change the background color or the appearance of gridlines.
You can capture your favorite styles as preferences. See Table Preferences on page II-272.
Modifying Column Properties
You can independently set properties, such as color, column width, font, etc., for the index or dimension 
label column and the data column of 1D waves. Except in rare cases all of the data columns of a multidi-
mensional wave should have the same properties. When you set the properties of one data column of a mul-
tidimensional wave using Igor’s menus or using the Modify Columns dialog, Igor sets the properties of all 
data columns the same.
For example, if you are editing a 3 x 3 2D wave and you set the first data column to red, Igor will make the 
second and third data columns will red too.
Despite Igor’s inclination to set all of the data columns of a multidimensional wave the same, it is possible 
to set them differently. Select the columns to be modified. Press Command (Macintosh) or Ctrl (Windows) 
before clicking the Table menu or Table pop-up menu and make a selection. Your selection will be applied 
to the selected columns only instead of to all data columns from the selected waves.
The ModifyTable operation supports a column number syntax that designates a column by its position in 
the table. Using this operation, you can set any column to any setting. For example:
Make/O/N=(3,3) mat
Edit mat
ModifyTable rgb[1]=(50000,0,0), rgb[2]=(0,50000,0)
This sets mat’s first data column to red and its second to blue.
You can specify a range of columns using column number syntax:
ModifyTable rgb[1,3]=(50000,0,0)
The Modify Columns dialog sets the properties for both the real and imaginary columns of complex waves 
at the same time. If you really want to set the properties of the real and imaginary columns differently, you 
must use the column number syntax shown above.
Column Titles
The column title appears at the top of each column. By default, Igor automatically derives the column title 
from the name of the wave displayed in the column. For example, if we display the X index and data values 
of wave1 and data values of wave2, the table will have columns titled wave0.x, wave0.d, and wave1.
Igor uses the suffixes “.x” and “.d” only if this is necessary to distinguish columns. If there is no index 
column displayed, Igor omits the suffix.
Using the Title setting in the Modify Columns dialog, you can replace the automatically derived title with 
a title of your own. Remove all text from this item to turn the automatic title back on.
The title setting changes only the title of the column in this table. It does not change wave name. We provide 
the column title setting primarily to make tables look better in presentations (in layouts and exported pic-
tures). If you are not using a table for a presentation, it is better to let Igor automatically generate column 
titles since this has less potential for confusion. If you want to rename a wave, use the Rename items in the 
Data and Table pop-up menus.
If you really need to use column titles for multidimensional waves, use the techniques described in Modi-
fying Column Properties on page II-254 to set the title for individual columns.
