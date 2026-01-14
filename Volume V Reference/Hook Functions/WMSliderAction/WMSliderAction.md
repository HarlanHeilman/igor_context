# WMSliderAction

WMSliderAction
V-1111
WMSetVariableAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to the SetVariable action procedure has the following meaning:
Event code -1 is never sent to an old-style (non-structure parameter) action procedure.
Event code 1 is sent when the mouse is released after clicking the up-arrow or down-arrow buttons. It is 
also sent for value changes caused by the mouse scroll wheel for a non-live mode control.
Event codes 4 and 5 are sent only for string SetVariables or numeric SetVariables whose increment setting 
is zero. Otherwise the value change is signaled by event code 1.
For numeric SetVariables whose increment is non-zero, the mouse scroll wheel acts like a mouse click on 
the up-arrow button or down-arrow button. That is, event code 1, mouse up, is more like "value changed".
Event code 6 is by default sent to only structure-based action procedures.
Use SetIgorOption EnableSVE6=0 to disable sending this event at all and EnableSVE6=2 to send the event 
to both structure-based and old-style SetVariable action procedures. The default for EnableSVE6 is =1.
The mousePart field is valid for mouse down, mouse scroll wheel, live update, and Enter key events only:
WMSliderAction
This structure is passed to action procedures for slider controls created using the Slider operation.
Structure WMSliderAction
char ctrlName[32]
// Control name
char win[200]
// Host window or subwindow name
STRUCT Rect winRect
// Local coordinates of host window
STRUCT Rect ctrlRect
// Enclosing rectangle of the control
STRUCT Point mouseLoc
// Mouse location
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed
1
Mouse up
2
Enter key
3
Live update
4
Mouse scroll wheel up
5
Mouse scroll wheel down
6
Value changed by dependency update
7
Begin edit (Igor7 or later)
8
End edit (Igor7 or later)
9
Mouse down (Igor8 or later)
Value
Mouse Part
0
A part other than 1, 2, or 3 - most likely the title
1
The up-arrow button on a numeric SetVariable via a mouse click on the button 
or the use of the up-arrow key
2
The down-arrow button on a numeric SetVariable via a mouse click on the 
button or the use of the down-arrow key
3
The value field
