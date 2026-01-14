# The Load Waves Dialog for Delimited Text — 1D

Chapter II-9 — Importing and Exporting Data
II-132
Simple delimited text
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
3.18934
5.91134
1.04205
6.90194
Loading this text would create four waves with three points each or, if you specify loading it as a matrix, a 
single 3 row by 4 column wave.
Delimited text with missing values
ch0
ch1
ch2
ch3
(optional row of labels)
2.97055
1.95692
8.10685
3.09921
4.08008
1.00016
7.53136
5.91134
1.04205
Loading this text as 1D waves would create four waves. Normally each wave would contain three points but 
there is an option to ignore blanks at the end of a column. With this option, ch0 and ch3 would have two points. 
Loading as a matrix would give you a single 3 row by 4 column wave with blanks in columns 0, 2 and 3.
Delimited text with a date column
Date
ch0
ch1
ch2
(optional row of labels)
2/22/93
2.97055
1.95692
1.00871
2/24/93
3.09921
4.08008
1.00016
2/25/93
3.18934
5.91134
1.04205
Loading this text as 1D waves would create four waves with three points each. Igor would convert the dates 
in the first column into the appropriate number using the Igor system for storing dates (number of seconds 
since 1/1/1904). This data is not suitable for loading as a matrix.
Delimited text with a nonnumeric column
Sample
ch0
ch1
ch2
(optional row of labels)
Ge
2.97055
1.95692
1.00871
Si
3.09921
4.08008
1.00016
GaAs
3.18934
5.91134
1.04205
Loading this text as 1D waves would normally create four waves with three points each. The first wave would 
be a text wave and the remaining would be numeric. You could also load this as a single 3x3 matrix, treating 
the first row as column labels and the first column as row labels for the matrix. If you loaded it as a matrix but 
did not treat the first column as labels, it would create a 3 row by 4 column text wave, not a numeric wave.
Delimited text with quoted strings
Starting with Igor Pro 8.00, Load Delimited Text (LoadWave/J) recognizes ASCII double-quote characters as 
enclosing a string that may contain delimiter characters. In this case, the Comment column contains text which 
contains commas. Comma is normally a delimiter character but, because the column text is quoted, LoadWave 
does not treat it as a delimiter. See Quoted Strings in Delimited Text Files on page II-135 for details.
The Load Waves Dialog for Delimited Text — 1D
The basic process of loading 1D data from a delimited text file is as follows:
1.
Choose DataLoad WavesLoad Waves to display the Load Waves dialog.
2.
Choose Delimited Text from the File Type pop-up menu.
Sample
ch0
ch1
ch2
Comment
Ge
2.97055
1.95692
1.00871
"Run 17, station 1"
Si
3.09921
4.08008
1.00016
"Run 17, station 2"
GaAs
3.18934
5.91134
1.04205
"Run 17, station 3"
