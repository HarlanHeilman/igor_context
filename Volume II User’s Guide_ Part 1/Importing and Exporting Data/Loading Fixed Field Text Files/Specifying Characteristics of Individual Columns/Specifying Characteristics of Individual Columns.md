# Specifying Characteristics of Individual Columns

Chapter II-9 — Importing and Exporting Data
II-145
Here are some examples showing custom date formats and how you would specify them using the Load-
Wave /R flag:
When loading data as delimited text, if you use a date format containing a comma, such as "October 11, 
1999", you must use the /V flag to make sure that LoadWave will not treat the comma as a delimiter.
When loading a date format that consists entirely of digits, such as 991011, you must use the LoadWave/B 
flag to tell LoadWave that the data is a date. Otherwise, LoadWave will treat it as a regular number.
Specifying Characteristics of Individual Columns
The LoadWave /B=columnInfoStr flag provides information to LoadWave for each column in a delimited 
text (/J), fixed field text (/F) or general text (/G) file. The flag overrides LoadWave's normal behavior. In most 
cases, you will not need to use it. /B is useful in user-defined functions when you need additional control.
columnInfoStr is constructed as follows:
"<column info>;<column info>; . . .;<column info>;"
October 11, 1999
/R={English, 2, 4, 1, 1, "Month DayOfMonth, Year", 40}
Oct 11, 1999
/R={English, 2, 3, 1, 1, "Month DayOfMonth, Year", 40}
11 October 1999
/R={English, 2, 4, 1, 1, "DayOfMonth Month Year", 40}
11 Oct 1999
/R={English, 2, 3, 1, 1, "DayOfMonth Month Year", 40}
10/11/99
/R={English, 1, 2, 1, 1, "Month/DayOfMonth/Year", 40}
11-10-99
/R={English, 1, 2, 2, 1, "DayOfMonth-Month-Year", 40}
11-Jun-99
/R={English, 1, 3, 2, 1, "DayOfMonth-Month-Year", 40}
991011
/R={English,1,2,2,1,"YearMonthDayOfMonth", 40}

Chapter II-9 — Importing and Exporting Data
II-146
where <column info> consists of one or more of the following:
Here is an example of the /B=columnInfoStr flag:
/B="C=1,F=-2,T=2,W=20,N=Factory; C=1,F=6,W=16,T=4,N=MfgDate;
C=1,F=0,W=16,T=2,N=TotalUnits; C=1,F=0,W=16,T=2,N=DefectiveUnits;"
This example is shown on two lines but in a real command it would be on a single line. In a procedure, it 
could be written as:
String columnInfoStr = ""
columnInfoStr += "C=1,F=-2,T=2,W=20,N=Factory;"
C=<number>
The number of columns controlled by this column info specification. <number> 
is an integer greater than or equal to one.
F=<format>
A code that specifies the data type of the column or columns. <format> is an 
integer from -2 to 10. The meaning of the <format> is:
-2: Text. The column will be loaded into a text wave.
-1: Format unknown. Igor will deduce the format.
0 to 5: Numeric.
6: Date
7: Time
8: Date/Time
9: Octal number
10: Hexadecimal number
The F= flag is used for delimited text and fixed field text files only. It is ignored 
for general text files.
N=<name>
A name to use for the column. <name> can be a standard name (e.g., wave0) or a 
quoted liberal name (e.g., 'Heart Rate'). If <name> is '_skip_' then LoadWave will 
skip the column.
The N= flag works for delimited text, fixed field text and general text files.
See LoadWave Generation of Wave Names on page II-142 for further 
discussion.
T=<numtype>
A number that specifies what the numeric type for the column should be. This 
flag overrides the LoadWave/D flag. It has no effect on columns whose format is 
text. <numtype> must be one of the following:
2: 32-bit float
4: 64-bit float
8: 8-bit signed integer
16: 16-bit signed integer
32: 32-bit signed integer
72: 8-bit unsigned integer
80: 16-bit unsigned integer
96: 32-bit unsigned integer
W=<width>
The column field width for fixed field files. <width> is an integer greater than or 
equal to one. Fixed width files are FORTRAN-style files in which a fixed number 
of bytes is allocated for each column and spaces are used as padding.
The W= flag is used for fixed field text only.

