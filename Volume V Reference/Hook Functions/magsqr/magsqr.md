# magsqr

MacroPath
V-525
Examples
To list all Macros with three parameters:
Print MacroList("*",";","KIND:2,NPARAMS:3")
To list all Macro, Proc, and Window procedures in the main procedure window whose names start with b:
Print MacroList("b*",";","WIN:Procedure")
See Also
The DisplayProcedure operation and the FunctionList, OperationList, StringFromList, and WinList 
functions.
For details on procedure subtypes, see Procedure Subtypes on page IV-204, as well as Button, CheckBox, 
SetVariable, and PopupMenu.
MacroPath
MacroPath(macroNameStr)
The MacroPath function returns a path to the file containing the named macro.
MacroPath was added in Igor Pro 9.01.
In this section, "macro" includes all types of interpreted procedures, namely procedures introduced by the 
Macro, Proc and Window keywords.
Parameters
If macroNameStr is "", MacroPath returns the path to the currently executing macro or "" if no macro is 
executing.
Otherwise MacroPath returns the path to the named macro or "" if no macro by that name exists.
Details
MacroPath is useful in certain specialized cases, such as if a macro needs access to a lookup table of a large 
number of values.
The most likely use for this is to find the path to the file containing the currently running macro. This is done 
by passing "" for macroNameStr.
The returned path uses Macintosh syntax regardless of the current platform. See Path Separators on page 
III-451 for details.
If the procedure file is a normal standalone procedure file, the returned path will be a full path to the file.
If the macro resides in the built-in procedure window the returned path will be ":Procedure". If the macro 
resides in a packed procedure file, the returned path will be ":<packed procedure window title>".
If MacroPath is called when procedures are in an uncompiled state, it returns ":".
See Also
Macro, Proc, Window, MacroInfo, MacroList, FunctionPath
magsqr 
magsqr(z)
The magsqr function returns the sum of the squares of the real and imaginary parts of the complex number 
z, that is, the magnitude squared.
Examples
Assume waveCmplx is complex and waveReal is real.
waveReal = sqrt(magsqr(waveCmplx))
sets each point of waveReal to the magnitude of the complex points in waveCmplx.
You may get unexpected results if the number of points in waveCmplx differs from the number of points 
in waveReal because of interpolation. See Mismatched Waves on page II-83 for details.
See Also
The cabs function.
