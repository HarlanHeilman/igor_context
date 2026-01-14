# Slider

Slider
V-874
// Because the /Q flag is omitted, pressing the user abort key combinations
// or pressing Igor's Abort button generates an abort instead of merely
// terminating the current Sleep call. 
Sleep/S/C=2/B sleepTime
endif
junk = sin(x*(i+2))
DoUpdate
endfor
catch
Printf "An abort occurred with V_abortCode=%d\r", V_abortCode
endtry
End 
Slider 
Slider [/Z] controlName [key [= value]][, key [= value]]…
The Slider operation creates or modifies a Slider control in the target window.
A Slider control sets or displays a single numeric value. The user can adjust the value by dragging a thumb 
along the length of the Slider.
For information about the state or status of the control, use the ControlInfo operation.
Parameters
ctrlName is the name of the Slider control to be created or changed.
The following keyword=value parameters are supported:
align=alignment
Sets the alignment mode of the control. The alignment mode controls the 
interpretation of the leftOrRight parameter to the pos keyword. The align keyword 
was added in Igor Pro 8.00.
If alignment=0 (default), leftOrRight specifies the position of the left end of the control 
and the left end position remains fixed if the control size is changed.
If alignment=1, leftOrRight specifies the position of the right end of the control and the 
right end position remains fixed if the control size is changed.
appearance={kind [, platform]}
Sets the appearance of the control. platform is optional. Both parameters are names, 
not strings.
kind can be one of default, native, or os9.
platform can be one of Mac, Win, or All.
Note: The Slider control reverts to os9 appearance on Macintosh if thumbColor isn’t 
the default blue (0,0,65535).
See Button and DefaultGUIControls for more appearance details.
disable=d
fColor=(r,g,b[,a])
Sets the color of the tick marks. r, g, b, and a specify the color and optional opacity as 
RGBA Values. The default is opaque black.
focusRing=fr
On Macintosh, regardless of this setting, the focus ring appears if you have enabled 
full keyboard access via the Shortcuts tab of the Keyboard system preferences.
font="fontName "
Sets the font used to display the tick labels, e.g., font="Helvetica".
Sets user editability of the control.
d=0:
Normal.
d=1:
Hide.
d=2:
Draw in gray state; disable control action.
Enables or disables the drawing of a rectangle indicating keyboard focus:
fr=0:
Focus rectangle will not be drawn.
fr=1:
Focus rectangle will be drawn (default).

Slider
V-875
fsize=s
Sets the size of the type for tick mark labels.
help={helpStr}
Sets the help for the control.
helpStr is limited to 1970 bytes (255 in Igor Pro 8 and before).
You can insert a line break by putting “\r” in a quoted string.
limits= {low,high,inc}
low sets left or bottom value, high sets right or top value. Use inc=0 for continuous or 
use desired increment between stops.
live=l
noproc
Specifies that no procedure is to execute when the control’s value is changed.
pos={leftOrRight,top}
Sets the position in Control Panel Units of the top/left corner of the control if its 
alignment mode is 0 or the top/right corner of the control if its alignment mode is 1. 
See the align keyword above for details.
pos+={dx,dy}
Offsets the position of the slider in Control Panel Units.
proc=procName
Specifies the action procedure for the slider.
rename=newName
Gives control a new name.
repeat={style,springback,rate,restingValue}
Set the control to call its action procedure repeatedly at timed intervals while the user 
clicks the thumb.
springback controls what happens to the slider value when the user releases the 
mouse. If springback is 1, the slider returns to the resting value. If it is 0, it remains at 
the last set value.
rate specifies the rate at which the action procedure is called in calls per second. The 
maximum rate accepted rate is 1000. If rate is 0, it sets style to 0 which turns the 
repeating feature off.
restingValue specifies the value to which the slider returns when the user releases the 
mouse. If springback is 1, the thumb automatically returns to restingValue when the 
mouse button is released. If springback is 0, restingValue has no effect.
side=s
size={width,height}
Sets width or height of control in Control Panel Units. height is ignored if vert=0 and 
width is ignored if vert=1.
thumbColor=(r,g,b[
,a])
If appearance={os9} is in effect, sets dominant foreground color of thumb. r, g, b, and 
a specify the color and optional opacity as RGBA Values. Alpha (a) is accepted but 
ignored.
Controls updating of readout.
l=0:
Update only after mouse is released.
l=1:
Update as slider moves (default).
style can take one of the following values:
0:
No repeat (default). Use this to turn the repeat feature off.
1:
Slider repeats at a constant rate.
2:
Slider repeats at a rate proportional to the distance from the 
restingValue.
Controls slider thumb.
s=0:
Thumb is blunt and tick marks are suppressed.
s=1:
Thumb points right or down (default).
s=2:
Thumb points up or left.

Slider
V-876
Flags
Details
The target window must be a graph or panel.
If you use negative ticks to suppress automatic labeling, you can label tick marks using drawing tools 
(panels only).
Slider Action Procedure
The action procedure for a Slider control takes a predefined WMSliderAction structure as a parameter to 
the function:
Function ActionProcName(S_Struct) : SliderControl
STRUCT WMSliderAction &S_Struct
…
return 0
End
The “: SliderControl” designation tells Igor to include this procedure in the Procedure pop-up menu 
in the Slider Control dialog.
ticks=t
tkLblRot= deg
Rotates tick labels. deg is a value between -360 and 360.
userdata(UDName)=UDStr
Sets the unnamed user data to UDStr. Use the optional (UDName) to specify a named 
user data to create.
userdata(UDName)+=UDStr
Appends UDStr to the current unnamed user data. Use the optional (UDName) to 
append to the named UDStr.
userTicks={tvWave,tlblWave}
User-defined tick positions and labels. tvWave contains the tick positions, and text 
wave tlblWave contains the labels. See ModifyGraph userticks for more info. 
Overrides normal ticking specified by ticks keyword.
value=v
v is the new value for the Slider.
valueColor=(r,g,b[,
a])
Sets the color of the tick labels. r, g, b, and a specify the color and optional opacity as 
RGBA Values. The default is opaque black.
variable= var
Sets the variable (var) that the slider will update. It is not necessary to connect a Slider 
to a variable — you can get a Slider’s value using the ControlInfo operation.
vert=v
Set vertical (v =1; default) or horizontal (v =0) orientation of the slider.
win=winName
Specifies which window or subwindow contains the named control. If not given, then 
the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
No error reporting.
Controls slider ticks.
t=0:
No ticks.
t=1:
Number of ticks is calculated from limits (no ticks drawn if 
calculated value is less than 2 or greater than 100). Default value.
t>1:
t is the number of ticks distributed between the start and stop 
position. Ticks are labeled using the same automatic algorithm 
used for graph axes. Use negative tick values to force ticks to not 
be labeled. Ticks are shown on the side specified by the side 
keyword and are not drawn if side=0.
