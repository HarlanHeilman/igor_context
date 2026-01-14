# GuideInfo

GuideInfo
V-336
Flags
Details
If no title is given and the width is less than 11 or height is specified as less than 6, then a vertical or 
horizontal separator line will be drawn rather than a box.
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The GetUserData function for retrieving named user data.
The ControlInfo operation for information about the control.
GuideInfo 
GuideInfo(winNameStr, guideNameStr)
The GuideInfo function returns a string containing a semicolon-separated list of information about the 
named guide line in the named host window or subwindow.
Parameters
winNameStr can be "" to refer to the top host window.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
guideNameStr is the name of the guide line for which you want information.
Details
The returned string contains several groups of information. Each group is prefaced by a keyword and colon, 
and terminated with the semicolon. The keywords are as follows:
The following keywords will be present only for user-defined guides:
See Also
The GuideNameList,s StringByKey and NumberByKey functions; the DefineGuide operation.
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left corner of the control if its 
alignment mode is 0 or the top/right corner of the control if its alignment mode is 
1. See the align keyword above for details.
pos+={dx,dy}
Offsets the position of the box in Control Panel Units.
size={width,height}
Sets box size in Control Panel Units.
userdata(UDName)=UDStr
Sets the unnamed user data to UDStr. Use the optional (UDName) to specify a 
named user data to create.
userdata(UDName)+=UDStr
Appends UDStr to the current unnamed user data. Use the optional (UDName) to 
append to the named UDStr.
title=titleStr
Sets title to titleStr. Use "" for no title.
win=winName
Specifies which window or subwindow contains the named control. If not given, 
then the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
/Z
No error reporting.
Note:
Like TabControls, you need to click near the top of a GroupBox to select it.
