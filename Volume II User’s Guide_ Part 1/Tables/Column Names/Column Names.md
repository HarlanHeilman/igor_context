# Column Names

Chapter II-12 — Tables
II-241
You can show a table by choosing its name from the WindowsTables submenu.
Killing and Recreating a Table
Igor provides a way for you to kill a table and then later to recreate it. Use this to temporarily get rid of a 
table that you expect to be of use later.
You kill a table by clicking the table window’s close button or by using the Close item in the Windows menu. 
When you kill a table, Igor offers to create a window recreation macro. Igor stores the window recreation 
macro in the procedure window of the current experiment. The name of the window recreation macro is the 
same as the name of the table. You can invoke the window recreation macro later to recreate the table by 
choosing its name from WindowsTable Macros.
A table does not contain waves but is just a way of viewing them. Killing a table does not kill the waves 
displayed in a table. If you want to kill the waves in a table, select all of them (Select All in Edit menu) and 
then choose Kill All Selected Waves from the Table pop-up menu.
For further details, see Closing a Window on page II-46 and Saving a Window as a Recreation Macro on 
page II-47.
Index Columns
There are two kinds of numeric values associated with a numeric wave: the stored data values and the com-
puted index values. For example, each point in a real 1D wave has two values: a data value and an X index 
value. The data value is stored in memory. The X value is computed based on the point number and the 
wave’s X scaling property. The correspondence between point numbers and X values is discussed in detail 
under Waveform Model of Data on page II-62.
Because the index values for a wave are computed, a value in an index column in a table can not be altered 
by editing the wave. Only values in data columns of a table can be edited. To alter the index values of a 
wave, use the Change Wave Scaling dialog.
Column Names
Column names are related to but not identical to wave names. You need to use column names to append, 
remove or modify table columns from the command line or from an Igor procedure.
A column name consists of a wave name and a suffix that identifies which part of the wave the column dis-
plays. For each real 1D wave there can be two columns: one for the X index values or dimension labels of 
the wave and one for the data values of the wave. For complex waves there can be three columns: one for 
the X index values or dimension labels of the wave, one for the real data values of the wave and one for the 
imaginary data values of the wave.
If we have a real 1D wave named “test” then there are three column names associated with that wave: test.i 
(“i” for “index”), test.l (“l” for “label”) and test.d (“d” for “data”). If we have a complex 1D wave named 
“ctest” then there are four column names associated with that wave:ctest.i, ctest.l, ctest.d.real and ctest.d.imag.
Wave Name
Column Name
Column Contents
test
test.i
Index values of test
test
test.l
Dimension labels of test
