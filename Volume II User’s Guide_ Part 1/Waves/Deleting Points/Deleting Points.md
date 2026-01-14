# Deleting Points

Chapter II-5 — Waves
II-73
You cannot change a wave from numeric to text or vice versa. The following examples illustrate how you 
can make a text copy of a numeric wave and a numeric copy of a text wave:
Make/N=10 numWave = p
Make/T/N=(numpnts(numWave)) textWave = num2str(numWave)
Make/N=(numpnts(textWave)) numWave2 = str2num(textWave)
However, you can lose precision because num2str prints with only 6 digits of precision.
Inserting Points
There are two ways to insert new points in a wave. You can do this by:
•
Using the InsertPoints operation
•
Typing or pasting in a table
This section deals with the InsertPoints operation (see page V-443). For information on typing or pasting 
in a table, see Chapter II-12, Tables.
Using the InsertPoints operation, you can insert new data points at the start, in the middle or at the end of 
a 1D wave. You can also insert new elements in multidimensional waves. For example, you can insert new 
columns in a 2D matrix wave. The inserted values will be 0 for a numeric wave and "" for a text wave.
The Insert Points dialog provides an interface to the InsertPoints operation. To use it, choose Insert Points 
from the Data menu.
If the value that you enter for first point is greater than the number of elements in the selected dimension 
of a selected wave, the new points are added at the end of the dimension. InsertPoints can change the 
dimensionality of a wave. For example, if you insert a column in a 1D wave, you end up with at 2D wave.
If the top window is a table at the time that you select Insert Points, Igor will preset the dialog items based 
on the selection in the table.
Deleting Points
There are two ways to delete points from a wave. You can do this by:
•
Using the DeletePoints operation
•
Doing a cut in a table
This section deals with the DeletePoints operation (see page V-157). For information on cutting in a table, 
see Chapter II-12, Tables.
Using the DeletePoints operation, you can delete data points from the start, middle or end of a 1D wave. 
You can also delete elements from multidimensional waves. For example, you can delete columns from a 
2D matrix wave.
The Delete Points dialog provides an interface to the DeletePoints operation. To use it, choose Delete Points 
from the Data menu.
If the value that you enter for first point is greater than the number of elements in the selected dimension 
of a selected wave, DeletePoints will do nothing to that wave. If the number of elements is too large, Delete-
Points will delete from the specified first element to the end of the dimension.
Except for the case of removing all elements, which leaves the wave as 1D, DeletePoints does not change 
the dimensionality of a wave. Use Redimension for that.
If the top window is a table at the time that you choose Delete Points, Igor will preset the dialog items based 
on the selection in the table.
