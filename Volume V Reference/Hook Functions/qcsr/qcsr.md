# qcsr

PutScrapText
V-785
See Also
The FindLevel operation about the /B=box, /T=dx, /P and /Q flags, EdgeStats and the numtype function.
PutScrapText 
PutScrapText textStr
The PutScrapText operation places textStr on the Clipboard (aka “scrap”). This text will be used when the 
user subsequently chooses Paste from the Edit menu.
Details
All contents of the Clipboard (including pictures) are cleared before the text is placed there.
Examples
Put two lines of text into the Clipboard:
String text = "This is the first line.\rAnd this is the second."
PutScrapText text
Empty the Clipboard:
PutScrapText ""
See Also
The GetScrapText function and the SavePICT operation.
pwd
pwd
The pwd operation prints the full path of the current data folder to the history area. It is equivalent to Print 
GetDataFolder(1).
pwd is named after the UNIX "print working directory" command.
See Also
GetDataFolder, cd, Dir, Data Folders on page II-107
q 
q
The q function returns the current column index of the destination wave when used in a multidimensional 
wave assignment statement. The corresponding scaled column index is available as the y function.
Details
Unlike p, outside of a wave assignment statement, q does not act like a normal variable.
See Also
Waveform Arithmetic and Assignments on page II-74.
For other dimensions, the p, r, and s functions.
For scaled dimension indices, the x, y, z and t functions.
qcsr 
qcsr(cursorName [, graphNameStr])
The qcsr function can be used with cursors on images or waterfall plots to return the column number. It can 
also be used with free cursors to return the relative Y coordinate.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
