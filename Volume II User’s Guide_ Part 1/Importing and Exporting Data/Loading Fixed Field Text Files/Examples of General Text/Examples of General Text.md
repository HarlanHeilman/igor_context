# Examples of General Text

Chapter II-9 — Importing and Exporting Data
II-138
Stripping leading and trailing spaces also allows Igor's Load Fixed Field routine to load values that are left-
justified or right-justified, so long as each value for a given row is in a consistent width field.
Igor’s Load Fixed Field Text routine works just like the Load Delimited Text routine except that, instead of 
looking for a delimiter character to determine where a column ends, it counts the number of bytes in the 
column. All of the features described in the section Loading Delimited Text Files on page II-129 apply also 
to loading fixed field text.
The Load Waves Dialog for Fixed Field Text
To load a fixed field text file, invoke the Load Waves dialog by choosing DataLoad WavesLoad 
Waves. The dialog is the same as for loading delimited text except for three additional items.
In the Number of Columns item, you must enter the total number of columns in the file. In the Field Widths 
item, you must enter the number of bytes in each column of the file, separated by commas. The last value 
that you enter is used for any subsequent columns in the file. If all columns in the file have the same number 
of bytes, just enter one number.
If you select the All 9’s Means Blank checkbox then Igor will treat any column that consists entirely of the digit 
9 as a blank. If the column is being loaded into a numeric wave, Igor sets the corresponding wave value to NaN. 
If the column is being loaded into a text wave, Igor sets the corresponding wave value to "" (empty string).
Specifying Fixed Field Widths Programmatically
If all of the columns in the file consist of the same number of bytes, you can specify this number using the Load-
Wave /F flag. If different columns consist of different numbers of bytes, you have to use the LoadWave /B flag 
to specify the width of each column.
Loading General Text Files
We use the term “general text” to describe a text file that consists of one or more blocks of numeric data. A 
block is a set of rows and columns of numbers. Numbers in a row are separated by one or more tabs or 
spaces. One or more consecutive commas are also treated as white space. A row is terminated by a carriage 
return character, a linefeed character, or a carriage return/linefeed sequence.
The Load General Text routine handles numeric data only, not date, time, date/time or text. Use Load Delimited 
Text or Load Fixed Field Text for these formats. Load General Text can handle 2D numeric data as well as 1D.
The first block of data may be preceded by header information which the Load General Text routine auto-
matically skips.
If there is a second block, it is usually separated from the first with one or more blank lines. There may also 
be header information preceding the second block which Igor also skips.
When loading 1D data, the Load General Text routine loads each column of each block into a separate wave. 
It treats column labels as described above for the Load Delimited Text routine, except that spaces as well as 
tabs and commas are accepted as delimiters. When loading 2D data, it loads all columns into a single 2D wave.
The Load General Text routine determines where a block starts and ends by counting the number of 
numbers in a row. When it finds two rows with the same number of numbers, it considers this the start of 
a block. The block continues until a row which has a different number of numbers.
Examples of General Text
Here are some examples of text that you might find in a general text file.
Simple general text
ch0
ch1
ch2
ch3
(optional row of labels)
2.97055
1.95692
1.00871
8.10685
3.09921
4.08008
1.00016
7.53136
