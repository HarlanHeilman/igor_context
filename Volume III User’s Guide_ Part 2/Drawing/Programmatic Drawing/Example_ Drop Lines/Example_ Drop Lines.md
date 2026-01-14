# Example: Drop Lines

Chapter III-3 — Drawing
III-77
Another consideration is whether or not you should set the default drawing environment. In general you 
should not but instead leave the uer in control. This varies depending on specific objectives.
Grouping
It is a good idea to use grouping for your drawing. This allows the user to move the entire drawing by 
merely selecting and dragging it.
Example: Drop Lines
In this example, we show a procedure that adds a line from a particular point on a wave, identified by 
cursor A, to the bottom axis. The procedure assumes that the graph has left and bottom axes and that cursor 
A is on a trace. For clarity, error checking is omitted.
Menu "Graph"
“Add Drop Line", AddDropLine()
End
Function AddDropLine()
Variable includeArrow = 2
// 1=No, 2=Yes
Prompt includeArrow, "Include arrow head?", popup "No;Yes"
DoPrompt "Add Drop Line", includeArrow
includeArrow -= 1
// 0=No, 1=Yes
Variable xCursorPosition = hcsr(A)
Variable yCursorPosition = vcsr(A)
GetAxis/Q left
Variable axisYPosition = V_min
SetDrawEnv xcoord=bottom, ycoord=left
if (includeArrow)
SetDrawEnv arrow=1, arrowlen=8, arrowfat=0.5
else
SetDrawEnv arrow=0
endif
DrawLine xCursorPosition,yCursorPosition,xCursorPosition,axisYPosition
End
