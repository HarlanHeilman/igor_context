#pragma rtGlobals=1

// This file contains BringDestFront and FindGraphWithWave. The former is
// an old routine that takes a wave name as a string expression. It has been
// extended to work with a data folder path to the wave and also does not rearrange
// the order of windows like the original did.
//
// The new, more modern, routine (that BringDestFront now uses) is
// FindGraphWithWave. It takes an actual wave (reference) and returns
// the name of the graph window.


// Find topmost graph containing given wave
//	returns zero length string if not found
//
Function/S FindGraphWithWave(w)
	wave w
	
	string win=""
	variable i=0
	
	do
		win=WinName(i, 1)				// name of ith graph window
		if( strlen(win) == 0 )
			break;							// no more graph wndows
		endif
		CheckDisplayed/W=$win  w
		if(V_Flag)
			break
		endif
		i += 1
	while(1)
	return win
end


// Bring the first graph window containing a given wave to the front.
// If no such window is found then one is created.
// 960124,LH: Now uses FindGraphWithWave and can take a data folder path.
//
Proc BringDestFront(w)
	string w
	
	string win= FindGraphWithWave($w)
	if( strlen(win) != 0 )
		DoWindow /F $win
	else
		Display $w
	endif
end

