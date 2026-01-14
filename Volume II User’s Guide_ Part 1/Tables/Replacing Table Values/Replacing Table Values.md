# Replacing Table Values

Chapter II-12 — Tables
II-251
A find in the current selection also starts from the target cell and proceeds forward or backward, depending 
on the state of the Search Backwards checkbox. The search stops when it hits the end or beginning of the 
selection, unless Wrap Around Search is enabled, in which case the whole selection is searched.
If Search Rows First is selected, all rows of a given column are searched, then all rows of the next column. If 
Search Columns First is selected, all columns of a given row are searched, then all columns of the next row.
To do a search of a 3D or 4D wave, you must create a table containing just that wave. Then the Table Find 
will search the entirety of the wave. If the table contains more than one wave, the Table Find will not search 
the parts (e.g. other layers of a 3D wave) of a 3D or 4D wave that are not shown in the table.
Choosing the EditFind Selection menu sets the Find mode to Find Text String, Find Blank Cells, Find Numeric 
Value, Find Date, Find Time Of Day, Find Elapsed Time, or Find Date/Time based on the format of the target cell 
except that, if the target cell is blank, the mode is set to Find Blank Cells regardless of the cell’s format.
You may find it convenient to use Find Again (Command-G on Macintosh, Ctrl+G on Windows) after doing 
an initial find to find subsequent cells with the specified contents. Pressing Shift (Comand-Shift-G on Mac-
intosh, Ctrl+Shift+G on Windows) does a Find Again in the opposite direction.
Replacing Table Values
You can perform a mass replace in a table by choosing EditReplace. This displays the Replace In Table 
dialog.
Unlike Find In Table, which can search all tables, Replace In Table is limited to the top table or the current 
selection, as set by the right-hand pop-up menu.
When you click Replace All, Replace In Table first finds the specified cell contents using the same rules as 
Find In Table. It then replaces the contents with the specified replace value. It then continues searching and 
replacing until it hits the end of the table or selection, unless Wrap Around Search is enabled, in which case 
the whole table or selection is searched.
You can undo all of the replacements by choosing EditUndo Replace.
Replace In Table does not affect X columns. You must use the Change Wave Scaling dialog (Data menu) for that.
Replace In Table goes through each candidate cell looking for the specified search value. If it finds the value, 
it extracts the text from the cell and does the replacement on the extracted text. If the resulting text is legal 
given the format of the cell, the replacement is done. If it is not legal, Replace In Table stops and displays 
an error dialog showing where the error occurred.
Here are some additional considerations regarding Replace In Table.
Find Type
Description
Text String
In each cell, all occurrences of the find string are replaced with the replace string. For 
example, if you replacing “22” with “33” and a cell contains the value 122.223, the 
resulting value will be 133.333. The replace string is limited to 254 bytes.
Using text string replace, it is possible to come up with a value that is not legal given a cell’s 
formatting. For example, if you replace “22” with “9.9” in the example above, you get 
“19.9.9.93”. This is not a legal numeric value so Replace In Table displays an error dialog.
Date
You can replace a date in a date column or a date/time column. When replacing a date in a 
date/time column, the time component is not changed. Dates must use the format specified 
by the Table Date Format dialog (Table menu).
Time of Day
You can replace a time of day in a time column or a date/time column. When replacing a 
time of day in a date/time column, the date component is not changed.
