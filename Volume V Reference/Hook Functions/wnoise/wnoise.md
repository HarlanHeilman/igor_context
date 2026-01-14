# wnoise

WMTooltipHookStruct
V-1113
WMTooltipHookStruct
See Tooltip Hook Functions on page IV-310 for further explanation of WMTooltipHookStruct.
Structure WMTooltipHookStruct
char winName[MAX_WIN_PATH+1]
// Host window name or subwindow path
double ticks
// Tick count when event happened
STRUCT Rect winRect
// Local coordinates of the window or subwindow
STRUCT Point mouseLoc
// Mouse location
STRUCT Rect trackRect
// Tooltip tracking rect
double duration_ms
// Time to display the tooltip, in milliseconds
char traceName[MAX_OBJ_NAME+1]
// If in a graph window, name of the trace
char imageName[MAX_OBJ_NAME+1]
// If in a graph window, name of the image
waveHndl yWave
// Y wave for trace, image, or table column
double row
// Row in trace, image or wave
double column
// Column in trace, image or wave
double layer
// Layer in trace, image or wave
double chunk
// Chunk in trace, image or wave
char ctrlName[MAX_OBJ_NAME+1]
// Name of control during hover event
Int32 isHtml
// Set to indicate tooltip contains HTML tags
String tooltip
// Set this to your tooltip text
EndStructure
WMWinHookStruct
See Named Window Hook Functions on page IV-295 for further explanation of WMWinHookStruct.
Structure WMWinHookStruct
char winName[200]
// Host window or subwindow name
STRUCT Rect winRect
// Local coordinates of the affected (sub)window
STRUCT Point mouseLoc
// Mouse location
Variable ticks
// Tick count when event happened
Int32 eventCode
// See Named Window Hook Events on page IV-295
char eventName[32]
// See Named Window Hook Events on page IV-295
Int32 eventMod
// See Control Structure eventMod Field on page III-438
char menuName[256]
// Name of the menu item as for SetIgorMenuMode
char menuItem[256]
// Text of the menu item as for SetIgorMenuMode
char traceName[32]
// See Named Window Hook Functions on page IV-295
char cursorName[2]
// Cursor name A through J
Variable pointNumber
// See Named Window Hook Functions on page IV-295
Variable yPointNumber
// See Named Window Hook Functions
Int32 isFree
// 1 if the cursor is not attached to anything
Int32 keycode
// ASCII value of key struck
Int32 specialKeyCode
// See Keyboard Events on page IV-300 - Igor Pro 7 or later
char keyText[16]
// UTF-8 string representing key struck - Igor Pro 7 or later
char oldWinName[32]
// Simple name of the window or subwindow
Int32 doSetCursor
// Set to 1 to change cursor to cursorCode
Int32 cursorCode
// See Setting the Mouse Cursor on page IV-302
Variable wheelDx
// Vertical lines to scroll
Variable wheelDy
// Horizontal lines to scroll
char focusCtrl[MAX_WIN_PATH+1]
// Added in Igor Pro 9.00. See EarlyKeyboard Events.
EndStructure
wnoise 
wnoise(shape, scale)
The wnoise function returns a pseudo-random value from the two-parameter Weibull distribution 
characterized by the shape and scale, the respective gamma and alpha parameters. The two-parameter Weibull 
probability distribution function is
The mean of the Weibull distribution is
x  0
f (x;, ) = 
 x 1 exp  1
 x


 

 > 0
 > 0
