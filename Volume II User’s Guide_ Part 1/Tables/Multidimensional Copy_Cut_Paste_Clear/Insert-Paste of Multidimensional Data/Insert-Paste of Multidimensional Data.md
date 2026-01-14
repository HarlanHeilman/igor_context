# Insert-Paste of Multidimensional Data

Chapter II-12 — Tables
II-267
The data that we copied from layer 1 replaces the data in layer 0.
9.
Choose EditUndo to return layer 0 to the original state.
Copying and Pasting All Data of a 3D Wave
Now let’s consider an example in which we copy and paste all of the wave data, not just one layer.
1.
Make a wave with 5 rows, 4 columns and 3 layers and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
2.
Select all of the visible cells.
3.
Press Option (Macintosh) or Alt (Window) and choose EditCopy All Layers.
This copies the entire wave, all three layers, to the clipboard.
4.
Press Option or Alt and choose EditClear All Layers.
This clears all three layers.
5.
Use Option-Down Arrow or Alt+Down Arrow and Option-Up Arrow or Alt+Up Arrow to verify that 
all three layers were cleared.
6.
Press Option or Alt and choose EditPaste All Layers. 
This pastes all three layers from the clipboard into the selected wave.
7.
Use Option-Down Arrow and Option-Up Arrow or Alt+Down Arrow and Alt+Up Arrow to verify that 
all three layers were pasted.
Making a 2D Wave from Two 1D Waves
In this example, we make a 2D wave from two 1D waves. Execute:
Make/O/N=5 w1DA=p, w1DB=100+p; Edit w1DA, w1DB
1.
Select all of the first 1D wave and choose EditCopy.
2.
Click in the first unused cell in the table and choose EditPaste.
Because you pasted into the unused cell, Igor created a new wave. This is a “create-paste”.
3.
Choose Redimension w1DA1 from the Table pop-up menu (gear icon).
4.
In the Redimension Waves dialog, enter 2 for the number of columns and click Do It.
5.
Right-click the column name of the redimensioned wave and choose Rename.
6.
Rename w1DA1 as w2D.
7.
Select all of the second 1D wave, w1DB, and choose EditCopy.
8.
Select all of the second column of the 2D wave, w2D, and choose EditPaste.
We now have a 2D wave generated from two 1D waves.
Insert-Paste of Multidimensional Data
If you copy data in a table, and then select in the table or in another table, and do a paste while pressing 
Shift, you are doing an insert-paste. The copied data is inserted into the selected wave or waves before the 
selected cells. As in the case of the replace-paste, the insert-paste works on just the visible layer of data if 
Option (Macintosh) or Alt (Windows) is not pressed or on all layers if the Option or Alt is pressed. Next is an 
example that illustrates this.
Inserting New Rows in a 3D Wave
1.
Make a wave with 5 rows, 4 columns and 3 layers and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
2.
Select all of the cells in rows 1 and 2 of the table.
An easy way to do this is to click the “1” in the Row column and drag down to the “2”.
