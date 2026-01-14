# Copying Values

Chapter II-12 — Tables
II-247
example, if you enter 991005, are you trying to enter a date or a number? Igor has no way to know. There-
fore, if you want to create a new column consisting of dates with no separators, you must choose Date from 
the Table Format submenu before you enter the value. This is not necessary for dates that include separators 
because Igor can distinguish them from numbers.
If you choose a date format that includes alphabetic characters, such as “October 11, 1999”, you must enter 
dates exactly as the format indicates, including spaces.
For further discussion of how Igor represents dates, see Date/Time Waves on page II-85.
Special Values
There are two special values that can be entered in any numeric data column. They are NaN and INF.
Missing Values (NaNs)
NaN stand for “Not a Number” and is the value Igor uses for missing or blank data. Igor displays NaNs in 
a table as a blank cell. NaN is a legal number in a text data file, in text pasted from the clipboard, and in a 
numeric expression in Igor’s command line or in a procedure.
A point will have the value NaN when a computation has produced a meaningless result, for example if 
you take the log of a negative number. You can enter a missing value in a cell of a table by entering NaN or 
by deleting all of the text in the entry line and confirming the entry.
You can also get NaNs in a wave if you load a delimited text data file or paste delimited text which contains 
two delimiters with no number in between.
Infinities (INFs)
INF stands for “infinity”. Igor displays infinities in a table as “INF”. INF is a legal number in a text data file, 
in text pasted from the clipboard and in a numeric expression in Igor’s command line or in a procedure.
A point will have the value INF or -INF when a computation has produced an infinity, for example if you 
divide by zero. You can enter an infinity in a cell of a table by entering INF or -INF.
Clearing Values
You invoke the clear operation by choosing EditClear from. Clear sets all selected cells in numeric 
columns to zero. It sets all selected cells in text and dimension label columns to "" (empty string). It has no 
effect on selected cells in index columns.
To set a block of numeric values to NaN (or any other numeric value), select the block and then choose Anal-
ysisCompose Expression. In the resulting dialog, choose “_table selection_” from the Wave Destination 
pop-up menu. Enter “NaN” as the expression and click Do It.
Copying Values
You invoke the copy operation by choosing EditCopy. This copies all selected cells to the clipboard as text 
and as Igor binary. It is useful for copying ranges of points from one wave to another, from one part of a 
wave to another part of that wave, and for exporting data to another application or to another Igor experi-
ment (see Exporting Data from Tables on page II-252).
Copying and pasting in Igor tables uses the binary version of the data which represents the data with full 
precision and also includes wave properties such as scaling and units. If you paste anywhere other than an 
Igor table, for example to an Igor notebook or to another program, the text version of the data is used.
For technical reasons relating to 64-bit support, the binary clipboard format is different from the Igor Pro 6 
format. Consequently you can not copy/paste binary table data between these versions.
