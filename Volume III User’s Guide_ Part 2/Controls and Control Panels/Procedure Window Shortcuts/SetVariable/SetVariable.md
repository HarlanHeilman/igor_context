# SetVariable

Chapter III-14 — Controls and Control Panels
III-417
and another where there is no current item and a title is shown in the box:
The first form is usually used to choose one of many items while the second is used to run one of many com-
mands.
Pop-up menus can also be configured to act like Igor’s color, line style, pattern, or marker pop-up menus. 
These always show the current item.
SetVariable 
SetVariable controls also can take on a number of forms and can display numeric values. Unlike Value 
Display controls that display the value of an expression, SetVariable controls are connected to individual 
global variables and can be used to set or change those variables in addition to reading out their current 
value. SetVariable controls can also be used with global string variables to display or set short one line 
strings. SetVariable controls are automatically updated whenever their associated variables are changed.
When connected to a numeric variable, these controls can optionally have up or down arrows that incre-
ment or decrement the current value of the variable by an amount specified by the programmer. Also, the 
programmer can set upper and lower limits for the numeric readouts.
New values for both numeric and string variables can be entered 
by directly typing into the control. If you click the control once 
you will see a thick border form around the current value.
You can then edit the readout text using the standard techniques including Cut, Copy, and Paste. If you 
want to discard changes you have made, press Escape. To accept changes, press Return, Enter, or Tab or 
click anywhere outside of the control. Tab enters the current value and also takes you to the next control if 
any. Shift-Tab is similar but takes you to the previous control if any.
If the control is connected to a numeric variable and the text you have entered can not be converted to a 
number then a beep will be emitted when you try to enter the value and no change will be made to the value 
of the variable. If the value you are trying to enter exceeds the limits set by the programmer then your value 
will be replaced by the nearest limit.
When a numeric control is selected for editing, the Up and Down Arrow keys on the keyboard act like the 
up and down buttons on the control.
Changing a value in a SetVariable control may run a procedure if the programmer has specified one.
SetVariable Controls and Data Folders
SetVariable controls remember the data folder in which the variable exists, and continue to function prop-
erly when the current data folder is different than the controlled variable. See SetVariable on page III-417.
The system variables (K0 through K19) belong to no particular data folder (they are available from any data 
folder), and there is only one copy of these variables. If you create a SetVariable controlling K0 while the 
current data folder is “aFolder”, and another SetVariable controlling K0 while the current data folder is 
“bFolder”, they are actually controlling the same K0.
