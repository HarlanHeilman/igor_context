# XLLoadWave and Wave Names

Chapter II-9 — Importing and Exporting Data
II-161
date/time, and the string "T" means all columns are text. The string must not contain any blanks or other 
extraneous characters.
Here are examples of suitable strings:
When loading numeric columns, the "use column type string" method differs from the "treat all columns as 
numeric" method in one way. In the "Treat all columns as numeric" method, any text cells in the numeric 
column are treated as blanks. This behavior is compatible with previous versions of XLLoadWave. In the 
"use column type string" method, if XLLoadWave encounters a text cell in a numeric column, it converts 
the text cell into a number. If the text represents a valid number (e.g., "1.234"), this will produce a valid 
number in the Igor wave. If the text does not represent a valid number (e.g., "January"), this will produce 
a blank in the Igor wave. This is useful if you have a file that inadvertently contains a text cell in a numeric 
column.
XLLoadWave and Wave Names
As you can see in the Load Excel File dialog, XLLoadWave uses one of three ways to generate names for the 
Igor waves that it creates. First, it can take wave names from a row that you specify in the worksheet. In this 
case XLLoadWave expects that the row contains string values. Second, it can generate default wave names 
of the form ColumnA, ColumnB and so on, where the letter at the end of the name indicates the column in 
the worksheet from which the wave was created. Third, XLLoadWave can generate wave names of the form 
wave0, wave1 and so on using a base name, "wave" in this case, that you specify.
XLLoadWave supports a fourth wave naming method that is not available from the dialog: the /NAME flag. 
This flag allows you to specify the desired name for each column using a semicolon-separated string list.
There are several situations, described below, in which XLLoadWave changes the name of the wave that it 
creates from what you might expect. When this happens, XLLoadWave prints the original and new names 
in Igor's history area. After the load, you can use Igor's Rename operation to pick another name of your 
choice, if you wish.
If a name in the worksheet is too long, XLLoadWave truncates it to a legal length. If a name contains char-
acters that are not allowed in standard Igor wave names, XLLoadWave replaces them with the underscore 
character.
If two names in the worksheet conflict with each other, XLLoadWave makes the second name unique by 
adding a prefix such as “D_” where the letter indicates the Excel column from which the wave is being 
loaded.
If a name in the worksheet conflicts with the name of an existing wave, XLLoadWave makes the name of 
the incoming wave unique by adding one or more digits unless you use the overwrite option. With the over-
write option on, the incoming data overwrites the existing wave.
If XLLoadWave needs to add one or more digits to a name to make it unique and if the length of the name 
is already at the limit for Igor wave names, XLLoadWave removes one or more characters from the middle 
of the name.
It is possible that a name taken from a cell in the worksheet might conflict with the name of an Igor opera-
tion, function or macro. For example, Date and Time are built-in Igor functions so a wave can not have these 
names. If such a conflict occurs, XLLoadWave changes the name and prints a message in Igor's history area 
showing the original and the new names.
"N"
All columns are numeric.
"T"
All columns are text.
"1T1D3N"
One text column followed by one numeric date/time column followed by three or 
more numeric columns.
"1T1N3T25N"
One text column followed by one numeric column followed by three text columns 
followed by 25 or more numeric columns.
