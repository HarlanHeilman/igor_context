# ModifyTable

ModifyTable
V-645
You can obtain the information provided by the output variables without modifying any procedure 
windows by omitting the lock, writeProtect, and userCanOverride keywords.
Examples
// Completely unlock main Procedure window
ModifyProcedure lock=0, writeProtect=0, userCanOverride=1; Print S_windowList
// Completely unlock the procedure window containing the function named MyFunction
ModifyProcedure procedure="MyFunction", lock=0, writeProtect=0, userCanOverride=1
Print S_windowList
// Print procedure window title
// Lock all procedure windows in the myIM independent module, even those included into it,
// and print the titles of the matching procedure windows
Execute "SetIgorOption IndependentModuleDev=1"
ModifyProcedure/W="[myIM]" lock=1, writeProtect=1, userCanOverride=0; Print S_windowList
// Unlock all procedure windows in the ProcGlobal module
ModifyProcedure/A=1 lock=0, writeProtect=0, userCanOverride=1
// Hide all procedures in ProcGlobal and all independent modules
ModifyProcedure/A=2 hide=1
// Equivalent to HideProcedures
See Also
Independent Modules on page IV-238
HideProcedures, DisplayProcedure, ProcedureText, ProcedureVersion
DoWindow, WinList
MacroList, FunctionList
ModifyTable 
ModifyTable [/W=winName/Z] key [(columnSpec)] =value [, key [(columnSpec)] =value]…
The ModifyTable operation modifies the appearance the top or named table window or subwindow.
Parameters
Many of the parameter keywords take an optional columnSpec enclosed in parentheses. Usually columnSpec is 
simply the name of a wave displayed in the table. All table columns are affected when you omit (columnSpec).
More precisely, column specifications are wave names for waves in the current data folder or data folder 
paths leading to waves in any data folder optionally followed by the suffixes .i, .l, .d, .id or .ld to specify 
dimension indices, dimension labels, data values, dimension indices and data values, or dimension labels 
and data values of the wave. For example, ModifyTable font(myWave.i)="Helvetica". If the wave 
is complex, the column specification may be followed by .real or .imag suffixes.
One additional columnSpec is Point, which refers to the first column containing the dimension index 
numbers. If multidimensional waves are displayed in the table, this column may have the title “Row”, 
“Column”, “Layer”, “Chunk” or “Element”, but the columnSpec for this column is always Point. See 
Column Names on page II-241 for details.
Though not shown in the syntax, the optional (columnSpec) may be replaced with [columnIndex], 
where columnIndex is zero or a positive integer denoting the column to be modified. [0] denotes the Point 
column, [1] denotes the first column appended to the table, [2] denotes the second appended column, 
etc. This syntax is used for style macros, in conjunction with the /Z flag.
You can use a range of column numbers instead of just a single column number, for example [0,3].
S_windowList
Set to a semicolon-separated list of procedure window titles that match the 
parameters, with an appended independent module name in brackets if 
necessary.
If S_windowList is empty, then no procedure windows matched the parameters, 
and no modifications were performed.

ModifyTable
V-646
The parameter descriptions below omit the optional (columnSpec).
alignment=a
autosize={mode, options, padding, perColumnMaxSeconds, totalMaxSeconds}
padding specifies extra padding for each column in points. Use -1 to get the default 
amount of padding (16 points).
perColumnMaxSeconds specifies the maximum amount of time to spend autosizing a 
single column. Use 0 to get the default amount of time (one second).
totalmaxSeconds specifies the maximum amount of time for autosizing the entire table. 
Use 0 to get the default amount of time (ten seconds).
digits=d
Specifies the number of digits after decimal point or, for hexadecimal and octal 
columns, the number of total digits.
elements=(row, col, layer, chunk)
entryMode=m
Sets the alignment of table cell text.
a=0:
Left aligned.
a=1:
Center aligned.
a=2:
Right aligned.
Autosizes the specified column or columns.
mode=0:
Sets width of each data column from a given multidimensional 
wave individually.
mode=1:
Sets width of all data columns from a given multidimensional wave 
the same.
options is a bitwise parameter. Usually 0 is the best choice.
All other bits are reserved and must be set to zero.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Ignores column names.
Bit 1:
Ignores horizontal indices.
Bit 2:
Ignores data cells.
Selects the view of a multidimensional wave in the table. The values given to row, 
col, layer, and chunk specify how to change the view.
See ModifyTable Elements Command on page II-263 for a detailed discussion of 
-1:
No change from current view.
-1:
Display this dimension vertically.
-3:
Display this dimension horizontally.
0:
For waves with 3 or 4 dimensions, display this element of the 
other dimensions.
Queries or sets the table’s entry line mode.
m=0:
Just queries.
m=1:
Accepts any entry that was started if possible.
m=2:
Cancels any entry that was started if possible.
If m is 0 then the entry line state is not changed but is returned via V_flag as follows:
In Igor Pro 8.03 and later, S_value is set to contain the text showing in the entry line.
0:
No entry is in progress.
-1:
An entry is in progress and is valid.
Other:
An entry is in progress and is invalid.

