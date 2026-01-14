# CheckBoxControl

CheckBoxControl
V-67
Examples
// Create a radio button group
Window Panel0() : Panel
PauseUpdate; Silent 1
// building window …
NewPanel /W=(150,50,353,212)
Variable/G gSelectedRadioButton = 1
CheckBox radioButton1,pos={52,25},size={78,15},title="Radio 1"
CheckBox radioButton1,value=1,mode=1,proc=MyRadioButtonProc
CheckBox radioButton2,pos={52,45},size={78,15},title="Radio 2"
CheckBox radioButton2,value=0,mode=1,proc=MyRadioButtonProc
CheckBox radioButton3,pos={52,65},size={78,15},title="Radio 3"
CheckBox radioButton3,value= 0,mode=1,proc=MyRadioButtonProc
EndMacro
static Function HandleRadioButtonClick(controlName)
String controlName
NVAR gSelectedRadioButton = root:gSelectedRadioButton
strswitch(controlName)
case "radioButton1":
gSelectedRadioButton = 1
break
case "radioButton2":
gSelectedRadioButton = 2
break
case "radioButton3":
gSelectedRadioButton = 3
break
endswitch
CheckBox radioButton1, value = gSelectedRadioButton==1
CheckBox radioButton2, value = gSelectedRadioButton==2
CheckBox radioButton3, value = gSelectedRadioButton==3
End
Function MyRadioButtonProc(cb) : CheckBoxControl
STRUCT WMCheckboxAction& cb
switch(cb.eventCode)
case 2:
// Mouse up
HandleRadioButtonClick(cb.ctrlName)
break
endswitch
return 0
End
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The ControlInfo operation for information about the control.
The GetUserData function for retrieving named user data.
CheckBoxControl 
CheckBoxControl
CheckBoxControl is a procedure subtype keyword that identifies a macro or function as being an action 
procedure for a user-defined checkbox control. See Procedure Subtypes on page IV-204 for details. See 
CheckBox for details on creating a checkbox control.
