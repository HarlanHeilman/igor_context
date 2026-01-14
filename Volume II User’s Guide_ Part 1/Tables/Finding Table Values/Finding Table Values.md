# Finding Table Values

Chapter II-12 — Tables
II-249
For example, if you have M columns of text in the clipboard but you select N columns and then do a paste, 
Igor presents presents the Columns to Paste dialog which gives you two options:
•
Paste M columns using the current selection
•
Change the selection and paste N columns
Mismatched Number of Rows
If the number of rows in the clipboard is not the same as the number of rows selected in the table then Igor 
asks you how many rows to paste. This applies to the replace-paste but not to the insert-paste or create-
paste.
For example, if you have M rows of text in the clipboard but you select N rows and then do a paste, Igor 
presents the Rows to Paste dialog which gives you three options:
•
Paste M rows using the current selection
•
Change the selection and paste N rows
•
Replace the selected N rows with M rows from the clipboard
Pasting and Index Columns
Since the values of an index column are computed based on point numbers, they can not be altered by past-
ing. However, if index columns and data columns are adjacent in a range of selected cells, a paste can still 
be done. The data values will be altered by the paste but the index values will not be altered.
Pasting and Column Formats
When you paste plain text data into existing numeric columns, Igor tries to interpret the text in the clip-
board based on the numeric format of the columns. For example, if a column is formatted as dates then Igor 
tries to interpret the data according to the table date format. If the column is formatted as time then Igor 
tries to interpret the text as a time values (e.g., 10:00:00). If the column has a regular number format, Igor 
tries to intrepret the text as regular numbers.
When you paste plain text data into unused columns, Igor does a create-paste. In this case, Igor inspects the 
text in the clipboard to determine if the data is in date format, time format, date and time format or regular 
number format. When it appends new columns to the table, it applies the appropriate numeric format.
When pasting octal or hexadecimal text in a table, you must first set the column format to octal or hexadec-
imal so that Igor will correctly interpret the text.
If the column does not appear to be in any of these formats, Igor creates a text wave rather than a numeric wave.
See Date Values on page II-245 for details on entering dates.
Copy-Paste Waves
You can copy and paste entire waves within Igor. This is described under Creating New Waves by Pasting 
Data from Igor on page II-240.
Inserting and Deleting Points
In addition to pasting and cutting, you can also insert and delete points from waves using the Insert Points 
and Delete Points dialogs via the Data menu or via the Table pop-up menu. You can use these dialogs to 
modify waves without using a table but they do work intelligently when a table is the top window.
Finding Table Values
You can search tables for specific contents by choosing EditFind. This displays the Find In Table dialog.

Chapter II-12 — Tables
II-250
Find In Table can search the current selection in the active table, the entire active table or all table windows. 
You control this using the right-hand pop-up menu at the top of the dialog.
The All Table Windows mode searches standalone table windows only. It does not search table subwin-
dows. It is possible to search a table subwindow in a control panel using the Top Table mode. Searching in 
tables embedded in graphs and page layouts is not supported.
Find In Table can search for the following types of values which you control using the left-hand pop-up menu.
Find In Table does not search the point column.
The search starts from the “anchor” cell. If you are searching the top table or the current selection, the 
anchor cell is the target cell. If you are searching all tables, the anchor cell is the first cell in the first-opened 
table, or the last cell in the last-opened table if you are doing a backward search.
When you do an initial search via the Find dialog, the search includes the anchor cell. When you do a sub-
sequent search using Find Again, the search starts from the cell after the anchor cell, or before it if you are 
doing a backward search.
A find in the top table starts from the target cell and proceeds forward or backward, depending on the state 
of the Search Backwards checkbox. The search stops when it hits the end or beginning of the table, unless 
Wrap Around Search is enabled, in which case the whole table is searched.
Find Type
Description
Row
Displays the specified row but does not select it.
Text String
Finds the specified text string in any type of column: text, numeric, date, time, 
date/time, and dimension labels.
For example, searching for “-1” would find numeric cells containing -1.234 and -1e6. A 
given cell is found only once, even if the search string occurs more than once in that cell.
The target string is limited to 254 bytes.
Blank Cell
Finds blank cells in any type of column: text, numeric, date, time, date/time, and 
dimension labels. Finds blank cells in numeric columns (NaNs) and text columns (text 
elements containing zero characters).
Numeric Value
Finds numeric values within the specified range in numeric columns only. Does not 
search the following types of columns: text, date, time, date/time, and dimension labels.
Date
Finds date values within the specified range in date and date/time columns only. Does 
not search the following types of columns: text, numeric, time and dimension labels.
Accepts input of dates in the format specified by Table Date Format dialog (Table menu).
Time of Day
Finds a time of day within the specified range in time and date/time columns only. Does 
not search the following types of columns: text, numeric, date and dimension labels.
A time of day is a time between 00:00:00 and 24:00:00. Times are entered as hh:mm:ss.ff 
with the seconds part and fractional part optional.
Elapsed Time
Finds an elapsed time within the specified range in time columns only. Does not search 
the following types of columns: text, numeric, date, date/time and dimension labels.
Unlike a time of day, an elapsed time can be negative and can be greater than 24:00:00. 
Times are entered as hh:mm:ss.ff with the seconds part and fractional part optional.
Date/Time
Finds a date/time within the specified range in date/time columns only. Does not search 
the following types of columns: text, numeric, date, time and dimension labels.
Date/time values consist of a date, a space and a time.
