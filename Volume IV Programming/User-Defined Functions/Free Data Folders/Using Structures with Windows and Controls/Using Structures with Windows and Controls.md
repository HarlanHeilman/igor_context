# Using Structures with Windows and Controls

Chapter IV-3 — User-Defined Functions
IV-103
Note the use of WAVE, NVAR, SVAR and FUNCREF in the function foo. These keywords are required both 
in the structure definition and again in the function, when the structure members are initialized.
Built-In Structures
Igor includes a few special purpose, predefined structures for use with certain operations. Some of those 
structures use these predefined general purpose structures:
Structure Rect
Int16 top,left,bottom,right
EndStructure
Structure Point
Int16 v,h
EndStructure
Structure RGBColor
UInt16 red, green, blue
EndStructure
A number of operations use built-in structures that the Igor programmer can use. See the command refer-
ence information for details about these structures and their members.
Applications of Structures
Structures are useful for reading and writing disk files. The FBinRead and the FBinWrite understand struc-
ture variables and read or write the entire structure from or to a disk file. The individual fields of the struc-
ture are byte-swapped if you use the /B flag.
Structures can be used in complex programming projects to reduce the dependency on global objects and 
to simplify passing data to and getting data from functions. For example, a base function might allocate a 
local structure variable and then pass that variable on to a large set of lower level routines. Because struc-
ture variables are passed by reference, data written into the structure by lower level routines is available to 
the higher level. Without structures, you would have to pass a large number of individual parameters or 
use global variables and data folders.
Using Structures with Windows and Controls
Action procedures for controls and window hook functions take parameters that use predefined structure 
types. These are listed under Built-In Structures on page IV-103.
Operation
Structure Name
Button
WMButtonAction
CheckBox
WMCheckboxAction
CustomControl
WMCustomControlAction
ListBox
WMListboxAction
ModifyFreeAxis
WMAxisHookStruct
PopupMenu
WMPopupAction
SetVariable
WMSetVariableAction
SetWindow
WMWinHookStruct
SetWindow
WMTooltipHookStruct
Slider
WMSliderAction
TabControl
WMTabControlAction
