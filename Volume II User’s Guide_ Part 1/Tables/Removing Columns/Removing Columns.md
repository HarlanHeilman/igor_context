# Removing Columns

Chapter II-12 — Tables
II-242
For multidimensional waves, the “.i” and “.l” suffixes still specify a single column of index values or dimen-
sion labels while the “.d” suffix specifies all of the data columns.
In the table-related commands, you can abbreviate column names as follows:
A 2D wave has X and Y index values. A 3D wave has X, Y and Z index values. A 4D wave has X, Y, Z and T 
index values. Regardless of the dimensionality of the wave, however, it has only one index column in a table. 
The index column for a 2D wave, for example, may show the X values or the Y values, depending on how you 
are viewing the data. The index column will be labeled “wave.x” or “wave.y”, depending on the view. How-
ever, when referring to the column from an Igor command, you can always use the generic column name 
“wave.i” as well as the specific column name “wave.x” or “wave.y”. A dimension label column is always 
called “wave.l”, regardless of which dimension is showing in the table.
See Edit on page V-192 for some examples of commands using column names.
Appending Columns
To append columns to a table, choose TableAppend Columns to Table. This displays the Append 
Columns dialog.
Igor appends columns to the right end of the table. You can drag a column to a new position by pressing 
Option (Macintosh) or Alt (Windows) and dragging the column name.
Removing Columns
To remove columns from a table, choose TableRemove Columns from Table. This displays the Remove 
Columns dialog.
You can also select the columns in the table, and use the Table pop-up menu to remove the selected columns.
test
test.d
Data values of test
ctest
ctest.i
Index values of ctest
ctest
ctest.d.real
Real part of data values of ctest
ctest
ctest.d.imag
Imaginary part of data values of ctest
Full Column Specification
Abbreviated Column Specification
test.d
test
test.i, test.d
test.id
test.l, test.d
test.ld
ctest.d.real, ctest.d.imag
ctest.d or ctest
ctest.i, ctest.d.real
ctest.id.real
ctest.l, ctest.d.real
ctest.ld.real
ctest.i, ctest.d.imag
ctest.id.imag
ctest.l, ctest.d.imag
ctest.ld.imag
ctest.i,ctest.d.real,ctest.d.imag
ctest.id
ctest.l,ctest.d.real,ctest.d.imag
ctest.ld
Wave Name
Column Name
Column Contents
