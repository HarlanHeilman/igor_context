#pragma rtGlobals = 1

// Concatenate Waves version 1.02
// 		Feb. 1, 2001, 1.02 JP - removed inclusion of Strings As Lists and Keyword-Value.
// 		Feb. 2, 1997, 1.01 JW - added test for text waves

//	ConcatenateWaves(w1, w2)
//		Tacks the contents of w2 on the to end of w1.
//		If w1 does not exist, it is created.
//		This is designed for 1D waves only.
Function ConcatenateWaves(w1, w2)
	String w1, w2
	
	Variable numPoints1, numPoints2

	if (Exists(w1) == 0)
		Duplicate $w2, $w1
	else
		String wInfo=WaveInfo($w2, 0)
		Variable WType=NumberByKey("NUMTYPE", wInfo)
		numPoints1 = numpnts($w1)
		numPoints2 = numpnts($w2)
		Redimension/N=(numPoints1 + numPoints2) $w1
		if (WType)				// Numeric wave
			Wave/C/D ww1=$w1
			Wave/C/D ww2=$w2
			ww1[numPoints1, ] = ww2[p-numPoints1]
		else						// Text wave
			Wave/T tw1=$w1
			Wave/T tw2=$w2
			tw1[numPoints1, ] = tw2[p-numPoints1]
		endif
	endif
End

//	ConcatenateWavesInList(dest, wl)
//		Makes a dest wave that is the concatenation of the source waves.
//		Overwrites the dest wave if it already exists.
//		wl is assumed to contain at least one wave name.
//		This is designed for 1D waves only.
Function ConcatenateWavesInList(dest, wl)
	String dest		// name of output wave
	String wl		// semicolon separated list of waves ("w0;w1;w2;")
	
	Variable i					// for walking through wavelist
	String theWaveName
	Variable destExisted
	
	destExisted = Exists(dest)
	if (destExisted)
		Redimension/N=0 $dest
	endif
	
	i = 0
	do
		theWaveName = StringFromList(i,wl)
		if (strlen(theWaveName) == 0)
			break										// no more waves
		endif
		if (cmpstr(theWaveName, dest) != 0)		// don't concat dest wave with itself
			ConcatenateWaves(dest, theWaveName)
		endif
		i += 1
	while (1)
End
