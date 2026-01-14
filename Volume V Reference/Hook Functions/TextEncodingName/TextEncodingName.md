# TextEncodingName

TextEncodingCode
V-1028
TextEncodingCode
TextEncodingCode(textEncodingNameStr)
The TextEncodingCode function returns the Igor text encoding code for the named text encoding or 0 if the 
text encoding is unknown.
The TextEncodingCode function was added in Igor Pro 7.00.
Parameters
textEncodingNameStr is an Igor text encoding name as listed under Text Encoding Names and Codes on 
page III-490.
Details
Igor ignores all non-alphanumeric characters in text encoding names so "Shift JIS", "ShiftJIS", "Shift_JIS" and 
"Shift-JIS" are equivalent.
It also ignores leading zeros in numbers embedded in text encoding names so "ISO-8859-1" and "ISO-8859-
01" are equivalent.
TextEncodingCode does a case-insensitive comparison.
See Also
Text Encodings on page III-459, Text Encoding Names and Codes on page III-490, TextEncodingName
TextEncodingName
TextEncodingName(textEncoding, index)
The TextEncodingName function returns one or more text encoding names corresponding to the specified 
text encoding code. The result is returned as a string value.
If textEncoding is not a valid Igor text encoding code or if index is out of range, TextEncodingName returns 
"Unknown".
This function is mainly useful for providing a human-readable string corresponding to a given text 
encoding code for display purposes. You might use it to generate some Internet-compatible text, such as an 
HTML page, if you need a string to specify the charset.
The TextEncodingName function was added in Igor Pro 7.00.
Parameters
textEncoding is an Igor text encoding code as listed under Text Encoding Names and Codes on page III-490.
index specifies which text encoding name you want. A given text encoding can be identified by more than 
one name. Normally you will pass 0 to get the first text encoding name for the specified text encoding code. 
This is the preferred text encoding name. You can pass 1 for the second name, if any, 2 for the third, if any, 
and so on. You can pass -1 to get a semicolon-separated list of all text encoding names for the specified text 
encoding.
Details
Internally Igor has a table of text encoding codes and the corresponding text encoding names. For a given 
code there may be more than one acceptable name. For example, for the code 2 (MacRoman), the names 
"macintosh", "MacRoman" and "x-macroman" are accepted, with "macintosh" being preferred. The 
TextEncodingName function returns a text encoding name from the internal table.
The preferred name is usually the name recognized by the Internet Assigned Numbers Authority (IANA) 
as listed at http://www.iana.org/assignments/character-sets.
Examples
// Get the preferred name for the MacRoman text encoding (2)
String firstName = TextEncodingName(2, 0); Print firstName
// Get the second name for the MacRoman text encoding (2)
String secondName = TextEncodingName(2, 1); Print secondName
// Get a semicolon-separated list of all text encoding names for MacRoman
String names = TextEncodingName(2, -1); Print names
