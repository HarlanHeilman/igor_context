# Dynamic Menu Items

Chapter IV-5 — User-Defined Menus
IV-129
Adding a New Main Menu
You can add an entirely new menu to the main menu bar by using a menu title that is not used by Igor. For 
example:
Menu "Test"
"Load Data File"
"Do Analysis"
"Print Report"
End
Dynamic Menu Items
In the examples shown so far all of the user-defined menu items are static. Once defined, they never change. 
This is sufficient for the vast majority of cases and is by far the easiest way to define menu items.
Igor also provides support for dynamic user-defined menu items. A dynamic menu item changes depending 
on circumstances. The item might be enabled under some circumstances and disabled under others. It might 
be checked or deselected. Its text may toggle between two states (e.g. “Show Tools” and “Hide Tools”).
Because dynamic menus are much more difficult to program than static menus and also slow down Igor’s 
response to a menu-click, we recommend that you keep your use of dynamic menus to a minimum. The 
effort you expend to make your menu items dynamic may not be worth the time you spend to do it.
For a menu item to be dynamic, you must define it using a string expression instead of the literal strings 
used so far. Here is an example.
Function DoAnalysis()
Print "Analysis Done"
End
Function ToggleTurboMode()
Variable prevMode = NumVarOrDefault("root:gTurboMode", 0)
Variable/G root:gTurboMode = !prevMode
End
Function/S MacrosMenuItem(itemNumber)
Variable itemNumber
Variable turbo = NumVarOrDefault("root:gTurboMode", 0)
if (itemNumber == 1)
if (strlen(WaveList("*", ";", ""))==0) // any waves exist?
return "(Do Analysis"
// disabled state
else
return "Do Analysis"
// enabled state
endif
endif
if (itemNumber == 2)
if (turbo)
return "!"+num2char(18)+"Turbo"
// Turbo with a check
else
return "Turbo"
endif
endif
End
Menu "Macros", dynamic
MacrosMenuItem(1)
MacrosMenuItem(2), /Q, ToggleTurboMode()
End
