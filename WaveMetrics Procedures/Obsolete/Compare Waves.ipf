// The purpose of these functions is to compare two waves to see if they are identical.
// The main function is CompareWaves(), at the bottom of the file.

// HR, 970904: Version 1.01. Fixed comparison of NaNs.

// HR, 010712: Version 1.02. Added support for complex waves.

// HR, 2018-10-22: Version 1.03
//	Changed CmpStr to use binary compare because regular CmpStr does not handle nulls.
// Added CompareWavesTextEncodings as a separate test. You will probably not need it.

// HR, 2019-03-26: Version 1.04
//	Made all routines threadsafe. Added tests for null waves.

#pragma rtGlobals=3
#pragma version = 1.04				// 2019-03-26

ThreadSafe static Function CheckThatWavesExist(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (!WaveExists(w1))
		if (printDiscrepancy)
			Print "*** Discrepancy: First wave does not exist"
		endif
		return 1
	endif
	
	if (!WaveExists(w2))
		if (printDiscrepancy)
			Print "*** Discrepancy: Second wave does not exist"
		endif
		return 1
	endif
	
	return 0
End

ThreadSafe Function CompareWavesTypes(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif

	Variable type1, type2
	
	type1 = WaveType(w1)
	type2 = WaveType(w2)
	if (type1 != type2)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First wave type is %d, second is %d.\r", type1, type2
		endif
		return 1
	endif
	
	return 0
End

ThreadSafe Function CompareWavesNumDimensions(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable w1Dims, w2Dims
	
	w1Dims = WaveDims(w1)
	w2Dims = WaveDims(w2)
	if (w1Dims != w2Dims)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First has %d dimensions, second has %d dimensions.\r", w1Dims, w2Dims
		endif
		return 1
	endif
	return 0
End

ThreadSafe Function CompareWavesDimSizes(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable n1, n2
	
	n1 = DimSize(w1, 0)
	n2 = DimSize(w2, 0)
	if (n1 != n2)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First has %d rows, second has %d rows.\r", n1, n2
		endif
		return 1
	endif
	
	n1 = DimSize(w1, 1)
	n2 = DimSize(w2, 1)
	if (n1 != n2)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First has %d columns, second has %d columns.\r", n1, n2
		endif
		return 1
	endif
	
	n1 = DimSize(w1, 2)
	n2 = DimSize(w2, 2)
	if (n1 != n2)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First has %d layers, second has %d layers.\r", n1, n2
		endif
		return 1
	endif
	
	n1 = DimSize(w1, 3)
	n2 = DimSize(w2, 3)
	if (n1 != n2)
		if (printDiscrepancy)
			Printf "*** Discrepancy: First has %d chunks, second has %d chunks.\r", n1, n2
		endif
		return 1
	endif
	
	return 0
End

ThreadSafe Function CompareWavesValues(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable isText, isComplex
	Variable p, q, r, s
	Variable numRows, numColumns, numLayers, numChunks
	Variable discrepancy
	
	isText = WaveType(w1) == 0
	if (isText && WaveType(w2)!=0)
		if (printDiscrepancy)
			Print "*** Discrepancy: One wave is text and the other is numeric.\r"
		endif
		return 1
	endif

	isComplex = WaveType(w1) & 1
	if (isComplex && (WaveType(w2) & 1)==0)
		if (printDiscrepancy)
			Print "*** Discrepancy: One wave is complex and the other is real.\r"
		endif
		return 1
	endif
	
	numRows = DimSize(w1, 0)
	numColumns = DimSize(w1, 1)
	numLayers = DimSize(w1, 2)
	numChunks = DimSize(w1, 3)
	
	s = 0
	do
		r = 0
		do
			q = 0
			do
				p = 0
				do
					if (numRows==0)
						break
					endif
					if (isText)
						Wave/T tw1=w1, tw2=w2		// so compiler knows they are text waves
						// HR, 2018-10-22, 9.00: Changed to binary comparison because normal CmpStr does not handle nulls
						discrepancy = CmpStr(tw1[p][q][r][s],tw2[p][q][r][s],2) != 0	// Binary compare because text wave content can include nulls
					else
						if (isComplex)						// HR, 010712, 5.0: Added support for complex waves.
							Wave/C cw1=w1, cw2=w2		// so compiler knows they are complex waves
							discrepancy = real(cw1[p][q][r][s]) != real(cw2[p][q][r][s])
							if (discrepancy)
								if (numtype(real(cw1[p][q][r][s])==2))				// Is NaN?
									if (numtype(real(cw2[p][q][r][s])==2))			// Is NaN?
										discrepancy = 0
									endif
								endif
							endif
							if (discrepancy == 0)
								discrepancy = imag(cw1[p][q][r][s]) != imag(cw2[p][q][r][s])
								if (discrepancy)
									if (numtype(imag(cw1[p][q][r][s])==2))			// Is NaN?
										if (numtype(imag(cw2[p][q][r][s])==2))		// Is NaN?
											discrepancy = 0
										endif
									endif
								endif
							endif						
						else
							// Here for real, numeric wave.
							discrepancy = w1[p][q][r][s] != w2[p][q][r][s]
							if (discrepancy)				// HR, 970904: Fixed bug regarding NaNs.
								if (numtype(w1[p][q][r][s])==2)						// Is NaN?
									if (numtype(w2[p][q][r][s])==2)					// Is NaN?
										discrepancy = 0
									endif
								endif
							endif
						endif
					endif
					if (discrepancy)
						if (printDiscrepancy)
							Printf "*** Discrepancy in value: Row=%d, column=%d, layer=%d, chunk=%d.\r", p, q, r, s
						endif
						return 1
					endif
					p += 1
				while (p < numRows)
				q += 1
			while (q < numColumns)
			r += 1
		while (r < numLayers)
		s += 1
	while (s < numChunks)
	
	return 0
End

ThreadSafe Function CompareWavesScaling(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable dimension
	Variable/D v1, v2
	
	dimension = 0
	do
		v1 = DimOffset(w1, dimension)
		v2 = DimOffset(w2, dimension)
		if (v1 != v2)
			if (printDiscrepancy)
				Printf "*** Discrepancy: Different scale offset in dimension %d, first=%g, second=%g.\r", dimension, v1, v2
			endif
			return 1
		endif
		
		v1 = DimDelta(w1, dimension)
		v2 = DimDelta(w2, dimension)
		if (v1 != v2)
			if (printDiscrepancy)
				Printf "*** Discrepancy: Different scale delta in dimension %d, first=%g, second=%g.\r", dimension, v1, v2
			endif
			return 1
		endif
		
		dimension += 1
	while (dimension < WaveDims(w1))
	
	return 0
End

ThreadSafe Function CompareWavesUnits(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable dimension
	String units1, units2
	
	dimension = 0
	do
		units1 = WaveUnits(w1, dimension)
		units2 = WaveUnits(w2, dimension)
		if (CmpStr(units1,units2,2) != 0)			// Binary compare (not really needed because units can not contain nulls)
			if (printDiscrepancy)
				Printf "*** Discrepancy: Different units in dimension %d, first=\"%s\", second=\"%s\".\r", dimension, units1, units2
			endif
			return 1
		endif
		dimension += 1
	while (dimension < WaveDims(w1))
	
	return 0
End

ThreadSafe Function CompareWavesNotes(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	String note1, note2
	
	note1 = Note(w1)
	note2 = Note(w2)
	if (CmpStr(note1,note2,2) != 0)		// Binary compare because the wave note can contain nulls
		if (printDiscrepancy)
			Print "*** Discrepancy: Different wave notes."
		endif
		return 1
	endif
	
	return 0
End

ThreadSafe Function CompareWavesLabels(w1, w2, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	Variable element, numElements
	Variable dimension
	String label1, label2
	
	dimension = 0
	do
		numElements = DimSize(w1, dimension)
		element = -1					// element -1 is the label for the entire dimension
		do
			if (numElements == 0)
				break
			endif
			label1 = GetDimLabel(w1, dimension, element)
			label2 = GetDimLabel(w2, dimension, element)
			if (CmpStr(label1,label2,2) != 0)		// Binary compare (not really needed because dimension labels can not contain nulls)
				if (printDiscrepancy)
					Printf "*** Discrepancy: Different labels. Dimension %d, element %d. First is '%s', second is '%s'.\r", dimension, element, label1, label2
				endif
				return 1
			endif
			element += 1
		while (element < numElements)
		dimension += 1
	while (dimension < WaveDims(w1))
	
	return 0
End

// CompareWaves(w1, w2, testMask, printDispcrepancy)
//	Compares properties of the waves, returning 0 if the waves are equal and non-zero
//	if there is a discrepancy.
//	testMask determines which tests are done (details below).
//	If printDiscrepancy is non-zero and if there is a discrepancy, CompareWaves prints
//	a discrepancy message in the history area.
//	CompareWaves compares the following properties:
//		Test 1:	Wave types (e.g. single precision, double precision, text)
//		Test 2:	The number of dimensions.
//		Test 3:	The size of each dimension.
//		Test 4:	The dimension labels for each dimensions.
//		Test 5:	The scaling of each dimension.
//		Test 6:	The units for each dimension.
//		Test 7:	The wave notes.
//		Test 8:	The value of each data point.
//
//	To execute all tests, or until a discrepancy is found, pass -1 for testMask.
//	To execute a subset of the test, set the corresponding bit in testMask.
//	For example, to do tests 1, 2, 3 and 8:
//		testMask = 2^1 + 2^2 + 2^3 + 2^8
ThreadSafe Function CompareWaves(w1, w2, testMask, printDiscrepancy)
	Wave/Z w1
	Wave/Z w2
	Variable testMask				// Set bit 2^i to do test number i.
	Variable printDiscrepancy		// Non-zero to print message about discrepancy.
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif
	
	if (testMask %& 2^1)
		if (CompareWavesTypes(w1, w2, printDiscrepancy))
			return 1
		endif
	endif
	
	if (testMask %& 2^2)
		if (CompareWavesNumDimensions(w1, w2, printDiscrepancy))
			return 2
		endif
	endif
		
	if (testMask %& 2^3)
		if (CompareWavesDimSizes(w1, w2, printDiscrepancy))
			return 3
		endif
	endif
		
	if (testMask %& 2^4)
		if (CompareWavesLabels(w1, w2, printDiscrepancy))
			return 4
		endif
	endif
		
	if (testMask %& 2^5)
		if (CompareWavesScaling(w1, w2, printDiscrepancy))
			return 5
		endif
	endif
		
	if (testMask %& 2^6)
		if (CompareWavesUnits(w1, w2, printDiscrepancy))
			return 6
		endif
	endif
		
	if (testMask %& 2^7)
		if (CompareWavesNotes(w1, w2, printDiscrepancy))
			return 7
		endif
	endif
		
	if (testMask %& 2^8)
		if (CompareWavesValues(w1, w2, printDiscrepancy))
			return 8
		endif
	endif
	
	return 0
End

// CompareWavesTextEncodings(w1, w2, elementMask, printDiscrepancy)
// This is separate from the main CompareWaves function because it is likely
// to fail with waves from the Igor6 era. Call this routine separately if
// you want to verify that the various wave text encoding settings match.
// See the documentation for WaveTextEncoding for details.
//	elementMask controls which wave element text encodings are tested. Pass -1 for all.
ThreadSafe Function CompareWavesTextEncodings(w1, w2, elementMask, printDiscrepancy)		// HR, 2018-10-22, 1.03: Added this
	Wave/Z w1
	Wave/Z w2
	Variable elementMask				// Bit mask that controls testing of the various wave text encodings
	Variable printDiscrepancy		// non-zero to print message about discrepancy
	
	if (CheckThatWavesExist(w1, w2, printDiscrepancy))
		return 1
	endif

	Variable textEncoding1, textEncoding2
	Variable element
	Variable getEffectiveTextEncoding = 0		// We want raw text encodings
	
	// Compare text encoding for wave name
	if (elementMask & 1)
		element = 1							// Wave name
		textEncoding1 = WaveTextEncoding(w1, element, getEffectiveTextEncoding)
		textEncoding2 = WaveTextEncoding(w2, element, getEffectiveTextEncoding)
		if (textEncoding1 != textEncoding2)
			if (printDiscrepancy)
				Printf "*** Discrepancy in raw wave name text encoding: First is %d, second is %d.\r", textEncoding1, textEncoding2
			endif
			return 1
		endif
	endif
	
	// Compare text encoding for wave units
	if (elementMask & 2)
		element = 2							// Wave units
		textEncoding1 = WaveTextEncoding(w1, element, getEffectiveTextEncoding)
		textEncoding2 = WaveTextEncoding(w2, element, getEffectiveTextEncoding)
		if (textEncoding1 != textEncoding2)
			if (printDiscrepancy)
				Printf "*** Discrepancy in raw wave units text encoding: First is %d, second is %d.\r", textEncoding1, textEncoding2
			endif
			return 1
		endif
	endif
	
	// Compare text encoding for wave note
	if (elementMask & 4)
		element = 4							// Wave note
		textEncoding1 = WaveTextEncoding(w1, element, getEffectiveTextEncoding)
		textEncoding2 = WaveTextEncoding(w2, element, getEffectiveTextEncoding)
		if (textEncoding1 != textEncoding2)
			if (printDiscrepancy)
				Printf "*** Discrepancy in raw wave note text encoding: First is %d, second is %d.\r", textEncoding1, textEncoding2
			endif
			return 1
		endif
	endif
	
	// Compare text encoding for wave dimension labels
	if (elementMask & 8)
		element = 8							// Wave dimension labels
		textEncoding1 = WaveTextEncoding(w1, element, getEffectiveTextEncoding)
		textEncoding2 = WaveTextEncoding(w2, element, getEffectiveTextEncoding)
		if (textEncoding1 != textEncoding2)
			if (printDiscrepancy)
				Printf "*** Discrepancy in raw wave dimension labels text encoding: First is %d, second is %d.\r", textEncoding1, textEncoding2
			endif
			return 1
		endif
	endif
	
	// Compare text encoding for wave contents
	if (elementMask & 16)
		element = 16							// Wave content
		textEncoding1 = WaveTextEncoding(w1, element, getEffectiveTextEncoding)
		textEncoding2 = WaveTextEncoding(w2, element, getEffectiveTextEncoding)
		if (textEncoding1 != textEncoding2)
			if (printDiscrepancy)
				Printf "*** Discrepancy in raw wave content text encoding: First is %d, second is %d.\r", textEncoding1, textEncoding2
			endif
			return 1
		endif
	endif
	
	return 0
End
