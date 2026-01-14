// SetDecadeLength(xInches, yInches)

// Assuming the top window is a log/log graph, SetDecadeLength sets the size of the
// graph's plot area such that the length of a decade on the horizontal and vertical axes
// equals xInches and yInches.
// Enter zero for xInches or yInches if you do not want to affect that dimension.

Macro SetDecadeLength(xInches, yInches)	// works on top window, assumed to be a log/log graph
	Variable xInches=1.5, yInches=1
	Prompt xInches, " X inches per decade"
	Prompt yInches, " Y inches per decade"
	
	Silent 1;PauseUpdate					// setting graph size . . .
	
	if (xInches)
		GetAxis /Q bottom					// puts bottom axis min and max in global variables
		Modify width = (log(V_Max) - log(V_Min)) * xInches * 72
	endif

	if (yInches)
		GetAxis /Q left						// puts left axis min and max in global variables
		Modify height = (log(V_Max) - log(V_Min)) * yInches * 72
	endif
EndMacro
