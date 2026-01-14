# Creating Subwindows

Chapter III-4 — Embedding and Subwindows
III-82
When the second icon in the tool palette is selected, the window is in drawing mode. In this mode, you can 
use drawing tools on the window or active subwindow.
If you click the black frame around a subwindow while in edit mode, you enter subwindow layout mode. 
In this mode, you can position, and resize subwindows, as well as create and adjust guides.
Subwindow Restrictions
The following table summarizes the rules for allowed host and embedded subwindow configurations.
Creating Subwindows
You can create subwindows either from the command line (see Subwindow Command Concepts on page 
III-92) or interactively using contextual menus. To add a subwindow interactively, show the tool palette of 
the base window, click the second icon to enter drawing mode, and then right-click (Windows) or Control-
click (Macintosh) in the interior of the window and choose the desired type of subwindow from the New 
menu:
Igor presents the normal dialog for creating a new window but the result will be a subwindow:
Host
Graph
Table
Panel
Layout
Subwindow
Graph
Yes
No
Yes
Yes
Table
Yes*
*
Tables embedded in graphs or layouts are presentation-only objects. They do 
not support editing of data.
No
Yes
Yes*
Panel
Yes†
†
Panels can be embedded in base graphs only.
No
Yes
No
Layout
No
No
No
No
Notebook
No
No
Yes
No
Gizmo
Yes
No
Yes
No
