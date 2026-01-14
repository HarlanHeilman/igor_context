# FunctionPath

FunctionPath
V-287
Return Type and Parameter Type Code Examples
This section shows common values used with the PARAM_N_TYPE and RETURN_N_TYPE keywords:
If /Z is used, add 32768 or 0x8000.
For pass-by-reference parameters, add 4096 or 0x1000.
To list user-defined functions in the main procedure window that have either a Wave or Wave/D first 
parameter, with or without /Z:
Print FunctionList("*",";","KIND:2,PARAM_0_TYPE:-2,WIN:Procedure") // WIN must be last
Examples
To list user-defined fitting functions for two independent variables:
Print FunctionList("*",";","KIND:10,NINDVARS:2")
To list button-control functions that start with the letter b (note that button-control functions are user-
defined):
Print FunctionList("b*",";","KIND:2,SUBTYPE:ButtonControl")
See Also
Independent Modules on page IV-238, Multiple Return Syntax on page IV-36, Procedure Subtypes on 
page IV-204.
FunctionInfo, FuncRefInfo, MacroList, OperationList, StringFromList, WinList, DisplayProcedure
FunctionPath 
FunctionPath(functionNameStr)
The FunctionPath function returns a path to the file containing the named function. This is useful in certain 
specialized cases, such as if a function needs access to a lookup table of a large number of values.
The most likely use for this is to find the path to the file containing the currently running function. This is 
done by passing "" for functionNameStr, as illustrated in the example below.
The returned path uses Macintosh syntax regardless of the current platform. See Path Separators on page 
III-451 for details.
If the procedure file is a normal standalone procedure file, the returned path will be a full path to the file.
If the function resides in the built-in procedure window the returned path will be ":Procedure". If the 
function resides in a packed procedure file, the returned path will be ":<packed procedure window 
title>".
If FunctionPath is called when procedures are in an uncompiled state, it returns “:”.
Parameters
If functionNameStr is "", FunctionPath returns the path to the currently executing function or "" if no 
function is executing.
Any text wave
-4
Any WAVE/WAVE
-5
Any WAVE/DF
-6
Any real-valued numeric wave
-2
Any complex numeric wave
-3
Any text wave
-4
Wave/S
16386
0x4000 + 2 
Wave or Wave/D
16388
0x4000 + 4
Wave/C or Wave/D/C
16389
0x4000 + 4 + 1
Wave/T
16384
0x4000 + 0
