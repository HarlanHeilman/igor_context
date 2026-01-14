# Creating Slider Controls

Chapter III-14 — Controls and Control Panels
III-429
To associate a SetVariable control with a variable that is not in the current data folder at the time SetVariable 
runs, you must use a data folder path:
Variable/G root:Packages:ImagePack:globalVar=99
SetVariable setvar0 value=root:Packages:ImagePack:globalVar
Unlike PopupMenu controls, SetVariable controls remember the current data folder when the SetVariable 
command executes. Thus an equivalent set of commands is:
SetDataFolder root:Packages:ImagePack
Variable/G globalVar=99
SetVariable setvar0 value=globalVar
Also see SetVariable Controls and Data Folders on page III-417.
You can control the style of the numeric readout via the format keyword. For example, the string "%.2d" 
will display the value with 2 digits past the decimal point. You should not use the format string to include 
text in the readout because Igor has to read back the numeric value. You may be able to add suffixes to the 
readout but prefixes will not work. When used with string variables the format string is not used.
Often it is sufficient to query the value using ControlInfo and you there is no need for an action procedure. 
If you want to do something every time the value is changed, then you need to create an action procedure of 
the following form:
Function SetVarProc(sva) : SetVariableControl
STRUCT WMSetVariableAction sva
switch(sva.eventCode)
case 1:
// Mouse up
case 2:
// Enter key
case 3:
// Live update
Variable dval = sva.dval
String sval = sva.sval
break
break
case -1:
// Control being killed
break
endswitch
End
varName will be the name of the variable being used. If the variable is a string variable then varStr will 
contain its contents and varNum will be set to the results of an attempt to convert the string to a number. If 
the variable is numeric then varNum will contain its contents and varStr will be set to the results of a 
number to string conversion.
If the value is a string, then sva.sval contains the value. If it is numeric, then sva.dval contains the value. 
sva.isStr is 0 for numeric values and non-zero for string values.
When the user presses and holds in the up or down arrows then the value of the variable will be steadily 
changed by the increment value but your action procedure will not be called until the user releases the 
mouse button.
Creating Slider Controls
The Slider creates or modifies a slider control.
A slider control is tied to a numeric global variables or to a numeric internal value stored in the control itself. To 
minimize clutter, you should use internal values in most cases. The value is changed by dragging the “thumb” 
part of the control.
There are many options for labelling the numeric range such as setting the number of ticks.
