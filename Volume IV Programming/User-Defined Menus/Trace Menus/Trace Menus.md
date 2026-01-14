# Trace Menus

Chapter IV-5 — User-Defined Menus
IV-137
As with other keyboard shortcuts, you can specify that one or more modifier keys must be pressed along 
with the function key. By including the “C” modifier character, you can specify that Command (Macintosh) 
or Ctrl (Windows) must also be pressed:
Menu "Macros"
// Function keys without modifiers
"Test/F5"
// F5
// Function keys with Shift and/or Option/Alt modifiers
"Test/SF5"
// Shift-F5 (Macintosh), Shift+F5 (Windows)
"Test/OF5"
// Option-F5, Alt+F5
"Test/SOF5"
// Shift-Option-F5, Shift+Alt+F5
// Function keys with Command (Macintosh) or Ctrl (Windows) modifiers
"Test/CF5"
// Cmd-F5, Ctrl+F5
"Test/SCF5"
// Shift-Cmd-F5, Shift-Ctrl-F5
"Test/OCF5"
// Option-Cmd-F5, Alt-Ctrl-F5
"Test/OSCF5"
// Option-Shift-Cmd-F5, Alt-Shift-Ctrl-F5
// Function keys with Ctrl (Macintosh) or Meta (Windows) modifiers
"Test/LOSCF5"
// Control-Option-Shift-Cmd-F5, Meta+Alt+Shift+Ctrl+F5
End
Although some keyboards have function keys labeled F13 and higher, they do not behave consistently and 
are not supported.
Marquee Menus
Igor has two menus called “marquee menus”. In graphs and page layouts you create a marquee when you 
drag diagonally. Igor displays a dashed-line box indicating the area of the graph or layout that you have 
selected. If you click inside the marquee, you get a marquee menu.
You can add your own menu items to a marquee menu by creating a GraphMarquee or LayoutMarquee 
menu definition. For example:
Menu "GraphMarquee"
"Print Marquee Coordinates", GetMarquee bottom; Print V_left, V_right
End
The use of keyboard shortcuts is not supported in marquee menus.
See Marquee Menu as Input Device on page IV-163 for details.
Trace Menus
Igor has two “trace” menus named “TracePopup” and “AllTracesPopup”. When you control-click or right-
click in a graph on a trace you get the TracesPopup menu. If you press Shift while clicking, you get the All-
TracesPopup (standard menu items in that menu operated on all the traces in the graph). You can append 
menu items to these menus with Menu “TracePopup” and Menu “AllTracesPopup” definitions.
For example, this code adds an Identify Trace item to the TracePopup contextual menu but not to the All-
TracesPopup menu:
Menu "TracePopup"
"Identify Trace", /Q, IdentifyTrace()
End
Function IdentifyTrace()
GetLastUserMenuInfo
Print S_graphName, S_traceName
End
