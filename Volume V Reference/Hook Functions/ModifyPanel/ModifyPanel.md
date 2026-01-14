# ModifyPanel

ModifyPanel
V-640
Flags
The /I and /M flags affect the units of the parameters for the left, top, width and height keywords only. If 
neither /I nor /M is present then the parameters for the left, top, width and height keywords are points.
Details
Note that the units keyword affects only the units used in the layout info panel and in the Modify Objects 
dialog. It has nothing to do with the units used for the left, top, width and height keywords. Those units are 
points unless the /I or /M flags is present.
See Also
NewLayout, AppendLayoutObject, RemoveLayoutObjects, LayoutPageAction
ModifyPanel 
ModifyPanel [/W=winName] keyword = value [, keyword = value …]
The ModifyPanel operation modifies properties of the top or named control panel window or subwindow.
Parameters
keyword is one of the following:
trans=t
units=u
width=w
Sets the object width.
/I
Dimensions in inches.
/M
Dimensions in centimeters.
/W=winName
winName is the name of the page layout window to be modified. If /W is omitted or if 
winName is $"", the top page layout is modified.
/Z
Does not generate an error if the indexed or named object does not exist in a style macro.
cbRGB=(r,g,b[,a])
Specifies the background color of the entire control panel or the graph’s control bar 
area. r, g, b, and a specify the color and optional opacity as RGBA Values.
drawInOrder=d
Controls the transparency of the layout object:
t=0:
Opaque (default).
t=1:
Transparent. For this to be effective, the object itself must also be 
transparent. Annotations have their own transparent/opaque 
settings. Graphs are transparent only if their backgrounds are white. 
PICTs may have been created transparent or opaque, and Igor cannot 
make an opaque PICT transparent.
Sets dimension units in the layout info panel and in the Modify Objects dialog.
u=0:
Points.
u=1:
Inches.
u=2:
Centimeters.
Determines the drawing order of controls in the control panel.
The drawInOrder keyword was added in Igor Pro 8.00.
Prior to Igor Pro 8.00 tab controls (see TabControl) were always drawn before all 
other controls. This prevented placing a tab control inside a groupbox with a 
colored interior. drawInOrder=1 forces Igor to draw controls in creation order, 
which is the same as the order in which they appear in a recreation macro.
d=0:
Draw tab controls before any other controls (default).
d=1:
Draw all controls in the order in which they appear in the 
recreation macro, which is also the creation order.

ModifyPanel
V-641
Flags
Details
On Windows, set r, g, and b to 65535 (maximum white) to set the background color of the control panel to 
track the 3D Objects color in the Appearance Tab of the Display Properties control panel.
See Also
The NewPanel operation.
Controls in Graphs on page III-441.
expand=e
Sets the expansion factor of the panel. e is a number between 0.25 to 8.0. Values of e 
greater than 1.0 make the panel, its controls, and its subwindows, appear larger than 
normal.
Though rarely needed, using the expand keyword, you can set the expansion of panel 
subwindows independent of the main panel window's expansion.
When you change the expansion of a top-level control panel window, the panel 
window automatically resizes itself.
The expand keyword was added in Igor Pro 9.00.
See Control Panel Expansion on page III-443 for further discussion.
fixedSize=f
frameInset= i
Specifies the number of pixels by which to inset the frame of the panel subwindow. 
Mostly useful for overlaying panels in graphs to give a fake 3D frame a better appearance.
frameStyle= f
noEdit= e
/W= winName
Modifies the control panel in the named graph or control panel window or 
subwindow. When omitted, action will affect the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
Controls the resizing of the panel window.
f=0:
Panel can be resized (default).
f=1:
Panel cannot be resized by adjusting the size box or frame (nor 
maximized on Windows), but the window can be minimized (on 
Windows) and the MoveWindow operation can still change the size.
The fixedSize keyword overrides any previous size limit set 
using the SetWindow sizeLimit command. If you try to use 
SetWindow sizeLimit on a window with fixedSize=1, Igor 
generates an error.
Specifies the frame style for a panel subwindow.
The last three styles are fake 3D and will look good only if the background color of 
the enclosing space and the panel itself is a light shade of gray.
f=0:
None.
f=1:
Single.
f=2:
Indented.
f=3:
Raised.
f=4:
Text well.
Sets the editability of the panel.
e=0:
Editable (default).
e=1:
Not editable. For a panel window, the Panel menu item is not 
present and the ShowTools command is ignored. For a panel 
subwindow, it can not be activated by clicking.
