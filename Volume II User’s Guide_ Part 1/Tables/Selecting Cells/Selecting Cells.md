# Selecting Cells

Chapter II-12 — Tables
II-243
Removing a column from a table does not kill the underlying wave. The column is not the wave but just a view 
of the wave. Use the Kill Waves item in the Table pop-up menu to remove waves from the table and kill them. 
Use the Kill Waves item in the Data menu to kill waves you have already removed from a table.
Selecting Cells
If you click in a cell, it becomes the target cell. The old target cell is deselected and the cell you clicked on is 
highlighted. The target cell ID changes to reflect the row and column of the new target cell and the value of 
the target cell is shown in the entry line. You click in a cell and make it the target when you want to enter a 
new value for that cell or because you want to select a range of cells starting with that cell.
Here are the selections that you can make:
The selection in a table must be rectangular. Igor will not let you select a range that is not rectangular. If you 
choose Select All, Igor will attempt to select all of the cells in the table. However, if you have columns of 
different length, Igor will be limited to selecting a rectangular array of cells.
If, after clicking in a cell to make it the target cell, you drag the mouse, the cells over which you drag are 
selected and highlighted to indicate that they are selected. You select a range of cells in preparation for 
copying, cutting, pasting or clearing those cells. While you drag, the cell ID area shows the number of rows 
and columns that you have currently selected. If you drag beyond the edges of the table, the cell area scrolls 
so that you can select as many cells as you want.
Moving the target cell accepts any data entry in progress.
You can change which cell is the target cell using Return, Enter, Tab, or arrow keys. If you are entering a 
value, these keys also accept the entry.
If you have a range of cells selected, these keys keep the target cell within that selected range. If it is at one 
extreme of the selected range it will wrap around to the other extreme.
By default, the arrow keys move the target cell. You can change it so they move the insertion point in the 
entry line using TableTable Misc Settings.
The used columns in a table are always contiguous. If you click in any unused column, Igor selects the first 
unused cell. There are just two things you can do when the first unused cell is selected: create a new wave 
Click
Action
Click
Selects a single cell and makes it the target cell
Shift-click
Extends or reduces the selection range
Click in the point column
Selects the entire row
Click in a column name
Selects the entire column
Click in an unused column
Selects the first unused cell
Choose Select All (Edit menu)
Selects all cells (if possible)
Key
Action (When a Single Cell is Selected)
Return, Enter, Down Arrow
Moves target cell down
Shift-Return, Shift-Enter, Up Arrow
Moves target cell up
Tab, Right Arrow
Moves target cell right
Shift-Tab, Left Arrow
Move target cell left
