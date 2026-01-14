# Using $ Examples

Chapter IV-3 — User-Defined Functions
IV-63
The NVAR, SVAR and WAVE references are necessary in functions so that the compiler can identify the 
kind of object. This is explained under Accessing Global Variables and Waves on page IV-65.
Using $ to Refer to a Window
A number of Igor operations modify or create windows, and optionally take the name of a window. You 
need to use a string variable if the window name is not determined until run time but must convert the 
string into a name using $.
For instance, this function creates a graph using a name specified by the calling function:
Function DisplayXY(xWave, yWave, graphNameStr)
Wave xWave, yWave
String graphNameStr
// Contains name to use for the new graph
Display /N=$graphNameStr yWave vs xWave
End
The $ operator in /N=$graphNameStr converts the contents of the string graphNameStr into a graph name 
as required by the Display operation /N flag. If you forget $, the command would be:
Display /N=graphNameStr yWave vs xWave
This would create a graph literally named graphNameStr.
Using $ In a Data Folder Path
$ can also be used to convert a string to a name in a data folder path. This is used when one of many data 
folders must be selected algorithmically.
Assume you have a string variable named dfName that tells you in which data folder a wave should be cre-
ated. You can write:
Make/O root:$(dfName):wave0
The parentheses are necessary because the $ operator has low precedence.
Using $ Examples
This function illustrates various uses of $ in user-defined functions:
Function Demo()
 String s = "wave0"
// A string containing a name
// Make requires a name, not a string
Make/O $s
// A wave declaration requires a name on the righthand side, not a string
WAVE w = $s
// w is a wave reference
// Display requires a wave reference
Display w
// ModifyGraph requires a trace name, not a string or a wave reference 
ModifyGraph mode($s) = 0
AppendToGraph w
// Add another trace showing wave0
// #1 is "instance notation" to distinguish multiple traces from same wave
String t = "wave0#1"
// ModifyGraph requires a trace name, not a string or a wave reference
