# Cutting and Pasting Rows Versus Columns

Chapter II-12 — Tables
II-268
3.
Choose EditCopy to copy the selected cells.
Since you did not press Option or Alt, this copies just the visible layer.
4.
Press shift and choose EditInsert Paste to insert-paste the copied data.
Notice that two new rows were inserted, pushing the pre-existing rows down.
5.
Press Option-Down Arrow or Alt+Down Arrow to see what was inserted in layers 1 and 2 of the 3D 
wave.
Notice that zeros were inserted. This is because the paste stored data only in the visible layer.
6.
Press Option-Up Arrow or Alt+Up Arrow to view layer 0 again.
7.
Choose EditUndo from the Edit menu to undo the paste.
8.
Use Option-Down Arrow or Alt+Down Arrow to check the other layers of the wave and then use 
Option-Up Arrow or Alt+Up Arrow to come back to layer zero.
The wave is back in its original state.
Now we will do an insert-paste in all layers.
9.
Select rows 1 and 2 of the wave.
10. Press Option or Alt and choose EditCopy All Layers.
This copies data from all three layers to the clipboard.
11. Press Shift-Option or Shift+Alt and choose EditInsert Paste All Layers.
This pastes data from the clipboard into all three layers of the wave. By pressing Shift, we did an 
insert-paste rather than a replace-paste and by pressing Option or Alt, we pasted into all layers, not 
just the visible layer.
12. Use Option-Down Arrow or Alt+Down Arrow to verify that we have pasted data into all layers.
Cutting and Pasting Rows Versus Columns
Normally, you cut and paste rows of data. However, there may be cases where you want to cut and paste 
columns. For example, if you have a 2D wave with 5 rows and 3 columns, you may want to cut the middle 
column from the wave. Here is how Igor determines if you want to cut rows or columns.
If the selected wave is 2D or higher, and if one or more entire columns is selected, Igor cuts the selected 
column or columns. In all other cases Igor cuts rows.
After copying or cutting wave data, you have data in the clipboard. Normally, a paste overwrites the 
selected rows or inserts new rows (if you press Shift).
To insert columns, you need to do the following:
1.
Copy the column that you want to insert.
2.
Select exactly one entire column. You can do this quickly by clicking the column name.
3.
Press Shift and choose EditInsert Paste or press Command-Shift-V (Macintosh) or Ctrl+Shift+V 
(Windows).
If the wave data is real (not complex), Igor normally pastes the new column or columns before the selected 
column. This behavior would provide you with no way to paste columns after the last column of a wave. 
Therefore, if the selected column is the last column, Igor presents a dialog to ask you if you want to paste 
the new columns before or after the last column.
If the wave data is complex, Igor pastes the new columns before the selected column if the selected column 
is real or after the selected column if it is imaginary.
If you select more than one column or if you do not select all of the column, Igor will insert rows instead of 
columns.
