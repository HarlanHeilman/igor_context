# GetWindow

GetWindow
V-318
GetWindow 
GetWindow [/Z] winName, keyword
The GetWindow operation provides information about the named window or subwindow. Information is 
returned in variables, strings, and waves.
Parameters
winName can be the name of any target window (graph, table, page layout, notebook, control panel, Gizmo, 
camera, or XOP target window) or subwindow. It can also be the title of a procedure window or one of these 
four special keywords:
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Only one of the following keywords may follow winName. The keyword chosen determines the information 
stored in the output variables:
kwTopWin
Specifies the topmost target window.
kwCmdHist
Specifies the command history area.
kwFrameOuter
Specifies the “frame” or “application” window that Igor Pro has only under 
Windows. This is the window that contains Igor’s menus and status bar.
kwFrameInner
Specifies the inside of the same “frame” window under Windows. This is the window 
that all other Igor windows are inside.
active
Sets V_Value to 1 if the window is active or to 0 otherwise. Active usually means 
the window is the frontmost window.
activeSW
Stores the window “path” of currently active subwindow in S_Value. See 
Subwindow Syntax on page III-92 for details on the window hierarchy.
axsize
Reads graph axis area dimensions (where the traces are, including axis standoff) 
into V_left, V_right, V_top, and V_bottom in local coordinates. Dimensions are in 
points.
axsizeDC
Same as axSize but dimensions are in device coordinates (pixels).
backRGB
Sets V_Red, V_Green, V_Blue, and V_Alpha as RGBA Values to the background 
color of the window. The background color is set with ModifyGraph (colors) 
wbRGB, ModifyLayout bgRGB, and Notebook backRGB. Also returns the 
background color of procedure windows and the command/history windows. 
Other windows set these values to 65535 (opaque white).
Added in Igor Pro 7.00.
exterior
Sets V_value to 1 if the window is an exterior panel window or to 0 otherwise. 
Useful for window hook functions that must work for both regular windows and 
exterior panel windows, since exterior panels use their own hook function.
bgRGB
Another name for backRGB.
Added in Igor Pro 7.00.
cbRGB
Sets V_Red, V_Green, V_Blue, and V_Alpha as RGBA Values to the control panel 
area background color of the window in graphs and panel windows, as set by 
ModifyGraph (colors) cbRGB and ModifyPanel cbRGB. Other windows set 
these values to 65535 (opaque white).
Added in Igor Pro 7.00.

GetWindow
V-319
doScroll
If the window is a graph or panel window with scroll bars added by SetWindow 
doScroll, the variable V_value is set to 1.
If the window is a graph or panel window without scroll bars added by 
SetWindow doScroll, the variable V_value is set to 0.
If the window is other than a graph or panel window, an error is generated.
Added in Igor Pro 9.00.
drawLayer
If the specified window is a graph, layout, or panel window then the window's 
current drawing layer is returned in S_value. S_value is set to "" for other 
windows. See Drawing Layers on page III-68.
Added in Igor Pro 7.00.
expand
Graph windows set V_Value to the expand value set by ModifyGraph (general) 
expand=value, a value normally 0 or 1, where 1.5 means 150%.
Notebook, procedure and command windows set V_Value to the magnification, 
normally 100. See the Notebook magnification=m documentation for details.
Layout windows set V_Value to the ModifyLayout mag=m value, usually 0.5 
(50%).
In Igor Pro 9.01 and later, panel windows set V_Value to the expand value set by 
ModifyPanel expand=value, a value normally 0 or 1, where 1.5 means 150%. This 
is the same value returned by PanelResolution(winName)/PanelResolution("").
Table windows set V_Value to 0, panels and other unsupported windows to 
NaN.
Added in Igor Pro 7.00.
file
Works for notebook and procedure windows only.
Returns via S_value a semicolon-separated list containing:
- the file name
- the Mac path to the folder containing the file with a colon at the end
- the name of a symbolic path pointing to that folder, if any
If the window was never saved to a standalone file then "" is returned in S_value. 
If the specified window is not a notebook or procedure window then "" is 
returned in S_value.
gbRGB
Sets V_Red, V_Green, V_Blue, and V_Alpha as RGBA Values to the plot area 
background color of the window in graph windows, as set by ModifyGraph 
(colors) gbRGB. Other windows set these values to 65535 (opaque white).
Use wbRGB to get the color of window background (the area outside of the axes).
Added in Igor Pro 7.00.
gsize
Reads graph outer dimensions into V_left, V_right, V_top, and V_bottom in local 
coordinates. This includes axes but not the tool palette, control bar, or info panel. 
Dimensions are in points.
gsizeDC
Same as gsize but dimensions are in device coordinates (pixels).
hide
Sets V_Value bit 0 if the window or subwindow is hidden.
Sets bit 1 if the host window is minimized.
Sets bit 2 if the subwindow is hidden only because an ancestor window or 
subwindow is hidden. Added in Igor Pro 7.00.
On Macintosh, if you execute MoveWindow 0,0,0,0 to minimize a window to 
the dock, and then you immediately call GetWindow hide, bit 1 may not be 
correctly set because of the delay caused by the animation of the window sliding 
into the dock.

