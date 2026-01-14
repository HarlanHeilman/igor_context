# MLLoadWave

Menu
V-589
Example
See the Example section of the documentation for MeasureStyledText in the Igor Reference help file.
See Also
Annotation Escape Codes on page III-53 for a list of text formatting codes.
DefaultFont
Menu 
Menu menuNameStr [, hideable, dynamic, contextualmenu]
The Menu keyword introduces a menu definition. You can use this to create your own menu, or to add 
items to a built-in Igor menu.
Use the optional hideable keyword to make the menu hideable using HideIgorMenus.
Use the optional dynamic keyword to cause Igor to re-evaluate the menu definition when the menu is used. 
This is helpful when the menu item text is provided by a user-defined function. See Dynamic Menu Items 
on page IV-129.
Use the optional contextualmenu keyword for menus invoked by PopupContextualMenu/N.
See Chapter IV-5, User-Defined Menus for further information.
min 
min(num1, num2 [, num3, ... num200])
The min function returns the least value of num1, num2, ... num200.
If any parameter is NaN, the result is NaN.
Details
In Igor7 or later, you can pass up to 200 parameters. Previously min was limited to two parameters.
See Also
max, limit, WaveMin, WaveMax, WaveMinAndMax
MLLoadWave
MLLoadWave [flags] fileNameStr
The MLLoadWave operation loads data from the named Matlab MAT file into single 1D waves (vectors), 
multidimensional waves (matrices), numeric variables or string variables.
For background information, including configuration instructions, see Loading Matlab MAT Files on page 
II-163.
Parameters
The file to be loaded is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If 
LoadWave can not determine the location of the file from fileNameStr and pathName, it displays a dialog 
allowing you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
If fileNameStr is omitted or is "" or the /I flag is used, MLLoadWave displays an Open File dialog in which 
you locate the file to be loaded.
{
V_ascent+V_descent Hg
Hg Hg
80
Hg
Hg2Cl2
Hg2Cl2
V_superscriptExtraHeight { 
V_subscriptExtraHeight { 
V_height

MLLoadWave
V-590
Flags
/A[=name]
Assign wave names using "wave" or name, if present, as the name or base name. Skips 
names already in use.
/B
This flag is obsolete and is ignored. Previously it was required to tell MLLoadWave 
the byte order of the data in the file. MLLoadWave now determines the byte order 
automatically.
/C
Loads columns from a Matlab matrix into an Igor 1D wave. Use /R to load rows.
/E
Skips empty Matlab matrices.
/G
Tells Igor to make numeric and string variables global when called from a macro. 
When called from a user-defined function or from the command line, variables are 
always created as globals.
/I
Interactive. Displays the Open File dialog to get the path to the file.
/M=m
m=1: Loads an entire Matlab matrix into an Igor 1D wave. This is the default if you 
omit /M.
m=2: Loads an entire Matlab matrix into an Igor multidimensional wave.
m=3: Loads an entire Matlab matrix into a transposed Igor multidimensional wave.
/M by itself is equivalent to /M=1.
Starting with Igor Pro 8.00, after loading a matrix that results in an Mx1 2D wave, 
MLLoadWave automatically redimensions the wave as an M-row 1D wave.
/N[=name]
Assign wave names using "wave" or name, if present, as the name or base name. 
Overwrites existing waves if the name is already in use.
/O
Overwrites existing waves and variables in case of a name conflict. If /O is omitted, 
MLLoadWave chooses names that don’t conflict with existing objects.
/P=pathName
Specifies the folder to look in for the specified file or folder. pathName is the name of 
an existing Igor symbolic path.
/Q
Be quiet. Suppresses normal diagnostic messages.
/R
Loads rows from a Matlab matrix into an Igor 1D wave. Use /C to load columns.
/S=s
/S by itself is equivalent to /S=1.
/T
Displays the loaded waves in a new table.
/V
Skips Matlab numeric variables (numeric matrices with one element).
Controls how Matlab string data is loaded:
s=1
Skips Matlab string matrices.
s=2
Loads Matlab string matrices into Igor string variables. This is the 
default if /S is omitted.
s=3
Loads Matlab string matrices into Igor text waves.

MLLoadWave
V-591
MLLoadWave Wave Naming
If neither /A, /A[=name], /N, or N[=name] is used then the waves names are taken from the matrix name, as 
stored in the Matlab file.
When loading 1D waves, the /N flag instructs MLLoadWave to automatically name new waves "wave" (or 
baseName if /N=baseName is used) plus a number. The number starts from zero and increments by one for 
each wave loaded from the file. When loading multidimensional waves, name is used without an appended 
number.
The /A flag is like /N except that MLLoadWave skips names already in use.
If you specify /M=2 (load matrix into matrix) or /M=3 (load matrix into transposed matrix), MLLoadWave 
uses the name without appending any digits. For example, if you have a 5x3 matrix in a file and you tell 
MLLoadWave to load it as a matrix using the name "mat", MLLoadWave will name the matrix "mat". 
However, if you tell MLLoadWave to load the matrix as 3 1D waves, it will use "mat0", "mat1" and "mat2".
If the name that MLLoadWave would use when creating a wave or variable is in use for an object of the 
same type and if you use the overwrite flag, then it will overwrite the existing object. If you do not tell 
MLLoadWave to overwrite, it will choose a non-conflicting name. If the conflict is with an object of a 
different type or with an operation or function, MLLoadWave will also choose a non-conflicting name.
Loading Strings from Matlab Files
When loading Matlab strings into Igor, you can tell MLLoadWave to create Igor string variables or Igor text 
waves. For example, if you have a 2x8 string matrix, MLLoadWave can create two string variables (/S=2) or 
one text wave (/S=3) containing two elements.
When loading Matlab string data into an Igor wave, the Igor wave will be of dimension one less than the 
Matlab data set. This is because each element in a Matlab string data set is a single byte whereas each 
element in an Igor string wave is a string (any number of bytes).
Loading Numeric Variables from Matlab Files
MLLoadWave loads numeric matrices with one element into Igor numeric variables. It loads all other 
numeric matrices into Igor waves.
When called from a macro, MLLoadWave creates local numeric and string variables unless you use the /G 
flag which tells it to create global variables. When called from the command line or from a user-defined 
function, MLLoadWave always creates global variables. Macros should be avoided in new programming.
Automatic Redimensioning from 2D to 1D
Starting with Igor Pro 8.00, after loading a matrix that results in an Mx1 2D wave, MLLoadWave 
automatically redimensions the wave as an M-row 1D wave.
This automatic redimensioning not affect the naming of the wave. It is still named using the 2D rules 
explained above under MLLoadWave Wave Naming.
Loading 3D and 4D Data from Matlab Files
For a discussion of how MLLoadWave handles 3D and 4D Matlab data, see Numeric Data Loading Modes.
/Y=y
/Z
Interactive load. Displays a dialog presenting options for each Matlab matrix in the 
file.
Specifies the number type of the numeric waves to be created. The allowed codes 
for y are:
2:
Single-precision floating point
4:
Double-precision floating point
32:
32-bit signed integer
16:
16-bit signed integer
8:
8-bit signed integer
96:
32-bit signed integer
80:
16-bit signed integer
72:
8-bit signed integer
