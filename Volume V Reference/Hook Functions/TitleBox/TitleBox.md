# TitleBox

TitleBox
V-1038
TitleBox 
TitleBox [/Z] ctrlName [keyword = value [, keyword = value …]]
The TitleBox operation creates the named title box in the target window.
For information about the state or status of the control, use the ControlInfo operation.
Parameters
ctrlName is the name of the TitleBox control to be created or changed.
The following keyword=value parameters are supported:
anchor= hv
Specifies the anchor mode using a two letter code, hv. h may be L, M, or R for left, 
middle, and right. v may be T, C, or B for top, center and bottom. Default is LT.
If fixedSize=1, the anchor code sets the positioning of text within the frame.
align=alignment
Sets the alignment mode of the control. The alignment mode controls the 
interpretation of the leftOrRight parameter to the pos keyword. The align keyword 
was added in Igor Pro 8.00.
If alignment=0 (default), leftOrRight specifies the position of the left end of the control 
and the position of the control depends on the anchor keyword.
If alignment=1, leftOrRight specifies the position of the right end of the control and the 
right end position remains fixed if the control size is changed.
There is a conflict between the align keyword and the anchor keyword. See TitleBox 
Positioning on page V-1040.
appearance={kind [, platform]}
Sets the appearance of the control. platform is optional. Both parameters are names, 
not strings.
kind can be one of default, native, or os9.
platform can be one of Mac, Win, or All.
See Button and DefaultGUIControls for more appearance details.
disable=d
fColor=(r,g,b[,a])
Sets color of the titlebox. r, g, b, and a specify the color and optional opacity as RGBA 
Values.
fixedSize=f
font="fontName"
Sets the font used for the control, e.g., font="Helvetica".
frame= f
fsize=s
Sets font size.
Sets user editability of the control.
d=0:
Normal.
d=1:
Hide.
d=2:
Draw in gray state.
Controls title box sizing:
f =0:
The titlebox automatically sizes itself to fit the title text (default).
f =1:
The size settings are honored, and the titlebox does not 
automatically size itself to fit the title text.
Sets frame style:
f=0:
No frame.
f=1:
Default (same as f=3).
f=2:
Simple box.
f=3:
3D sunken frame.
f=4:
3D raised frame.
f=5:
Text well.

TitleBox
V-1039
Flags
Details
The text can come from either the title=titleStr or variable=svar method. Whichever is used last is the current 
method. The maximum length of text with the title=titleStr method is 255 bytes while the variable=svar 
method has no limit.
Using escape codes you can change the font, size, style and color of text, and apply other effects. See 
Annotation Escape Codes on page III-53 for details.
By default, the titlebox automatically resizes itself relative to the anchor point on the rectangle that encloses 
the text. Therefore you can specify a size of 0,0 along with a pos value in order to place the anchor point at 
the desired position. When fixedSize=1 is used, the titlebox does not resize itself and instead honors the 
values specified via the size keyword.
TitleBoxes can be used not only for titles but also as status or results readout areas, especially in conjunction 
with the variable= svar mode. When using a titlebox like this, you may find it useful to use fixedSize=1 so 
that the titlebox doesn't change size as the text changes.
fstyle=fs
help={helpStr}
Sets the help for the control.
helpStr is limited to 1970 bytes (255 in Igor Pro 8 and before).
You can insert a line break by putting “\r” in a quoted string.
labelBack=(r,g,b[,a]) or 0
Sets background color for title box.r, g, b, and a specify the color and optional opacity 
as RGBA Values. If not set (or labelBack=0), then background is transparent (not 
erased).
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left or top/right corner of the 
control at the time it is created. Unless fixedSize=1, a TitleBox control adjusts its size 
to fit the title text and the position can move in a way that depends on the anchor and 
align modes. See TitleBox Positioning on page V-1040.
pos+={dx,dy}
Offsets the position of the control in Control Panel Units.
size={w,h}
Sets the width and height of the control in pixels.
If fixedSize=1, sets the width of the control in pixels. If fixedSize=0, a TitleBox control 
adjusts its size to the title text, resulting in confusion about what the size does. In this 
case, size={0,0} is recommended. See TitleBox Positioning on page V-1040.
title=titleStr
Sets the text of the title box to titleStr. titleStr is limited to 255 bytes.
Using escape codes you can change the font, size, style, and color of the title. See 
Annotation Escape Codes on page III-53 or details.
variable= svar
Specifies an optional global string variable from which to get the TitleBox text.
win=winName
Specifies which window or subwindow contains the named control. If not given, then 
the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
No error reporting.
fs is a bitwise parameter with each bit controlling one aspect of the font style 
as follows:
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