GetWindow
V-320
hook
Copies name of window hook function to S_value. See Unnamed Window Hook 
Functions on page IV-305.
hook(hName)
For the given named hook hName, copies name of window hook function to 
S_value. See Named Window Hook Functions on page IV-295.
logicalpapersize
Returns logical paper size of the page setup associated with the named window 
into V_left, V_right, V_top, and V_bottom. Dimensions are in points.
If the Page Setup dialog uses 100% scaling, these are also the physical dimensions 
of the page. V_left and V_top are 0 and correspond to the left top corner of the 
physical page.
On the Macintosh, using a Scale of 50% multiplies all of these dimensions by 2.
logicalprintablesize
Returns logical printable size of the page setup associated with the named 
window into V_left, V_right, V_top, and V_bottom. Dimensions are in points.
If the Page Setup dialog uses 100% scaling, these are also the physical dimensions 
of the page minus the margins. V_left and V_top are the number of points from 
the left top corner of the physical page to the left top corner of the printable area 
of page.
On the Macintosh, using a page setup scale of 50% multiplies all of these 
dimensions by 2.
magnification
Sets V_Value exactly the same way that expand does.
Added in Igor Pro 7.00.
maximize
Sets V_Value to 1 if the window is maximized, 0 otherwise. On Macintosh, 
V_Value is always 0.
needUpdate
Sets V_Value to 1 if window or subwindow is marked as needing an update.
note
Copies window note to S_value.
psize
Reads graph plot area dimensions (where the traces are) into V_left, V_right, 
V_top, and V_bottom in local coordinates. Dimensions are in points.
psizeDC
Same as psize but dimensions are in device coordinates (pixels).
sizeLimit
Returns the size limits imposed on a window via SetWindow sizeLimit in the 
V_minWidth, V_minHeight, V_maxWidth and V_maxHeight. The values are 
scaled for screen resolution to the same units as GetWindow wsize, which is 
points. Very large limits are returned as INF.
The sizeLimit keyword was added in Igor Pro 7.00.
Also returns a sizeLimit status value in V_Value. 0 means no SetWindow 
sizeLimit command will appear in the window's recreation macro, usually 
because no SetWindow sizeLimit command was applied to the window. 1 
means a SetWindow sizeLimit command will appear in the window's 
recreation macro. -1 means it won't appear because of conflicts with graph 
absolute sizing modes.
title
Gets the title (set by as titleStr with NewPanel, Display, etc., or by the Window 
Control dialog) and puts it into S_value. S_value is set to "" if winName specifies a 
subwindow. See also the wtitle keyword, below.
userdata
Returns the primary (unnamed) user data for a window in S_value. Use 
GetUserData to obtain any named user data.
wavelist
Creates a 3 column text wave called W_WaveList containing a list of waves used 
in the graph in winName. Each wave occupies one row in W_WaveList. This list 
includes all waves that can be in a graph, including the data waves for contour 
plots and images.

GetWindow
V-321
Flags
Details
winName can be the title of a procedure window. If the title contains spaces, use:
GetWindow $"Title With Spaces" wsize
However, if another window has a name which matches the given procedure window title, that window’s 
properties are returned instead of the procedure window.
The wsize parameter is appropriate for all windows.
wbRGB
Another name for backRGB.
Added in Igor Pro 7.00.
wsize
Reads window dimensions into V_left, V_right, V_top, and V_bottom in points 
from the top left of the screen. For subwindows, values are local coordinates in the 
host.
If the window is a graph or panel window with scroll mode turned on using 
SetWindow doScroll, then V_left and V_top are set to zero, and V_right and 
V_bottom are set to the width and height in points of the window content area.
wsizeDC
Same as wsize but dimensions are in local device coordinates (pixels). The origin 
is the top left corner of the host window’s active rectangle.
If the window is a graph or panel window with scroll mode turned on using 
SetWindow doScroll, then V_left and V_top are set to zero, and V_right and 
V_bottom are set to the width and height in pixels of the window content area.
wsizeForControls
Reads window width into V_right and the window height into V_bottom in panel 
units. "Panel units" are scaled so that a control having the dimensions of V_right 
and V_bottom exactly fills the window.
The wsizeForControls keyword was added in Igor Pro 9.00. See Examples below 
for an example.
wsizeOuter
Reads window dimensions into V_left, V_right, V_top, and V_bottom in points 
from the top left of the screen. Dimensions are for the entire window including 
any frame and title bar. For subwindows, values are for the host window.
wsizeOuterDC
Same as wsizeOuter but dimensions are in local device coordinates (pixels). The 
origin is the top left corner of the host window’s active rectangle, so V_top will be 
negative for a window with a title bar. V_left will be negative for windows with 
a frame; windows on Macintosh OS X have no frame, so V_left will be zero.
wsizeRM
Generally the same as wsize, but these are the coordinates that would actually be 
used by a recreation macro except that the coordinates are in points even if the 
window is a panel. Also, if the window is minimized or maximized, the 
coordinates represent the window’s restored location.
On Windows, GetWindow kwFrameOuter wsizeRM returns the pixel 
coordinates of the MDI frame even when the frame is maximized. wsizeDC 
returns 2,2,2,2 in this case.
wtitle
Gets the actual window title displayed in the window's title bar, regardless of 
whether it was set by the user (see the title keyword above) or is the default title 
created by Igor, and puts it into S_value. 
S_value is set to "" if winName specifies a subwindow.
If winName is kwFrameOuter or kwFrameInner, on Macintosh S_Value is set to 
the name of the Igor application. On Windows it is set to the full title of the 
application as seen on the frame's window, which can be altered using 
DoWindow/T kwFrame.
/Z
Suppresses error if, for instance, winName doesn't name an existing window. 
V_flag is set to zero if no error occurred or to a non-zero error code.

