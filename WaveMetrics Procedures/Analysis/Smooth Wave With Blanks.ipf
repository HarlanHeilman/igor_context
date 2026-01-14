#pragma rtGlobals=1

// See the "Sectional Smoothing" example experiment for an example

Function FindSegStart(source, segStart, theEnd)	// returns # of first "normal" data point in segment
	Wave source										// wave being searched
	Variable segStart									// point to start search from
	Variable theEnd									// last point to search
														// NOTE: if no more normal points in wave, returns neg #
	Variable curPoint = segStart
	
	if (curPoint >= theEnd)
		return (-1)
	endif
	
	do
		if (numtype(source[curPoint]) == 0)		// is this a normal number
			return (curPoint)						// we've found segment start
		endif
		curPoint += 1
	while (curPoint < theEnd)
	return (-2)										// if here, there are no normal points in segment
End

Function FindSegEnd(source, segStart, theEnd)	// returns # of last "normal" data point in segment
	Wave source									// wave being searched
	Variable segStart								// point to start search from
	Variable theEnd								// last point to search
	
	Variable curPoint = segStart+1
													// NOTE: assumes source[segStart] is normal
	if (curPoint > theEnd)
		return (theEnd)
	endif
	
	do
		if (numtype(source[curPoint]))		// is this an abnormal number
			return (curPoint-1)					// we've found segment end
		endif
		curPoint += 1
	while (curPoint <= theEnd)
	return (theEnd)
End

//	SmoothWaveWithBlanks(sourceStr, destStr, passes)
//	NOTE: This routine is obsolescent. New programming should use
//	FSmoothWaveWithBlanks or FSmoothWaveWithBlanksDialog.
Proc SmoothWaveWithBlanks(sourceStr, destStr, passes)
	String sourceStr							// name of wave to supply data to be smoothed
	Prompt sourceStr, "Source Wave"
	String destStr								// name of wave to put result in (can be same as source)
	Prompt destStr, "Dest Wave"				// NOTE: dest assumed to have same number of points as source
	Variable passes = 5						// number of desired smoothing passes
	Prompt passes, "Number of passes: "
	
	Silent 1

	Variable lastPoint = numpnts($sourceStr)-1
	Variable segStart, segEnd					// point numbers for segment being worked on
	Variable segments=0						// for debugging

	segStart = 0;segEnd = 0
	do
		segStart = FindSegStart($sourceStr, segStart, lastPoint)	// find start of next segment
		Print "segStart = " + num2istr(segStart)
		if (segStart < 0)
			break													// no more normal points
		endif
		segEnd = FindSegEnd($sourceStr, segStart, lastPoint)		// find end of next segment
		Print "segEnd = " + num2istr(segEnd)
		if (segEnd > segStart)										// don't smooth one point		
			Duplicate /O/R=[segStart,segEnd] $sourceStr, root:tempSegWave
			Smooth passes, root:tempSegWave
			$destStr[segStart, segEnd] = root:tempSegWave[p-segStart]
			segments += 1
		endif
		
		segStart = segEnd+1
	while (segStart < lastPoint)
	Print  "Smoothed " + num2istr(segments) + " segments"
	KillWaves/Z root:tempSegWave
End

//	FSmoothWaveWithBlanks(source, dest, passes, reportProgress)
//	The destination wave is assumed to have the same number of points as the source wave.
Function FSmoothWaveWithBlanks(source, dest, passes, reportProgress)
	Wave source								// Wave to supply data to be smoothed
	Wave dest									// Wave to put result in (can be same as source)
	Variable passes							// Number of desired smoothing passes
	Variable reportProgress					// 1=report progress in history, 0=don't report

	Variable lastPoint = numpnts(source)-1
	Variable segStart, segEnd					// point numbers for segment being worked on
	Variable segments=0						// for debugging

	dest = NaN
	
	segStart = 0; segEnd = 0
	do
		segStart = FindSegStart(source, segStart, lastPoint)	// Find start of next segment
		if (reportProgress)
			Print "segStart = " + num2istr(segStart)
		endif
		if (segStart < 0)
			break													// No more normal points
		endif
		segEnd = FindSegEnd(source, segStart, lastPoint)		// Find end of next segment
		if (reportProgress)
			Print "segEnd = " + num2istr(segEnd)
		endif
		if (segEnd > segStart)										// Don't smooth one point		
			Duplicate /O/R=[segStart,segEnd] source, root:tempSegWave
			Wave tempSegWave = root:tempSegWave
			Smooth passes, tempSegWave
			dest[segStart, segEnd] = tempSegWave[p-segStart]
			segments += 1
		endif
		segStart = segEnd+1
	while (segStart < lastPoint)
	if (reportProgress)
		Print  "Smoothed " + num2istr(segments) + " segments"
	endif
	KillWaves/Z tempSegWave
End

//	FSmoothWaveWithBlanksDialog(sourceStr, destStr, passes, reportProgress)
//	Displays a dialog allowing the user to enter the name of the source and destination
//	waves and other parameters. The source wave must exist. The destination need not exist.
Function FSmoothWaveWithBlanksDialog(sourceStr, destStr, passes, reportProgress)
	String sourceStr, destStr
	Variable passes
	Variable reportProgress						// 1=report progress in history, 0=don't report
	
	if (reportProgress != 1)
		reportProgress = 2						// For dialog, 1=yes, 2=no
	endif
	
	Prompt sourceStr, "Source Wave"
	Prompt destStr, "Dest Wave"
	Prompt passes, "Number of passes:"
	Prompt reportProgress, "Report progress in history:", popup "Yes;No"
	DoPrompt "Smooth Waves With Blanks", sourceStr, destStr, passes, reportProgress
	if (V_flag != 0)
		return -1
	endif
	
	if (reportProgress != 1)
		reportProgress = 0						// For normal use, 1=yes, 0=no
	endif
	
	Wave source = $sourceStr
	Wave/Z dest = $destStr
	if (!WaveExists(dest))
		Duplicate/O source, $destStr
		Wave dest = $destStr
	endif
	if (numpnts(dest) != numpnts(source))
		Duplicate/O source, $destStr
		Wave dest = $destStr
	endif
	FSmoothWaveWithBlanks(source, dest, passes, reportProgress==1)
End
