# ControlInfo

ControlInfo
V-89
Flags
Details
The control bar is an area at the top of graphs reserved for controls such as buttons, checkboxes and pop-
up menus. A line is drawn between this area and the graph area. The control bar may be assigned a separate 
background color by pressing Control (Macintosh) or Ctrl (Windows) and clicking in the area, or by right-
clicking it (Windows), or with the ModifyGraph operation. You cannot use draw tools in this area.
For graphs with no controls, you do not need to use this operation.
Use ControlInfo kwControlBar operation to determine the current size of the control bar.
Examples
Display myData
ControlBar 35
// 35 pixels high
Button button0,pos={56,8},size={90,20},title="My Button"
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Chapter V-1, ControlInfo
ControlInfo 
ControlInfo [/W=winName] controlName
The ControlInfo operation returns information about the state or status of the named control in a graph or 
control panel window or subwindow.
Flags
Parameters
controlName is the name of a control in the window specified by /W or in the top graph or panel window. 
controlName may also be the keyword kwBackgroundColor to set V_Red, V_Green, V_Blue, and V_Alpha, 
the keyword kwControlBar or kwControlBarBottom to set V_Height, the keyword kwControlBarLeft or 
kwControlBarRight to set V_Width, or the keyword kwSelectedControl to set S_value and V_flag.
Details
Information for all controls is returned via the following string and numeric variables. Coordinates are 
returned in Control Panel Units.
The kind of control is returned in V_flag as a positive or negative integer. A negative value indicates the 
control is incomplete or not active. If V_flag is zero, then the named control does not exist. Information 
returned for specific control types is as follows:
/EXP=e
Sets the expansion of the panel control bar area.
See the NewPanel operation /EXP flag for details.
The /EXP flag was added in Igor Pro 9.00.
/L/R/B/T
Designates whether to use the left, right, bottom, or top (default) window edge, 
respectively, for the control bar location.
/W=graphName
Specifies the name of a particular graph containing a control bar.
/G [=doGlobal]
If doGlobal is non-zero or absent, the position returned via V_top and V_left is in 
global screen coordinates rather relative to the window containing the control.
/W=winName
Looks for the control in the named graph or panel window or subwindow. If /W is 
omitted, ControlInfo looks in the top graph or panel window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.

ControlInfo
V-90
Buttons
Chart
Checkbox
CustomControl
S_recreation
Commands to recreate the named control.
S_title
Title of the named control.
V_disable
V_Height, V_Width, 
V_top, V_left, V_right, 
V_pos, V_align
Dimensions and position of the named control in Control Panel Unitss.
V_right, V_pos, and V_align were added in Igor Pro 8.00 and depend on 
whether the align keyword was applied to the control (e.g., Button <name> 
align=1).
V_align is 1 if the the align keyword was applied to the control or to 0 
otherwise.
V_pos is the horizontal coordinate used to position the control. It represents 
the position of the left end of the control if the align keyword was omitted or 
of the right end if the align keyword was applied.
V_left and V_right are the the horizontal coordinates of the left and right ends 
of the control regardless of whether the align keyword was applied or not.
V_flag
1
V_value
Tick count of last mouse up.
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
6 or -6
V_value
Current point number.
S_UserData
Keyword-packed information string. See S_value for Chart Details for more 
keyword information.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
2
V_value
0 if it is deselected or 1 if it is selected.
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
12
V_value
Tick count of last mouse up.
Disable state of control:
0:
Normal (enabled, visible).
1:
Hidden.
2:
Disabled, visible.

