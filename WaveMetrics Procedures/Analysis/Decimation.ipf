#pragma rtGlobals=1		// Use modern global access method.

#pragma version = 6.00

// Version 6.00, 09/05/06 -- for Igor 6, JP moved the Macros into the the Analysis menu, made small formatting revisions.
// Version 1.14b, 06/11/06 -- Dan Sinclair (DJS) added the option for generating standard deviation and/or standard error wave.
// Version 1.14, 09/06/01 -- JP fixed X scaling when the decimation factor isn't a submultiple of the source wave size.
// Version 1.13, 09/04/97 -- JP removed debugging Print from Decimate()
// Version 1.11, 06/21/96 -- JW added options for X positioning in Decimate, and made FDecimateXPos to do the work
// Version 1.10, 12/28/95 -- Updated for Igor Pro 3.0. Removed /D which is no longer needed.
// Version 1.02, 08/08/94 -- Changed factor to (factor-1) in FDecimate. Previously, one extra point was being averaged.
// Version 1.01, 05/17/94 -- Used Wave/D instead of Wave in several places.

Menu "Analysis"
	"Decimate",/Q, Decimate_With_Stdev()
End

//	DJS Mod. 11 June 2006 - New Macro - now has option to output standard deviation/error waves.
// 	Decimate_With_Stdev(source, dest, factor, XPosition, StdevOptions)
//	Creates an output wave by averaging every n points of the input wave down to one point in the output wave.
//	Also creates a wave containing standard deviations or standard errors (or both) [DJS 11 June 2006]
//	Example:
//		Make/N=1000 wave0; SetScale x 0, 5, wave0
//		wave0 = sin(x) + gnoise(.1)
//		Decimate_With_Stdev("wave0", "wave1", 10, 1, 1)
Proc Decimate_With_Stdev(sourceName, destName, factor, XPosition, StdevOptions)
	String sourceName
	Prompt sourceName, "Source Wave", popup WaveList("*", ";", "")
	String destName
	Prompt destName, "Destination Wave"
	Variable factor=10
	Prompt factor, "Decimation factor"
	Variable XPosition = 2
	Prompt XPosition, "X Position of data point within decimation window", popup "left;middle;right"
	Variable StdevOptions = 1		// DJS Mod. 10 June 2006 - this option added to cover standard deviation/error waves
	Prompt StdevOptions, "Generate a Standard Deviation/Error Wave?", popup "no;stdev only;stderr only;both stdev and stderr"

	PauseUpdate; Silent 1
	FDecimateXPosStd($sourceName, destName, factor, XPosition, StdevOptions)
End

