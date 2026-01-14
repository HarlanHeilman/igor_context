# WMTabControlAction

WMTabControlAction
V-1112
Int32 eventCode
// See details below
Int32 eventMod
// See Control Structure eventMod Field on page III-438
String userData
// Primary unnamed user data
Int32 blockReentry
// Obsolete, see Control Structure blockReentry Field on page 
III-439
Variable curval
// Value of slider
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMSliderAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to slider action procedure has the following meaning:
The event codes greater than zero are bits that may be combined in certain cases. For instance, if your slider 
does not have the live mode set, you may receive event code 5 = 1+4. This indicates that a mouse up event 
was detected, and that mouse up set the slider's value.
For a demo of many of these events, see Handling Slider Events on page III-430.
WMTabControlAction
This structure is passed to action procedures for tab controls created using the TabControl operation.
Structure WMTabControlAction
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
Int32 eventCode
// See details below
Int32 eventMod
// See Control Structure eventMod Field on page III-438
String userData
// Primary unnamed user data
Int32 blockReentry
// Obsolete, see Control Structure blockReentry Field on page 
III-439
Int32 tab
// Tab number
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMTabControlAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to tab control action procedure has the following meaning:
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed
1
Value set
2
Mouse down
4
Mouse up
8
Mouse moved or arrow key moved the slider
16
Repeat timer fired (see Repeating Sliders on page III-418)
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed
2
Mouse up
