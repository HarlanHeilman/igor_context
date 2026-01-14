# Pop-Up Menus in Simple Dialogs

Chapter IV-6 — Interacting with the User
IV-145
if (V_Flag)
return -1
// User canceled
endif
Print "Diagonal=",sqrt(x^2+y^2)
End
If you run the CalcDiagDialog function, you see the following dialog:
If the user presses Continue without changing the default values, “Diagonal= 22.3607” is printed in the 
history area of the command window. If the user presses Cancel, nothing is printed because DoPrompt sets 
the V_Flag variable to 1 in this case.
The simple input dialog allows for up to 10 numeric or string variables. When more than 5 items are used, 
the dialog uses two columns and you may have to limit the length of your Prompt text.
The simple input dialog is unique in that you can enter not only literal numbers or strings but also numeric 
expressions or string expressions. Any literal strings that you enter must be quoted.
If the user presses the Help button, Igor searches for a help topic with a name derived from the dialog title. 
If such a help topic is not found, then generic help about the simple input dialog is presented. In both cases, 
the input dialog remains until the user presses either Continue or Cancel.
Pop-Up Menus in Simple Dialogs
The simple input dialog supports pop-up menus as well as text items. The pop-up menus can contain an 
arbitrary list of items such as a list of wave names. To use a pop-up menu in place of the normal text entry 
item in the dialog, you use the following syntax in the prompt declaration:
Prompt <variable name>, <title string>, popup <menu item list>
The popup keyword indicates that you want a pop-up menu instead of the normal text entry item. The 
menu list specifies the items in the pop-up menu separated by semicolons. For example:
Prompt color, "Select Color", popup "red;green;blue;"
If the menu item list is too long to fit on one line, you can compose the list in a string variable like so:
String stmp= "red;green;blue;"
stmp += "yellow;purple"
Prompt color, "Select Color", popup stmp
The pop-up menu items support the same special characters as the user-defined menu definition (see 
Special Characters in Menu Item Strings on page IV-133) except that items in pop-up menus are limited 
to 50 characters, keyboard shortcuts are not supported, and special characters are disabled by default.
You can use pop-up menus with both numeric and string parameters. When used with numeric parameters 
the number of the item chosen is placed in the variable. Numbering starts from one. When used with string 
parameters the text of the chosen item is placed in the string variable.
There are a number of functions, such as the WaveList function (see page V-1075) and the TraceNameList 
function (see page V-1044), that are useful in creating pop-up menus.

Chapter IV-6 — Interacting with the User
IV-146
To obtain a menu item list of all waves in the current data folder, use:
WaveList("*", ";", "")
To obtain a menu item list of all waves in the current data folder whose names end in “_X”, use:
WaveList("*_X", ";", "")
To obtain a menu item list of all traces in the top graph, use:
TraceNameList("", ";", 1)
For a list of all contours in the top graph, use ContourNameList. For a list of all images, use ImageNameList. 
For a list of waves in a table, use WaveList.
This next example creates two pop-up menus in the simple input dialog.
Menu "Macros"
"Color Trace...", ColorTraceDialog()
End
Function ColorTraceDialog()
String traceName
Variable color=3
Prompt traceName,"Trace",popup,TraceNameList("",";",1)
Prompt color,"Color",popup,"red;green;blue"
DoPrompt "Color Trace",traceName,color
if( V_Flag )
return 0
// user canceled
endif
if (color == 1)
ModifyGraph rgb($traceName)=(65000, 0, 0)
elseif(color == 2)
ModifyGraph rgb($traceName)=(0, 65000, 0)
elseif(color == 3)
ModifyGraph rgb($traceName)=(0, 0, 65000)
endif
End
If you choose Color Trace from the Macros menu, Igor displays the simple input dialog with two pop-up 
menus. The first menu contains a list of all traces in the target window which is assumed to be a graph. The 
second menu contains the items red, green and blue with blue (item number 3) initially chosen.
After you choose the desired trace and color from the pop-up menus and click the Continue button, the 
function continues execution. The string parameter traceName will contain the name of the trace chosen 
from the first pop-up menu. The numeric parameter color will have a value of 1, 2 or 3, corresponding to 
red, green and blue.
In the preceding example, we needed a trace name to pass to the ModifyGraph operation. In another 
common situation, we need a wave reference to operate on. For example:
