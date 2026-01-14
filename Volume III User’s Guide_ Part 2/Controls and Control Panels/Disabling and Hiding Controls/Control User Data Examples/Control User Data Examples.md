# Control User Data Examples

Chapter III-14 — Controls and Control Panels
III-440
User Data for Controls
You can store arbitrary data with a control using the userdata keyword. You can set user data for the following 
controls: Button, CheckBox, CustomControl, ListBox, PopupMenu, SetVariable, Slider, and TabControl.
Each control has a primary, unnamed user data string that is used by default. You can also store an unlim-
ited number of additional user data strings by specifying a name for each one. The name can be any legal 
standard Igor name.
You can retrieve information from the default user data using the ControlInfo operation (page V-89), which 
returns such information in the S_UserData string variable. To retrieve any named user data, you must use 
the GetUserData operation (page V-316).
Although there is no size limit to how much user data you can store, it does have to be generated as part of 
the recreation macro for the window when experiments are saved. Consequently, huge user data strings 
can slow down experiment saving and loading
User data is intended to replace or reduce the usage of global variables for maintaining state information 
related to controls.
Control User Data Examples
:Here is a simple example of a button with user data:
NewPanel
Button b0, userdata="user data for button b0"
Print GetUserData("","b0","")
Here is a more complex example.
Copy the following code into the procedure window of a new experiment and run the Panel0 macro. Then 
click the buttons.
Structure mystruct
Int32 nclicks
double lastTime
EndStructure
Function ButtonProc(ctrlName) : ButtonControl
String ctrlName
STRUCT mystruct s1
String s= GetUserData("", ctrlName,"")
if( strlen(s) == 0 )
print "first click"
else
StructGet/S s1,s
// Warning: Next command is wrapped to fit on the page.
printf "button %s clicked %d time(s), last click = %s\r",ctrlName, s1.nclicks, 
Secs2Date(s1.lastTime, 1 )+" "+Secs2Time(s1.lastTime,1)
endif
s1.nclicks += 1
s1.lastTime= datetime
StructPut/S s1,s
Button $ctrlName,userdata= s
End
Window Panel0() : Panel
PauseUpdate; Silent 1
// building window...
NewPanel /W=(150,50,493,133)
SetDrawLayer UserBack
Button b0,pos={12,8},size={50,20},proc=ButtonProc,title="Click"
Button b1,pos={65,8},size={50,20},proc=ButtonProc,title="Click"
Button b2,pos={119,8},size={50,20},proc=ButtonProc,title="Click"
Button b3,pos={172,8},size={50,20},proc=ButtonProc,title="Click"
Button b4,pos={226,8},size={50,20},proc=ButtonProc,title="Click"
EndMacro
