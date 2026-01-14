# WMCustomControlAction

WMCustomControlAction
V-1105
Int32 chunkIndex
// Chunk index for a wave if chunkLabel is empty
char chunkLabel[MAX_OBJ_NAME+1]
// Wave chunk dimension label
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMCheckboxAction eventCode Field
Your action function should test the eventCode field and respond only to documented eventCode values 
because other event codes may be added in the future.
The event code passed to the checkbox action procedure has the following meaning:
WMCustomControlAction
This structure is passed to action procedures for custom controls created using the CustomControl 
operation.
Structure WMCustomControlAction
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
Int32 missedEvents
// TRUE when events occurred but the user
// function was not available for action
Int32 mode
// General purpose
// Used only when eventCode==kCCE_frame
Int32 curFrame
// Input and output
// Used when eventCode is kCCE_mousemoved, kCCE_mouseenter or kCCE_mouseleave
Int32 needAction
// See below for details
// These fields are valid only with value=varName
Int32 isVariable
// TRUE if varName is a variable
Int32 isWave
// TRUE if varName referenced a wave
Int32 isString
// TRUE if varName is a String type
NVAR nVal
// Valid if isVariable and not isString
SVAR sVal
// Valid if isVariable and isString
WAVE nWave
// Valid if isWave and not isString
WAVE/T sWave
// Valid if isWave and isString
Int32 rowIndex
// If isWave, this is the row index
// unless rowLabel is not empty
char rowLabel[32]
// Wave row label
// These fields are valid only when eventCode==kCCE_char
Int32 kbChar
// Keyboard key character code
Int32 specialKeyCode
// See Keyboard Events on page IV-300 - Added in Igor Pro 7
char keyText[16]
// UTF-8 string representing key struck - Added in Igor Pro 7
Int32 kbMods
// Keyboard key modifiers bit field. See details below.
EndStructure
The constants used to specify the size of structure char arrays are internal to Igor Pro and may change.
WMCustomControlAction eventCode Field
When determining the state of the eventCode member in the WMCustomControlAction structure, the 
various values you use are listed in the following table. You can define the kCCE symbolic constants by 
adding this to your procedure file:
Event Code
Event
-3
Control received keyboard focus (Igor8 or later)
-2
Control received keyboard focus (Igor8 or later)
-1
Control being killed
2
Mouse up, checkbox toggled
