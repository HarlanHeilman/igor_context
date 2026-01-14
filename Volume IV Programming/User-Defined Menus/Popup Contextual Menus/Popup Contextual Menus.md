# Popup Contextual Menus

Chapter IV-5 — User-Defined Menus
IV-141
endif
if (!doSVG && shiftKeyPressed)
return ""
// Caller wants PNG menu item but shift key is pressed
endif
String selectedGraphName = GetSingleSelectedGraphName()
if (strlen(selectedGraphName) == 0)
return ""
// The selection is other than a single graph window
endif
String format = "PNG"
if (doSVG)
format = "SVG"
endif
String menuText = ""
sprintf menuText, "Copy %s as %s", selectedGraphName, format
return menuText
End
// If doSVG is true, copy the graph as SVG. Otherwise copy it as PNG.
Function CopySelectedGraphToClip(Variable doSVG)
String selectedGraphName = GetSingleSelectedGraphName()
if (strlen(selectedGraphName) > 0)
Variable formatCode = -5
// PNG
if (doSVG)
formatCode = -9
// SVG
endif
SavePict/E=(formatCode)/WIN=$(selectedGraphName) as "Clipboard" 
endif
End
Popup Contextual Menus
You can create a custom pop-up contextual menu to respond to a control-click or right-click. For an exam-
ple, see Creating a Contextual Menu on page IV-162.

Chapter IV-5 — User-Defined Menus
IV-142
