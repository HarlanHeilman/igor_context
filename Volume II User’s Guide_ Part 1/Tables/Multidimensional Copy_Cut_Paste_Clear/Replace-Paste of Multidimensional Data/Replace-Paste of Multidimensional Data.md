# Replace-Paste of Multidimensional Data

Chapter II-12 — Tables
II-266
This table shows the effect of the Option (Macintosh) or Alt (Windows) key.
The middle column of the preceding table mentions “replace-pasting”. When you do a paste, Igor normally 
replaces the selection in the table with the data in the clipboard. However, if you press Shift while pasting, 
Igor inserts the data as new cells in the table. This is called an “insert-paste”. This table shows the effect of 
the Shift and Option (Macintosh) or Alt (Windows) keys on a paste.
Replace-Paste of Multidimensional Data
If you copy data in a table, and then select cells in the table or in another table, and do a paste, you are doing 
a replace-paste. The copied data replaces the selection when you do the paste.
For 1D and 2D waves, the subset that you copy and paste is obvious from the table selection. In the case of 
3D and 4D waves, you can only see two dimensions in the table at one time and you can select a subset of 
those two dimensions.
When you do a normal replace-paste involving waves of dimension 3 or higher, the data in the clipboard 
replaces the data in the currently visible slice of the selected wave.
Copying a Layer of a 3D Wave to Another Layer
Here is an example that illustrates replace-paste.
1.
Make a wave with 5 rows, 4 columns and 3 layers and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
The table now displays all rows and all columns of layer 0 of the wave. Let’s look at layer 1 of the 
wave.
2.
Press Option-Down Arrow (Macintosh) or Alt+Down Arrow (Windows) while the table is active.
This changes the view to show layer 1 instead of layer 0.
3.
Select all of the visible cells and choose EditCopy.
This copies all of layer 1 to the clipboard.
4.
Press Option-Down Arrow or Alt+Down Arrow again to view layer 2 of the wave.
5.
With all of the cells still selected, choose EditPaste.
The data copied from layer 1 replaces the data in layer 2 of the wave.
6.
Choose EditUndo.
Layer 2 is restored to its original state.
7.
Press Option-Up Arrow or Alt+Up Arrow two times.
We are now looking at layer 0.
8.
Choose EditPaste.
Copy
Paste
Clear
No modifiers
Copies visible
Replace-pastes visible
Clears visible
Option or Alt
Copies all
Replace-pastes all
Clears all
Paste
No modifiers
Replace-pastes visible
Option
Replace-pastes all
Shift
Insert-pastes visible
Shift and Option or Alt
Insert-pastes all
