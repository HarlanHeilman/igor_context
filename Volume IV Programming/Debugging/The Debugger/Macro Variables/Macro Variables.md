# Macro Variables

Chapter IV-8 — Debugging
IV-218
Here we’ve selected UpdatePeakFromXY, the routine that called mygauss (see the light blue arrow). Notice 
that the Variables List is showing the variables that are local to UpdatePeakFromXY.
For illustration purposes, the Variables List has been resized by dragging the dividing line, and the pop-up 
menu has been set to show local and global variables and type information.
The Variables List Columns
The Variables List shows either two or three columns, depending on whether the "show variable types" item 
in the Variable pop-up menu is checked.
Double-clicking a column's header resizes the column to fit the contents. Double-clicking again resizes the 
column to a default width.
The first column is the name of the local variable. The name of an NVAR, SVAR, or WAVE reference is a 
name local to the macro or function that refers to a global object in a data folder.
The second column is the value of the local variable. Double-click the second column to edit numbers in-
place, double-click anywhere on the row to "inspect" waves, strings, SVARS, or char arrays in structures in 
the appropriate Inspector.
In the case of a wave, the size and precision of the wave are shown here. The "->" characters mean "refers 
to". In our example wcoef is a local name that refers to a (global) wave named coef, which is one-dimen-
sional, has 4 points, and is single precision.
To determine the value of a particular wave element, use an inspector as described under Inspecting 
Waves.
The optional third column shows what the type of the variable is, whether Variable, String, NVAR, SVAR, 
WAVE, etc. For global references, the full data folder path to the global is shown.
Variables Pop-Up Menu
The Variables pop-up menu controls which information is displayed in the Variables List. When debugging 
a function, it looks like this:
When debugging a macro, proc or window macro, the first two items in the popup menu are unavailable.
Macro Variables
The ExampleMacro below illustrates how variables in Macros, Procs or Window procedures are classified 
as locals or globals:

Chapter IV-8 — Debugging
IV-219
Local variables in macros include all items passed as parameters (numerator in this example) and local vari-
ables and local strings (oldDF) whose definitions have been executed, and Igor-created local variables 
created by operations such as WaveStats after the operation has been executed. Note that localStr isn't 
listed, because the command has not yet executed. 
Global variables in macros include all items in the current data folder, whether they are used in the macro 
or not. If the data folder changes because of a SetDataFolder operation, the list of global variables also 
changes. Note that there are no NVAR, SVAR, WAVE or STRUCT references in a macro.
