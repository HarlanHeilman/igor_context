# WMListboxAction

WMListboxAction
V-1108
Variable ymin
Variable ymax
Variable zmin
Variable zmax
Variable eulerA
Variable eulerB
Variable eulerC
Variable wheelDx
Variable wheelDy
EndStructure
WMListboxAction
This structure is passed to action procedures for listbox controls created using the ListBox operation.
Structure WMListboxAction
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
Int32 eventCode2
// Obsolete
Int32 row
// Selection row. See ListBox for details.
Int32 col
// Selection column. See ListBox for details.
WAVE/T listWave
// List wave specified by ListBox command
WAVE selWave
// Selection wave specified by ListBox command
WAVE colorWave
// Color wave specified by ListBox command
WAVE/T titleWave
// Title wave specified by ListBox command
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMListboxAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to the listbox action procedure has the following meaning:
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed.
1
Mouse down.
2
Mouse up.
3
Double click.
4
Cell selection (mouse or arrow keys).
5
Cell selection plus Shift key.
6
Begin edit.
7
Finish edit.
8
Vertical scroll. See Scroll Event Warnings on page V-495.
9
Horizontal scroll by user or by the hScroll=h keyword.
10
Top row set by row=r or first column set by col=c keywords.