ControlInfo
V-91
GroupBox
ListBox
PopupMenu
SetVariable
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Name of the picture used to define the control appearance.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
9
S_value
Title text.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
11
V_value
Currently selected row (valid for mode 1 or 2 or modes 5 and 6 when no selWave is 
used). If no list row is selected, then it is set to -1.
V_selCol
Currently selected column (valid for modes 5 and 6 when no selWave is used).
V_horizScroll
Number of pixels the list has been scrolled horizontally to the right.
V_vertScroll
Number of pixels the list has been scrolled vertically downwards.
V_rowHeight
Height of a row in pixels.
V_startRow
The current top visible row.
S_columnWidths
A comma-separated list of column widths in pixels.
S_dataFolder
Full path to listWave (if any).
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Name of listWave (if any).
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
3 or -3
V_Red, V_Green, 
V_Blue. V_Alpha
For color array pop-up menus, these are the encoded color values.
V_value
Current item number (counting from one).
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Text of the current item. If PopupMenu is a color array then it contains color values 
encoded as RGBA Values.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
5 or -5

ControlInfo
V-92
Slider
TabControl
TitleBox
ValDisplay
V_value
Value of the variable. If the SetVariable is used with a string variable, then it is the 
interpretation of the string as a number, which will be NaN if conversion fails.
S_dataFolder
Full path to the variable.
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Name of the variable or, if the value was set using _STR: syntax, the string value itself.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
7
V_value
Numeric value of the variable.
S_dataFolder
Full path to the variable.
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Name of the variable.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
8
V_value
Number of the current tab.
S_UserData
Primary (unnamed) user data text. For retrieving any named user data, you must use 
the GetUserData operation.
S_value
Tab text.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.
V_flag
10
S_dataFolder
Full path if text is from a string variable.
S_value
Name if text is from a string variable.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, and 
V_left at the beginning of the Details section.
See TitleBox Positioning on page V-1040 for details on V_right, V_pos, and V_align.
V_flag
4 or -4
V_value
Displayed value.
S_value
Text of expression that ValDisplay evaluates.
See also the descriptions of S_recreation, V_disable, V_Height, V_Width, V_top, 
V_left, V_right, V_pos, and V_align at the beginning of the Details section.

ControlInfo
V-93
kwBackgroundColor
kwControlBar or kwControlBarTop
kwControlBarBottom
kwControlBarLeft
kwControlBarRight
kwSelectedControl
S_value for Chart Details
The following applies only to the keyword-packed information string returned in S_value for a chart. 
S_value will consist of a sequence of sections with the format: “keyword:value;” You can pick a value out of 
a keyword-packed string using the NumberByKey and StringByKey functions. Here are the S_value 
keywords: 
In addition, ControlInfo writes fields to S_value for each channel in the chart. The keyword for the field is 
a combination of a name and a number that identify the field and the channel to which it refers. For 
example, if channel 4 is named “Pressure” then the following would appear in the S_value string: 
“CHNAME4:Pressure”. In the following table, the channel’s number is represented by #:
V_Red, V_Green, 
V_Blue, V_Alpha
If controlName is kwBackgroundColor then this is the color of the control panel 
background. This color is usually the default user interface background color, as set 
by the Appearance control panel on the Macintosh or by the Appearance tab of the 
Display Properties on Windows, until changed by ModifyPanel cbRGB.
V_Height
The height in pixels of the top control bar area in a graph as set by ControlBar.
V_Height
The height in pixels of the bottom control bar area in a graph as set by ControlBar/B.
V_Width
The width in pixels of the left control bar area in a graph as set by ControlBar/L.
V_Width
The width in pixels of the right control bar area in a graph as set by ControlBar/R.
V_flag
Set to 1 if a control is selected or 0 if not.
SetVariable and ListBox controls can be selected, most other controls can not.
S_value
Name of selected control (if any) or "".
Keyword
Type
Meaning
FNAME
string
Name of the FIFO chart is monitoring.
LHSAMP
number
Left hand sample number.
NCHANS
number
Number of channels displayed in chart.
PPSTRIP
number
The chart’s points per strip value.
RHSAMP
number
Right hand sample number (same as V_value).
Keyword
Type
Meaning
CHCTAB#
number
Channel’s color table value as set by Chart ctab keyword. 
CHGAIN#
number
Channel’s gain value as set by Chart gain keyword.
CHNAME#
string
Name of channel defined by FIFO.
CHOFFSET#
number
Channel’s offset value as set by Chart offset keyword.
