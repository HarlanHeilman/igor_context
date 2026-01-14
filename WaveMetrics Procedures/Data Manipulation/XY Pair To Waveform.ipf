#pragma rtGlobals=1
#pragma version=6.2	// shipped with Igor 6.2

#include <XY Pair to Waveform Panel>

// Version 1.11, 11/28/2006 (JW)
//	Substituted Interpolate2 for Interpolate plus Execute, making it a one-liner.

// Version 6.2, 6/14/2010  (JP)
//	Added include of XY Pair to Waveform Panel.ipf.
//	See the Data->Packages menu for an XY to Waveform Panel.

// XYToWave1(xWave, yWave, wWaveName, numPoints)
//	Generates a waveform from an XY pair using linear interpolation
//	The name of the output waveform must not be the same as the x or y input wave.
//	The macro makes the assumption that the input waves are already sorted.
//	You can sort with: Sort xWave, xWave, yWave
//	If you have blanks (NaNs) in your input data, this function will give you blanks
//	in your output waveform as well. If you don't want this, you can try the
//	XYToWave2 function below.
Function XYToWave1(xWave, yWave, wWaveName, numPoints)
	Wave xWave							// x wave in the XY pair
	Wave yWave							// y wave in the XY pair
	String wWaveName					// name to use for new waveform wave
	Variable numPoints					// number of points for waveform
	
	Make/O/N=(numPoints) $wWaveName			// make waveform
	Wave wWave= $wWaveName
	WaveStats/Q xWave								// find range of x coordinates
	SetScale/I x V_min, V_max, wWave				// set X scaling for waveform
	wWave = interp(x, xWave, yWave)				// do the interpolation
End

// XYToWave2(xWave, yWave, wWaveName, numPoints)
//	Generates a waveform from an XY pair using cubic interpolation.
//	The name of the output waveform must not be the same as the x or y input wave.
//	It must be a simple wave name, not a full or partial path plus wave name.
//	numPoints must be at least as large as the number of points in the XY pair.
//	The input waves need not be sorted.
//	This function interpolates through the NaNs.
Function XYToWave2(xWave, yWave, wWaveName, numPoints)
	Wave xWave							// x wave in the XY pair
	Wave yWave							// y wave in the XY pair
	String wWaveName					// name to use for new waveform wave
	Variable numPoints					// number of points for waveform

	Interpolate2/T=2/N=(numPoints)/E=2/Y=$wWaveName xWave, yWave
End
