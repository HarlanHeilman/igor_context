# Determining Column Formats

Chapter II-9 — Importing and Exporting Data
II-129
Mac OS 9 used the carriage-return character (CR).
Unix uses linefeed (LF).
Windows uses a carriage-return and linefeed (CRLF) sequence.
When loading waves, Igor treats a single CR, a single LF, or a CRLF as the end of a line. This allows Igor to 
load text data from file servers on a variety of computers without translation.
LoadWave Text Encodings
This section applies to loading a text file using Load General Text, Load Delimited Text, Load Fixed Field 
Text, or Load Igor Text.
If your file uses a byte-oriented text encoding (i.e., a text encoding other than UTF-16 or UTF-32), and if the 
file contains just numbers or just ASCII text, then you don’t need to be concerned with text encodings.
If your file uses UTF-16, UTF-32, or contains non-ASCII text, you may neeed to tell the LoadWave operation 
which text encoding the file uses. For details, see LoadWave Text Encoding Issues on page II-149.
Loading Delimited Text Files
A delimited text file consists of rows of values separated by tabs or commas with a carriage return, linefeed or 
carriage return/linefeed sequence at the end of the row. There may optionally be a row of column labels. Igor can 
load each column in the file into a separate 1D wave or it can load all of the columns into a single 2D wave. There 
is no limit to the number of rows or columns except that all of the data must fit in available memory.
In addition to numbers and text, the delimited text file may contain dates, times or date/times. The Load 
Delimited Text routine attempts to automatically determine which of these formats is appropriate for each 
column in the file. You can override this automatic determination if necessary.
A numeric column can contain, in addition to numbers, NaN and [±]INF. NaN means “Not a Number” and is 
the way Igor represents a blank or missing value in a numeric column. INF means “infinity”. If Igor finds text in 
a numeric or date/time column that it can’t interpret according to the format for that column, it treats it as a NaN.
If Igor encounters, in any column, a delimiter with no data characters preceding it (i.e., two tabs in a row) 
it takes this as a missing value and stores a blank in the wave. In a numeric wave, a blank is represented by 
a NaN. In a text wave, it is represented by an element with zero characters in it.
Determining Column Formats
The Load Delimited Text routine must determine the format of each column of data to be loaded. The 
format for a given column can be numeric, date, time, date/time, or text. Text columns are loaded into text 
waves while the other types are loaded into numeric waves with dates being represented as the number of 
seconds since 1904-01-01.
There are four methods for determining column formats:
•
Auto-identify column type
•
Treat all columns as numeric
•
Treat all columns as text
•
Use the LoadWave /B flag to explicitly specify the format of each column
You can choose from the first three of these methods using the Column Types pop-up menu in the Tweaks 
subdialog of the Load Waves dialog. To use the /B flag, you must manually add the flag to a LoadWave 
command. This is usually done in a procedure.
In the “auto-identify column type” method, Igor attempts to determine the format of each column by exam-
ining the file. This is the default method when you choose DataLoad WavesLoad Delimited Text. Igor
