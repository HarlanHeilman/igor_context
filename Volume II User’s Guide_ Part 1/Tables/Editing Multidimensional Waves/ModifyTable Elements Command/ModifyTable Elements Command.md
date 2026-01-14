# ModifyTable Elements Command

Chapter II-12 — Tables
II-263
If you know the index of the layer you want to view you can enter it directly in a dialog by pressing 
Command (Macintosh) or Ctrl (Windows) while clicking the next or previous layer icon.
If you display a four dimensional wave in a table, you can still view and edit only one layer at a time. You can 
change which layer you are viewing by using the icons or keyboard shortcuts described above. To view the pre-
vious chunk in the 4D wave, press Option (Macintosh) or Alt (Windows) while clicking the up icon or press 
Command-Option-Up Arrow (Macintosh) or Ctrl+Alt+Up Arrow (Windows). To view the next chunk, press 
Option or Alt while clicking the down icon or press Command-Option-Down Arrow or Ctrl+Alt+Down Arrow.
In addition to using the keyboard shortcuts, you can specify the layer and chunk that you want to use using 
the ModifyTable elements operation.
Changing the Viewed Dimensions
When you initially view a 3D wave in a table, Igor shows a slice of the wave in the rows-columns plane. The 
wave’s rows dimension is mapped to the table’s vertical dimension and the wave’s columns dimension is 
mapped to the table’s horizontal dimension.
Using the Choose Dimensions icon, which appears to the right of the layer icons, you can instruct Igor to map 
any wave dimension to the vertical table dimension and any other wave dimension to the horizontal table 
dimension. This is primarily of interest if you work with waves of dimension three or higher because you can 
view and edit any orthogonal plane in the wave. You can, for example, create a new wave that contains a slice 
of data from the 3D wave.
When you click the Choose Dimensions icon, Igor displays the Choose Dimensions dialog. This dialog 
allows you to specify how the dimensions in the wave are to be displayed in the table.
ModifyTable Elements Command
This section discusses choosing viewed dimensions using the ModifyTable “elements” keyword. You do 
not need to know about this unless you want a thorough understand of editing 3D and 4D waves and 
viewing them from different perspectives.
The best way to understand this section is to execute all of the commands shown.
Igor needs to know which wave dimension to map to the vertical table dimension and which wave dimen-
sion to map to the horizontal table dimension. In addition, for waves of dimension three or higher, Igor 
needs to know which element of the remaining dimensions to display.
The form of the command is:
ModifyTable elements(<wave name>) = (<row>,<column>,<layer>,<chunk>)
The parameters specify which element of the wave’s rows, columns, layers and chunks dimensions you 
want to view. The value of each parameter may be an element number (0 or greater) or it may be a special 
value. There are three special values that you can use for any of the parameters:
In reading the following discussion, remember that the first parameter specifies how you want to view the 
wave’s rows, the second parameter specifies how you want to view the wave’s columns, the third parame-
ter specifies how you want to view the wave’s layers and the fourth parameter specifies how you want to 
view the wave’s chunks.
If you omit a parameter, it takes the default value of -1 (no change). Thus, if you are dealing with a 2D wave, 
you can supply only the first two parameters and omit the last two.
-1
Means no change from the current value.
-2
Means map this dimension to the table’s vertical dimension.
-3
Means map this dimension to the table’s horizontal dimension.

Chapter II-12 — Tables
II-264
To get a feel for this command, let’s start with the example of a simple matrix, which is a 2D wave.
Make/O/N=(3,3) wave0 = p + 10*q
Edit wave0.id
As you look down in the table, you see the rows of the matrix and as you look across the table, you see its 
columns. Thus, initially, the rows dimension is mapped to the vertical table dimension in the and the 
columns dimension is mapped to the horizontal table dimension. This is the default mapping. You can 
change this with the following command:
ModifyTable elements(wave0) = (-3, -2)
The first parameter specifies how you want to view the wave’s rows and the second parameter specifies 
how you want to view the wave’s columns. Since the wave has only two dimensions, the third and fourth 
parameters can be omitted.
The -3 in this example maps the wave’s rows to the table’s horizontal dimension. The -2 maps the wave’s 
columns to the table’s vertical dimension.
You can return the wave to its default view using:
ModifyTable elements(wave0) = (-2, -3)
When you consider a 3D wave, things get a bit more complex. In addition to the rows and columns dimen-
sions, there is a third dimension — the layers dimension. When you initially create a table containing a 3D 
wave, it shows all of the rows and columns of layer 0 of the wave. Thus, as with the 2D wave, the rows 
dimension is mapped to the vertical table dimension and the columns dimension is mapped to the horizon-
tal table dimension. You can control which layer of the 3D wave is displayed in the table using the icons 
and keyboard shortcuts described above, or using the ModifyTable elements keyword.
For example:
Make/O/N=(5,4,3) wave0 = p + 10*q + 100*r
ModifyTable elements(wave0)=(-2, -3, 1)
//Shows layer 1 of 3D wave
ModifyTable elements(wave0)=(-2, -3, 2)
//Shows layer 2 of 3D wave
In these examples, the wave’s layers dimension is fixed to a specific value whereas the wave’s rows and 
columns dimensions change as you look down or across the table. The term “free dimension” refers to a 
wave dimension that is mapped to either of the table’s dimensions. The term “fixed dimension” refers to a 
wave dimension for which you have chosen a fixed value.
In the preceding example, we viewed a slice of the 3D wave in the rows-columns plane. We can view any 
orthogonal plane. For example, this command shows us the data in the layers-rows plane:
ModifyTable elements=(-3, 0, -2)
// Shows column 0 of 3D wave
The first parameter says that we want to map the wave’s rows dimension to the table’s horizontal dimen-
sion. The second parameter says that we want to see column 0 of the wave. The third parameter says that 
we want to map the wave’s layers dimension to the table’s vertical dimension.
Dealing with a 4D wave is similar to the 3D case, except that, in addition to the two free dimensions, you 
have two fixed dimension.
Make/O/N=(5,4,3,2) wave0 = p + 10*q + 100*r + 1000*s
ModifyTable elements(wave0)=(-2, -3, 1, 0)
//Shows layer 1/chunk 0
ModifyTable elements(wave0)=(-2, -3, 2, 1)
//Shows layer 2/chunk 1
If you change a wave (using Make/O or Redimension) such that one or both of the free dimensions has zero 
points, Igor automatically resets the view to the default — the wave’s rows dimension mapped to the table’s 
vertical dimension and the wave’s column dimension mapped to the table’s horizontal dimension. Here is 
an example:
Make/O/N=(5,4,3) wave0 = p + 10*q + 100*r
Edit wave0.id
