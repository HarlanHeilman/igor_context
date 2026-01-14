# time

time
V-1037
Details
If you omit the /W flag, the default tiling area is used. This is the area above your preferred command 
window position. You can set this using MiscCommand BufferCapture Prefs or MiscHistory 
AreaCapture Prefs.
The windows to be tiled are determined by the /WINS, /C, /P, and /O=objTypes flags and by the 
windowNames. If none of these flags are present and there is no windowNames then all windows are tiled.
Otherwise the windows to be tiled are determined as follows:
•
All visible named windows are tiled.
•
All visible windows specified by /WINS are tiled.
•
If the /C flag is present and the command window is visible, the command window is also tiled.
•
If the /P flag is present and the procedure window is visible, the procedure window is also tiled.
•
If the /O=objTypes flag is present, any visible windows specified by objTypes are also tiled.
Examples
To tile all the visible procedure windows, including the main one, use:
TileWindows/P/O=128
// 2^7=128
See Also
The StackWindows operation.
time 
time()
The time function returns a string containing the current local time. The empty parentheses are required.
See Also
The date, date2secs and DateTime functions.
Other bits should always be zero. See Setting Bit Parameters on page IV-12 for details 
about bit settings.
/P
Adds the main procedure window to the windows to be tiled.
/R
Specifies coordinates measured as % of tiling rectangle.
/W=(left,top,right,bottom)
Specifies tiling rectangle on the screen. Coordinates are in points unless /I, /M, or /R 
are specified before /W.
/WINS=windowListStr
Specifies the windows to be tiled using a semicolon-separated list of window names. 
Added in Igor Pro 9.00.
objTypes is a bitwise mask where:
Bit 0:
Graphs
Bit 1:
Tables
Bit 2:
Page layouts
Bit 4:
Notebooks
Bit 6:
Control panels
Bit 7:
Procedure windows
Bit 9:
Help windows
Bit 12:
XOP target windows
Bit 14:
Camera windows
Bit 16:
Gizmo windows
