# HideTools

HideInfo
V-347
Hiding a built-in menu to which a user-defined menu is attached results in a built-in menu with only the 
user-defined items. For example, if this menu definition attaches items to the built-in Graph menu:
Menu "Graph"
"Do My Graph Thing", ThingFunction()
End
Calling HideIgorMenus "Graph" will still leave a Graph menu showing (when a Graph is the top-most 
target window) with only the user-defined menu(s) in it: in this example the one “Do My Graph Thing” item.
Hiding the Macros menu hides menus created from Macro definitions like:
Macro MyMacro()
Print "Hello, world."
End
but does not hide normal user-defined “Macros” definitions like:
Menu "Macros"
"Macro 1", MyMacro(1)
End
You can set user-defined menus to hide and show along with built-in menus by adding the optional 
hideable keyword to the menu definition:
Menu "Graph", hideable
"Do My Graph Thing", ThingFunction()
End
Then HideIgorMenus "Graph" will hide those items, too. If all user-defined Graph menu definitions use 
the hideable keyword, then no Graph menu will appear in the menu bar.
Some WaveMetrics procedures use the hideable keyword so that only customer-defined menus remain 
when HideIgorMenus is executed.
See Also
ShowIgorMenus, DoIgorMenu, SetIgorMenuMode, Chapter IV-5, User-Defined Menus
HideInfo 
HideInfo [/W=winName]
The HideInfo operation removes the info panel from a graph if it was previously shown by the ShowInfo 
operation.
Flags
See Also
The ShowInfo operation.
Programming With Cursors on page II-321.
HideProcedures 
HideProcedures
The HideProcedures operation hides all procedure windows without closing or killing them.
See Also
The DisplayProcedure and DoWindow operations.
HideTools 
HideTools [/A/W=winName]
The HideTools operation hides the tool palette in the top graph or control panel if it was previously shown 
by the ShowTools operation.
File
Edit
Data
Analysis
Macros
Windows
Graph 
Layout
Notebook
Panel
Procedure
Table
Misc
Help
/W=winName
Hides the info panel in the named window.
