# Symbol Font

Chapter III-16 — Text Encodings
III-491
Binary is not a real text encoding. Rather it marks data stored in a text wave as containing binary rather than 
text. See Text Waves Containing Binary Data on page III-475 for details.
Symbol Font
Igor Pro 6 and before used "system text encoding", typically MacRoman on Macintosh and Windows-1252 
on Windows. These text encodings can represent a maximum of 256 characters because each character is 
represented by a single byte and a single byte can represent only 256 unique values from 0 to 255.
Most Greek letters can not be represented in MacRoman or Windows-1252. Because of that, people resorted 
to Symbol font when they wanted to display special characters, such as Greek letters. In system text encod-
ing, Symbol font is treated specially. For example, the byte value 0x61 (61 hex, 97 decimal), which is nor-
mally interpreted as "small letter a", is interpreted in Symbol font as "Greek small letter alpha".
Thus, in Igor6, to create a textbox that displayed a Greek small letter alpha, you needed to execute this:
TextBox "\\F'Symbol'a"
Because Igor now uses Unicode, you have at your disposal a wide range of characters of all types without 
changing fonts. To create a textbox that displays a Greek small letter alpha, you simply execute this:
Windows-949, ks_c_5601-1987
41
Windows Korean
ISO-2022-KR
42
Korean text encoding not used on Macintosh or Windows
x-mac-arabic
50
Macintosh Arabic. NOT SUPPORTED.
Windows-1256
51
Windows Arabic
x-mac-hebrew
55
Macintosh Hebrew
Windows-1255
56
Windows Hebrew
x-mac-greek
60
Macintosh Greek
Windows-1253
61
Windows Greek
x-mac-cyrillic
65
Macintosh Cyrillic
Windows-1251
66
Windows Cyrillic
x-mac-thai
70
Macintosh Thai. NOT SUPPORTED.
Windows-874
71
Windows Thai
x-mac-ce
80
Macintosh Central European
Windows-1250
81
Windows Central European
x-mac-turkish
90
Macintosh Turkish
Windows-1254
91
Windows Turkish
UTF-16BE
100
UTF-16, big-endian
UTF-16LE
101
UTF-16, little-endian
UTF-32BE
102
UTF-32, big-endian
UTF-32LE
103
UTF-32, little-endian
ISO-8859-1, Latin1
120
ISO standard western European
Symbol
150
Used by Symbol font
Binary
255
Indicates data is really binary, not text
Text Encoding Name
Code
Notes
