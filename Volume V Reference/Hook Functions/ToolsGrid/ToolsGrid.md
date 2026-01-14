# ToolsGrid

ToolsGrid
V-1041
The intended usage is for user-created panel windows with “To Cmd Line” buttons that are mimicking 
built-in Igor dialogs. You’ll usually want to use Execute, instead.
Parameters
Details
To send more than one line of commands, separate the commands with “\r” characters.
Examples
Macro CmdPanel()
PauseUpdate; Silent 1
NewPanel /W=(150,50,430,229)
Button toCmdLine,pos={39,148},size={103,20},title="To Cmd Line"
Button toCmdLine,proc=ToCmdLineButtonProc
End
Function ToCmdLineButtonProc(ctrlName) : ButtonControl
String ctrlName
String cmd="MyFunction(xin,yin,\"yResult\")"// line 1: generate results
cmd +="\rDisplay yOutput vs wx as \"results\"" // line 2: display results
ToCommandLine cmd
return 0
End
See Also
The Execute and DoIgorMenu operations.
ToolsGrid 
ToolsGrid [/W=winName] keyword = value [, keyword = value …]
The ToolsGrid operation controls the grid you can use for laying out draw or control objects.
Parameters
ToolsGrid can accept multiple keyword = value parameters on one line.
Flags
Details
The default grid is 1 inch with 8 subdivisions. The grid is visible only in draw or selector mode and appears 
in front of the currently active draw layer.
commandsStr
The text of one or more commands.
Note:
ToCommandLine does not work when typed on the command line; use it only in a Macro, 
Proc, or Function.
snap=n
Turns snap to grid on (n=1) or off (n=0).
visible=n
Turns on grid visibility (n=1) or hides it (n=0).
grid=(xy0,dxy,ndiv) Defines both X and Y grids where ndiv is the number of subdivisions between major 
grid lines and xy0 and dxy define the origin and spacing. Units are in points.
gridx=(x0,dx,ndiv)
Defines the X grid where ndiv is the number of subdivisions between major grid lines 
and x0 and dx define the origin and spacing. Units are in points.
gridy=(y0,dy,ndiv)
Defines the Y grid where ndiv is the number of subdivisions between major grid lines 
and y0 and dy define the origin and spacing. Units are in points.
/W=winName
Sets the named window or subwindow for drawing. When omitted, action will affect 
the active window or subwindow. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
