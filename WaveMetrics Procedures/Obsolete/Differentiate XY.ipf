#pragma rtGlobals=1

//	Version 1.01, 5/17/94
//		Used Wave/D instead of Wave in several places.
//	Version 1.10, 12/28/95
//		Updated for Igor Pro 3.0. Removed /D (no longer needed).
//	Version 1.11, 2/5/98, JP
//		Now works if xWave and yWave have different X scaling.

//	DifferentiateXY(xWave, yWave, yDestWaveName)
//		Produces derivative of XY pair.
//		The XY pair is assumed to be sorted.
//		You can sort with: Sort xWave, xWave, yWave
Function DifferentiateXY(xWave, yWave, yDestWaveName)
	Wave xWave, yWave							// input X, Y waves
	String yDestWaveName						// name to use for output wave
	
	String xDestWaveName						// to hold name of temp dx/dp wave
	
	xDestWaveName = "DifferentiateXYTempX"
	
	Duplicate/O xWave, $xDestWaveName		// make clones
	Duplicate/O yWave, $yDestWaveName
	
	Wave xDest = $xDestWaveName
	Wave yDest = $yDestWaveName
	
	CopyScales/P yDest, xDest					// same dx, same Differentiate scale
	Differentiate xDest, yDest					// do differentiation
	yDest /= xDest								// take ratio
	KillWaves xDest								// don't need dx/dp anymore
End
