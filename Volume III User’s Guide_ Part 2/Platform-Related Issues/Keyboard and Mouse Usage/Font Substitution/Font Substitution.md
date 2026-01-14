# Font Substitution

Chapter III-15 — Platform-Related Issues
III-453
Command Window Input
This table compares command window mouse actions:
Cross-Platform Text and Fonts
Text Encoding Compatibility
Prior to Igor7, Igor used system text encoding. On Macintosh, this was usually MacRoman. On Windows, it 
was usually Windows-1252. On Japanese systems, it was Shift JIS on both platforms.
As of Igor7, Igor uses UTF-8 text encoding internally on both Macintosh and Windows.
When opening old files, Igor must convert from the file’s text encoding to UTF-8 for storage in memory.
Dealing with various text encodings is a complex issue. See Text Encodings on page III-459 for details.
Carriage Returns and Linefeeds
The character or character pattern that marks the end of a line of text in a plain text file is called the “line 
terminator”. There are three common line terminators, carriage return (CR, ASCII 13, used on old Macin-
tosh systems), linefeed (LF, ASCII 10, used on Unix) and carriage return plus linefeed (CRLF, used on Win-
dows).
When Igor Pro opens a text file (procedure file, plain text notebook or plain text data file), it accepts CR, LF 
or CRLF as the line terminator.
If you create a new procedure file or plain text notebook, Igor writes LF on Mac OS and CRLF on Windows. 
If you open an existing plain text file, edit it and then save it, Igor preserves the original terminator as deter-
mined by examining the first line in the file.
By default, the FReadLine operation treats CR, LF, or CRLF as terminators. Use this to write a procedure 
that can read lines from a text file without caring whether it is a Macintosh, Windows, or Unix file.
Font Substitution
When a font specified in a command or document is not installed, Igor applies font substitution to choose 
an installed font to use in place of the missing font. Dealing with these missing fonts often occurs when 
transferring a Windows-originated document to Macintosh or vice versa.
Igor employs two levels of font substitution: user-level editable substitution and built-in uneditable substitution.
The first level is an optional user-level font substitution facility that you will usually encounter for the first 
time when Igor displays the Substitute Font Dialog while opening an experiment or file. Use the dialog to 
choose a temporary or permanent replacement for the missing font:
Action
Macintosh
Windows
Copy history selection to command line
Option-click
Alt+click
Copy history to command and start execution
Command-Option-click
Ctrl+Alt+click
Invoke contextual menu
Control-click
Right-click
