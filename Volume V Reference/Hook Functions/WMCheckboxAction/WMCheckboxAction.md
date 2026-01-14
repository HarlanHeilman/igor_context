# WMCheckboxAction

WMButtonAction
V-1104
WMButtonAction
This structure is passed to action procedures for button controls created using the Button operation.
Structure WMButtonAction
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
// Primary unnamed user data.
Int32 blockReentry
// Obsolete, see Control Structure blockReentry Field on page 
III-439
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMButtonAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to the button action procedure has the following meaning:
Events 2 and 3 happen only after event 1.
Events 4, 5, and 6 happen only when the mouse is over the control but happen regardless of the mouse 
button state.
Event 7 happens only when the mouse is pressed inside the control and then dragged outside.
WMCheckboxAction
This structure is passed to action procedures for checkbox controls created using the CheckBox operation.
Structure WMCheckboxAction
char ctrlName[MAX_OBJ_NAME+1]
// Control name
char win[MAX_WIN_PATH+1]
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
// See Control Structure eventMod Field on page 
III-438
String userData
// Primary unnamed user data
Int32 blockReentry
// Obsolete, see Control Structure blockReentry 
Field on page III-439
Int32 checked
// Checkbox state
char vName[MAX_OBJ_NAME+2 + (MAXDIMS * (MAX_OBJ_NAME+5)) + 1]
// Name of variable
WAVE ckWave;
// Valid if using wave
Int32 rowIndex
// Row index for a wave, if rowLabel is empty
char rowLabel[MAX_OBJ_NAME+1]
// Wave row dimension label
Int32 colIndex
// Column index for a wave if colLabel is empty
char colLabel[MAX_OBJ_NAME+1]
// Wave column dimension label
Int32 layerIndex
// Layer index for a wave if layerLabel is empty
char layerLabel[MAX_OBJ_NAME+1]
// Wave layer dimension label
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed
1
Mouse down
2
Mouse up
3
Mouse up outside control
4
Mouse moved
5
Mouse enter
6
Mouse leave
7
Mouse dragged while outside the control
