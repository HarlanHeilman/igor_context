# Parts of a Table

Chapter II-12 — Tables
II-235
Creating a Table to Edit Existing Waves
Choose WindowsNew Table.
Select the waves to appear in the table from the Columns to Edit list. Press Shift while clicking to select a 
range of waves. Press Cmd (Macintosh) or Ctrl (Windows) to select an individual list item.
Click the Do It button to create the table.
Showing Index Values
As described in Chapter II-5, Waves, waves have built-in scaled index values. The New Table and Append 
to Table dialogs allow you to display just the data in the wave or the index values and the data. If you click 
the Edit Index And Data Columns radio button in either of these dialogs, Igor displays both index and data 
columns in the table.
A 1D wave’s X index values are determined by its X scaling which is a property that you set using the 
Change Wave Scaling dialog or SetScale operation. A 2D wave has X and Y scaling, controlling X and Y 
scaled index values. Higher dimension waves have additional scaling properties and scaled index values. 
Displaying index values in a table is of use mostly if you are not sure what a wave’s scaling is or if you want 
to see the effect of a SetScale operation.
Showing Dimension Labels
As described in Dimension Labels on page II-93, waves have dimension labels. The New Table and 
Append Columns to Table dialogs allow you to display just the data in the wave or the dimension labels 
and the data. If you click the Edit Dimension Label And Data Columns radio button in either of these dia-
logs, Igor displays both label and data columns in the table.
Dimension labels are of use only when individual rows or columns of data have distinct meanings. In an 
image, for example, this is not the case because the significance of one row or column is the same as any other 
row or column. It is the case when a multidimensional wave is really a collection of related but disparate data.
A 2D wave has row and column dimension labels. A 1D wave has row dimension labels only.
You can display dimension labels or dimension indices in a table, but you can not display both at the same 
time for the same wave.
The Horizontal Index Row
When a multidimensional wave is displayed in a table, Igor adds the horizontal index row, which appears 
below the column names and above the data cells. This row can display numeric dimension indices or 
textual dimension labels.
By default, the horizontal index row displays dimension labels if the wave’s dimension label column is dis-
played in the table. Otherwise it displays numeric dimension indices. You can override this default using 
the TableHorizontal Index submenu.
Creating a Table While Loading Waves From a File
The Load Waves dialog (Data menu) has an option to create a table to show the newly loaded waves.
Parts of a Table
This diagram shows the parts of a table displaying 1D waves. If you display multidimensional waves, Igor 
adds some additional items to the table, described under Editing Multidimensional Waves on page II-261.

Chapter II-12 — Tables
II-236
The bulk of a table is the cell area. The cell area contains columns of numeric or text data values as well as 
the column of point numbers on the left. If you wish, it can also display index columns or dimension label 
columns. To the right are unused columns into which you can type or paste new data.
If the table displays multidimensional waves then it will include a row of column indices or dimension labels 
below the row of names. Use the Append Columns to Table dialog to switch between the indices and labels.
In the top left corner is the target cell ID area. This identifies a wave element corresponding to the target 
cell. For example, if a table displays a 2D wave, the ID area might show “R13 C22”, meaning that the target 
cell is on row 13, column 22 of the 2D wave. For 3D waves the target cell ID includes the layer (“L”) and for 
a 4D wave it includes the chunk (“Ch”).
If you scroll the target cell out of view you can quickly bring it back into view by clicking in the target cell ID
There is a special cell, called the insertion cell, at the bottom of each column of data values. You can add 
points to a wave by entering a value or pasting in the insertion cell.
The Table pop-up menu provides a quick way to inspect or change a wave, remove or kill a wave and 
change the formatting of one or more columns. You can invoke the Table pop-up menu by clicking the gear 
icon or right-clicking (Windows) or Control-clicking (Macintosh) a column.
Table pop-up menu.
Click to browse, rename, redimension, 
remove, kill waves or to change the 
style of the column.
Column name. Click to select entire column.
Accept box.
Click to accept entry.
Discard box.
Click to discard entry.
Entry line.
Enter numbers here.
Target cell ID
Target cell
Unused cell.
Click here and 
enter numeric or 
non-numeric 
text to create a 
new wave.
The cells after the insertion cell are 
unused. They are not part of the wave.
The insertion cell appears after the 
very last point in a wave.
