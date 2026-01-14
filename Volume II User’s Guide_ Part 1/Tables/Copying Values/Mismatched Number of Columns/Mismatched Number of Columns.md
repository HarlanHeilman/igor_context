# Mismatched Number of Columns

Chapter II-12 — Tables
II-248
The text version of the copied data uses as many digits as needed to represent the data with full precision. 
If you want to export text exactly as shown in the table you must use the Save operation with the /F flag, or 
FileSave Table Copy, or the SaveTableCopy operation.
You can also create new waves by copying data from existing waves. This is described earlier in this chapter 
under Creating New Waves by Pasting Data from Igor on page II-240.
See also Multidimensional Copy/Cut/Paste/Clear on page II-265.
Cutting Values
You invoke the cut operation by choosing EditCut. Cut starts by copying all selected cells to the clipboard 
as text and as Igor binary. Then it deletes the selected points from their respective waves, thereby shorten-
ing the waves.
You cannot cut sections of an index column since index values are computed based on point numbers, not 
stored. However, if you cut a section of a data or dimension label column, the index column corresponding 
to the data column will also be shortened.
Pasting Values
You invoke the paste operation by choosing EditPaste. There are three kinds of paste operations: a 
replace-paste, an insert-paste and a create-paste.
When dealing with multidimensional waves, there are other options. See Multidimensional 
Copy/Cut/Paste/Clear on page II-265 for details.
When you do a paste, Igor starts by figuring out how many rows and columns of values are in the clipboard. 
The clipboard may contain binary data that you just copied from an Igor table or it may contain plain text 
data from another application such as a spreadsheet or a text editor.
If the data in the clipboard is plain text, Igor expects that rows of values be separated by carriage return 
characters, linefeed characters, or carriage return/linefeed pairs and that individual values in a row be sep-
arated by tabs or commas. This is normally no problem since most applications export data as tab-delimited 
text. If you have trouble with a paste and are not sure about the format of the data in the clipboard, you can 
paste it into an Igor notebook to inspect or edit it.
Once Igor has figured out how many rows and columns are in the clipboard, it proceeds to paste those 
values into the table and therefore into the waves that the table displays.
If you select the first cell in the first unused column, the paste will be a create-paste. In this case, Igor makes 
new waves, appends them to the table and then stores the data in the clipboard in the new waves. It makes 
one new wave for each column of text in the clipboard. If the text starts with a row of column names, Igor 
uses this row as the basis for the names of the new waves. Otherwise Igor uses default wave names.
Mismatched Number of Columns
If the number of columns in the clipboard is not the same as the number of columns selected in the table 
then Igor asks you how many columns to paste. This applies to the replace-paste but not to the insert-paste 
or create-paste.
Paste Type
What You Do
What Igor Does
Replace-paste
Choose Paste.
Replaces the selected cells with data from the 
clipboard.
Insert-paste
Press Shift and choose Paste.
Inserts data from clipboard as new cells.
Create-paste
Select the first cell in the first unused 
column and then choose Paste.
Creates new waves containing clipboard data.
