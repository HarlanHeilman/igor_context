# Draw<object> Operations

Chapter III-3 — Drawing
III-74
mentsGraphing TechniquesNew Polar Graph Demo.) Nonprogrammers can use the package as-is 
while programmers can modify the code to suit their purposes or can extract useful code snippets for their 
own projects.
You can get a quick start on a drawing programming project by first drawing interactively and then asking 
Igor to create a recreation macro for the window (click the close button and look in the Procedure window). 
You can then extract useful code snippets for your project. Frequently all you will have to do is replace 
literal coordinate values with calculated values and you are in business.
Drawing Operations
Here is a list of operations related to drawing.
SetDrawLayer Operation
Use SetDrawLayer to specify which layer the following drawing commands will affect. If you use the /K 
flag then the current contents of the given drawing layer are deleted. See Drawing Programming Strategies 
on page III-76 for considerations in the use of SetDrawLayer and the /K flag.
SetDrawEnv Operation
This is the workhorse command of the drawing facility. It is used to specify the characteristics for a single 
object, to specify the default drawing environment for future objects, and to create groups of objects.
You can issue several SetDrawEnv commands in sequence; their effect is cumulative. By default, the group of 
SetDrawEnv commands affects only the next drawing command. Drawing commands that follow the first 
will use the default settings that were in effect before the SetDrawEnv commands were issued. For instance, 
these SetDrawEnv commands change the font and font size for only the first of the two DrawText commands:
SetDrawEnv fname="Courier New"
SetDrawEnv fsize=18
// 18 point Courier New, commands accumulate
DrawText 0,1,"This is in 18 point Courier New"
DrawText 0,0,"Has font and size in use before SetDrawEnv commands"
Use the save keyword in the SetDrawEnv specification to make the settings permanent. The usual use of 
the save keyword is at the end of the last SetDrawEnv command in a series. The permanent settings allow 
you to draw a number of objects all with the same characteristics without having to reissue SetDrawEnv 
commands before each object.
To create a grouping of objects, simply bracket a group of drawing commands with SetDrawEnv commands 
using the gstart and gstop keywords. Grouping is purely a user interface concept. Objects are drawn exactly 
the same regardless of grouping.
Draw<object> Operations
These operations, along with SetDrawEnv, operate differently depending on whether or not drawing 
objects are selected in the target window. If, for example, a rectangle is selected in the target window and a 
DrawRect command is executed then the selected rectangle is changed. If, on the other hand, no rectangle is 
selected then a new rectangle is created. This behavior exists to support interactive drawing and is not useful 
to Igor programmers, since there is no programmatic way to select a drawing object. Normally, you will be 
creating new objects rather than modifying existing objects.
DrawAction
DrawArc
DrawBezier
DrawLine
DrawOval
DrawPICT
DrawPoly
DrawRect
DrawRRect
DrawText
DrawUserShape
GraphNormal
GraphWaveDraw
GraphWaveEdit
HideTools
SetDashPattern
SetDrawEnv
SetDrawLayer
ShowTools
ToolsGrid
