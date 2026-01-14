# DelayUpdate

DefineGuide
V-153
See Also
#define, Conditional Compilation on page IV-108, Predefined Global Symbols on page IV-110
DefineGuide 
DefineGuide [/W= winName] newGuideName = {[guideName1, val [, guideName2]]} [,…]
The DefineGuide operation creates or overwrites a user-defined guide line in the target or named window 
or subwindow. Guide lines help with the positioning of subwindows in a host window.
Parameters
newGuideName is the name for the newly created guide. When it is the name of an existing user-defined 
guide, the guide will be moved to the new position.
guideName1, guideName2, etc., must be the names of existing guides.
The meaning of val depends on the form of the command syntax. When using only one guide name, val is 
an absolute distance offset from to the guide. The directionality of val is to the right or below the guide for 
positive values. The units of measure are points except in panels where they are in Control Panel Units. 
When using two guide names, val is the fractional distance between the two guides.
Flags
Details
The names for the built-in guides are as defined in the following table:
The frame guides apply to all window and subwindow types. The graph rectangle and plot rectangle guide 
types apply only to graph windows and subwindows. The layout margin rectangle guide types only apply 
to layout windows.
To delete a guide use guideName={}.
See Also
The Display, Edit, NewPanel, NewImage, and NewWaterfall operations.
The GuideInfo function.
DelayUpdate 
DelayUpdate
The DelayUpdate operation delays the updating of graphs and tables while executing a macro.
Details
Use DelayUpdate at the end of a line in a macro if you want the next line in the macro to run before graphs 
or tables are updated.
This has no effect in user-defined functions. During execution of a user-defined function, windows update 
only when you explicitly call the DoUpdate operation.
See Also
The DoUpdate, PauseUpdate, and ResumeUpdate operations.
/W=winName
Defines guides in the named window or subwindow. When omitted, action will affect 
the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
Left
Right
Top
Bottom
Host Window Frame
FL
FR
FT
FB
Host Graph Rectangle
GL
GR
GT
GB
Inner Graph Plot Rectangle
PL
PR
PT
PB
Layout Margin Rectangle
ML
MR
MT
MB
