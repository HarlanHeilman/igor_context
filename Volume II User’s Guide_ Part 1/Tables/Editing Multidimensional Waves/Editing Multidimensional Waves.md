# Editing Multidimensional Waves

Chapter II-12 — Tables
II-261
This use of stand-in symbols in tables applies only when the yellow warning icon is visible. If the yellow 
warning icon is not visible, there is no special treatment of these symbols.
You can disable use of stand-in symbols by unchecking the Use Special Symbols for Control Characters check-
box in the Tables section of the Miscellaneous Settings dialog. Except in rare cases, you should leave that 
setting checked.
Entering Special Characters
While editing a cell, you can enter special characters, such as Greek letters and math symbols, by choosing 
EditCharacters to enter commonly-used characters such as Greek letters and math symbols or 
EditSpecial Characters to enter other characters.
If the wave whose element you are editing uses the UTF-8 text encoding, which is the default for waves 
created in Igor7 or later, then you can enter any character.
If the wave uses another text encoding then it is not possible to represent all characters. For example, the triple 
integral character, U+222D, can not be represented in MacRoman, Windows-1252, Shift JIS, or any other non-
Unicode text encoding.
If you attempt to enter a character that can not be represented in the wave's text encoding, Igor displays an 
alert informing you of the problem. Your options are to omit that character or to convert the wave to UTF-8, 
using MiscText EncodingSet Wave Text Encoding.
See also Chapter III-16, Text Encodings, Wave Text Encodings on page III-472.
Editing Multidimensional Waves
If you view a multidimensional wave in a table, Igor adds some items to the table that are not present for 
1D waves. To see this, execute the following commands which create and display a 2D wave:
Make/O/N=(3,4) w2D = p + 10*q; Edit w2D.id
The first column in the table is labeled Row, indicating that it shows row numbers. The second column con-
tains the scaled row indices, which in this case are the same as the wave row numbers. The remaining 
columns show the wave data. Notice the name at the top of the first column of wave data: “w2D[][0].d”. 
The “w2D” identifies the wave. The “.d” specifies that the column shows wave data rather than wave indi-
ces. The “[][0]” identifies the part of the wave shown by this column. The “[]” means “all rows” and the 
“[0]” means column 0. This is derived from the syntax that you would use from Igor’s command line to 
store values into all rows of column 0 of the wave:
w2D[][0] = 123
// Set all rows of column 0 to 123
When displaying a multidimensional wave in a table, Igor adds a row to the table below the row of names. 
This row is called the horizontal index row. It can display either the scaled indices or the dimension labels 
for the wave elements shown in the columns below.
By default, if you view a 2D wave in a table and append the wave’s index column, Igor displays the wave’s 
row indices in a column to the left of the wave data and displays the wave’s column indices in the horizontal 
index row, above the wave data.
Horizontal index row.
