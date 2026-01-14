# Subwindow Operations and Functions

Chapter III-4 — Embedding and Subwindows
III-93
Guides may override the numeric positioning set by /W. All operations supporting /HOST take the 
/FG=(gleft,gtop,gright,gbottom) flag where the parameters are the names of built-in or user-
defined guides. FG stands for frame guide and this flag specifies that the outer frame of the subwindow is 
attached to the guides. A * character in place of a name indicates that the default value should be used.
The inner plot area of a graph subwindow may be attached to guides using the analogous PG flag. Thus a 
subgraph may need up to three specifications. For example:
Display /HOST=# /W=(0,10,400,200) /FG=(FL,*,FR,*) /PG=(PL,*,PR,*)
When the subwindow position is fully specified using guides, the /W flag is not needed but it is OK to 
include it anyway.
Subwindow Operations and Functions
Here are the main operations and functions that are useful in dealing with subwindows:
ChildWindowList(hostName)
DefineGuide [/W= winName] newGuideName = {[guideName1, val 
[, guideName2]]} [,…]
KillWindow winNameStr
MoveSubwindow [/W=winName] key = (values)[, key = (values)]…
RenameWindow oldName, newName
SetActiveSubwindow subWinName

Chapter III-4 — Embedding and Subwindows
III-94
