# Edit

Edit
V-192
These X locations and distances are in terms of the X scaling of the named wave unless you use the /P flag, 
in which case they are in terms of point number.
The EdgeStats operation is not multidimensional aware. See Analysis on Multidimensional Waves on 
page II-95 for details.
See Also
The FindLevel operation for use of the /B=box, /T=dx, /P and /Q flags, and PulseStats.
Edit 
Edit [flags] [columnSpec [, columnSpec]…][as titleStr]
The Edit operation creates a table window or subwindow containing the specified columns.
Parameters
columnSpec is usually just the name of a wave. If no columnSpecs are given, Edit creates an empty table.
Column specifications are wave names optionally followed by one of the suffixes:
If the wave is complex, the wave names may be followed by .real or .imag suffixes. However, as of Igor Pro 
3.0, both the real and imaginary columns are added to the table together — you can not add one without 
the other — so using these suffixes is discouraged.
titleStr is a string expression containing the table’s title. If not specified, Igor will provide one which 
identifies the columns displayed in the table.
Flags
Suffix
Meaning
.i
Index values.
.l
Dimension labels.
.d
Data values.
.id
Index and data values.
.ld
Dimension labels and data values.
Historical 
Note:
Prior to Igor Pro 3.0, only 1D waves were supported. We called index values “X values” 
and used the suffix “.x” instead of “.i”. We called data values “Y values” and used the 
suffix “.y” instead of “.d”. For backward compatibility, Igor accepts “.x” in place of “.i” 
and “.y” in place of “.d”.
/FG=(gLeft, gTop, gRight, gBottom)
Specifies the frame guide to which the outer frame of the subwindow is attached 
inside the host window.
The standard frame guide names are FL, FR, FT, and FB, for the left, right, top, and 
bottom frame guides, respectively, or user-defined guide names as defined by the 
host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/HOST=hcSpec
Embeds the new table in the host window or subwindow specified by hcSpec.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/I
Specifies that /W coordinates are in inches.

Edit
V-193
Details
You can not change dimension index values shown in a table. Use the Change Wave Scaling dialog or the 
SetScale operation.
If /N is not used, Edit automatically assigns to the table window a name of the form “Tablen”, where n is 
some integer. In a function or macro, the assigned name is stored in the S_name string. This is the name you 
can use to refer to the table from a procedure. Use the RenameWindow operation to rename the graph.
Examples
These examples assume that the waves are 1D.
Edit myWave,otherWave
// 2 columns: data values from each wave
Edit myWave.id
// 2 columns: x and data values
Edit cmplxWave
// 2 columns: real and imaginary data values
Edit cmplxWave.i
// One column: x values
The following examples illustrates the use of column name suffixes in procedures when the name of the 
wave is in a string variable.
Macro TestEdit()
String w = "wave0"
Edit $w
// edit data values
Edit $w.i
// show index values
Edit $w.id
// index and data values
End
Note that the suffix, if any, must not be stored in the string. In a user-defined function, the syntax would be 
slightly different:
Function TestEditFunction()
Wave w = $"wave0"
Edit w
// no $, because w is name, not string
Edit w.i
// show index values
Edit w.id
// index and data values
End
See Also
The DoWindow operation. For a description of how tables are used, see Chapter II-12, Tables.
/K=k
/M
Specifies that /W coordinates are in centimeters.
/N=name
Requests that the created table have this name, if it is not in use. If it is in use, then name0, 
name1, etc. are tried until an unused window name is found. In a function or macro, 
S_name is set to the chosen table name.
/W=(left,top,right,bottom)
Gives the table a specific location and size on the screen. Coordinates for /W are in 
points unless /I or /M are specified before /W.
When used with the /HOST flag, the specified location coordinates of the sides can 
have one of two possible meanings:
When all values are less than 1, coordinates are assumed to be fractional relative to 
the host frame size.
When any value is greater than 1, coordinates are taken to be fixed locations measured 
in points, or Control Panel Units for control panel hosts, relative to the top left corner 
of the host frame.
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.
