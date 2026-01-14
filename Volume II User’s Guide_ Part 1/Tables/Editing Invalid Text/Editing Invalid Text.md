# Editing Invalid Text

Chapter II-12 — Tables
II-259
When the dialog's text entry area includes one or more terminators, buttons appear that allow you to 
change terminators:
You can also enter control characters by executing a command. For example:
textWave0[0] = "Hello\tGoodbye"
// Text with tab character
Use \t for tab, \r for carriage-return, and \n for linefeed.
You can examine what is in a text wave by printing it from the command line:
Print textWave0
This displays tabs, carriage-returns and linefeeds using escape sequences.
Editing Invalid Text
Some patterns of bytes are invalid in some text encodings. For example, this command creates a UTF-8 text 
wave with invalid text:
// "\xFE" represents a single byte with value 0xFE
Make/O/T test = {"A", "\xFE", "C"}
Point 1 of the wave is invalid because, in UTF-8, any byte outside the range 0x00..0x7F must be part of a multi-
byte character. Invalid bytes are displayed in table cells using the Unicode replacement character.
The most likely way for this situation to arise is if you have a text wave containing MacRoman, Windows-1252 
or Shift JIS text but the wave's text encoding is mistakenly set to UTF-8. In this case, you can either edit the 
wave to remove the invalid text or correct Igor's notion of the wave's text encoding using MiscText Encod-
ingsSet Wave Text Encoding. In this section we assume that you want to edit the wave.
¬
Linefeed (LF)
LF is the Unix-standard line terminator. Text for use with Unix programs 
should have LF terminators.
¶
Carriage-return/linefeed (CRLF)
CRLF is the Windows-standard line terminator. Text for use with 
Windows programs should have CRLF terminators.
