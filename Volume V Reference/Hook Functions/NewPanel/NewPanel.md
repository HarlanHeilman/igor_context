# NewPanel

NewPanel
V-687
NewPanel 
NewPanel [flags] [as titleStr]
The NewPanel operation creates a control panel window or subwindow, which may contain Igor controls 
and drawing objects.
Flags
/EXP=e
Sets the expansion of the panel. e is a number between 0.25 to 8.0. Values of e greater 
than 1.0 make the panel, its controls, and its subwindows, appear larger than normal.
The expansion factor affects the size of the window specified by /W.
If you omit /EXP or specify /EXP=0, the expansion defaults to the value set in the Panel 
section of the Miscellaneous Settings dialog.
To change the expansion after the panel is created, use ModifyPanel expand=e or the 
Expansion submenu of the Panel menu.
The /EXP flag was added in Igor Pro 9.00.
See Control Panel Expansion on page III-443 for further discussion.
/EXT=e
/FG=(gLeft, gTop, gRight, gBottom)
Specifies the frame guide to which the outer frame of the subwindow is attached 
inside the host window.
The standard frame guide names are FL, FR, FT, and FB, for the left, right, top, and 
bottom frame guides, respectively, or user-defined guide names as defined by the 
host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/FLT[=f]
/FLT or /FLT=1 makes the panel a floating panel.
/FLT=2 makes it a floating panel with no close box.
/FLT=0 is the same as omitting /FLT and creates a regular (non-floating) control panel.
You must execute the following after the NewPanel command:
SetActiveSubwindow _endfloat_
See Floating Panels below for further information.
/FLTH=h
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/HOST=hcSpec
Embeds the new control panel in the host window or subwindow specified by hcSpec.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/I
Sets coordinates to inches.
Creates an exterior subwindow in combination with /HOST. e specifies the host 
window side location:
e=0:
Right.
e=1:
Left.
e=2:
Bottom.
e=3:
Top.
Selects whether a floating panel is automatically hidden when Igor is deactivated.
The default is platform specific and matches the behavior prior to Igor Pro 9. On 
Macintosh floating panels are hidden when Igor is deactivated. On Windows 
they are not hidden when Igor is deactivated.
h=0:
The panel is not automatically hidden.
h=1:
The panel is automatically hidden.

NewPanel
V-688
Details
If /N is not used, NewPanel automatically assigns to the panel a window name of the form “Paneln”, where 
n is some integer. In a function or macro, the assigned name is stored in the S_name string. This is the name 
you can use to refer to the panel from a procedure. Use the RenameWindow operation to rename the panel.
On Windows there are special considerations relating to screen resolution and control panels. See Control 
Panel Resolution on Windows on page III-456 for details.
Floating Panels
Floating control panels float above all other windows except dialogs. Because floating panels cover up other 
windows, you should use them sparingly and you should take care to make them small and unobtrusive.
Floating panels are not resizable by default. To allow panel resizing use
ModifyPanel fixedSize=0
Because floating panels always act as if they are on top, the standard rules for target windows and keyboard 
focus do not apply.
Normally, a floating panel is never the target window and control procedures will need to explicitly designate 
the target. But a newly-created floating panel is the default target and will remain so until you execute
SetActiveSubwindow _endfloat_
/K=k
/M
Sets coordinates to centimeters.
/N=name
Requests that the created panel have this name, if it is not in use. If it is in use, then 
name0, name1, etc. are tried until an unused window name is found. In a function or 
macro, S_name is set to the chosen panel name.
Note that a function or macro with the same name will cause a name conflict.
/NA= n
/W=(left,top,right,bottom)
Sets the initial coordinates of the panel window. See Interpretation of NewPanel 
Coordinates on page III-444 for a discussion of the left, top, right, and bottom 
parameters.
When used with the /HOST flag, the specified location coordinates of the sides can 
have one of two possible meanings:
When all values are less than 1, coordinates are assumed to be fractional relative to 
the host frame size. This applies to interior panels only, not to exterior panels.
When any value is greater than 1, coordinates are taken to be fixed locations measured 
in points, or Control Panel Units for control panel hosts, relative to the top left corner 
of the host frame.
When the subwindow position is fully specified using guides (using the /HOST or /FG 
flags), the /W flag may still be used although it is not needed.
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
Exterior subwindows never display a dialog when killed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.
Sets panel no-activate mode.
n=0:
Normal (default).
n=1:
Button click doesn’t activate window but click outside of any control does.
n=2:
No activation even if click is outside controls. Title bar clicks still activate.

