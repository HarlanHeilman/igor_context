# General Escape Codes

Chapter III-2 — Annotations
III-54
General Escape Codes
These escape codes are can be used in any text that supports annotation escape codes:
\B
Subscript.
\F'fontName'
Use the specified font (e.g., \F'Helvetica').
\fdd
See Setting Bit Parameters on page IV-12 for details about bit settings.
\JR
Right align text.
\JC
Center align text.
\JL
Left align text.
\K(r,g,b)
Use specified color for text. r, g and b are integers from 0 to 65535.
You can optionally include a fourth alpha parameter which specifies opacity in the 
range 0 to 65535.
\K also sets the marker fill color for markers added by \W. For setting the marker 
stroke color, use \k.
\KB(r,g,b)
Use specified color for text background. r, g and b are integers from 0 to 65535.
You can optionally include a fourth alpha parameter which specifies opacity in the 
range 0 to 65535.
Use \KB0; to turn background color off.
\KB was added in Igor Pro 9.00.
\k(r,g,b)
Use specified color for marker stroke (line color). r, g and b are integers from 0 to 
65535. Use before \Wtdd to change marker stroke color from the default of black 
(0,0,0).
You can optionally include a fourth alpha parameter which specifies opacity in the 
range 0 to 65535.
For setting the marker fill color for markers added by \W, use \K.
\Ldtss
Draws a line from the x position specified in text info variable d to the current x 
position. Uses current text color. Thickness is encoded by digit t with values of 4,5,6 
and 7 giving 0.25, 0.5, 1.0 and 1.5 pt. Line style is specified by 2 digit number ss.
\M
Use normal (main) script (reverts to main line and size).
\$PICT$name=pictName$/PICT$
Inserts specified picture. pictName can be a ProcPict or the name of a picture as listed 
in the MiscPictures dialog. This is useful for inserting math equations created by 
another program.
\$WMTEX$ formula $/WMTEX$
Inserts a math equation using a subset of LaTeX. See Igor TeX for details.
\S
Superscript.
\sa+dd
Adds extra space above line. dd is two digits in units of half points (1/144 inch). Can 
go anywhere in a line.
dd is a bitwise parameter with each bit controlling one aspect of the font style 
as follows:
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
