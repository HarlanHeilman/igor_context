# Disabling and Hiding Controls

Chapter III-14 — Controls and Control Panels
III-436
ControlInfo is generally not used for the other style of control panel in which the action procedure for each 
control acts as soon as that control is clicked.
Updating Controls
You can use the ControlUpdate operation (page V-94) to cause a given control to redraw with its current 
value. You would use this in a procedure after changing the value or appearance of a control to display the 
changes before the normal update occurs.
Help Text for User-Defined Controls
Each control type has a help text property, set using the help keyword, through which you add a help tip. 
In Igor Pro 9.00 and later, tips are limited to 1970 bytes. Previously they were limited to 255 bytes.
Here is an example:
Button button0 title="Beep", help={"This button beeps."}
The tip appears when the user moves the mouse over the control, if tooltips are enabled in the Help section 
of the Miscellaneous Settings dialog.
You can use a limited set of HTML tags for formatting. See HTML Tags in Tooltips on page IV-311.
Modifying Controls
The control operations create a new control if the name parameter doesn’t match a control already in the 
window. The operations modify an existing control if the name does match a control in the window, but 
generate an error if the control kind doesn’t match the operation.
For example, if a panel already has a button control named button0, you can modify it with another 
Button button0 command:
Button button0 disable=1
// hide
However, if you use a Checkbox instead of Button, you get a “button0 is not a Checkbox” error.
You can use the ModifyControl operation (page V-606) and ModifyControlList operation (page V-608) to 
modify a control without needing to know what kind of control it is:
ModifyControl button0 disable=1
// hide
This is especially handy when used in conjunction with tab controls.
Disabling and Hiding Controls
All controls support the keyword “disable=d” where d can be:
Charts and ValDisplays do not change appearance when disable=2 because they are read-only.
SetVariables also have the noedit keyword. This is different from disable=2 mode in that noedit allows user input 
via the up or down arrows but disable=2 does not.
0:
Normal operation
1:
Hidden
2:
User input disabled
3:
Hidden and user input disabled
