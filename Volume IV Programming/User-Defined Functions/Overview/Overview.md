# Overview

Chapter IV-3 — User-Defined Functions
IV-30
Overview
Most of Igor programming consists of writing user-defined functions.
A function has zero or more parameters. You can use local variables to store intermediate results. The func-
tion body consists of Igor operations, assignment statements, flow control statements, and calls to other 
functions.
A function can return a numeric, string, wave reference or data folder reference result. It can also have a 
side-effect, such as creating a wave or creating a graph.
Before we dive into the technical details, here is an informal look at some simple examples.
Function Hypotenuse(side1, side2)
Variable side1, side2
Variable hyp
hyp = sqrt(side1^2 + side2^2)
return hyp
End
The Hypotenuse function takes two numeric parameters and returns a numeric result. “hyp” is a local vari-
able and sqrt is a built-in function. You could test Hypotenuse by pasting it into the built-in Procedure 
window and executing the following statement in the command line:
Print Hypotenuse(3, 4)
Now let’s look at a function that deals with text strings.
Function/S FirstStr(str1, str2)
String str1, str2
String result
if (CmpStr(str1,str2) < 0)
result = str1
else
result = str2
endif
return result
End
The FirstStr function takes two string parameters and returns the string that is first in alphabetical order. CmpStr 
is a built-in function. You could test FirstStr by executing pasting it into the built-in Procedure window the 
following statement in the command line:
Print FirstStr("ABC", "BCD")
Now a function that deals with waves.
Function CreateRatioOfWaves(w1, w2, nameOfOutputWave)
WAVE w1, w2
String nameOfOutputWave
Duplicate/O w1, $nameOfOutputWave
WAVE wOut = $nameOfOutputWave
wOut = w1 / w2
End
The CreateRatioOfWaves function takes two wave parameters and a string parameter. The string is the 
name to use for a new wave, created by duplicating one of the input waves. The “WAVE wOut” statement 
creates a wave reference for use in the following assignment statement. This function has no direct result 
(no return statement) but has the side-effect of creating a new wave.
