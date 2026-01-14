# Changing the View of the Data

Chapter II-12 — Tables
II-262
If you append the wave’s dimension label column, Igor displays the wave’s row labels in a column to the left 
of the wave data and displays the wave’s column labels in the horizontal index row, above the wave data.
If you display neither index columns nor dimension labels, Igor still displays the wave’s column indices in 
the horizontal index row.
If you want to show numeric indices horizontally and dimension labels vertically or vice versa, you can use 
the TableHorizontal Index submenu to override the default behavior. For example, if you want dimen-
sion labels vertically and numeric indices horizontally, append the wave’s dimension label column to the 
table and then choose TableHorizontal IndexNumeric Indices.
In the example above, the row and column indices are equal to the row and column element numbers. You 
can set the row and column scaling of your 2D data to reflect the nature of your data. For example, if the 
data is an image with 5 mm resolution in both dimensions, you should use the following commands:
SetScale/P x 0, .005, "m", w2D; SetScale/P y 0, .005, "m", w2D
When you do this, you will notice that the row and column indices in the table reflect the scaling that you 
have specified.
1D waves have no column indices. Therefore, if you have no multidimensional waves in the table, Igor does 
not display the horizontal index row. If you have a mix of 1D and multidimensional waves in the table, Igor 
does display the horizontal index row but displays nothing in that row for the 1D waves.
When showing 1D data, Igor displays a column of point numbers at the left side of the table. This is called 
the Point column. When showing a 2D wave, Igor titles the column Row or Column depending on how you 
are viewing the 2D wave. If you have 3D or 4D waves in the table, Igor titles the column Row, Column, 
Layer or Chunk, depending on how you are viewing the waves.
It is possible to display a mix of 1D waves and multidimensional waves such that none of these titles is appro-
priate. For example, you could display two 2D waves, one with the wave rows shown vertically (the normal 
case) and one with the wave rows shown horizontally. In this case, Igor will title the Point column “Element”.
You can edit dimension labels in the main body of the table by merely clicking in the cell and typing. How-
ever, you can’t edit dimension labels in the horizontal index row this way. Instead you must double-click a 
label in this row. Igor then displays a dialog into which you can enter a dimension label. You can also set 
dimension labels using the SetDimLabel operation from the command line.
Changing the View of the Data
A table can display waves of dimension 1 through 4. A one dimensional wave appears as a simple column 
of numbers, or, if the wave is complex, as two columns, one real and one imaginary. A two dimensional 
wave appears as a matrix. In the one and two dimensional cases, you can see all of the wave data at once.
If you display a three dimensional wave in a table, you can view and edit only one slice at a time. To see 
this, execute the following commands:
Make/O/N=(5,4,3) w3D = p + 10*q + 100*r; Edit w3D.id
Initially you see the slice of the wave whose layer index is 0 — layer zero of the wave. You can change which 
layer you are viewing using the next layer and previous layer icons that appear in the top/right corner of 
the table or using keyboard shortcuts.
By analogy with the up-arrow and down-arrow keys as applied to the row dimension of a 1D wave, “up” 
means “previous layer” (lower index) and “down” means “next layer” (higher index).
To change the layer from the keyboard, press Option-Up Arrow (Macintosh) or Alt+Up Arrow (Windows) to 
view the previous layer and Option-Down Arrow (Macintosh) or Alt+Down Arrow (Windows) to view the next 
layer.
Pressing the Shift key reverses the direction for both the icons and the arrow keys.
