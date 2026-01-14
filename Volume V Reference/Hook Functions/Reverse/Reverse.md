# Reverse

ResumeUpdate
V-809
ResumeUpdate 
ResumeUpdate
The ResumeUpdate operation cancels the corresponding PauseUpdate.
This operation is of use in macros. It is not allowed from the command line. It is allowed but has no effect 
in user-defined functions. During execution of a user-defined function, windows update only when you 
explicitly call the DoUpdate operation.
See Also
The DelayUpdate, DoUpdate, and PauseUpdate operations.
return 
return [expression]
The return flow control keyword immediately stops execution of the current procedure. If called by another 
procedure, it returns expression and control to the calling procedure.
Functions can return only a single value directly to the calling procedure with a return statement. The 
return value must be compatible with the function type. A function may contain any number of return 
statements; only the first one encountered during procedure execution is evaluated.
A macro has no return value, so return simply quits the macro.
See Also
The Return Statement on page IV-35.
Reverse 
Reverse [type flags][/DIM=d /P] waveA [/D = destWaveA][, waveB [/D = destWaveB][, …]]
The Reverse operation reverses data in a wave in a specified dimension. It does not accept text waves.
Flags
Type Flags (used only in functions)
Reverse also can use various type flags in user functions to specify the type of destination wave reference 
variables. These type flags do not need to be used except when it is needed to match another wave reference 
variable of the same name or to identify what kind of expression to compile for a wave assignment. See 
WAVE Reference Types on page IV-73 and WAVE Reference Type Flags on page IV-74 for a complete list 
of type flags and further details.
Wave Parameters
Details
If the optional /D = destWave flag is omitted, then the wave is reversed in place.
See Also
Sorting on page III-132, Sort, SortColumns
/DIM = d
Specifies the wave dimension to reverse.
d=-1: Treats entire wave as 1D (default).
For d=0, 1, …, operates along rows, columns, etc.
/P
Suppresses adjustment of dimension scaling. Without /P the scaled dimension value 
of reversed points remains the same.
Note:
All wave parameters must follow wave in the command. All wave parameter flags and 
type flags must appear immediately after the operation name (Reverse).
/D=destWave
Specifies the name of the wave to hold the reversed data. It creates destWave if it does not 
already exist or overwrites it if it exists.
