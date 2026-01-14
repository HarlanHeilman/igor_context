# ToCommandLine

ToCommandLine
V-1040
TitleBox Positioning
For compatibility with other controls, you can use the align=1 to maintain the position of the right end of a 
TitleBox control. This presents a conflict with the anchor keyword. To resolve the conflict, these rules are 
applied:
Applying align=1, which sets the alignment mode to right alignment, overrides any horizontal positioning 
specified using the anchor keyword.
Applying the anchor keyword resets the alignment mode to 0 and the anchor mode controls the horizontal 
position of the control.
If you specify fixedSize=1, only the align and pos keywords affect horizontal positioning; the anchor 
keyword has no effect.
For clarity, don't mix the anchor and align keywords unless you are using fixedSize=1. Use anchor in 
preference to align unless you are trying to keep the right ends of various types of controls aligned, 
especially on high-resolution displays on Windows.
Examples
NewPanel /W=(94,72,459,294)
DrawLine 150,32,150,140
DrawLine 70,100,213,100
// draw crossing lines at 150,100
// illustrate a default box
TitleBox tb1,title="A title box\rwith 2 lines",pos={150,100}
// Move center to 150,100
TitleBox tb1,pos={150,100},size={0,0},anchor=MC
// Set background color and therfore opaque mode
TitleBox tb1,labelBack=(55000,55000,65000)
// Now a few frame styles. Run these one at a time
TitleBox tb1,frame= 0
// no frame
TitleBox tb1,frame= 2
// plain frame
TitleBox tb1,frame= 3
// 3D sunken
TitleBox tb1,frame= 4
// 3D raised
TitleBox tb1,frame= 5
// text well
// Now some fancy text…
TitleBox tb1,frame= 1
// back to default (3D raised)
TitleBox tb1,title= "\Z18\[020 log\\B10\\M|[1 + 2K(jwt) + (jwt)\\S2\\M]|\\S-1"
// Create a string variable and hook up to the TitleBox
String s1= "text from a string variable"
TitleBox tb1,variable=s1
// Change string variable contents & note automatic update of TitleBox
s1= "something new"
// A TitleBox with right end at X=200 because the align keyword takes precedence
TitleBox tb, pos={200,40},size={0,0},align=1,anchor=MT,title="Short Title"
// A TitleBox with right end at X=200 because align by itself overrides
// any preexisting anchor
TitleBox tb, pos={200,40},size={0,0},align=1,title="Short Title"
// A TitleBox with text centered in the frame and right end at X=200,
// with frame always 75 points wide
TitleBox tb, pos={200,40},size={75,20},align=1,fixedSize=1,anchor=MT,title="Short Title"
See Also
Annotation Escape Codes on page III-53.
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The ControlInfo operation for information about the control.
ToCommandLine 
ToCommandLine commandsStr
The ToCommandLine operation sends command text to the command line without executing the command(s).
