# XLLoadWave

XLLoadWave
V-1115
Details
The result is derived from the wave that the cursor is on, not from the X axis of the graph. If the wave is 
displayed as an XY pair, the X axis and the wave’s X scaling will usually be different.
See Also
The hcsr, pcsr, qcsr, vcsr, and zcsr functions.
Programming With Cursors on page II-321.
XLLoadWave
XLLoadWave [flags] [fileNameStr]
The XLLoadWave operation loads data from the named Excel .xls, .xlsx or .xlsm file into waves.
XLLoadWave does not support .xlsb files and can not load password-protected Excel files.
Parameters
The file to be loaded is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If 
XLLoadWave can not determine the location of the file from fileNameStr and pathName, it displays a dialog 
allowing you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
If fileNameStr is omitted or is "", or if the /I flag is used, XLLoadWave presents an Open File dialog from 
which you can choose the file to load.
Flags
/A
Automatically assigns arbitrary wave names using "wave" as the base name. Skips 
names already in use.
/A=baseName
Same as /A but it automatically assigns wave names of the form baseName0, 
baseName1.
/C=columnType
XLLoadWave will use the Deduce from Row method of determining the type of the 
Excel file columns, using the row specified by columnType to deduce column types. 
See Deduce from row on page II-160.
/COLT=columnTypeStr
columnTypeStr specifies how XLLoadWave should treat each column. For example, 
"1T3N" means 1 text column followed by 3 numeric columns. See Determining Wave 
Types on page V-1117.
/D
Creates double-precision floating point waves. If omitted, XLLoadWave creates 
single-precision floating point waves.
/F=f
/I
Forces XLLoadWave to display an Open File dialog even if the file is fully specified 
via /P and fileNameStr.
/J=infoMode
If infoMode is 1, 2 or 3, XLLoadWave does not load the file but instead returns 
information about the worksheets within the workbook via the string variable 
S_value. See Getting Information About the Excel File on page V-1117.
/K=k
Discards waves with fewer than k points. For historical reasons, k defaults to 2.
New programming should use the /T flag instead of the /D, /L and /F flags.
f specifies the data format of the file:
f=1:
Signed integer (8, 16, 32 bits allowed)
f=2:
Creates double-precision waves
f=3:
Floating point (default, 32, 64 bits allowed)

XLLoadWave
V-1116
Wave Names
The names of the loaded waves are determined by the /A, /N, /W and /NAME flags. If all of the flags are 
omitted, default names, like ColumnA and ColumnB, are used.
If /W=w is present, names are loaded from row w of the worksheet and then converted to standard Igor 
names by replacing spaces and punctuation characters with underscores.
If /NAME=nameList is present, the wave names come from nameList, a semicolon-separated list of names. 
For example:
/NAME="StartTime;UnitA;UnitB;"
The names in nameList can be standard or liberal names. For example, this specifies names two standard 
names and one liberal name which contains a space:
/NAME="Signal;Ambient Temp;Response;"
If a name in the list is _skip_, the corresponding Excel column is skipped. For example, this would load the 
first and third columns and skip the second:
/NAME="Signal;_skip_;Response;"
If a name in the list is empty, the name used for the corresponding wave is as it would be if /NAME were 
omitted. This can be used to skip columns while taking wave names from the spreadsheet for loaded 
columns. In this example, the names of the first and third waves would be determined by row 1 of the 
spreadsheet while the second column would be skipped:
/N
Same as /A except that, instead of choosing names that are not in use, it overwrites 
existing waves.
/N=baseName
Same as /N except that it automatically assigns wave names of the form baseName0, 
baseName1.
/NAME=nameList
nameList is a semicolon-separated list of wave names to be used for the loaded waves. 
See Wave Names on page V-1116 for details.
/O
Overwrites existing waves in case of a name conflict.
/P=pathName
Specifies the folder to look in for fileNameStr. pathName is the name of an existing 
symbolic path.
/Q
Suppresses the normal messages in the history area.
/R=(cell1,cell2)
Restricts loading to the specified cells, e.g. /R=(A3,D21). Row and column numbers 
start from 1.
The /R flag supports an optional extra parameter that should be used only in very rare 
cases. XLLoadWave reads the range of defined cells from the file itself and clips cell1 
and cell2 to that range.
In very rare cases the file does not accurately identify the range of defined cells so the 
clipping prevents loading cells that exist in the file. In this rare case, use /R=(cell1, 
cell2,1). The last parameter tells XLLoadWave to skip the clipping. If you specify 
incorrect values for cell1 or cell2 you may get errors or garbage results.
/S=sheetNameStr
Specifies which worksheet to load from a workbook file. If you omit /S=sheetNameStr, 
or if sheetNameStr is "", XLLoadWave loads the first worksheet in the workbook.
/T
Automatically creates a table of loaded waves.
/V=v
/W=w
w specifies the row in which XLLoadWave will look for wave names. The first row is 
row number 1.
Controls the handling of blanks at the end of a column.
v=0:
XLLoadWave leaves blanks at the end of a column in the Igor wave.
v=1:
XLLoadWave removes blanks at the end of a column from the Igor 
wave. If the column has fewer than two remaining points, it is not 
loaded into a wave. This is the default mode that is used if you omit 
/V.

