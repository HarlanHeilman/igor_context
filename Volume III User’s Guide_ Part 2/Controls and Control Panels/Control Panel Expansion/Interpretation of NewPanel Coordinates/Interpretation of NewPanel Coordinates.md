# Interpretation of NewPanel Coordinates

Chapter III-14 — Controls and Control Panels
III-444
When a control panel is recreated, such as when you open an experiment with a control panel, if the 
/EXP=<factor> flag is present in the recreation macro, Igor applies the specified expansion factor to the 
panel. If the /EXP flag is omitted, Igor applies the user's default control panel expansion factor.
When Igor generates a control panel recreation macro, if the control panel uses other than the default expan-
sion as set in the Panel section of the Miscellaneous Settings dialog, Igor uses the NewPanel /EXP flag to 
specify the desired expansion. If the experiment is opened on a different machine, the specific expansion 
factor is applied. This overrides the user's default control panel expansion factor. You can avoid overriding 
the user's preference by using the default control panel expansion rather than setting it for a specific panel.
It is rarely necessary, but you can programmatically set the expansion factor of a control panel window or 
subwindow using a ModifyPanel command with the expand keyword which was added in Igor Pro 9.00. 
For main control panel windows, this works the same as setting the expansion using the Expansion sub-
menu. For control panel subwindows, it affects the size of the controls but not the size of the subwindow 
itself. For the reasons explained above, it is usually best to refrain from programmatically setting the expan-
sion so that the user's default takes effect.
You can add controls to a graph by creating a control bar using the ControlBar operation. The default 
control panel expansion factor affects the size of the control bar in a graph and the sizes of the controls in 
the control bar.
Control Panel Units
The size and position of a control panel window on screen is set by the NewPanel /W=(left,top,right,bottom) 
flag. The size and position of controls within a control panel are set by the pos={left,top} and 
size={width,height} keywords of control operations like Button and TitleBox.
For historical reasons, the interpretation of these parameters depends on the operating system; see Control 
Panel Resolution on Windows on page III-456 for details.
On Macintosh the parameters are always interpreted as points (1/72 of an inch).
On Windows, they are interpreted as points except if the screen resolution is 96 DPI in which case, for com-
patibility with existing experiments and procedures, they are interpreted as pixels.
To allow users to control the size of control panels and their contents, Igor Pro 9.00 introduced Control 
Panel Expansion (see page III-443). The rest of this section discusses how control panel expansion affects 
the interpretation of the NewPanel /W and control operation keyword parameters.
A parameter that is expressed in normal control panel units (points or pixels as described above) to which 
Igor applies the control panel expansion factor is said to be expressed in control panel units.
Interpretation of NewPanel Coordinates
First we consider the NewPanel /W=(left,top,right,bottom) flag.
When control panel expansion is other than the factory default 1.0, Igor scales the width (computed as right-
left) and height (computed as bottom-top) of the panel by the expansion factor but does not change the inter-
pretation of left and top.
Consider these examples assuming that the default control panel expansion is 1.0:
NewPanel/N=Panel1/W=(100,100,300,200)
NewPanel/N=Panel2/EXP=2/W=(100,100,300,200)
The first NewPanel command creates a panel at the specified coordinates which are interpreted as points 
or pixels as described in the preceding section.
In the second command, the expansion is 2.0 because of the /EXP flag. This does not affect the position of 
the window as specified by the left and top parameters. It does affect the width and height of the panel as 
computed by Igor from width=right-left and height=bottom-top. After computing the width and height, Igor
