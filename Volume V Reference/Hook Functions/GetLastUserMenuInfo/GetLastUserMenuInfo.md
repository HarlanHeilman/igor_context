# GetLastUserMenuInfo

GetLastUserMenuInfo
V-306
Function EscapeKeyExample()
Variable keys
do
keys = GetKeyState(0)
if ((keys & 32) != 0)
// User is pressing escape?
break
endif
while(1)
End
See Also
Keyboard Shortcuts on page IV-136. Setting Bit Parameters on page IV-12 for details about bit settings.
GetLastUserMenuInfo 
GetLastUserMenuInfo
The GetLastUserMenuInfo operation sets variables in the local scope to indicate the value of the last 
selected user-defined menu item.
Details
GetLastUserMenuInfo creates and sets these special variables:
V_flag
V_value
The kind of menu that was selected:
 See Specialized Menu Item Definitions on page IV-132 for details about these special user-
defined menus.
V_flag
Menu Kind
0
Normal text menu item, including Optional Menu Items (see page 
IV-130) and Multiple Menu Items (see page IV-131).
3
"*FONT*"
6
"*LINESTYLEPOP*"
7
"*PATTERNPOP*"
8
"*MARKERPOP*"
9
"*CHARACTER*"
10
"*COLORPOP*"
13
"*COLORTABLEPOP*"
Which menu item was selected. The value also depends on the kind of menu the item was 
selected from:
V_flag
V_value meaning
0
Text menu item number (the first menu item is number 1).
3
Font menu item number (use S_Value, instead).
6
Line style number (0 is solid line)
7
Pattern number (1 is the first selection, a SW-NE light diagonal).
8
Marker number (1 is the first selection, the X marker).
9
Character as an integer, = char2num(S_Value). Use S_Value instead.
10
Color menu item (use V_Red, V_Green, V_Blue, and V_Alpha instead).
13
Color table list menu item (use S_Value instead).

GetLastUserMenuInfo
V-307
S_value
V_Red, V_Green, V_Blue,V_Alpha
If a user-defined color menu ("*COLORPOP*" menu item) was chosen then these values hold 
the red, green, and blue values of the selected color. The values range from 0 to 65535 - see 
RGBA Values.
These outputs are set to 0 if the last user-defined menu selection was not a color menu 
selection.
S_graphName, S_traceName,V_mouseX,V_mouseY
These variables are set only when the user chooses a user-defined menu item from the 
TracePopup, AllTracesPopup, or GraphPopup contextual menu.
S_graphName and S_traceName are initially "" until a user-defined menu selection is made 
from one of these contextual menus, and are not reset for each user-defined menu selection.
S_graphName is the full host-child specification for the graph. If the graph is embedded into 
a host window, S_graphName might be something like “Panel0#G0”. See Subwindow 
Syntax on page III-92.
S_traceName is name of the trace that was selected by the trace contextual menu, or "" if the 
AllTracesPopup or GraphPopup menu was chosen. See Trace Names on page II-282.
V_mouseX and V_mouseY, added in Igor Pro 8.00, are the mouse location of the click that 
invoked the contextual menu. The location is in pixels; use AxisValFromPixel to determine 
the X and Y axis values that correspond to the pixel location.
S_tableName, S_firstColumnPath, S_columnName,V_mouseX,V_mouseY
The menu item text, depending on the kind of menu it was selected from:
In the case of Specialized Menu Item Definitions (see page IV-132), S_value will be the title 
of the menu or submenu, etc.
V_flag
S_value meaning
0
Text menu item text.
3
Font name or “default”.
6
Name of the line style menu or submenu.
7
Name of the pattern menu or submenu.
8
Name of the marker menu or submenu.
9
Character as string.
10
Name of the color menu or submenu.
13
Color table name.

GetLastUserMenuInfo
V-308
Examples
A Multiple Menu Items menu definition:
Menu "Wave List", dynamic
"Menu Item 1", <some command>
"Menu Item 2", <some command>
WaveList("*",";",""), DoSomethingWithWave()
End
The last item can create multiple menu items - one for each wave name returned by WaveList. If the user 
selects one of these items, the DoSomethingWithWave user function can call GetLastUserMenuInfo to 
determine which wave was selected:
Function DoSomethingWithWave()
GetLastUserMenuInfo
WAVE/Z selectedWave = $S_value
// Use selectedWave for something
End
A trivial user-defined color menu definition:
Menu "Color"
"*COLORPOP*", DoSomethingWithColor()
End
Function DoSomethingWithColor()
GetLastUserMenuInfo
... do something with V_Red, V_Green, V_Blue, V_Alpha ...
End
See Specialized Menu Item Definitions on page IV-132 for another color menu example.
A Trace contextual menu Items menu definition:
Menu "TracePopup", dynamic
// menu when a trace is right-clicked
"-"
// separator divides this from built-in menu items
ExportTraceName(), ExportSelectedTrace()
"Draw XY Here", DrawXYHere()
End
Function/S ExportTraceName()
GetLastUserMenuInfo
// Sets S_graphName, S_traceName, V_mouseX, V_mouseY
if (strlen(S_traceName) > 0)
String item = "Export "+S_traceName
return item
endif
return ""
// No item is added to the menu
End
Added in Igor Pro 9.00.
These variables are set only when the user chooses a user-defined menu item from the 
TablePopup contextual menu.
S_tableName, S_firstColumnPath and S_columnName are initially "" until a user-
defined menu selection is made from a TablePopup contextual menus, and are not reset for 
each user-defined menu selection.
S_tableName is the full host-child specification for the table. If the table is embedded into a 
host window, S_tableName might be something like "Panel0#T0". See Subwindow Syntax on 
page III-92.
S_firstColumnPath is full path to the wave selected by the table contextual menu, or "" if 
multiple columns from different waves were chosen. The full path is identical to 
GetWavesDataFolder(wave,2).
S_columnName is name of the selected column as used in the ModifyTable command, or "" 
if multiple columns from different waves were selected.
You can obtain additional information about the selected cells in the table using the 
GetSelection operation.
V_mouseX and V_mouseY are the mouse location of the click that invoked the contextual 
menu. The location is in pixels relative to the top-left corner of the table.
