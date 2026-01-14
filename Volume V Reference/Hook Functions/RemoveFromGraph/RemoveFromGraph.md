# RemoveFromGraph

RemoveEnding
V-792
RemoveEnding 
RemoveEnding(str [, endingStr])
The RemoveEnding function removes one character from the end of str, or it removes the endingStr from 
the end of str.
The RemoveEnding function returns str with endingStr removed from the end. If you omit endingStr, it 
returns str with one grapheme removed from the end.
Details
If you specify endingStr, RemoveEnding compares it to the end of str using case-insensitive comparison. If 
there is a match, RemoveEnding returns the contents of str up to endingStr. If there is no match, 
RemoveEnding returns the entirety of str.
If you omit endingStr, RemoveEnding returns str with the last grapheme removed. A grapheme is whatever 
visually appears to be one character even if it consists of more than one character. In "ABC", the last 
grapheme is "C" which is also the last character. In "ABC", "C" consists of two characters: a C character and 
a "combining cedilla" character; RemoveEnding removes "C" which is the last grapheme.
Examples
Print RemoveEnding("123") 
// Prints "12"
Print RemoveEnding("ABC") 
// Prints "AB"
Print RemoveEnding("no semi" , ";")
// Prints "no semi"
Print RemoveEnding("trailing semi;" , ";")
// Prints "trailing semi"
Print RemoveEnding("file.txt" , ".TXT") 
// Prints "file"
See Also
The CmpStr and ParseFilePath functions.
RemoveFromGizmo 
RemoveFromGizmo [flags]
The RemoveFromGizmo operation removes the specified object from the specified list and optionally 
performs an update.
Documentation for the RemoveFromGizmo operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "RemoveFromGizmo"
RemoveFromGraph 
RemoveFromGraph [/W=winName/Z] traceName [, traceName]…
The RemoveFromGraph operation removes the specified wave traces from the target or named graph. A 
trace is a representation of the data in a wave, usually connected line segments.
Parameters
traceName is usually just the name of a wave.
More generally, traceName is a wave name, optionally followed by the # character and an instance number 
- for example, wave0#1. See Instance Notation on page IV-20 for details.
