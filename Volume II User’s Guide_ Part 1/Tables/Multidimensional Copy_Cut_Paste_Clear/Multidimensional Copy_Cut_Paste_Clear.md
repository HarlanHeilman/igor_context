# Multidimensional Copy/Cut/Paste/Clear

Chapter II-12 — Tables
II-265
Modify elements(wave0) = (0, -2, -3)// Map layers to horizontal dim
Redimension/N=(5,4) wave0
// Eliminate layers dimension!
This last command has eliminated the wave dimension that is mapped to the table horizontal dimension. 
Thus, Igor will automatically reset the table view.
If you use a dimension with zero points as a free dimension, Igor will also reset the view to the default:
Make/O/N=(3,3) wave0 = p + 10*q
Edit wave0.id
Modify elements(wave0) = (0, -2, -3)
// Map layers to horizontal dim
This last command maps the wave’s layers dimension to the table’s horizontal dimension. However, the 
wave has no layers dimension, so Igor will reset the view to the default.
The initial discussion of changing the view using keyboard shortcuts was incomplete for the sake of simplic-
ity. It said that Option-Down Arrow (Macintosh) or Alt+Down Arrow (Windows) displayed the next layer and 
that Command-Option-Down Arrow or Ctrl+Alt+Down Arrow displayed the next chunk. This is true if rows 
and columns are the free dimensions. A more general statement is that Option-Down Arrow or Alt+Down 
Arrow changes the viewed element of the first fixed dimension and Command-Option-Down Arrow or 
Ctrl+Alt+Down Arrow changes the viewed element of the second fixed dimension. Here is an example using 
a 4D wave:
Make/O/N=(5,4,3,2) wave0 = p + 10*q + 100*r + 1000*s
Edit wave0.id
ModifyTable elements(wave0)=(0, -2, 0, -3)
The ModifyTable command specifies that the columns and chunks dimensions are the free dimensions. The 
rows and layers dimensions are fixed at 0. If you now press Option-Down Arrow or Alt+Down Arrow, you 
change the element of the first fixed dimension — the rows dimension in this case. If you press Command-
Down Arrow or Ctrl+Alt+Down Arrow, you change the element of the second fixed dimension — the layers 
dimension in this case.
Multidimensional Copy/Cut/Paste/Clear
The material in this section is primarily of interest if you intend to edit 3D and 4D data in a table. There are 
also a few items that deal with 2D data.
When you copy table cells, Igor copies the data in two formats:
•
Igor binary, for pasting into another Igor wave
•
Plain text, for pasting into another program
For 1D and 2D waves, the subset that you copy and paste is obvious from the table selection. In the case of 
3D and 4D waves, you can only see two dimensions in the table at one time and you can select a subset of 
those two dimensions.
When copying as plain text, Igor always copies just the visible cells to the clipboard.
When copying as Igor binary, if you press Option (Macintosh) or Alt (Windows), Igor copies cells from all 
dimensions.
Consider the following example. We make a wave with 5 rows, 4 columns and 3 layers and display it in a table:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D.id
The table now displays all rows and all columns of layer 0 of the wave. If you select all of the visible data cells 
and do a copy, Igor copies all of layer 0 to the clipboard. However, if you do an Option-copy or Alt-copy, Igor 
copies all three layers to the clipboard — layer 0 plus the two layers that are currently not visible — in Igor 
binary format.