GetWindow
V-322
The gsize, psize, gbRGB, and wavelist parameters are appropriate only for graph windows.
The logicalpapersize, logicalprintablesize and expand/magnification parameters are appropriate for all printable 
windows except for control panels and Gizmo plots.
Local Coordinates
“Local coordinates” are relative to the top left of the graph area, regardless of where that is on the screen or 
within the graph window. All dimensions are reported in units of points (1/72 inch) regardless of screen 
resolution. On the Macintosh, this is the same as screen pixels.
Frame Window Coordinates
kwCmdHist, kwFrameInner, and kwFrameOuter may be used with only the wsize keyword.
On Windows computers, kwFrameInner and kwFrameOuter return coordinates into V_left, V_right, V_top, 
and V_bottom. On the Macintosh, they always return 0, because Igor has no frame on the Macintosh.
kwFrameOuter coordinates are the location of the outer edges of Igor’s application window, expressed in 
screen (pixel) coordinates suitable for use with MoveWindow/F to restore, minimize, or maximize the Igor 
application window.
If Igor is currently minimized, kwFrameOuter returns 0 for all values. If maximized, it returns 2 for all 
values. Otherwise, the screen (pixel) coordinates of the frame are returned in V_left, V_right, V_top, and 
V_bottom. This is consistent with MoveWindow/F.
kwFrameInner coordinates, however, are the location of the inner edges of the application window, expressed 
in Igor window coordinates (points) suitable for positioning graphs and other windows with MoveWindow.
If Igor is currently minimized, kwFrameInner returns the inner frame coordinates Igor would have if Igor 
were “restored” with MoveWindow/F 1,1,1,1.
V_left and V_top will always both be 0, and V_Bottom and V_Right will be the maximum visible (or 
potentially visible) window (not screen) coordinates in points.
The Wavelist Keyword
The format of W_WaveList, created with the wavelist keyword, is as follows:
The wave name in column 1 is simply the name of the wave with no path. It may be the same as other waves 
in the list, if there are waves from different data folders.
The partial path in column 2 includes the wave name and can be used with the $ operator to get access to 
the wave.
The special ID number in column 3 has the format ##<number>##. A version of the recreation macro for the 
graph can be generated that uses these ID numbers instead of wave names (see the WinRecreation function). 
This makes it relatively easy to find every occurrence of a particular wave using a function like strsearch.
Examples
// These commands draw a red foreground rectangle framing
// the printable area of a page layout window.
GetWindow Layout0 logicalpapersize
DoWindow/F Layout0
SetDrawLayer/K userFront
SetDrawEnv linefgc=(65535,0,0), fillpat=0
// Transparent fill
DrawRect V_left+1, V_top+1, V_right-1, V_bottom-1
// These commands demonstrate the difference between title and wtitle.
Make/O data=x
Display/N=MyGraph data
GetWindow MyGraph title;Print S_Value
// Prints nothing (S_Value = "")
GetWindow MyGraph wtitle;Print S_Value
// Prints "MyGraph:data"
DoWindow/T MyGraph, "My Title for My Graph"
GetWindow MyGraph title;Print S_Value
// Prints "My Title for My Graph"
GetWindow MyGraph wtitle;Print S_Value
// Prints "My Title for My Graph"
// Create a panel expanded at 200% with a ListBox that fills the entire panel.
String list = CTabList()
// List of color tables
Make/O/T/N=(ItemsInList(list)) tw = StringFromList(p,list)
Column 1
Column 2
Column 3
Wave name
partial path to the wave
special ID number
