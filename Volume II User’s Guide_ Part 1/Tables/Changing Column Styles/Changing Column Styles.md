# Changing Column Styles

Chapter II-12 — Tables
II-253
If the no modifier keys are pressed and you double-click the boundary of a data column of a multidimen-
sional wave then the width of each data column is set individually.
When pressing Option (Macintosh) or Alt (Windows) and you double-click the boundary of a data column 
of a multidimensional wave then the width of all data columns are set the same.
If Shift is pressed, all table columns except the Point column are autosized. Shift pressed with Option (Mac-
intosh) or Alt (Windows) will autosize all data columns of a given wave to the same width.
When pressing Command (Macintosh) or Ctrl (Windows), only the double-clicked column is autosized, not 
all data columns of a multidimensional wave.
Autosizing Columns Using Menus
You can autosize columns by selecting them and choosing Autosize Columns from the Table menu or from 
the table popup menu in the top-right corner of the table. You can also choose Autosize Columns from the 
contextual menu that you get when you Control-click (Macintosh) or right-click (Windows) on a column.
You can influence the manner in which column widths are changed by pressing certain modifier keys.
If the no modifier keys are pressed and a data column of a multidimensional wave is selected, all data 
columns of that wave are set individually.
If Option (Macintosh) or Alt (Windows) is pressed and a data column of a multidimensional wave is selected, 
all data columns of that wave are set the same.
If Shift is pressed, all table columns except the Point column are autosized. Shift pressed with Option (Mac-
intosh) or Alt (Windows) will autosize all data columns of a given wave to the same width.
When pressing Command (Macintosh) or Ctrl (Windows), only the selected columns are autosized, not all 
data columns of a multidimensional wave.
Autosizing Limitations
When you autosize a column, the width of every cell in that column must determined. For very long 
columns (100,000 points or more), this may take a very long time. When this happens, cell checking stops 
and the autosize is based only on the checked cells.
Similarly, if you autosize the data columns of a multidimensional wave with a very large number of 
columns (10,000 or more columns), this could take a very long time. When this happens, columns checking 
stops and the autosize is based only on the checked columns.
If the default time limits are not suitable, use the ModifyTable autosize keyword to set the time limits.
Changing Column Styles
You can change the presentation style of columns in a table using the Modify Columns dialog, the Table 
menu in the main menu bar, the Table pop-up menu (gear icon), or the contextual menu that you get by 
right-clicking.
You can invoke the Modify Columns dialog from the Table menu, from the Table pop-up menu, from the 
contextual menu, or by double-clicking a column name.
You can select one or more columns in the Columns to Modify list. If you select more than one column, the 
items in the dialog reflect the settings of the first selected column.
Once you have made your selection, you can change settings for the selected columns. After doing this, you 
can then select a different column or set of columns and make more changes. Igor remembers all of the 
changes you make, allowing you to do everything in one trip to the dialog.
