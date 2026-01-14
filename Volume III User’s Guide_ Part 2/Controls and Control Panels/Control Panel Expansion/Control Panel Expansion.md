# Control Panel Expansion

Chapter III-14 — Controls and Control Panels
III-443
A panel window’s background color can be set by Control-clicking (Macintosh) or right-clicking (Windows) 
in the background and then selecting a color from the pop-up color palette. See Control Background Color 
on page III-437 for details.
Embedding into Control Panels
You can embed a graph, table, notebook, or another 
panel into a control panel window. See Chapter III-4, 
Embedding and Subwindows for details. This tech-
nique is cleaner than adding control areas to a graph. 
It also allows you to embed multiple graphs in one 
window with controls.
Use the contextual menu while in drawing mode to 
add an embedded window. Click on the frame of the 
embedded window to adjust the size and position.
You can use a notebook subwindow in a control 
panel to display status information or to accept 
lengthy user input. See Notebooks as Subwindows in Control Panels on page III-91 for details.
Exterior Control Panels
Exterior subwindows are panels that act like subwindows but live in their own windows attached to a host 
window. The host window can be a graph, table, panel or Gizmo plot. The host window and its exterior 
subwindows move together and, in general, act as a single window. Exterior subwindows have the advan-
tage of not disturbing the host window and, unlike normal subwindows, are not limited in size by the host 
window.
To create an exterior subwindow panel, use NewPanel with the /EXT flag in combination with /HOST.
Floating Control Panels
Floating control panels float above all other windows, except dialogs. To create a floating panel, use New-
Panel with the /FLT flag.
Control Panel Expansion
In Igor Pro 9.00 and later, you can set an expansion factor for a control panel using the Expansion submenu 
in the Panel menu or the panel's contextual menu which you summon by right-clicking. You can set it for 
all control panels using the Panel section of the Miscellaneous Settings dialog. As explained below, setting 
it for all panels is recommended in most cases.
The factory default control panel expansion factor is 1.0 which means that control panels and their controls 
are displayed at "normal" size. The normal size depends on the pixel size of your screen and on various 
complex software factors. It may be too small or too large for your taste. If so, you can use the control panel 
expansion factor to adjust.
When you change the expansion factor, the size of the panel window and any controls and subwindows in 
the panel changes accordingly. Additionally, elements drawn in the panel using drawing tools are also 
expanded.
If normal size is not ideal for you, you will usually want to change the expansion for all control panels, not 
for just one specific control panel. You can do this by changing the default control panel expansion factor 
using the Panel section of the Miscellaneous Settings dialog. For most uses, changing the default is recom-
mended over changing the expansion for a specific control panel.
When creating a control panel programmatically, you can set the expansion factor using the NewPanel 
/EXP=<factor> flag which was added in Igor Pro 9.00. However, for most uses, you should omit /EXP and 
allow the user's default control panel expansion factor to take effect.
