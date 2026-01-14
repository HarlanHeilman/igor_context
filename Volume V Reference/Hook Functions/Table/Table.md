# Table

TabControl
V-1014
Example
Designing a TabControl with all the accompanying interior controls can be somewhat difficult. Here is a 
suggested technique:
First, create and set the size and label for one tab. Then create the various controls for this first tab. Before 
starting on the second tab, create the TabControl’s procedure so that it can be used to hide the first set of 
controls. Then add the second tab, click it to run your procedure and start adding controls for this new tab. 
When done, update your procedure so the new controls are hidden when you start on the third tab.
Here is an example:
1. Create a panel and a TabControl:
NewPanel /W=(150,50,478,250)
ShowTools
TabControl MyTabControl,pos={29,38},size={241,142},tabLabel(0)="First Tab",value=0
2. Add a few controls to the interior of the TabControl:
Button button0,pos={52,72},size={80,20},title="First"
CheckBox check0,pos={52,105},size={102,15},title="Check first",value=0
3. Write an action procedure:
Function TabActionProc(tc) : TabControl
STRUCT WMTabControlAction& tc
switch(tc.eventCode)
case 2:
// Mouse up
Button button0, disable=(tc.tab!=0)
CheckBox check0, disable=(tc.tab!=0)
break
endswitch
End
4. Set the action procedure and add a new tab:
TabControl MyTabControl,proc=TabActionProc,tabLabel(1)="Second Tab"
5. Click the second tab, which hides the first tab’s controls, and then add new controls like this:
Button button1,pos={58,73},size={80,20},title="Second"
CheckBox check1,pos={60,105},size={114,15},title="Check second",value= 0
6. Finally, change the action procedure by adding these lines at the end:
Button button1,disable=(tc.tab!=1)
CheckBox check1,disable=(tc.tab!=1)
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The GetUserData function for retrieving named user data.
The ControlInfo operation for information about the control.
The ModifyControl and ModifyControlList operations.
TabControl 
TabControl
TabControl is a procedure subtype keyword that identifies a macro or function as being an action procedure 
for a user-defined tab control. See Procedure Subtypes on page IV-204 for details. See TabControl for 
details on creating a tab control.
Table 
Table
Table is a procedure subtype keyword that identifies a macro as being a table recreation macro. It is 
automatically used when Igor creates a window recreation macro for a table. See Procedure Subtypes on 
page IV-204 and Killing and Recreating a Table on page II-241 for details.