Chapter II-9 — Importing and Exporting Data
II-147
columnInfoStr += "C=1,F=6,T=4,W=16,N=MfgDate;"
columnInfoStr += "C=1,F=0,T=2,W=16,N=TotalUnits;"
columnInfoStr += "C=1,F=0,T=2,W=16,N=DefectiveUnits;"
columnInfoStr += "C=1,F=0,T=2,W=16,N=DefectiveUnits;"
Note that each flag inside the quoted string ends with either a comma or a semicolon. The comma separates 
one flag from the next within a particular column info specification. The semicolon marks the end of a 
column info specification. The trailing semicolon is required. Spaces and tabs are permitted within the 
string.
This example provides information about a file containing four columns.
The first column info specification is "C=1;F=-2,T=2,W=20,N=Factory;". This indicates that the specification 
applies to one column, that the column format is text, that the numeric format is single-precision floating 
point (but this has no effect on text columns), that the column data is in a fixed field width of 20 bytes, and 
that the wave created for this column is to be named Factory.
The second column info specification is "C=1;F=6,T=4,W=16,N=MfgDate;". This indicates that the specifica-
tion applies to one column, that the column format is date, that the numeric format is double-precision float-
ing point (double precision should always be used for dates), that the column data is in a fixed field width 
of 16 bytes, and that the wave created for this column is to be named MfgDate.
The third column info specification is "C=1;F=0,T=2,W=16,N=TotalUnits;". This indicates that the specifica-
tion applies to one column, that the column format is numeric, that the numeric format is single-precision 
floating point, that the column data is in a fixed field width of 16 bytes, and that the wave created for this 
column is to be named TotalUnits.
The fourth column info specification is the same as the third except that the wave name is DefectiveUnits.
All of the items in a column specification are optional. The default value for each item in the column info 
specification is as follows:
Taking advantage of the default values, we could abbreviate the example as follows:
/B="F=-2,W=20,N=Factory; F=6,T=4,W=16,N=MfgDate;
W=16,N=TotalUnits; W=16,N=DefectiveUnits;"
If the file were not a fixed field text file, we would omit the W= flag and the example would become:
/B="F=-2,N=Factory; F=6,T=4,N=MfgDate; N=TotalUnits; N=DefectiveUnits;"
Here are some more examples and discussion that illustrate the use of the /B=columnInfoStr flag.
In this example, the /B flag is used solely to specify the name to use for the waves created from the columns 
in the file:
/B="N=WaveLength; N=Absorbance;"
C=<number>
C=1. Specifies that the column info describes one column.
F=<format>
F=-1. Determines the format as dictated by the /K flag. If /K=0 is used, LoadWave 
will automatically determine the column format.
N=<name>
N=_auto_. Generates the wave name as it would if the /B flag were omitted.
T=<numtype>
Defaults to T=4 (double precision) if the LoadWave/D flag is used or to T=2 
(single precision) if the /D flag is omitted.
W=<width>
W=0. For a fixed width file, LoadWave will use the default field width specified 
by the /F flag unless you provide an explicit field width greater than 0 using 
W=<width>.

Chapter II-9 — Importing and Exporting Data
II-148
The wave names in the previous example are standard names. If you want to use liberal names, such as 
names containing spaces or dots, you must use single quotes. For example:
/B="N='Wave Number'; N='Reflection Angle';"
The name that you specify via N= can not be used if overwrite is off and there is already a wave with this 
name or if the name conflicts with a macro, function or operation or variable. In these cases, LoadWave gen-
erates a unique name by adding one or more digits to the name specified by the N= flag for the column in 
question. You can avoid the problem of a conflict with another wave name by using the overwrite (/O) flag 
or by loading your data into a newly-created data folder. You can minimize the likelihood of a name conflict 
with a function, operation or variable by avoiding vague names.
If you specify the same name in two N= flags, LoadWave will generate an error, so make sure that the names 
are unique.
Except if the specified name is '_skip_', the N= flag generates a name for one column only, even if the C= 
flag is used to specify multiple columns. Consider this example:
/B="C=10,N=Test;"
This ostensibly uses the name Test for 10 columns. However, wave names must be unique, so LoadWave 
will not do this. It will use the name Test for just the first column and the other columns will receive default 
names.
You can load a subset of the columns in the file using the /L flag. Even if you do this, the column info spec-
ifications that you provide via the /B flag start from the first column in the file, not from the first column to 
be loaded. For example, if you are using /L to skip columns 0 and 1, you must skip columns 0 and 1 in the 
column info specification, like this:
// Skip column 0 and 1 and name the successive columns
/L={0,0,0,2,0} /B="C=2;N=Column2;N=Column3;"
The "C=2;" part accepts default specifications for columns 0 and 1 and the subsequent specifications apply 
to subsequent columns.
You can achieve the same thing using /B without /L, like this:
/B="C=2,N='_skip_';N=Column2;N=Column3;"
Also, when loading data into a matrix wave, LoadWave uses only one name. If you specify more than one 
name, only the first is used. If you are loading data into a matrix and also skipping columns, the explanation 
above about skipping applies.
In this example, the /B flag solely specifies the format of each column in the file. The file in question starts 
with a text column, followed by a date column, followed by 3 numeric columns.
/B="F=-2; F=6; C=3,F=0"
In most cases, it is not necessary to use the F= flag because LoadWave can automatically deduce the formats. 
The flag is useful for those cases where it deduces the column formats incorrectly. It is also useful to force 
LoadWave to interpret a column as octal or hexadecimal because LoadWave can not automatically deduce 
these formats.
The numeric codes (0...10) used by the F= flag are the same as the codes used by the ModifyTable operation. 
If you create a table using the /E flag, the F= flag controls the numeric format of table columns.
The code -1 is not a real column format code. If you use F=-1 for a particular column, LoadWave will deduce 
the format for that column from the column text.
In this example, the /B flag is used solely to specify the width of each column in a fixed field file. This file 
contains a 20 byte column followed by ten 16 byte columns followed by three 24 byte columns.
/B="C=1,W=20; C=10,W=16; C=3,W=24"
