# Chart

Chart
V-61
Printf "Valid UTF-8 text: U+%04X\r", char2num(str)
// Prints U+2022
Printf "First byte value: %02X\r", char2num(str[0]) & 0xFF
// Prints E2
Printf "Second byte value: %02X\r", char2num(str[1]) & 0xFF
// Prints 80
str = num2char(0xE2, 0) + num2char(0x41, 0)
// Invalid UTF-8 text
Printf "Invalid UTF-8 text: U+%04X\r", char2num(str)
// Prints NaN
str = ""
Printf "Empty string: %g\r", char2num(str)
// Prints NaN
End
See Also
The num2char, str2num and num2str functions.
Text Encodings on page III-459.
Chart 
Chart [/Z] ctrlName [keyword = value [, keyword = value …]]
The Chart operation creates or modifies a chart control. Charts are generally used in conjunction with data 
acquisition. Charts do not have to be connected to a FIFO, but they are not useful until they are.
For information about the state or status of the control, use the ControlInfo operation.
Parameters
ctrlName is the name of the Chart control to be created or changed.
The following keyword=value parameters are supported:
align=alignment
Sets the alignment mode of the control. The alignment mode controls the 
interpretation of the leftOrRight parameter to the pos keyword. The align 
keyword was added in Igor Pro 8.00.
If alignment=0 (default), leftOrRight specifies the position of the left end of the 
control and the left end position remains fixed if the control size is changed.
If alignment=1, leftOrRight specifies the position of the right end of the control and 
the right end position remains fixed if the control size is changed.
chans={ch#, ch#,…}
List of FIFO channel numbers that Chart is to monitor.
color(ch#)=(r,g,b[,a])
Sets the color of the specified trace. r, g, b, and a specify the color and optional 
opacity as RGBA Values.
ctab=colortableName
When a channel is connected to an image strip FIFO channel, the data is displayed 
as an image using this built-in color table. Valid names are the same as used in 
images. Invalid name will result in the default Grays color table being used.
disable=d
fbkRGB=(r,g,b[,a])
Sets frame background color. r, g, b, and a specify the color and optional opacity 
as RGBA Values.
fgRGB=(r,g,b[,a])
Sets foreground color (text, etc.). r, g, b, and a specify the color and optional 
opacity as RGBA Values.
fifo=FIFOName
Sets which named FIFO the chart will monitor. See the NewFIFO operation.
font="fontName"
Sets the font used in the chart, e.g., font="Helvetica".
fsize=s
Sets font size for chart.
Sets user editability of the control.
d=0:
Normal.
d=1:
Hide.
d=2:
Disable user input.
Charts do not change appearance because they are read-
only. When disabled, the hand cursor is not shown.

Chart
V-62
fstyle=fs
gain(ch#)=g
Sets the display gain g of the specified channel relative to nominal. Values greater 
than unity expand the display.
gridRGB=(r,g,b[,a])
Sets grid color. r, g, b, and a specify the color and optional opacity as RGBA 
Values.
help={helpStr}
Specifies help for the control.
helpStr is limited to 1970 bytes (255 in Igor Pro 8 and before).
You can insert a line break by putting “\r” in a quoted string.
jumpTo=p
Jumps to point number p. This works in review mode only.
lineMode(ch#)=lm
mass=m
Sets the “feel” of the chart paper when you move it with the mouse. The larger 
the mass m, the slower the chart responds. Odd values cause the movement of the 
paper to stop the instant the mouse is clicked while even values continue with the 
illusion of mass.
maxDots=md
Controls whether points in a given vertical strip of the chart are displayed as dots 
or as a solid line. See lineMode above. Default is 20.
offset(ch#)=o
Sets the display offset of the specified channel. The offset value o is subtracted 
from the data before the gain is applied.
oMode=om
pbkRGB=(r,g,b[,a])
Sets plot area background color. r, g, b, and a specify the color and optional 
opacity as RGBA Values.
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left corner of the control if its 
alignment mode is 0 or the top/right corner of the control if its alignment mode is 
1. See the align keyword above for details.
ppStrip=pps
Number of data points packed into each vertical strip of the chart.
rSize(ch#)=rs
Sets the relative vertical size allocated to the given channel. Nominal is unity. If 
the value of rs is zero then this channel shares space with the previous channel.
Specifies the font style. fs is a bitwise parameter with each bit controlling one 
aspect of the font style:
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
Sets the display line mode for the given channel.
lm=0:
Dots mode. Draws values as dots. However, if the number of 
dots in a strip exceeds maxDots then Igor draws a vertical line 
from the min to the max of the values packed into the strip.
lm=1:
Lines mode. Draws a vertical line encompassing the min and 
the max of the points in a given strip along with the last point 
of the preceding strip. Since which strip is the preceding strip 
depends on the direction of motion then the appearance may 
slightly shift depending on which direction the chart is 
moving.
lm=2:
Dots mode. Draws values as dots. However, if the number of 
dots in a strip exceeds maxDots then Igor draws a vertical line 
from the min to the max of the values packed into the strip.
Chart operation mode.
om=0:
Live mode.
om=1:
Review mode.
