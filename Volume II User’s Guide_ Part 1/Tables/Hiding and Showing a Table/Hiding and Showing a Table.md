# Hiding and Showing a Table

Chapter II-12 — Tables
II-240
.
.
.
.
.
.
.
.
.
In the other program, select the cells containing the data of interest and copy them to the clipboard. In Igor, 
select the first cell in the first unused column in a table and then select Paste from Igor’s Edit menu.
Igor scans the contents of the clipboard to determine the number of rows and columns of numeric text data. 
It also checks the first line of text in the clipboard to see if it contains column names. It creates waves and 
displays them in the table using the names found in the clipboard or default names. If the text contains 
names which conflict with existing names, Igor presents a dialog in which you can correct the problem.
If you paste text-only data, which does not contain numbers,dates, times or date/time values, Igor treats all 
of the pasted text as data instead of treating the first line as column names. This will usually produce the 
desired results. If you want to treat the first line as column names, use the Load Delimited Text routine to 
load the text from the clipboard and specify that you want to load wave names. See Loading Delimited 
Text Files on page II-129 for details.
Troubleshooting Table Copy and Paste
If the waves that are created when you paste don’t contain the values you expect, chances are that the clip-
board does not contain tab-delimited text. In this case you will need to undo the paste. To examine the con-
tents of the clipboard, paste it into an Igor plain text notebook or into the word processor of your choice. 
After editing the text, copy it to the clipboard again and repaste it into the table.
Creating New Waves by Pasting Data from Igor
You can also create new waves by copying data from existing waves. When you copy wave data in a table, 
Igor stores not only the raw data but also the following properties of the wave or waves:
•
Data units and dimension units
•
Data full scale and dimension scaling
•
Dimension labels
•
The wave note
Thus you can duplicate a wave by copying it in a table and pasting into the unused area of the same table or 
a different table. You can also copy from a table in one experiment and paste in a table in another experiment.
You can copy and paste the wave note only if you copy the entire wave. If you copy part of the wave, it does 
not copy the wave note.
Table Names and Titles
Every table that you create has a name. The name is a short Igor object name that you or Igor can use to 
reference the table from a command or procedure. When you create a new table, Igor assigns it a name of 
the form Table0, Table1 and so on. You will most often use a table’s name when you kill and recreate the 
table, as described in the next section.
A table also has a title. The title is the text that appears at the top of the table window. Its purpose is to iden-
tify the table visually. It is not used to identify the table from a command or procedure. The title can consist 
of any text, up to 255 bytes.
You can change the name and title of a table using the Window Control dialog. This dialog is a collection of 
assorted window-related things. Choose WindowsControlWindow Control to display the dialog.
Hiding and Showing a Table
You can hide a table by Shift-clicking the close button.
