# Example: Normalizing Waves

Chapter II-5 — Waves
II-79
// Add a column changing wave0 from 1D to 2D. Adds a column
// because the column index, 1, is equal to the number of wave columns.
wave0[][1] = {10,11,12,13,14}
2D Lists of Values
This section shows how to set elements of a 2D wave and add rows and columns using lists of values. As 
shown below a 2D list of values consists of a a nested list of lists in curly braces. Each inner list defines the 
row values for one column.
Make/O/N=(4,3) w2D = NaN
// Make wave with 4 rows and 3 columns
Edit/W=(225,45,850,350) w2D
// Redimension w2D and set elements.
// Set column 0 to {1,2,3}, column 1 to {10,11,12}.
w2D = {{0,1,2}, {10,11,12}}
Make/O/N=(4,3) w2D = NaN
// Restore to 4 rows by 3 column
// Set column 0 to {0,1,2,3}, column 1 to {10,11,12,13}.
// Here [] can be read as "all rows" so this means set
// all rows of columns 0 through 1.
w2D[][0,1] = {{0,1,2,3}, {10,11,12,13}}
// Extend w2D from 4 rows to 5 rows and set new Y values.
// Adds a row because the row index, 4, is equal to the number of wave rows.
// Here [] can be read as "all columns" so this means set row 4, all columns.
w2D[4][] = {{4},{14},{24}}
// Extend w2D from 5 rows to 7 rows and set new Y values.
w2D[5][] = {{5,6},{15,16},{25,26}}
Make/O/N=(4,3) w2D = NaN
// Restore to 4 rows by 3 column
// Extend w2D from 3 columns to 4 columns and set new Y values.
// Adds a column because the column index, 3, is equal
// to the number of wave columns.
w2D[][3] = {{30,31,32,33}}
// Extend w2D from 4 columns to 6 columns and set new Y values.
w2D[][4] = {{40,41,42,43},{50,51,52,53}}
Wave Initialization
From Igor’s command line or in a procedure, you can make a wave and initialize it with a single command, 
as illustrated in the following examples:
Make wave0=sin(p/8)
// wave0 has default number of points
Make coeffs={1,2,3}
// coeffs has just three points
Example: Normalizing Waves
When comparing the shape of multiple waves you may want to normalize them so that the share a common 
range. For example:
// Create some sample data
Make waveA = 3*sin(x/8)
Make waveB = 2*sin(pi/16 + x/8)
// Display the waves
Display waveA, waveB
ModifyGraph rgb(waveB)=(0,0,65535)