XLLoadWave
V-1117
/W=1 /NAME=";_skip_;;"
The /N flag instructs Igor to automatically name new waves "wave", or baseName if /N=baseName is used, 
plus a number. The number starts from zero and increments by one for each wave loaded from the file. If 
the resulting name conflicts with an existing wave, the existing wave is overwritten.
The /A flag is like /N except that it skips names already in use.
/NAME overrides /W. /A or /N overrides both /NAME and /W.
No matter how the wave names are generated, if there is a name conflict and overwrite is off (/O is omitted), 
a unique name is generated. See XLLoadWave and Wave Names on page II-161 for further details.
Determining Wave Types
The /C or /COLT flag tells XLLoadWave how to decide what kind of wave, numeric, text, or date/time, to 
make for each Excel column.
Using /C=columnType causes XLLoadWave to use the Deduce from Row method of determining the type of 
the Excel file columns. columnType is the Excel row number that XLLoadWave should use to make the 
deduction.
Using /COLT=columnTypeStr causes XLLoadWave treat the columns based on the columnTypeStr 
parameter. If columnTypeStr is "N", XLLoadWave uses the Treat all Columns as Numeric method. If 
columnTypeStr is "T", XLLoadWave uses the Treat all Columns as Text method. If columnTypeStr is "D", 
XLLoadWave uses the Treat all Columns as Date method.
For any other value of columnTypeStr , XLLoadWave uses the Use Column Type String method. For 
example, "1T5N" tells XLLoadWave to create a text wave for the first column and numeric waves for the 
next 5 or more columns.
If you omit /C and /COLT, XLLoadWave uses the Treat all Columns as Numeric method.
See What XLLoadWave Loads on page II-159 for further details.
Output Variables
XLLoadWave sets the followin output variables:
S_path uses Macintosh path syntax (e.g., “hd:FolderA:FolderB:”), even on Windows. It includes a 
trailing colon.
When XLLoadWave presents an Open File dialog and the user cancels, V_flag is set to 0 and S_fileName is set 
to "".
Getting Information About the Excel File
The /J flag allows you to get information about an Excel file without actually loading it.
If infoMode is 1, XLLoadWave does not load the file but instead returns a semicolon-separated list of the 
names of the worksheets within the workbook via the string variable S_value.
If infoMode is 2, XLLoadWave does not load the file but instead returns information about the first 
worksheet or the worksheet specified by /S via the string variable S_value. The format of the returned 
information is:
NAME:<worksheet name>;FIRSTROW:<first row>;FIRSTCOL:<first col>;LASTROW:<last 
row>;LASTCOL:<last col>;
V_flag
Number of waves loaded.
S_fileName
Name of the file being loaded.
S_path
File system path to the folder containing the file.
S_waveNames
Semicolon-separated list of the names of loaded waves.
S_worksheetName
Name of the loaded worksheet within the workbook file.
S_value
Set only if you use the /J flag. See Getting Information About the Excel File 
below.
