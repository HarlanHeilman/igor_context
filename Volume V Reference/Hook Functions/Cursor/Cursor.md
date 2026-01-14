# Cursor

Cursor
V-121
Details
Once start has been issued, the FIFO can accept no further commands except stop.
The FIFO must be in the valid state for you to access its data (using a chart control or using the FIFO2Wave 
operation). When you create a FIFO, using NewFIFO, it is initially invalid. It becomes valid when you issue the 
start command via the CtrlFIFO operation. It remains valid until you change a FIFO parameter using CtrlFIFO.
FIFOs are used for data acquisition.
See Also
The NewFIFO and FIFO2Wave operations, and FIFOs and Charts on page IV-313.
Cursor 
Cursor [flags] cursorName traceName x_value
Cursor /F[flags] cursorName traceName x_value, y_value
Cursor /K[/W=graphName] cursorName
Cursor /I[/F][flags] cursorName imageName x_value, y_value
Cursor /M[flags] cursorName
The Cursor operation moves the cursor specified by cursorName onto the named trace at the point whose X 
value is x_value. or the coordinates of an image pixel or free cursor position at x_value and y_value.
Parameters
cursorName is one of ten cursors A through J.
Flags
file=oRefNum
File reference number for the FIFO’s output file. You obtain this reference number 
from the Open operation used to create the file.
note=noteStr
Stores the note string in the file header. It is limited to 255 bytes.
rdfile=rRefNum
Like rfile but for review of raw data (use Open/R command). Channel data must 
match raw data in file. Offset from start of file to start of data can be provided 
using doffset given in same command. If data does not extend all the way to the 
end of the file, then the number of bytes of data can be provided using dsize in 
the same command.
rfile=rRefNum
File reference number for the FIFO’s review file. Use a review file when you are 
using a FIFO to review existing data. Obtain the reference number from the 
Open/R operation used to open the file. File may be either unified header/data or 
a split format where the header contains the name of a file containing the raw 
data.
size=s
Sets number of chunks in the FIFO. The default is 10000. A chunk of data consists 
of a single data point from each of the FIFO’s channels.
start
Starts the FIFO running by setting the time/date in the FIFO header, writing the 
header to the output file and marking the FIFO active.
stop
Stops the FIFO by flushing data to disk and marking the FIFO as inactive.
swap
Used only with rdfile. Indicates that the raw data file requires byte-swapping 
when it is read. This would be the case if you are running on a Macintosh, reading 
a binary file from a PC, or vice versa.
/A=a
Activates (a=1) or deactivates (a=0) the cursor. Active cursors move with arrow keys 
or the cursor panel.
/C=(r,g,b[,a])
Sets the cursor color. r, g, b, and a specify the color and optional opacity as RGBA 
Values. The default is opaque black.

Cursor
V-122
/DF=format
/DGTS=nd
Sets the number of digits precision to use when a cursor value is displayed in the 
Graph Info Panel (see Info Panel and Cursors on page II-319). The number of digits 
is set by nd and must be a value from 1 to 15.
The /DGTS flag was added in Igor Pro 9.00.
/F
Cursor roams free. The trace or image provides the axis pair that defines x and y 
coordinates for the setting and readout. Use /P to set in relative coordinates, where 0,0 is 
the top left corner of the rectangle defined by the axes and 1,1 is the right bottom corner.
/H=h
/I
Places cursor on specified image.
/K
Removes the named cursor from the top graph.
/L=lStyle
/M
Modifies properties without having to specify trace or image coordinates. Does not 
work with the /F or /I flags.
/N=noKill
/NUML=n
Used in conjunction with /H when h is non-zero. Sets the number of crosshair lines to 
draw. n must be between 1 and 3. When n is greater than 1, the line separation is set 
by the /T=t flag. If n = 2 or 3 and t is less than 3, the line appears as if n is 1. If n = 3 and 
t is less than 5, the appearance reverts to n = 2. Lines are symmetrically disposed 
around the cursor position. When n = 3, t sets the separation of the outer pair of lines.
/NUML was added in Igor Pro 7.00.
Sets the format to use when displaying date/time data in the Graph Info Panel (see 
Info Panel and Cursors on page II-319).
The /DF flag was added in Igor Pro 9.00.
The values for format are:
0:
Compact format: YYMMDD HHMM.
1:
Compact format with seconds added: YYMMDD HHMMSS. The 
seconds portion may optionally show fractions of seconds - see the 
/SDGT flag below.
2:
Date and Time using a more readable format, the same format you get 
on a graph axis if you select the "short date" format. Time is formatted as 
HH:MM.
3:
Date and Time with seconds added. Time is formatted as HH:MM:SS. The 
seconds portion may optionally show fractions of seconds - see the /SDGT 
flag below.
4:
Time without the date. Time is formatted as HH:MM:SS. May optionally 
show fractions of seconds - see the /SDGT flag below.
Specifies crosshairs on cursors.
h =0:
Full crosshairs off.
h =1:
Full crosshairs on.
h =2:
Vertical hairline.
h =3:
Horizontal hairline.
Line style for crosshairs (full or small).
lStyle=0:
Solid lines.
lStyle=1:
Alternating color dash.
Determines if the cursor is removed ("killed") if the user drags it outside of the 
plot area:
noKill=0:
Remove the cursor (default).
noKill=1:
Do not remove the cursor.

