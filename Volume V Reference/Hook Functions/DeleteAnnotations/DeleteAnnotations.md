# DeleteAnnotations

DeleteAnnotations
V-154
DeleteAnnotations
DeleteAnnotations [flags] [tagOffscreen, tagTraceHidden, invisible, 
offsetOffscreen, tooSmall[=size]]
The DeleteAnnotations operation lists, in the S_name output variable, and optionally deletes annotations 
that are hidden for reasons specified by the flags and keywords.
The operation affects the window or subwindow specified by the /W flag or, if /W is omitted, the active 
window or subwindow.
Do not use DeleteAnnotations to progammatically delete a specific, single annotation. Instead use:
TextBox/W=winName/K/N=annotationName
The /LIST flag limits the action to only listing, instead of deleting, the annotations.
The DeleteAnnotations operation was added in Igor Pro 7.00.
Keywords
The keywords identify annotations based on the reasons for their being hidden:
Flags
Output Variables
Examples
Function DeleteAnnotationsInWin(win)
String win
// Specifies a top-level window or a subwindow
// Handle specified top-level window or subwindow
DeleteAnnotations/W=$win/A
Variable numDeleted = V_Flag
// Now handle subwindows, if any
String children = ChildWindowList(win)
Variable n = ItemsInList(children)
Variable i
invisible
Deletes or lists annotations hidden with /V=0.
offsetOffscreen
Deletes or lists annotations that are offscreen, usually because of excessive /X and /Y 
offsets.
tagOffscreen
Deletes or lists tags hidden because they are attached to trace points that are offscreen. 
This affects trace tags, axis tags, and image tags if their "if offscreen" setting, as set in 
the Position tab of the Modify Annotation dialog, is set to "hide the tag".
tagTraceHidden
Deletes or lists tags hidden because the tagged trace is hidden.
tooSmall [=size]
Deletes or lists annotations whose height or width is size points or smaller. size is 
expressed in points and defaults to 8. This is useful for deleting annotations that are 
too small to see or to double-click.
/A
All annotations, whether hidden or not, are listed or deleted. All keywords are 
ignored.
/LIST
Specifies that annotations identified by the other parameters are to be listed in the 
S_name output variable but not deleted.
/W=winName
Annotations in the named window or subwindow are considered. When omitted, 
annotations in the active window or subwindow are considered.
When identifying a subwindow with winName, see Subwindow Syntax for details on 
forming the window hierarchy.
S_name
A semicolon-separated list of the annotations that match the criteria set by the 
keywords and flags.
V_flag
Set to the number of annotations deleted or listed.
