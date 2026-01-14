# WMWinHookStruct

Chapter IV-10 — Advanced Topics
IV-297
WMWinHookStruct
The WMWinHookStruct structure has members as described in the following tables:
Base WMWinHookStruct Structure Members
Member
Description
char winName[MAX_PATH_LENGTH+1] hcSpec of the affected (sub)window.
STRUCT Rect winRect
Local coordinates of the affected (sub)window.
STRUCT Point mouseLoc
Mouse location.
double ticks
Tick count when event happened.
Int32 eventCode
See see eventCode table on page IV-295.
char eventName[255+1]
Name-equivalent of eventCode, see eventCode table on page 
IV-295. Added in Igor 5.03.
Int32 eventMod
Bitfield of modifiers. See description for MODIFIERS:flags.
Members of WMWinHookStruct Structure Used with menu Code
Member
Description
char menuName[255+1]
Name of menu (in English) as used by SetIgorMenuMode.
char menuItem[255+1]
Text of the menu item as used by SetIgorMenuMode
Members of WMWinHookStruct Structure Used with keyboard and earlyKeyboard Code
Member
Description
Int32 keycode
ASCII value of key struck. Function keys are not available but 
navigation keys are translated to specific values and will be the 
same on Macintosh and Windows.
This field can not represent non-ASCII text such as accented 
characters. Use keyText instead.
Int32 specialKeyCode
See Keyboard Events on page IV-300.
This field was added in Igor Pro 7.
char keyText[16]
UTF-8 representation of key struck.
This field was added in Igor Pro 7.
char focusCtrl[MAX_WIN_PATH+1] Used only with EarlyKeyboard Events.
This field was added in Igor Pro 9.

Chapter IV-10 — Advanced Topics
IV-298
Members of WMWinHookStruct Structure Used with cursormoved Code
Member
Description
char traceName[MAX_OBJ_NAME+1] The name of the trace or image to which the moved cursor is 
attached or which supplies the X (and Y) values. Can be "" if the 
cursor is free.
char cursorName[2]
Cursor name A through J.
double pointNumber
Point number of the trace or the X (row) point number of the 
image where the cursor is attached.
If the cursor is “free”, pointNumber is actually the fractional 
relative xValue as used in the Cursor/F/P command.
double yPointNumber
Valid only when the cursor is attached to a two-dimensional 
item such as an image, contour, or waterfall plot, or when the 
cursor is free.
If attached to an image, contour, or waterfall plot, yPointNumber 
is the Y (column) point number of the image where the cursor is 
attached.
If the cursor is “free”, yPointNumber is actually the fractional 
relative yValue as used in the Cursor/F/P command.
Int32 isFree
Has value of 1 if the cursor is not attached to anything, or value 
of 0 if it is attached to a trace, image, contour, or waterfall.
Members of WMWinHookStruct Structure Used with mouseWheel Code
Member
Description
double wheelDy
Vertical lines to scroll. Typically +1 or -1.
double wheelDx
Horizontal lines to scroll. Typically +1 or -1.
On Windows, horizontal mouse wheel requires Vista.
Members of WMWinHookStruct Used with renamed Code
Member
Description
char oldWinName[MAX_OBJ_NAME+1] Old name of the window or subwindow. Not the absolute path 
hcSpec, just the name.
User-Modifiable Members of WMWinHookStruct Structure
Member
Description
Int32 doSetCursor
Set to 1 to change cursor to that specified by cursorCode.
Int32 cursorCode
See Setting the Mouse Cursor.
