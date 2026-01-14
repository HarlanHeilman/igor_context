# Entering Values

Chapter II-12 — Tables
II-244
by entering a value or create new waves by pasting data from the clipboard. Igor will not allow you to select 
any unused cell other than the first cell in the first unused column.
The Insertion Cell
At the bottom of every column of data values is a special cell called the insertion cell. It appears as a gray 
box below the very last point in a wave.
Sometimes you know the number of points that you want a wave to contain and don’t need to insert addi-
tional points into the wave. However, if you want to enter a short list of values into a table or to add new 
data to an existing wave, you can do this by entering data in the insertion cell.
When you enter a value in an insertion cell, Igor extends the wave by one point. Then the insertion cell 
moves down one position and you can insert another point.
The insertion cell can also be used to a extend a wave or waves by more than one point at a time. This is 
described under Pasting Values on page II-248.
You can also insert points in waves using the Insert Points item which appears in both the Table pop-up 
menu and the Data menu or using the InsertPoints operation from the command line.
Entering Values
You can alter the data value of a point in a wave by making the cell corresponding to that value the target 
cell, typing the new value in the entry line, and then confirming the entry.
You can also accept the entry by clicking in any cell or by pressing any of the keys that move the target cell: 
Return, Enter, Tab, or arrow keys. You can discard the entry by pressing Escape or by clicking the X icon.
If a range of cells is selected when you confirm an entry, the target cell will move within the range of 
selected cells unless you click in a cell outside this range.
While you are in the process of entering a value, the Clear, Copy, Cut and Paste items in the Edit menu as 
well as their corresponding command key shortcuts affect the entry line. If you are not in the process of 
entering, these operations affect the cells.
Entering a value in an insertion cell is identical to entering a value in any other cell except that when the 
entry is confirmed the wave is extended by one point.
Igor will not let you enter a value in an index column since index values are computed based on a waves 
dimension scaling.
Dimension labels are limited to 255 bytes. If you paste into a dimension label cell, Igor clips the pasted data 
to 255 bytes.
Prior to Igor Pro 8.00, dimension labels were limited to 31 bytes. If you use long dimension labels, your 
wave files and experiments will require Igor Pro 8.00 or later.
When entering a value in a numeric column, if what you have entered in the entry line is not a valid numeric 
entry, Igor will not let you confirm it. The check icon will be dimmed to indicate that the value can not be 
entered. To enter a date in a date column, you must use the date format specified in the Table Date Format 
dialog.
If you edit a text wave or dimension label which contains bytes that are not valid in the wave's text encod-
ing, Igor displays a warning and substitutes escape codes for the invalid bytes. See Editing Invalid Text on 
page II-259 for details.
If you attempt to enter a character that can not be represented in the text encoding controlling a text wave 
or dimension label, Igor displays an error message. See Entering Special Characters on page II-261 for 
details.
