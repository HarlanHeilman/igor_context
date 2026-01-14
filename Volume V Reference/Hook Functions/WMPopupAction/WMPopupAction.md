# WMPopupAction

WMMarkerHookStruct
V-1109
WMListboxAction row and col Fields
The row field is the zero-based row number of the first selected row in the list or -1 if the selection is in title 
area. If an event occurs in the empty space below the last row, the row field is set to the number of rows in 
the list which is one greater than the row number of the last row. A mouse down event in an empty list 
reports row=0.
The col field is the column number of the selection.
The meanings of row and col are different for eventCodes 8 through 11:
If eventCode is 11, row is the horizontal shift in pixels of the column col that was resized, not the total 
horizontal shift of the list as reported in V_horizScroll by ControlInfo. If row is negative, the divider was 
moved to the left. col=0 corresponds to adjusting the divider on the right side of the first column. Use 
ControlInfo to get a list of all column widths.
Selection Events 4 and 5
These events are sent when a click on the Listbox could result in a change in selection. If it is important to 
you to respond only when the selection actually changes, you will need to keep track of the selection 
yourself.
These events are not sent if the list is empty.
WMMarkerHookStruct
See Custom Marker Hook Functions on page IV-308 for further explanation of WMMarkerHookStruct.
Structure WMMarkerHookStruct
Int32 usage
// 0 = normal draw, 1 = legend draw
Int32 marker
// Marker number minus start
float x, y
// Location of desired center of marker
float size
// Half width/height of marker
Int32 opaque
// 1 if marker should be opaque
float penThick
// Stroke width
STRUCT RGBColor mrkRGB
// Fill color
STRUCT RGBColor eraseRGB
// Background color
STRUCT RGBColor penRGB
// Stroke color
WAVE ywave
// Trace's y wave
double ywIndex
// Point number on ywave where marker is being drawn
char winName[MAX_HostChildSpec+1] // Full path to window or subwindow
char traceName[MAX_OBJ_INST+1] 
// Full name of trace or "" if no trace
EndStructure
WMPopupAction
This structure is passed to action procedures for popup menu controls created using the PopupMenu 
operation.
11
Column divider resized.
12
Keystroke, character code is place in row field.
See Note on Keystroke Event on page V-495.
13
Checkbox was clicked. This event is sent after selWave is updated.
Code row
col
8
top visible row horiz shift in pixels.
9
top visible row horiz shift (user scroll).
9
-1
horiz shift (hScroll keyword).
10
top visible row -1 (row keyword).
10
-1
first visible col (col keyword).
11
column shift
column resized by user.
Event Code
Event
