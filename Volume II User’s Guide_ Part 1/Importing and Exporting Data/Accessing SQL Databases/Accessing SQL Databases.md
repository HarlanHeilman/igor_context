# Accessing SQL Databases

Chapter II-9 — Importing and Exporting Data
II-181
At present, the Save operation always uses the UTF-8 text encoding when writing text files. If your waves 
contain non-ASCII text, and if you need to import into a program that does not support UTF-8, you will 
need to convert the file’s text encoding after saving it. You can do this by opening the file as a notebook, 
changing the text encoding, and saving it again, or using an external text editor.
Exporting MultiDimensional Waves
When exporting a multidimensional wave as a delimited or general text file, you have the option of writing 
row labels, row positions, column labels and column positions to the file. Each of these options is controlled 
by a checkbox in the Save Waves dialog. There is a discussion of row/column labels and positions under 2D 
Label and Position Details on page II-134.
Igor writes multidimensional waves in column/row/layer/chunk order.
Accessing SQL Databases
Igor Pro includes an XOP, called SQL XOP, which provides access to relational databases from IGOR pro-
cedures. It uses ODBC (Open Database Connectivity) libraries and drivers on Mac OS X and Windows to 
provide this access.
For details on configuring and using SQL XOP, open the SQL Help file in “Igor Pro 7 Folder:More Exten-
sions:Utilities”.

Chapter II-9 — Importing and Exporting Data
II-182
