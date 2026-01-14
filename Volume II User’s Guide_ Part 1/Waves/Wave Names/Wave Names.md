# Wave Names

Chapter II-5 — Waves
II-65
Making Waves
You can make waves by:
•
Loading data from a file
•
Typing or pasting in a table
•
Using the Make operation (via a dialog or directly from the command line)
•
Using the Duplicate operation (via a dialog or directly from the command line)
Most people start by loading data from a file. Igor can load data from text files. In this case, Igor makes a 
wave for each column of text in the file. Igor can also load data from binary files or application-specific files 
created by other programs. For information on loading data from files, see Importing Data on page II-126.
You can enter data manually into a table. This is recommended only if you have a small amount of data. 
See Using a Table to Create New Waves on page II-239.
To synthesize data with a mathematical expression, you would start by making a wave using the Make 
operation (see page V-526). This operation is also often used inside an Igor procedure to make waves for 
temporary use.
The Duplicate operation (see page V-185) is an important and handy tool. Many built-in operations trans-
form data in place. Thus, if you want to keep your original data as well as the transformed copy of it, use 
Duplicate to make a clone of the original.
Wave Names
All waves in Igor have names so that you can reference them from commands. You also use a wave’s name 
to select it from a list or pop-up menu in Igor dialogs or to reference it in a waveform assignment statement.
You need to choose wave names when you use the Make, Duplicate or Rename operations via dialogs, 
directly from the command line, and when you use the Data Browser.
All names in Igor are case insensitive; wave0 and WAVE0 refer to the same wave.
The rules for the kind of characters that you can use to make a wave name fall into two categories: standard 
and liberal. Both standard and liberal names are limited to 255 bytes in length.
Prior to Igor Pro 8.00, wave names were limited to 31 bytes. If you use long wave names, your wave and 
experiment files will require Igor Pro 8.00 or later.
Standard names must start with an alphabetic character (A - Z or a-z) and may contain ASCII alphabetic 
and numeric characters and the underscore character only. Other characters, including spaces, dashes and 
periods and non-ASCII characters are not allowed. We put this restriction on standard names so that Igor 
can identify them unambiguously in commands, including waveform assignment statements.
Liberal names, on the other hand, can contain any character except control characters (such as tab or car-
riage return) and the following four characters:
" ' : ;
Standard names can be used without quotation in commands and expressions but liberal names must be 
quoted. For example:
Make wave0; wave0 = p
// wave0 is a standard name
Make 'wave 0'; 'wave 0' = p
// 'wave 0' is a liberal name
Igor can not unambiguously identify liberal names in commands unless they are quoted. For example, in
wave0 = miles/hour
miles/hour could be a single wave or it could be the quotient of two waves.
