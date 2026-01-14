# Creating New Waves by Pasting Data from Another Program

Chapter II-12 — Tables
II-239
When creating a new wave by entering data into an unused table cell, there are some rare situations when 
what you are trying to enter cannot be properly interpreted unless you first choose the appropriate column 
numeric format from the Table menu. For example, if the decimal symbol is comma and you want to enter 
a time or date/time value with fractional seconds, you must choose Time or Date/Time from the 
TableFormats menu before entering the data.
If the decimal symbol is period then the thousands separator is comma. If the decimal symbol is comma 
then the thousands separator is period. The thousands separator is permitted when entering data in a table. 
You can also choose a column numeric format that displays thousands separators. However thousands sep-
arators are not permitted when creating new waves by pasting text into a table.
Using a Table to Create New Waves
If you click in any unused column, Igor selects the first cell in the first unused column. You can then create 
new waves by entering a value or pasting data that you have copied to the clipboard.
Creating a New Wave by Entering a Value
When you enter a data value in the first unused cell, Igor creates a single new 1D wave and displays it in the 
table. This is handy for entering a small list of numbers or text items. If you enter a numeric value, including 
date/time values, Igor creates a numeric wave. If you enter a nonnumeric value, Igor creates a text wave.
Igor gives the wave a default name, such as wave0 or wave1. You can rename the wave using the Rename 
item in the Data menu or the Rename item in the Table pop-up menu. You can also rename the wave from 
the command line by simply executing:
Rename oldName, newName
When you create a new wave, the wave has one data point — point 0. The cell in point number 1 appears 
gray. This is the insertion cell. It indicates that the preceding cell is the last point of the wave. You can click 
in the insertion cell and enter a value or do a paste. This adds one or more points to the wave.
If the new wave is numeric, it will be single or double precision, depending on the Default Data Precision 
setting in the Miscellaneous Settings dialog. The number of digits displayed, however, depends on the 
numeric format. See Numeric Formats on page II-255.
When entering a date, you must use the format selected in the Table Date Format dialog, accessible via the 
Table menu. The setting in this dialog affects all tables.
If you enter a date (e.g., 1993-01-26), time (e.g., 10:23:30) or date/time (e.g., 1993-01-26 10:23:30) value, Igor 
notices this. It sets the column’s numeric format to display the value properly. It also forces the new wave 
to be double precision, regardless the Default Data Precision setting in the Miscellaneous Settings dialog. 
This is necessary because single precision does not have enough range to store date and time values.
Creating New Waves by Pasting Data from Another Program
If you have data in a spreadsheet program or other graphing program, you may be able to import that data 
into Igor using copy and paste.
This will work if the other program can copy its data to the clipboard as tab-delimited text or comma-delim-
ited text. Most programs that handle data in columns can do this. Tab-delimited data consists of a number 
of lines of text with following format:
value <tab> value <tab> value <terminator>
It may start with a line containing column names. The end of a line is marked by a terminator which may 
be a carriage return, a linefeed, or a carriage return/linefeed combination. If pasted into a word processor, 
tab delimited text would look something like this:
column1
column2
column3
(this line is optional)
27.95
-13.738
12.74e3
31.37
-12.89
13.97e3
