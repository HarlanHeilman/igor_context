# Creating an Empty Table for Entering New Waves

Chapter II-12 — Tables
II-234
Overview
Tables are useful for entering, modifying, and inspecting waves. You can also use a table for presentation 
purposes by exporting it to another program as a picture or by including it in a page layout. However, it is 
not optimized for this purpose.
If your data has a small number of points you will probably find it most convenient to manually enter it in 
a table. In this case, creating a new empty table will be your first step.
If your data has a large number of points you will most likely load it into Igor from a file. In this case it is 
not necessary to make a table. However, you may want to display the waves in a table to inspect them. Igor 
Pro tables can handle virtually any number of rows and columns provided you have sufficient memory.
A table in Igor is similar to but not identical to a spreadsheet in other graphing programs. The main difference 
is that in Igor data exists independent of the table. You can create new waves in Igor’s memory by entering data 
in a table. Once you have entered your data, you may, if you wish, kill the table. The waves exist independently 
in memory so killing the table does not kill the waves. You can still display them in a graph or in a new table.
In a spreadsheet, you can create a formula that makes one cell dependent on another. You can not create cell-
based dependencies in Igor. You can create dependencies that control entire waves using AnalysisCompose 
Expression, MiscObject Status, or the SetFormula operation (see page V-847), but this is not recommended 
for routine work.
To make a table, choose WindowsNew Table.
When the active window is a table, the Table menu appears in Igor’s menu bar. Items in this menu allow 
you to append and remove columns, change the formatting of columns, and sets table preferences.
Waves in tables are updated dynamically. Whenever the values in a wave change, Igor automatically 
updates any tables containing that wave. Because of this, tables are often useful for troubleshooting 
number-crunching procedures.
Creating Tables
Table Creation with New Experiment
By default, when you create a new experiment, Igor automatically creates a new, empty table. This is con-
venient if you generally start working by entering data manually. However, in Igor data can exist in 
memory without being displayed in a table. If you wish, you can turn automatic table creation off using the 
Experiment Settings category of the Miscellaneous Settings dialog (Misc menu).
Creating an Empty Table for Entering New Waves
Choose WindowsNew Table and click the Do It button.
If you enter a numeric value in the table, Igor creates a numeric wave. If you enter a non-numeric value, 
Igor creates a text wave.
To create multidimensional waves you must use the Make Waves dialog (Data menu).
After creating the wave, you may want to rename it. Choose Rename from the Table pop-up menu or from 
the Data menu in the main menu bar.
