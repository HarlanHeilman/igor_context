# AutoPositionWindow

asinh
V-42
asinh 
asinh(num)
The asinh function returns the inverse hyperbolic sine of num. In complex expressions, num is complex, and 
asinh returns a complex value.
atan 
atan(num)
The atan function returns the inverse tangent of num in radians. In complex expressions, num is complex, 
and atan returns a complex value. Results are in the range -/2 to /2.
See Also
tan, atan2
atan2 
atan2(y1, x1)
The atan2 function returns the angle in radians whose tangent is y1/x1. Results are in the range - to .
See Also
tan, atan
atanh 
atanh(num)
The atanh function returns the inverse hyperbolic tangent of num. In complex expressions, num is complex, 
and atanh returns a complex value.
AutoPositionWindow 
AutoPositionWindow [/E/M=m/R=relWindow][windowName]
The AutoPositionWindow operation positions the window specified by windowName relative to the next 
lower window of the same kind or relative to the window given by the /R flag. If windowName is not 
specified, AutoPositionWindow acts on the target window.
Flags
/E
Uses entire area of the monitor. Otherwise, it takes into account the command 
window.
/M=m
/R=relWindow
Positions windowName relative to relWindow.
Specifies the window positioning method.
m=0:
Positions windowName to the right of the other window, if possible. If 
there is no room, then it positions windowName just below the other 
window but at the left edge of the display area. If that is not possible, 
then the position is not affected.
m=1:
Positions windowName just under the other window lined up on the 
left edge, if possible. If there is no room, then it positions windowName 
just to the right of the other window lined up on the bottom edges. If 
neither are possible then it positions windowName as far to the bottom 
and right as it will go.
