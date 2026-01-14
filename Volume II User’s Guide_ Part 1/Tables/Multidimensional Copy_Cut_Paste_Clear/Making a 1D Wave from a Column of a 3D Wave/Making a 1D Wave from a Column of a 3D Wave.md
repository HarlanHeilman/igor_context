# Making a 1D Wave from a Column of a 3D Wave

Chapter II-12 — Tables
II-269
Create-Paste of Multidimensional Data
When you copy data in a table and then select the first unused cell in the table and then do a paste, Igor 
creates one or more new waves.
The number of waves created and the number of dimensions in each wave are the same as for the copied 
data. Igor also copies and pastes the following wave properties:
•
Data units and dimension units
•
Data full scale and dimension scaling
•
Dimension labels
•
The wave note
Igor copies and pastes the wave note only if you copy the entire wave. If you copy part of the wave, it does 
not copy the wave note.
You can use a create-paste to create a copy of a subset of the data displayed in the table. For 1D and 2D waves, 
the subset that you copy and paste is obvious from the table selection. In the case of 3 and higher dimension 
waves, you can only see two dimensions in the table at one time and you can choose a subset of those two dimen-
sions. If you do a copy and then a create-paste, Igor creates a new 2D wave containing just the data that was 
visible when you did the copy. If you do an Option-copy (Macintosh) or Alt-copy (Windows) to copy all and then 
a create-paste, Igor creates a new wave with the same number of dimensions and same data as what you copied.
Making a 2D Wave from a Slice of a 3D Wave
1.
Make a 3D wave and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
2.
Select all of the cells of the 3D wave and choose EditCopy.
3.
Click in the first unused cell and choose EditPaste.
You now have a 2D wave consisting of the data from layer 0 of the 3D wave.
Making a 3D Wave from a 3D Wave
1.
Make a 3D wave and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
2.
Select all of the cells of the 3D wave.
3.
Press Option or Alt, and choose EditCopy All Layers.
4.
Click in the first unused cell and choose EditPaste.
You now have a 3D wave consisting of the data from all layer2 of the original 3D wave.
To confirm this, we will inspect all layers of the new wave.
5.
To demonstrate this, view the other layers of the new wave by pressing Option-Down Arrow or 
Alt+Down Arrow (to go to the next layer) and Option-Up Arrow or Alt+Up Arrow (to go to the previ-
ous layer).
Making a 1D Wave from a Column of a 3D Wave
1.
Make a 3D wave and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D
2.
Select a single column of the 3D wave and choose EditCopy.
3.
Click the first unused cell in the table and choose EditPaste.
You have created a single-column wave but it is a 2D wave, not a 1D wave.
4.
Choose Redimension w3D1 from the Table pop-up menu (gear icon) to display the Redimension Waves 
dialog.
