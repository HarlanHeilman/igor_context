# SpecialCharacterInfo

SpecialCharacterInfo
V-893
The SoundSaveWave operation was added in Igor Pro 7.00. 24-bit integer and 64-bit floating point support 
were added in Igor Pro 9.00.
Output Variables
SoundSaveWave sets these automatically created variables:
Examples
// Create a simple sound (1000 Hz tone burst)
Make/O/N=10000 mySound
// Single-precision wave, 10,000 values
SetScale/P x, 0, 1/8000, "" mySound
// 8000 Hz sampling frequency (1.25 seconds)
mySound= sin(2*pi*1000*x)
// 1000 Hz tone
Hanning mySound
// Fade in and out
// Save it to a file, chosen from the Save File dialog
SoundSaveWave "AIFC", mySound, "my sound.aif"
// Create a floating point stereo frequency sweep
Make/O/N=(20000,2) stereoSineSoundF32
// 32-bit float data
SetScale/P x,0,1e-4,stereoSineSoundF32
// Set sample rate to 10KHz
stereoSineSoundF32= sin(2*Pi*(1000 + (1-2*q)*150*x)*x)
NewPath sound
// Create a symbolic path via dialog
SoundSaveWave/P=sound/O "WAVE", stereoSineSoundF32
See Also
SoundLoadWave, PlaySound, WaveType, WaveInfo
SpecialCharacterInfo 
SpecialCharacterInfo(notebookNameStr, specialCharacterNameStr, whichStr)
The SpecialCharacterInfo function returns a string containing information about the named special 
character in the named notebook window.
Parameters
If notebookNameStr is "", the top visible notebook is used. Otherwise notebookNameStr contains either 
kwTopWin for the top notebook window, the name of a notebook window or a host-child specification (an 
hcSpec) such as Panel0#nb0. See Subwindow Syntax on page III-92 for details on host-child specifications.
specialCharacterNameStr is the name of a special character in the notebook.
If specialCharacterNameStr is "" and if exactly one special character is selected, the selected special 
character is used. If other than exactly one special character is selected, an error is returned.
whichStr identifies the information item you want. Because SpecialCharacterInfo can return several items 
that may contain semicolons, it does not return a semicolon-separated keyword-value list like other info 
functions. Instead it returns just one item as specified by whichStr.
Details
Here are the supported values for whichStr.
V_flag
Set to 0 if the wave was successfully saved to the file or to a non-zero error code.
S_fileName
Set to the name of the saved file.
S_path
Set to the full path to the file's directory.
Keyword
Returned Information
NAME
The name of the special character.
FRAME
0: None
1: Single
2: Double
3: Triple
4: Shadow

SpecialCharacterInfo
V-894
These keywords apply to Igor-object pictures only. If the specified character is not an Igor-object picture, “” 
is returned.
The remaining keywords apply to notebook action characters only. If the specified special character is not 
a notebook action character, "" is returned.
If whichStr is an unknown keyword, SpecialCharacterInfo returns "" but does not generate an error.
Examples
Function PrintSpecialCharacterInfo(notebookName, specialCharacterName)
String notebookName, specialCharacterName
String typeStr=SpecialCharacterInfo(notebookName, specialCharacterName, "TYPE")
String locStr=SpecialCharacterInfo(notebookName, specialCharacterName, "LOC")
Printf "TYPE: %s\r", typeStr
Printf "LOC: %s\r", locStr
End
See Also
The Notebook and NotebookAction operations; the SpecialCharacterList function; Using Igor-Object 
Pictures on page III-18.
LOC
Paragraph and character position (e.g., 1,3).
SCALING
Horizontal and vertical scaling in units of one tenth of a percent (e.g., 1000,1000).
TYPE
Special character type is: Picture, Graph, Table, Layout, Action, ShortDate, 
LongDate, AbbreviatedDate, Time, Page, TotalPages, or WindowTitle.
Keyword
Returned Information
WINTYPE
1 for graphs, 2 for tables, 3 for layouts.
OBJECTNAME
The name of the window with which the special character is associated.
Keyword
Returned Information
BGRGB
Background color in RGB format (e.g., 65535,65534,49151).
COMMANDS
Command string.
ENABLEBGRGB
1 if the action’s background color is enabled, 0 if not.
HELPTEXT
Help text string.
IGNOREERRORS
0 or 1.
LINKSTYLE
0 or 1.
PADDING
The value of the left, right, top, bottom and internal padding properties, in that 
order (.e.g, 4,4,4,4,8).
PICTURE
1 if the action has a picture, 0 if not.
PROCPICTNAME
The name of the action Proc Picture or "" if none.
QUIET
0 or 1.
SHOWMODE
1: Title only
2: Picture only
3: Picture below title
4: Picture above title
5: Picture to the left of title
6: Picture to the right of title
TITLE
Title string.
Keyword
Returned Information
