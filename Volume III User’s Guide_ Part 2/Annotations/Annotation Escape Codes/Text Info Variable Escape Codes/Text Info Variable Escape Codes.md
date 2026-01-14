# Text Info Variable Escape Codes

Chapter III-2 — Annotations
III-55
Tag Escape Codes
Text Info Variable Escape Codes
A text info variable is an internal Igor structure created by Igor. Using the escape codes described in this 
section, you can manipulate text info variables to create sophisticated annotations. These escape codes are 
can be used in any text that supports annotation escape codes.
\sa-dd
Reduces space above line. dd is two digits in units of half points (1/144 inch). Can go 
anywhere in a line.
\sb+dd
Adds extra space below line. dd is two digits in units of half points (1/144 inch). Can 
go anywhere in a line.
\sb-dd
Reduces space below line. dd is two digits in units of half points (1/144 inch). Can go 
anywhere in a line.
\Wtdd
Draws a marker symbol dd using current font size and color.
\Wtddd
Draws a marker symbol ddd using current font size and color.
The marker outline thickness is specified by the one-digit number t with 1, 4, 5, 6, 7 
and 8 giving 0.0, 0.25, 0.5, 1.0, 1.25 and 1.5 points. A t value of 1, which sets the outline 
thickness to zero, is useful only for filled markers as it makes unfilled markers 
disappear.
The marker symbol number is specified by a two-digit number dd or a three-digit 
number ddd. New code should use the three-digit marker.
The three-digit syntax was added in Igor Pro 6.30 to support custom markers. This 
addition causes a two-digit dd escape sequence that is directly followed by a digit to 
be incorrectly interpreted. For example, the sequence:
\W718500 m
was intended to display marker 18 followed by "500 m". It is now interpreted as a 
three-digit marker number (185) followed by "00 m". To fix this, change the two-digit 
marker number to a three-digit marker number by adding a leading zero, like this:
\W7018500 m
Use \k to set the marker stroke color. Use \K to set the marker fill color.
\x+dd
Moves the current X position right by 2*dd percent of the current font max width.
\x-dd
Moves the current X position left by 2*dd percent of the current font max width.
\y+dd
Moves the current Y position up by 2*dd percent of the current font height.
\y-dd
Moves the current Y position down by 2*dd percent of the current font height.
\Znn 
Use font size nn. nn must be exactly two digits.
\Zrnnn
nnn is 3 digit percentage by which to change the current font size. nnn must be exactly 
three digits.
\ON
Inserts the name of the wave to which the tag is attached.
\On
Inserts the name of the trace and its instance number if greater than 0.
\OP
Inserts the point number to which the tag is attached.
\OX
Inserts the X value of the point to which the tag is attached.
\OY
Inserts the Y value of the point to which the tag is attached.
\OZ
Inserts the Z value of the point to which the tag is attached for contour level traces. 
Inserts NaN for other traces.