ModifyTable
V-647
font="fontName"
Sets font used in the table, e.g., font="Helvetica".
format=f
You cannot apply date or date&time formats to a wave that is not double-precision 
(see Date, Time, and Date&Time Units on page II-69). To avoid this error, use 
Redimension to change the wave to double-precision.
frameInset= i
Specifies the number of pixels by which to inset the frame of the table subwindow.
frameStyle= f
If m is 1 then the entry is accepted if it is valid and its state is returned via V_flag as 
follows:
In Igor Pro 8.03 and later, S_value is set to contain the text showing in the entry line 
whether or not an entry was in progress and whether or not i was accepted.
0:
No entry is in progress.
-1:
The entry was accepted.
Other:
The entry is invalid and was not accepted.
If m is 2 then the entry is cancelled if possible and its state is returned via V_flag as 
follows:
In Igor Pro 8.03 and later, S_value is set to contain the text showing in the entry line 
after the entry was cancelled.
0:
No entry is in progress.
-1:
The entry was cancelled.
Sets the data format for the table.
f=0:
General.
f=1:
Integer.
f=2:
Integer with thousands (e.g., "1,234").
f=3:
Fixed point (e.g., "1234.56").
f=4:
Fixed point with thousands (e.g., "1,234.56").
f=5:
Exponential (scientific only).
f=6:
Date format.
f=7:
Time format (always 24 hour time).
f=8:
Date&time format (date followed by time).
f=9:
Octal.
f=10:
Hexadecimal.
Specifies the frame style for a table subwindow.
The last three styles are fake 3D and will look good only if the background 
color of the enclosing space and the table itself is a light shade of gray.
f=0:
None.
f=1:
Single.
f=2:
Double.
f=3:
Triple.
f=4:
Shadow.
f=5:
Indented.
f=6:
Raised.
f=7:
Text well.

ModifyTable
V-648
horizontalIndex=h
The horizontal index row appears below the row of column names if the table 
contains a multidimensional wave. Use horizontalIndex to override the default 
behavior in order to display labels for the horizontal dimension while displaying 
numeric indices for the vertical dimension or vice versa.
The horizontalIndex keyword controls the horizontal index row only. To control what 
is displayed vertically, use AppendToTable to append a numeric index or dimension 
label column.
rgb=(r,g,b[,a])
Sets color of text. r, g, b, and a specify the color and optional opacity as RGBA Values. 
The default is opaque black.
selection=(firstRow, firstCol, lastRow, lastCol, targetRow, targetCol)
Sets the selected cells in the table.
If any of the parameters have the value -1 then the corresponding part of the selection 
is not changed.
Otherwise they set the first and last selected cell and the target cell. Row and column 
values are 0 or greater. The Point column can not be selected.
The proposed parameters are clipped to avoid invalid combinations, such as the last 
selected row being before the first selected row.
With one exception, it does not support selecting unused cells. Therefore the 
proposed selection is clipped to prevent this. The exception is that, if the parameters 
call for selecting the first cell in the first unused column, then this is permitted.
showFracSeconds=s Shows (s=1) or hides (s=0; default) fractional seconds.
showParts=parts
Specifies what elements of the table should be visible. Other elements are hidden.
All other bits are reserved and must be set to zero except that you can pass -1 to 
indicate that you want to show all parts of the table.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Presentation tables in subwindows in graphs and page layouts do not have an entry 
line or scroll bars and therefore never show these items.
See Parts of a Table on page II-235 and Showing and Hiding Parts of a Table on page 
II-237 for further information.
sigdigits=d
d is the number of significant digits when the numeric format is general.
size=s
Font size, e.g., size=14.
Controls what is displayed in the horizontal index row when multidimensional 
waves are displayed.
h=0:
Displays dimension labels if the multidimensional wave’s label column 
is displayed, otherwise displays numeric indices (default).
h=1:
Always displays numeric indices for multidimensional waves.
h=2:
Always displays dimension labels for multidimensional waves.
parts is a bitwise parameter specifying what to show.
bit 0:
Entry line and other top line controls.
bit 1:
Name row.
bit 2:
Horizontal index row.
bit 3:
Point column.
bit 4:
Horizontal scroll bar.
bit 5:
Vertical scroll bar.
bit 6:
Insertion cells.
bit 7:
Insertion cells.
