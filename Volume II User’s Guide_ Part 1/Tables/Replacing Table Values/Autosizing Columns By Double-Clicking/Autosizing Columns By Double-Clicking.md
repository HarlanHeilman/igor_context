# Autosizing Columns By Double-Clicking

Chapter II-12 — Tables
II-252
Selectively Replacing Table Values
The Replace In Table dialog is designed to do a mass replace. You can do a selective replace using the Find 
In Table dialog followed by a series of Find Again and Paste operations. Here is the process:
1.
Choose EditFind and find the first cell containing the value you want to replace.
2.
Edit that cell so it contains the desired value.
3.
Copy that cell’s contents to the clipboard.
4.
Do Find Again (Command-G on Macintosh, Ctrl+G on Windows) to find the next cell you might 
want to replace.
5.
If you want to replace the found cell, do Paste (Command-V on Macintosh, Ctrl+V on Windows).
6.
If not done, go back to step 4.
Exporting Data from Tables
You can use the clipboard to export data from an Igor table to another application. If you do this you must 
be careful to preserve the precision of the exported data.
When you copy data from an Igor table, Igor puts the data into the clipboard in two formats: tab-delimited 
text and Igor binary.
If you later paste that data into an Igor table, Igor uses the Igor binary data so that you retain all precision 
through the copy-paste operation.
If you paste the data into another application, the other application uses the text data that Igor stored in the 
clipboard. To prevent losing precision, Igor uses enough digits to represent the data with full precision.
You can also export data via files by choosing DataSave WavesSave Delimited Text or FileSave Table 
Copy.
Changing Column Positions
You can rearrange the order of columns in the table. To do this, position the cursor over the name of the 
column that you want to move. Press Option (Macintosh) or Alt (Windows) and the cursor changes to a hand. 
If you now click the mouse you can drag an outline of the column to its new position.
When you release the mouse the column will be redrawn in its new position. Igor always keeps all of the 
columns for a particular wave together so if you drag a column, you will move all of the columns for that wave.
The point column can not be moved and is always at the extreme left of the cell area.
Changing Column Widths
You can change the width of a column by dragging the vertical boundary to the right of the column name.
You can influence the manner in which column widths are changed by pressing certain modifier keys.
If Shift is pressed, all table columns except the Point column are changed to the same width.
The Command (Macintosh) or Ctrl (Windows) key determines what happens when you drag the boundary 
of a data column of a multidimensional wave. If that key is not pressed, all data columns of the wave are 
set to the same width. If that key is pressed then just the dragged column is changed.
Autosizing Columns By Double-Clicking
You can autosize a column by double-clicking the vertical boundary to the right of the column name.
You can influence the manner in which column widths are changed by pressing certain modifier keys.