Cursor
V-123
Details
Usually traceName is the same as the name of the wave displayed by that trace, but it could be a name in 
instance notation. See ModifyGraph (traces) and Instance Notation on page IV-20 for discussions of trace 
names and instance notation.
A string containing traceName can be used with the $ operator to specify the trace name.
x_value is an X value in terms of the X scaling of the wave displayed by traceName. If traceName is graphed 
as an XY pair, then x_value is not the same as the X axis coordinate. Since the X scaling is ignored when 
displaying an XY pair in a graph, we recommend you use the /P flag and use a point number for x_value.
cursorName is a name, not a string.
To get a cursor readout, choose ShowInfo from the Graph menu.
If a cursor is attached to a trace that represents a subrange of a wave, the /P flag causes x_value to be 
interpreted as a trace point number, not as a wave point number. For instance, if the trace was created by 
the command
Display yWave[4,25;3]
/P
Interpret x_value as a point number rather than an X value. If the cursor is on a trace 
representing a subrange of a wave, the point numbers are “trace” point numbers. See 
Details below.
When used with the /I flag, x_value and y_value are row and column numbers.
When used with the /F flag, x_value and y_value are relative graph coordinates (0-1).
/S=s
/SDGT=nd
Set the number of places to the right of the decimal point to be displayed in the Graph 
Info Panel (see Info Panel and Cursors on page II-319) when the display is in one of 
the date/time modes that includes seconds, or if the corresponding axis is showing 
elapsed time. nd is a value from 0 to 6.
The /SDGT flag was added in Igor Pro 9.00.
/T=t
Sets the thickness of crosshair lines for /H when h is non-zero. If /NUML sets the 
number of lines greater than 1 then /T sets the separation of the outer pair of lines.
t is the line thickness or separation distance in units of pixels. The default is /T=1.
The form /T={mode, t1, t2} provides finer control.
/T was added in Igor Pro 7.00.
/T={mode,t1,t2}
Sets the thickness of crosshair lines for /H when h is non-zero. If /NUML sets the 
number of lines greater than 1 then /T sets the separation of the outer pair of lines.
If mode=1 then t1 and t2 are in units of screen pixels. t1 is the vertical line thickness or 
separation distance and t2 is the horizontal line thickness or separation distance.
The default crosshair appearance is equivalent to /T={1,1,1}.
If mode=0 then t1 and t2 are in units of axis coordinates and consequently track 
changes in axis range and graph size. Normally t1 is the vertical line thickness or 
separation distance and t2 is the horizontal line thickness or separation distance but 
they are swapped if the trace or graph is in swap XY mode.
/T was added in Igor Pro 7.00.
/W=graphName
Specifies a particular named graph window or subwindow. When omitted, action 
will affect the active window or subwindow.
When identifying a subwindow with graphName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
Sets cursor style.
s=0:
Original square or circle.
s=1:
Small crosshair with letter.
s=2:
Small crosshair without letter.
