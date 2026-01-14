# Tabs, Terminators and Other Control Characters

Chapter II-12 — Tables
II-258
Object Reference Wave Formatting
This section is for advanced users only.
In addition to text and numeric waves, tables can also display object reference waves. An object reference 
wave is a WAVE wave or a DFREF wave.
The elements of object reference waves are displayed with full precision either as decimal integer, hexadec-
imal, or octal. If the column format is integer or octal, the column is displayed as integer or octal. If the 
column format is any other format, including general, decimal, scientific, date, time, and date&time, the 
column is displayed as hexadecimal.
Editing Text Waves
You can create a text wave in a table by clicking in the first unused cell and entering non-numeric text. For 
the most part, editing a text wave is self-evident. However, there are some issues, mostly relating to special 
characters or large amounts of text, that you may run into.
Large Amounts of Text in a Single Cell
A text wave is handy for storing short descriptions of corresponding data in numeric waves. In some cases, 
you may find it useful to store larger amounts of text. There is no limit on the number of characters in a 
point of a text wave. However, the entry area of a table can display no more than 100,000 bytes. You cannot 
edit in a table a cell containing more than 100,000 bytes.
The Edit Text Cell Dialog
You edit numeric wave data using the table entry line. To edit text wave data, you can use the the table entry 
line or the Edit Text Cell dialog. The dialog is convenient for editing multi-line data. It is also convenient 
for editing text to be used for annotations.
When a text wave cell is selected, an icon appears at the right end of the table entry line. Click the icon to 
invoke the dialog.
The next section discusses using the Edit Text Cell dialog to edit tabs and terminators.
Tabs, Terminators and Other Control Characters
In rare cases, you may want to store text containing control characters such as tabs and terminators (car-
riage-returns and linefeeds) in text waves. You can’t enter such characters in the table entry line, but you 
can enter them using the Edit Text Cell dialog. To display the dialog, click the icon at the right end of the 
table entry line. This icon appears only when you are editing an existing text wave.
You can display whitespace characters (tabs, spaces, and terminators) in the Edit Text Cell dialog by right-
clicking in the text entry area and choosing SettingsShow Whitespace. This is recommended for editing 
multi-line text. Tabs and terminators are identified with these symbols:

Tab

Carriage-return (CR)
For historical reasons, CR is the Igor-standard line terminator. Text for use 
within Igor should have CR terminators.