// DJS - modified version which now generates an output wave(s) with standard deviation or standard errors. 6/11/06
//JW- new version with control of X positioning. 6/21/96
Function FDecimateXPosStd(source, destName, factor, XPos, StdevOpts)
	Wave source
	String destName		// String contains name of dest which may or may not already exist
	Variable factor
	Variable XPos		//=1, X's are at left edge of decimation window (original FDecimate behavior)
						//=2, X's are in the middle; =3, X's are at right edge
	Variable StdevOpts	// DJS Mod. 11 June 2006 - options for stdev wave output. 1 = none. 2 = Stdev only. 3 = Stderr only. 4 = both Stdev and Stderr.

	// JP: added CleanupName
	String destNameSTD = CleanupName(destName + "_stdev",1)	// DJS Mod. 11 June 2006 - these strings only used if StdevOpts does not equal 1
	String destNameSTE = CleanupName(destName + "_stderr",1)// Standard deviation waves flagged with '_stdev'. Standard error waves flagged with '_stderr'
	
	XPos -= 1
	
	// Clone source so that source and dest can be identical
	Duplicate/O source, decimateTmpSource1
	
	Variable numPoints = floor(numpnts(decimateTmpSource1) / factor) // number of points in output wave
	Duplicate/O decimateTmpSource1, $destName		// keep same precision
	Redimension/N=(numPoints) $destName			// set number of points
	CopyScales decimateTmpSource1, $destName			// copy units
	// we'll need to fix the X scaling
	Variable x0= leftx(decimateTmpSource1)
	Variable dx= deltax(decimateTmpSource1)
	SetScale/P x, x0, dx*factor, "", $destName
	
	Variable segWidth = (factor-1)*dx // width of source wave segment
	Wave dw = $destName
	dw = mean(decimateTmpSource1, x, x+segWidth)

	switch(StdevOpts)	// DJS Mod. 11 June 2006 - this whole case block added to cover options listed above.
		default:
		case 1:		// no stdev wave
			break
		case 2:		// Stdev wave only
			Duplicate/o dw $destNameSTD 						// DJS Mod. 10 June 2006 - copies decimated wave and scaling for use as standard deviation/error wave
			Wave dww = $destNameSTD
			dww = stdev(decimateTmpSource1, x, x+segWidth)		// DJS Mod. 10 June 2006 - standard deviation wave assignment
			break
		case 3:		// Stderr wave only
			Duplicate/o dw $destNameSTE 
			Wave dww = $destNameSTE
			dww = stderr(decimateTmpSource1, x, x+segWidth)		// DJS Mod. 10 June 2006 - standard error wave assignment
			break
		case 4:		// Both Stdev and Stderr waves
			Duplicate/o dw $destNameSTD
			Wave dww = $destNameSTD
			dww = stdev(decimateTmpSource1, x, x+segWidth)		// DJS Mod. 10 June 2006 - standard deviation wave assignment
			Duplicate/o dw $destNameSTE
			Wave dwww = $destNameSTE
			dwww = stderr(decimateTmpSource1, x, x+segWidth)	// DJS Mod. 10 June 2006 - standard error wave assignment
			break
	endswitch	
	
	if (XPos)
		dx=deltax(dw)
		x0=pnt2x(dw, 0)+(segWidth)*0.5*XPos
		SetScale/P x x0, dx, dw

		switch(StdevOpts)	// DJS Mod. 11 June 2006 - this whole case block added to cover options listed above.
			default:
			case 1:		// no stdev wave
				break
			case 2:		// Stdev wave only
				SetScale/P x x0, dx, dww	// DJS Mod. 10 June 2006
				break
			case 3:		// Stderr wave only
				SetScale/P x x0, dx, dww	// DJS Mod. 10 June 2006
				break
			case 4:		// Both Stdev and Stderr waves
				SetScale/P x x0, dx, dww	// DJS Mod. 10 June 2006
				SetScale/P x x0, dx, dwww	// DJS Mod. 10 June 2006
				break
		endswitch	
	endif
	
	KillWaves/Z decimateTmpSource1
End

Static Function  stderr(wv,x1,x2) 	// DJS Mod. 10 June 2006 - a function supplied to me by Ferdinando De Tomasi
	Wave wv
	Variable x1,x2

    WaveStats /Q  /R=(x1,x2)  wv
    return v_sdev/sqrt(v_npnts)
End

Static Function  stdev(wv,x1,x2) 	// DJS Mod. 10 June 2006 - modified from a function supplied to me by Ferdinando De Tomasi
	Wave wv
	Variable x1,x2

    WaveStats /Q  /R=(x1,x2)  wv
    return v_sdev
End

//	FDecimate(source, dest, factor)
//	See Decimate below for usage.
//	JW- Original FDecimate - included for backwards compatibility
Function FDecimate(source, destName, factor)
	Wave source
	String destName		// String contains name of dest which may or may not already exist
	Variable factor
	
	FDecimateXPosStd(source, destName, factor, 1, 1)
End

//	DJS Mod 11 June 2006 - this is the old function - included for backwards compatibility
Function FDecimateXPos(source, destName, factor, Xpos)
	Wave source
	String destName		// String contains name of dest which may or may not already exist
	Variable factor
	Variable Xpos
	
	FDecimateXPosStd(source, destName, factor, Xpos, 1)
End

//	DJS Mod. 11 June 2006 - Original Macro - included for backwards compatibility
// 	Decimate(source, dest, factor, XPosition, StdevOptions)
//	Creates an output wave by averaging every n points of the input wave
//	down to a one point in the output wave.
//	Example:
//		Make/N=1000 wave0; SetScale x 0, 5, wave0
//		wave0 = sin(x) + gnoise(.1)
//		Decimate("wave0", "wave1", 10, 1, 1)
Proc Decimate(sourceName, destName, factor, XPosition)
	String sourceName
	Prompt sourceName, "Source Wave", popup WaveList("*", ";", "")
	String destName
	Prompt destName, "Destination Wave"
	Variable factor=10
	Prompt factor, "Decimation factor"
	Variable XPosition
	Prompt XPosition, "X Position of data point within decimation window", popup "left;middle;right"

	PauseUpdate; Silent 1
	FDecimateXPosStd($sourceName, destName, factor, XPosition, 1)
End