NewPanel
V-689
It also becomes the default target when the tools are showing and in any non-Operate mode. Similarly, a 
floating panel with tools not in Operate mode has keyboard focus. To avoid confusion, do not attempt to 
work on other windows when a floating panel is the default target.
When working with a floating panel, you can show or hide tools or create a recreation macro by Control-
clicking (Macintosh) or right-clicking (Windows) in the panel.
A floating panel does not have keyboard focus. However, a floating panel gains keyboard focus when a 
control that needs focus is clicked. Focus remains until you press Enter or Escape for a text entry in a 
setvariable, press Tab until no control has the focus, or until you click outside a focusable control.
On Macintosh, if a floating panel has focus and you activate another window, focus will leave the panel. 
However on Windows, if a floating panel has focus and you activate another window, the activate sequence 
will be fouled up leaving the windows in an indeterminate state. Consequently, it is important that you 
always finish any keyboard interaction started in a floating panel before moving on to other windows. If 
this can cause confusion, you should not use controls such as SetVariable and ListBox in a floating panel.
On Macintosh, floating panels are hidden when dialogs are up or when Igor Pro is not the front application.
Exterior Subwindows
Exterior subwindows are automatically positioned along the designated side of a host window. The host 
window can be a graph, table, panel or Gizmo plot. You can designate fixed sizes or automatic size with 
minima. Subwindows are stacked beside the designated side in their creation order with the first one 
closest.
Subwindow dimensions have various meanings depending on their location. Interior values are taken to be 
additional grout, exterior values are taken to be sizes. For left or right panels, top is taken to be the 
minimum height and bottom, if not zero, is height. For top and bottom, left is taken to be the minimum 
width and right, if not zero, is width. Zero values default to 50 for width and height or size of host.
Exterior subwindows are nonresizable by default. Use ModifyPanel fixedSize=0 to allow manual 
resizing. If you resize a panel, the original window dimensions are lost. You can also use MoveSubwindow 
to resize the subwindow.
Unlike normal subwindows, exterior subwindows have a tools palette. Click in the window and then 
choose the Show Tools or Hide Tools menu item.
Exterior subwindows have hook functions independent of the host window.
Examples
In a new experiment, execute these commands on the command line to create two exterior subwindows:
Display
// Create panel on right with min height of 200 points, width of 100.
NewPanel/HOST=Graph0/EXT=0/W=(0,200,100,0)
// Create another panel on right with grout of 10 and height= width= 100.
NewPanel/HOST=Graph0/EXT=0/W=(10,0,100,100)
Now try resizing and moving the graph.
For a demonstration of how the various exterior panels work, copy the following code to the procedure 
window in a new experiment:
Function bpNewExSw(ba) : ButtonControl
STRUCT WMButtonAction &ba
switch( ba.eventCode )
case 2:
// mouse up
ControlInfo/W=$ba.win ckUseRect
Variable useR= V_Value
ControlInfo/W=$ba.win popSide
Variable side= V_Value-1
ControlInfo/W=$ba.win ckResizeable
Variable resizeable= V_Value
WAVE w=root:epsizes
if( useR )
NewPanel/HOST=$ba.win/EXT=(side)/W=(w[0],w[1],w[2],w[3])
else
NewPanel/HOST=$ba.win/EXT=(side)
endif
if( resizeable )
ModifyPanel fixedSize=0 // default is 1 for floating and exterior sw
