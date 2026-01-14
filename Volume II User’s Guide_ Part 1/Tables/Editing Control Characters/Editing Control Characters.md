# Editing Control Characters

Chapter II-12 — Tables
II-260
If you click a cell containing invalid text, Igor displays a yellow warning icon. If you attempt to edit the cell 
contents, Igor displays a warning dialog.
When the yellow warning icon is visible, the entry line works in a special mode. Each invalid byte in the cell 
is represented by a \x escape code. In the example above, if you click the cell representing point 1 of the wave, 
Igor displays \xFE in the entry area.
While editing the text, in most cases you will want to remove the escape sequences.
If you accept the text in the entry area, Igor converts any remaining \x escape sequences back to the bytes 
which they represent. In the example above, assuming that you started the editing process, made no changes 
in the entry line, and accepted the text, the contents of the cell would be the same after editing as they were 
before.
This use of escape sequences in tables applies only when the yellow warning icon is visible, indicating that the 
cell contained invalid text when you selected it. It applies only to \x escape sequences, not to other escape 
sequences such as \t (tab), \r (carriage-return) or \n (linefeed). If the yellow warning icon is not visible, there 
is no special treatment of escape sequences.
For expert debugging purposes, you can get a hex dump of text wave and dimension label cell contents by 
double-clicking the yellow warning icon. You can also get a hex dump whether the warning icon is visible or 
not by pressing Cmd (Macintosh) or Ctrl (Windows) and double-clicking a cell. The hex dump is printed in the 
history area of the command window.
See also Chapter III-16, Text Encodings, Wave Text Encodings on page III-472.
Editing Control Characters
Control characters are special non-printing characters created in olden times for controlling teletype machines 
and similar equipment. The ASCII codes for control characters, expressed as hexadecimal, fall in the range 
0x00 to 0x1F, except for 0x7F which is the delete control character.
Other than tab (0x09), CR (carriage-return-0x0D) and LF (linefeed-0x0A), control characters have little use and 
rarely appear in modern computer text. When they do appear, it is often the result of an error or bug. Null 
(0x00) is used internally in many programs to mean “end-of-string” but should not appear in text documents.
In nearly all computer fonts, control characters are displayed as blanks. This makes it difficult to recognize 
and edit them, if they happen to appear in text whether on purpose or by error.
When Igor displays a control character in a table cell, it displays a “stand-in” symbol so that you can see what 
is there instead of seeing a blank. Here are some examples:
If you click a cell containing a control character, Igor displays a yellow warning icon. If you attempt to edit the 
cell contents, Igor displays a warning dialog.
When the yellow warning icon is visible, the entry line works in a special mode. If you edit and accept the text 
in the entry line, Igor converts any remaining stand-in symbols back to the control characters which they rep-
resent.
Character
ASCII Code
Stand-in Symbol (Unicode)
Tab
0x09
→ (U+2192)
CR
0x0D
 (U+21B5)
LF
0x0A
¬ (U+00AC)
CRLF
0x0D, 0x0A
¶ (U+00B6)
Null
0x00
NUL (U+2400)
Escape
0x1B
ESC (U+241B)
