# Button

Button
V-55
Button 
Button [/Z] ctrlName [keyword = value [, keyword = value …]]
The Button operation creates or modifies the named button control.
For information about the state or status of the control, use the ControlInfo operation.
Parameters
ctrlName is the name of the Button control to be created or changed.
align=alignment
Sets the alignment mode of the control. The alignment mode controls the 
interpretation of the leftOrRight parameter to the pos keyword. The align keyword 
was added in Igor Pro 8.00.
If alignment=0 (default), leftOrRight specifies the position of the left end of the control 
and the left end position remains fixed if the control size is changed.
If alignment=1, leftOrRight specifies the position of the right end of the control and the 
right end position remains fixed if the control size is changed.
appearance=
{kind [, platform]}
disable=d
See the ModifyControl example for setting the bits individually.
fColor=(r,g,b[,a])
Sets color of the button. r, g, b, and a specify the color and optional opacity as RGBA 
Values. While accepted as an input, a has no effect.
Specify fColor=(0,0,0) to get the default button color. If you want a black button use 
fColor=(1,1,1). To get the default blue button appearance, use fColor(0,0,65535).To set 
the color of the title text, see valueColor.
focusRing=fr
On Macintosh, regardless of this setting, the focus ring appears if you have enabled 
full keyboard access via the Shortcuts tab of the Keyboard system preferences.
font="fontName"
Sets button font, e.g., font="Helvetica".
fsize=s
Sets font size.
Sets the appearance of the control. platform is optional. Both parameters are 
names, not strings.
kind=default:
Appearance determined by DefaultGUIControls.
kind=native:
Creates standard-looking controls for the current computer 
platform.
kind=os9:
Igor Pro 5 appearance (quasi-Macintosh OS 9 controls that 
look the same on Macintosh and Windows).
platform=Mac:
Changes the appearance of controls only on Macintosh; 
affects the experiment whenever it is used on Macintosh.
platform=Win:
Changes the appearance of controls only on Windows; 
affects the experiment whenever it is used on Windows.
platform=All:
Changes the appearance on both Macintosh and Windows 
computers.
Sets the state of the control. d is a bit field: bit 0 (the least significant bit) is set when 
the control is hidden. Bit 1 is set when the control is disabled:
d=0:
Normal (visible), enabled.
d=1:
Hidden.
d=2:
Visible and disabled. Drawn in grayed state, also disables 
action procedure.
d=3:
Hidden and disabled.
Enables or disables the drawing of a rectangle indicating keyboard focus:
fr=0:
Focus rectangle will not be drawn.
fr=1:
Focus rectangle will be drawn (default).

Button
V-56
fstyle=fs
help={helpStr}
Specifies the help for the control.
helpStr is limited to 1970 bytes (255 in Igor Pro 8 and before).
You can insert a line break by putting “\r” in a quoted string.
labelBack=(r,g,b[,a]) or 0
Sets the background color for the control when using a picture to define the 
appearance of the button (see the picture keyword).
The labelBack keyword was added in Igor Pro 9.00.
r, g, b, and a specify the color and optional opacity as RGBA Values.
For transparency to work, the picture must be inherently transparent. For example, 
each pixel in a PNG picture has its own internal alpha value so it can be inherently 
transparent or inherently opaque.
If you want the button background to be actually transparent, use the labelBack color 
to set the background color of the picture. In most cases, use transparent white: 
labelBack=(65535, 65535, 65535, 0).
If you omit labelBack or specify labelBack=0 then the button background color is the 
background color of the window in which the button is drawn.
noproc
No procedure is executed when clicking the button.
picture= pict
Draws the button using the named picture. The picture is taken to be three side-by-
side frames that show the control appearance in the normal state, when the mouse is 
down, and in the disabled state. The picture may be either a global (imported) picture 
or a Proc Picture (see Proc Pictures on page IV-56).
By default, the button's rectangle is filled with the background color of the window it 
is drawn in before the picture is drawn. You can use the labelBack keyword to control 
the button's background color and transparency.
In Igor6, the size keyword is ignored when a picture is used with a button control. To 
make it easier to size graphics for high-resolution screens, as of Igor7, the size 
keyword is respected in this case.
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left corner of the control if its 
alignment mode is 0 or the top/right corner of the control if its alignment mode is 1. 
See the align keyword above for details.
pos+={dx,dy}
Offsets the position of the button in Control Panel Units.
proc=procName
Names the procedure to execute when clicking the button.
rename=newName
Gives the button a new name.
size={width,height}
Sets width and height of button in Control Panel Units.
title=titleStr
Sets title of button (text that appears in the button) to the specified string expression. If not 
given then title will be “New”. If you use "" the button will contain no text.
Using escape codes you can change the font, size, style, and color of the title. See 
Annotation Escape Codes on page III-53 or details.
Specifies the font style. fs is a bitwise parameter with each bit controlling one 
aspect of the font style:
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
