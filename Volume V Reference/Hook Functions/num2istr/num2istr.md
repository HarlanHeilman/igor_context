# num2istr

num2char
V-713
Notebook $nb, findSpecialCharacter={"Action0",1}
// Select action
Notebook $nb, frame=1
// Set frame
See Also
Chapter III-1, Notebooks.
The Notebook, NewNotebook, and OpenNotebook operations; the SpecialCharacterInfo and 
SpecialCharacterList functions.
num2char 
num2char(num [, options)
The num2char function returns a string containing a character.
The options parameter was added in Igor Pro 7.00 and defaults to 0.
As of Igor7, Igor represents text internally as UTF-8, a form of Unicode. Previously it represented text as 
system text encoding. Because of this change, the behavior of num2char is complicated.
Recommended use of num2char in Igor7 or later
If num is a Unicode code point, pass 0 for options and num2char will return a UTF-8 string containing the 
character for the Unicode code point represented by num.
If you want a string containing a single byte, even though it may not be a valid UTF-8 string, pass 1 for 
options and num2char will return a string containing the single byte whose value is num, provided that num 
is between 0 and 255.
Detailed description of num2char in Igor7 or later
If num is between 0 and 127, num2char returns a string containing a single byte whose value is num. This 
represents an ASCII character.
If num is between 128 and 255 and options is 1, num2char returns a string containing a single byte whose 
value is num. This is not valid UTF-8 text, but it is consistent with the behavior of num2char in Igor6.
If num is between 128 and 255 and options is 0 or omitted, num2char returns the UTF-8 representation of the 
character for the Unicode code point represented by num.
If num is greater than 255, num2char returns the UTF-8 representation of the character for the Unicode code 
point represented by num regardless of the value of options .
If you provide the options parameter, it must be either 0 or 1. Other values may be used for other purposes 
in the future.
Examples
Print num2char(65)
// Prints A
Print num2char(97)
// Prints a
Print num2char(0xF7)
// Prints division sign
Print num2char(0xF7,0)
// Prints division sign
Print num2char(0xF7,1)
// Prints missing character symbol
Print num2char(0x0127)
// Prints small letter h with stroke (h-bar)
Print num2char(0x0127,0)
// Prints small letter h with stroke (h-bar)
Print num2char(0x0127,1)
// Prints small letter h with stroke (h-bar)
// In the case of num2char(0xF7,1),num2char returns a string containing
// a single byte whose value is 0xF7. This is not a valid UTF-8 string.
See Also
The char2num, str2num and num2str functions.
Text Encodings on page III-459.
num2istr 
num2istr(num)
The num2istr function returns a string representing num after rounding to the nearest integer.
