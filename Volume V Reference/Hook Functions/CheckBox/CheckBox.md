# CheckBox

chebyshevU
V-64
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
See Also
chebyshevU.
chebyshevU 
chebyshevU(n, x)
The chebyshevU function returns the Chebyshev polynomial of the second kind, degree n and argument x.
The Chebyshev polynomial of the second kind satisfies the recurrence relation
U(n+1,x)=2xU(n,x)-U(n-1,x)
which is also the recurrence relation of the Chebyshev polynomials of the first kind.
The first 10 polynomials of the second kind are:
U(0,x)=1
U(1,x)=2x
U(2,x)=4x2-1
U(3,x)=8x3-4x
U(4,x)=16x4-12x2+1
U(5,x)=32x5-32x3+6x
U(6,x)=64x6-80x4+24x-1
U(7,x)=128x7-192x5+80x3-8x
U(8,x)=256x8-448x6+240x4-40x2+1
U(9,x)512x9-1024x^7+672x5-160x3+10x
See Also
The chebyshev function.
CheckBox 
CheckBox [/Z] ctrlName [keyword = value [, keyword = value …]]
The CheckBox operation creates or modifies a checkbox, radio button or disclosure triangle in the target or 
named window, which must be a graph or control panel.
ctrlName is the name of the checkbox.
For information about the state or status of the control, use the ControlInfo operation.
Parameters
ctrlName is the name of the CheckBox control to be created or changed.
The following keyword=value parameters are supported:
align=alignment
Sets the alignment mode of the control. The alignment mode controls the 
interpretation of the leftOrRight parameter to the pos keyword. The align 
keyword was added in Igor Pro 8.00.
If alignment=0 (default), leftOrRight specifies the position of the left end of the 
control and the left end position remains fixed if the control size is changed.
If alignment=1, leftOrRight specifies the position of the right end of the control and 
the right end position remains fixed if the control size is changed.
Tn(x)Tm(x)
1−x2
dx =
0
m ≠n
π / 2
m = n ≠0
π
m = m = 0
.
⎧
⎨⎪
⎩⎪
−1
1∫

CheckBox
V-65
appearance=
{kind [, platform]}
Sets the appearance of the control. platform is optional. Both parameters are 
names, not strings.
kind can be one of default, native, or os9.
platform can be one of Mac, Win, or All.
See Button and DefaultGUIControls for more appearance details.
disable=d
fsize=s
Sets font size for checkbox.
fColor=(r,g,b[,a])
Sets the initial color of the title. r, g, b, and a specify the color and optional opacity 
as RGBA Values. The default is opaque black.
To further change the color of the title text, use escape sequences as described for 
title=titleStr.
focusRing=fr
On Macintosh, regardless of this setting, the focus ring appears if you have 
enabled full keyboard access via the Shortcuts tab of the Keyboard system 
preferences.
help={helpStr}
Sets the help for the control.
helpStr is limited to 1970 bytes (255 in Igor Pro 8 and before).
You can insert a line break by putting “\r” in a quoted string.
mode=m
noproc
Specifies that no procedure is to execute when clicking the checkbox.
picture= pict
Draws the checkbox using the named picture. The picture is taken to be six side-by-
side frames which show the control appearance in the normal state, when the 
mouse is down, and in the disabled state. The first three frames are used when the 
checked state is false and the next three show the true state. The picture may be 
either a global (imported) picture or a Proc Picture (see Proc Pictures on page 
IV-56).
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left corner of the control if its 
alignment mode is 0 or the top/right corner of the control if its alignment mode is 
1. See the align keyword above for details.
pos+={dx,dy}
Offsets the position of the checkbox in Control Panel Units.
proc=procName
Specifies the procedure to execute when the checkbox is clicked.
rename=newName
Renames the checkbox to newName.
side=s
Sets user editability of the control.
d=0:
Normal.
d=1:
Hide.
d=2:
Disable user input.
Enables or disables the drawing of a rectangle indicating keyboard focus:
fr=0:
Focus rectangle will not be drawn.
fr=1:
Focus rectangle will be drawn (default).
Specifies checkbox appearance.
m=0:
Default checkbox appearance.
m=1:
Display as a radio button control.
m=2:
Display as a disclosure triangle (Macintosh) or treeview 
expansion node (Windows).
Sets the location of the title relative to the box:
s =0:
Checkbox is on the left, title is on the right (default).
s =1:
Checkbox is on the right, title is on the left.

CheckBox
V-66
Flags
Details
The target window must be a graph or panel.
Checkbox Action Procedure
The action procedure for a CheckBox control can takes a predefined structure WMCheckboxAction as a 
parameter to the function:
Function ActionProcName(CB_Struct) : CheckBoxControl
STRUCT WMCheckboxAction &CB_Struct
…
return 0
End
The “: CheckboxControl” designation tells Igor to include this procedure in the Procedure pop-up 
menu in the Checkbox Control dialog.
See WMCheckboxAction for details on the WMCheckboxAction structure.
Although the return value is not currently used, action procedures should always return zero.
You may see an old format checkbox action procedure in old code:
Function procName(ctrlName,checked) : CheckBoxControl 
String ctrlName
Variable checked
// 1 if selected, 0 if not
…
return 0
End
This old format should not be used in new code.
When using radio button controls, it is the responsibility of the Igor programmer to turn off other radio 
buttons when one of a group of radio buttons is pressed.
size={width,height}
Sets checkbox size in Control Panel Units.
title=titleStr
Sets title of checkbox to the specified string expression. The title is the text that 
appears in the checkbox. If not given or if "" then the title will be “New”.
Using escape codes you can change the font, size, style, and color of the title. See 
Annotation Escape Codes on page III-53 or details.
userdata(UDName)=
UDStr
Sets the unnamed user data to UDStr. Use the optional (UDName) to specify a 
named user data to create.
userdata(UDName)+=
UDStr
Appends UDStr to the current unnamed user data. Use the optional (UDName) to 
append to the named UDStr.
value=v
Specifies whether the checkbox is selected (v=1) or not (v=0).
variable=varName
Specifies a global numeric variable to be set to the current state of a checkbox 
whenever it is clicked or when it is set by the value parameter. The variable is 
two-way: setting the variable also changes the state of the checkbox.
wave=waveName
Specifies a point from a wave to be set to the current state of a checkbox when it 
is clicked or when it is set by the value keyword. The point is specified using 
standard bracket notation with either a numeric point number or a row label, e.g., 
value=awave[4] or value=awave[%alabel]. You may also use a 2D, 3D, or 
4D wave and specify a column, layer, and chunk index or dimension label in 
addition to the row index. This feature was added in Igor Pro 9.00.
win=winName
Specifies which window or subwindow contains the named control. If not given, 
then the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
/Z
No error reporting.
