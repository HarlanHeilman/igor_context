# Troubleshooting General Text Files

Chapter II-9 — Importing and Exporting Data
II-141
Note:
If your data is uniformly spaced it is very important that you set the X scaling of your waves. Many 
Igor operations depend on the X scaling information to give you correct results.
If your 1D data is not uniformly spaced then you will use XY pairs and you do not need to change X scaling. 
You may want to use Change Wave Scaling to set the waves’ data units.
General Text Tweaks
The Load General Text routines provides some tweaks that allow you to guide Igor as it loads the file. To 
do this, use the Tweaks button in the Load Waves dialog.
The items at the top of the dialog are hidden because they apply to the Load Delimited Text routine only. 
Load General Text always skips any tabs and spaces between numbers and will also skip a single comma. 
The “decimal point” character is always period and it can not handle dates.
The items relating to column labels, data lines and data columns have two potential uses. You can use them 
to load just a part of a file or to guide Igor if the automatic method of finding a block of data produces incor-
rect results.
Lines and columns in the tweaks dialog are numbered starting from zero.
Igor interprets the “Line containing column labels” and “First line containing data” tweaks differently for 
general text files than it does for delimited text files. For delimited text, zero means “the first line”. For 
general text, zero for these parameters means “auto”.
Here is what “auto” means for general text. If “First line containing data” is auto, Igor starts the search for data 
from the beginning of the file without skipping any lines. If it is not “auto”, then Igor skips to the specified 
line and starts its search for data there. This way you can skip a block of data at the beginning of the file. If 
“Line containing column labels” is auto then Igor looks for column labels in the line immediately preceding 
the line found by the search for data. If it is not auto then Igor looks for column labels in the specified line.
If the “Number of lines containing data” is not “auto” then Igor stops loading after the specified number of 
lines or when it hits the end of the first block, whichever comes first. This behavior is necessary so that it is 
possible to pick out a single block or subset of a block from a file containing more than one block.
If a general text file contains more than one block of data and if “Number of lines containing data” is “auto” 
then, for blocks after the first one, Igor maintains the relationship between the line containing column labels 
and first line containing data. Thus, if the column labels in the first block were one line before the first line 
containing data then Igor expects the same to be true of subsequent blocks.
You can use the “First column containing data” and “Number of columns containing data” tweaks to load 
a subset of the columns in a block. If “Number of columns containing data” is set to “auto” or 0, Igor loads 
all columns until it hits the last column in the block.
Troubleshooting General Text Files
You can examine the waves created by the Load General Text routine using a table. If you don’t get the 
results that you expected, you will need to inspect and edit the text file until it is in a form that Igor can 
handle. Remember the following points:
•
Load General Text can not handle dates, times, date/times, commas used as decimal points, or 
blocks of data with non-numeric columns. Try Load Delimited Text instead.
•
It skips any tabs or spaces between numbers and will also skip a single comma.
•
It expects a line of column labels, if any, to appear in the first line before the numeric data unless you 
set tweaks to the contrary. It expects that the labels are also delimited by tabs, commas or spaces. It 
will not look for labels unless you enable the Read Wave Names option.
•
It works by counting the number of numbers in consecutive lines. Some unusual formats (e.g., 
1,234.56 instead of 1234.56) can throw this count off, causing it to start a new block prematurely.
•
It can not handle blanks or non-numeric values in a column. Each of these cause it to start a new block 
of data.
