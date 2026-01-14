#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.01			// circa Igor 9.01

// Version 1.01, 5/17/94
//	Used Wave/D instead of Wave in several places.
// Version 1.10, 12/31/95
//	Updated for Igor Pro 3.0. Removed /D which is no longer needed.
// Version 1.20, 8/28/97
//	Added RemoveOutliersXY.
// Version 9.01, 3/7/22
//	Added DeletePointsXY.


// RemoveOutliers(theWave, minVal, maxVal)
//	Removes all points in the wave below minVal or above maxVal.
//	Returns the number of points removed.
Function RemoveOutliers(theWave, minVal, maxVal)
	Wave theWave
	Variable minVal, maxVal

	Variable p, numPoints, numOutliers
	Variable val
	
	numOutliers = 0
	p = 0											// the loop index
	numPoints = numpnts(theWave)				// number of times to loop

	do
		val = theWave[p]
		if ((val < minVal) %| (val > maxVal))	// is this an outlier?
			numOutliers += 1
		else										// if not an outlier
			theWave[p - numOutliers] = val		// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numOutliers, numOutliers, theWave
	
	return(numOutliers)
End

// RemoveOutliersXY(theXWave, theYWave, minVal, maxVal)
//	Removes each point in an XY pair whose Y value is below minVal or above maxVal.
//	Returns the number of points removed.
Function RemoveOutliersXY(theXWave, theYWave, minVal, maxVal)
	Wave theXWave
	Wave theYWave
	Variable minVal, maxVal

	Variable p, numPoints, numOutliers
	Variable val
	
	numOutliers = 0
	p = 0														// the loop index
	numPoints = numpnts(theYWave)						// number of times to loop

	do
		val = theYWave[p]
		if ((val < minVal) %| (val > maxVal))				// is this an outlier?
			numOutliers += 1
		else													// if not an outlier
			theYWave[p - numOutliers] = val				// copy to input Y wave
			theXWave[p - numOutliers] = theXWave[p]		// copy to input Y wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numOutliers, numOutliers, theXWave, theYWave
	
	return(numOutliers)
End

// RemoveNaNs(theWave)
//	Removes all points in the wave with the value NaN.
//	A NaN represents a blank or missing value.
//	Returns the number of points removed.
Function RemoveNaNs(theWave)
	Wave theWave

	Variable p, numPoints, numNaNs
	Variable val
	
	numNaNs = 0
	p = 0											// the loop index
	numPoints = numpnts(theWave)				// number of times to loop

	do
		val = theWave[p]
		if (numtype(val)==2)					// is this NaN?
			numNaNs += 1
		else										// if not NaN
			theWave[p - numNaNs] = val			// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numNaNs, numNaNs, theWave
	
	return(numNaNs)
End

// RemoveNaNsXY(theXWave, theYWave)
//	Removes all points in an XY pair if either wave has the value NaN.
//	A NaN represents a blank or missing value.
//	Returns the number of points removed.
Function RemoveNaNsXY(theXWave, theYWave)
	Wave theXWave
	Wave theYWave

	Variable p, numPoints, numNaNs
	Variable xval, yval
	
	numNaNs = 0
	p = 0											// the loop index
	numPoints = numpnts(theXWave)			// number of times to loop

	do
		xval = theXWave[p]
		yval = theYWave[p]
		if ((numtype(xval)==2) %| (numtype(yval)==2))		// either is NaN?
			numNaNs += 1
		else										// if not an outlier
			theXWave[p - numNaNs] = xval		// copy to input wave
			theYWave[p - numNaNs] = yval		// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numNaNs, numNaNs, theXWave, theYWave
	
	return(numNaNs)
End


// DeletePointsXY(theXWave, theYWave, deleteMode, checkMode, minX, maxX, minY, maxY)
//
//	Deletes points from the (required) y wave and the optional x wave.
//
//	To select which points will be deleted, set 
//
//		You can delete the points outside the marquee rather than inside.
//
//		You can delete points that fall inside or outside a given range of Y values,
//		regardless of their X values.
//
//		You can delete points that fall inside or outside a given range of X values,
//		regardless of their Y values. This is by far the fastest technique because it
//		does not have to search point by point.
//
//	The deleteMode and checkMode parameters determine the criteria used when
//	selecting points to delete:
//
//	If checkMode is 1 then only X values are tested.
//	If checkMode is 2 then only Y values are tested.
//	If checkMode is 3 then X and Y values are tested.
//
//	deleteMode determines whether points inside the marquee or outside the marquee
//	will be deleted:
//
//	If deleteMode is 1 then inside points are deleted.
//	If deleteMode is 2 then outside points are deleted.

Function DeletePointsXY(theXWave, theYWave, deleteMode, checkMode, minX, maxX, minY, maxY)
	Wave/Z theXWave						// pass $"" if not y vs x
	Wave theYWave
	Variable deleteMode					// 1 for delete inside x and/or y ranges, 2 for delete outside
	Variable checkMode					// 1 = check X values, 2 = check Y values, 3 = check X and Y values
	Variable minX, maxX					// we require minX <= maxX
	Variable minY, maxY					// we require minY <= maxY
	
	Variable n = numpnts(theYWave)
	if (n <= 0)
		return 0
	endif

	Variable isParametric= WaveExists(theXWave)			// true if y vs x

	// Algorithm is to copy retained values over discarded value, then delete at the end.
	// Compare to Remove Points.ipf's RemoveOutliersXY()
	Variable inPt, destPt
	Variable numDeleted = 0
	for(inPt=0,destPt=0; inPt<n; inPt+=1)
		Variable y = theYWave[inPt]
		Variable x
		if( isParametric )
			x = theXWave[inPt]
		else
			x = x2pnt(theYWave, inPt)
		endif
		Variable insideRange= 1	// if not checking x range, all of the x range is kept
		if( checkMode & 1 ) 		// checking x range?
			insideRange = (x >= minX) && (x <= maxX)
		endif
		
		if( checkMode & 2 ) 		// checking y range
			insideRange = insideRange && (y >= minY) && (y <= maxY)
		endif

		// deleteMode = 1 for delete inside marquee, 2 for delete outside
		Variable deleteIt = deleteMode == 1 ? insideRange : !insideRange
		if (deleteIt)
			numDeleted += 1
		else
			if (numDeleted)					// if we haven't deleted anything, no need to move values
				theYWave[destPt] = y				// move kept y over deleted y(s)
				if (isParametric)
					theXWave[destPt] = x		// move kept x over deleted x(s)
				endif
			endif
			destPt += 1
		endif
	endfor
		// Truncate the wave
	if (numDeleted)					// if we haven't deleted anything, no need to move values
		DeletePoints n-numDeleted, numDeleted, theYWave
		if( isParametric )
			DeletePoints n-numDeleted, numDeleted, theXWave
		endif
	endif
	return numDeleted
End
