# enoise

EndMacro
V-195
EndMacro 
EndMacro
The EndMacro keyword marks the end of a macro. You can also use End to end a macro.
See Also
The Macro and Window keywords.
EndStructure 
EndStructure
The EndStructure keyword marks the end of a Structure definition.
See Also
The Structure keyword.
endtry 
endtry
The endtry flow control keyword marks the end of a try-catch-endtry flow control construct.
See Also
The try-catch-endtry flow control statement for details.
enoise 
enoise(num [, RNG])
The enoise function returns a random value drawn from a uniform distribution having a range of [-num, 
num).
enoise returns a complex result if num is complex or if it is used in a complex expression. See Use of enoise 
With Complex Numbers on page V-196.
The random number generator is initialized using a seed derived from the system clock when you start Igor. This 
almost guarantees that you will never get the same sequence twice. If you want repeatable “random” numbers, 
use SetRandomSeed.
The optional parameter RNG selects one of three pseudo-random number generators.
If you omit the RNG parameter, enoise uses RNG number 3, named "Xoshiro256**". This random number 
generator was added in Igor Pro 9.00 and is recommended for all new code. In earlier versions of Igor, the 
default was 1 (Linear Congruential Generator).
