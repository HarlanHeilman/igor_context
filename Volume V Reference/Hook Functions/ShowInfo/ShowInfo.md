# ShowInfo

ShowIgorMenus
V-869
See Also
The GetWindow, SetIgorHook, and SetIgorMenuMode operations and AxisValFromPixel, 
NumberByKey, PopupContextualMenu, and TraceFromPixel functions. The GetUserData operation for 
retrieving named user data.
ShowIgorMenus 
ShowIgorMenus [MenuNameStr [, MenuNameStr] …
The ShowIgorMenus operation shows the named built-in menus or, if none are explicitly named, shows all 
built-in menus in the menu bar.
User-defined menus attached to built-in menus are also affected by this operation.
Parameters
Details
See HideIgorMenus for details.
See Also
HideIgorMenus, DoIgorMenu, SetIgorMenuMode, User-Defined Menus on page IV-125
ShowInfo 
ShowInfo [/CP=num /W=winName]
The ShowInfo operation puts an information panel on the target or named graph. The information panel 
contains cursors and readouts of values associated with waves in the graph.
Flags
See Also
Info Panel and Cursors on page II-319.
The HideInfo operation.
Programming With Cursors on page II-321.
MenuNameStr
The name of an Igor menu, like “File”, “Data”, or “Graph”.
/CP=num
/CP={n1,n2,...}
Allows you to select multiple cursor pairs to be displayed in the info panel. The 
numbers n1, n2, etc., are the same as the single-pair version of this flag.
This form of /CP was added in Igor Pro 7.00.
/SIDE=side
Selects the side of the host window where the info panel should be attached:
side = 0: right side
side = 1: left side
side = 2: bottom side (default)
side = 3: top side
/V=num
If num is non-zero, selects a vertical layout for the info panel. Most appropriate when 
/SIDE=0 or 1.
/W=winName
Displays info panel in the named window.
Selects a cursor pair to display in the info panel.
num=0:
Selects cursor A and cursor B.
num=1:
Selects cursor C and cursor D.
num=2:
Selects cursor E and cursor F.
num=3:
Selects cursor G and cursor H.
num=4:
Selects cursor I and cursor J.
