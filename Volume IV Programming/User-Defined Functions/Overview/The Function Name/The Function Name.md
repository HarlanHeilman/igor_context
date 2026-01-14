# The Function Name

Chapter IV-3 — User-Defined Functions
IV-31
Here are some commands to test CreateRatioOfWaves:
Make test1 = {1, 2, 3}, test2 = {2, 3, 4}
CreateRatioOfWaves(test1, test2, "ratio")
Edit test1, test2, ratio
Function Syntax
The basic syntax of a function is:
Function <Name> (<Parameter list> [<Optional Parameters>]) [:<Subtype>]
<Parameter declarations>
<Local variable declarations>
<Body code>
<Return statement>
End
Here is an example:
Function Hypotenuse(side1, side2)
Variable side1, side2
// Parameter declaration
Variable hyp
// Local variable declaration
hyp = sqrt( side1^2 + side2^2 )
// Body code
return hyp
// Return statement
End
You could test this function from the command line using one of these commands:
Print Hypotenuse(3,4)
Variable/G result = Hypotenuse(3,4); Print result
As shown above, the function returns a real, numeric result. The Function keyword can be followed by a 
flag that specifies a different result type.
The /D flag is obsolete because all calculations are now performed in double precision. However, it is still 
permitted.
The Function Name
The names of functions must follow the standard Igor naming conventions. Names can consist of up to 255 
characters. Only ASCII characters are allowed. The first character must be alphabetic while the remaining 
characters can include alphabetic and numeric characters and the underscore character. Names must not 
conflict with the names of other Igor objects, functions or operations. Names in Igor are case insensitive.
Prior to Igor Pro 8.00, function names were limited to 31 bytes. If you use long function names, your proce-
dures will require Igor Pro 8.00 or later.
Flag
Return Value Type
/D
Double precision number (obsolete)
/C
Complex number
/S
String
/WAVE
Wave reference
/DF
Data folder reference
