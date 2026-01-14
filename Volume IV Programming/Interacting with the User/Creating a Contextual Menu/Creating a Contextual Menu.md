# Creating a Contextual Menu

Chapter IV-6 — Interacting with the User
IV-162
Creating a Contextual Menu
You can use the PopupContextualMenu operation to create a pop-up menu in response to a contextual 
click (control-click (Macintosh) or right-click). You would do this from a window hook function or from the 
action procedure for a control in a control panel.
In this example, we create a control panel with a list. When the user right-clicks on the list, Igor sends a 
mouse-down event to the listbox procedure, TickerListProc in this case. The listbox procedure uses the 
eventMod field of the WMListboxAction structure to determine if the click is a right-click. If so, it calls Han-
dleTickerListRightClick which calls PopupContextualMenu to display the contextual menu.
Menu "Macros"
"Show Demo Panel", ShowDemoPanel()
End
static Function HandleTickerListRightClick()
String popupItems = ""
popupItems += "Refresh;"
PopupContextualMenu popupItems
strswitch (S_selection)
case "Refresh":
DoAlert 0, "Here is where you would refresh the ticker list."
break
endswitch
End
Function TickerListProc(lba) : ListBoxControl
STRUCT WMListboxAction &lba
switch (lba.eventCode)
case 1:
// Mouse down
if (lba.eventMod & 0x10)// Right-click?
HandleTickerListRightClick()
endif
break
endswitch
return 0
End
Function ShowDemoPanel()
DoWindow/F DemoPanel
if (V_flag != 0)
return 0 // Panel already exists.
endif
// Create panel data.
Make/O/T ticketListWave = {{"AAPL","IBM","MSFT"}, {"90.25","86.40","17.17"}}
// Create panel.
NewPanel /N=DemoPanel /W=(321,121,621,321) /K=1
ListBox TickerList,pos={48,16},size={200,100},fSize=12
ListBox TickerList,listWave=root:ticketListWave
ListBox TickerList,mode= 1,selRow= 0, proc=TickerListProc
End
