#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

// The ReduceMatrixSize function reduces the number of rows and/or columns
// of a matrix (2D wave) by sampling or averaging. See comments for ReduceMatrixSize
// below for further information.

#pragma IgorVersion = 8.00
#pragma version = 1.00			// Version 1.00, 2021-02-11

// TranslateIndices(matIn, dimension, startIndex, endIndex)
// Translates negative numbers specified as row or column indices.
// The starting and ending indices specified to ReduceMatrixSize can be
// specified using negative numbers. In that case the index is relative
// to the end of the dimension. For example, if endRowIn is -1 this means
// DimSize(matIn,0)-1. The resulting indices are not clipped to legal bounds.
// It is up to the user to specify valid input indices.
static Function TranslateIndices(matIn, dimension, startIndex, endIndex)
	WAVE matIn
	int dimension			// 0 for rows, 1 for columns
	int& startIndex			// Input and output: Index of first row or column to include in output
	int& endIndex			// Input and output: Index of last row or column to include in output
	
	int numElements = DimSize(matIn, dimension)
	if (startIndex < 0)
		startIndex = numElements + startIndex
	endif
	
	if (endIndex < 0)
		endIndex = numElements + endIndex
	endif
End

static Function IsLegalName(String outputMatrixName)
	if (strlen(outputMatrixName) == 0)
		return 0
	endif
	
	if (CmpStr(outputMatrixName, CleanupName(outputMatrixName,1)) != 0)
		return 0
	endif
	
	return 1
End

// PossiblyAdjustScaling(matIn, startRowIn, rowStride, startColumnIn, columnStride, matOut)
// Adjusts the X and Y scaling of matOut to take the reduction in size into account.
// If a dimension in matIn uses point scaling, that dimension in matOut is not adjusted.
static Function PossiblyAdjustScaling(matIn, startRowIn, rowStride, startColumnIn, columnStride, matOut)
	WAVE matIn
	int startRowIn				// Index of first row in matIn included in matOut, negative indices are not supported
	int rowStride
	int startColumnIn			// Index of first column in matIn included in matOut, negative indices are not supported
	int columnStride
	WAVE matOut
	
	Variable x0 = DimOffset(matIn, 0)
	Variable dx = DimDelta(matIn, 0)
	int adjustXScaling = x0!=0 || dx!=1			// Leave "point" scaling as is
	if (adjustXScaling)
		x0 += startRowIn * dx
		dx *= rowStride
		String xUnits = WaveUnits(matOut, 0)
		SetScale/P x, x0, dx, xUnits, matOut
	endif
	
	Variable y0 = DimOffset(matIn, 1)
	Variable dy = DimDelta(matIn, 1)
	int adjustYScaling = y0!=0 || dy!=1			// Leave "point" scaling as is
	if (adjustYScaling)
		y0 += startColumnIn * dy
		dy *= columnStride
		String yUnits = WaveUnits(matOut, 1)
		SetScale/P y, y0, dy, yUnits, matOut
	endif
End

// ValidateReduceMatrixSizeParameters(matIn, startRowIn, endRowIn, requestedNumRowsOut, startColumnIn, endColumnIn, requestedNumColumnsOut, doAverage, outputMatrixName)
// Returns an error string if the parameters are not valid, "" if they are valid.
Function/S ValidateReduceMatrixSizeParameters(matIn, startRowIn, endRowIn, requestedNumRowsOut, startColumnIn, endColumnIn, requestedNumColumnsOut, doAverage, outputMatrixName)
	WAVE/Z matIn
	int startRowIn				// Index of first row to include in output, negative is relative to end of row dimension
	int endRowIn				// Index of last row to include in output, negative is relative to end of row dimension
	int requestedNumRowsOut		// Requested number of output rows
	int startColumnIn			// Index of first column to include in output, negative is relative to end of column dimension
	int endColumnIn				// Index of last column to include in output, negative is relative to end of row dimension
	int requestedNumColumnsOut	// Requested number of output columns
	int doAverage				// 1=average the rows and columns, otherwise rows and columns are sampled
	String outputMatrixName
	
	if (!WaveExists(matIn))
		return "ReduceMatrixSize: Input matrix does not exist"
	endif
	int numDims = WaveDims(matIn)
	if (numDims<2 || numDims>3)
		return "ReduceMatrixSize: Input wave must be 2D or 3D"
	endif
	if (WaveType(matIn,1) != 1)
		return "ReduceMatrixSize: Input wave must be numeric"
	endif
	
	if (!IsLegalName(outputMatrixName))
		return "ReduceMatrixSize: Invalid outputMatrixName"
	endif
	String inputWaveName = NameOfWave(matIn)
	if (CmpStr(outputMatrixName,inputWaveName) == 0)
		return "ReduceMatrixSize: Output matrix name must be distinct from input matrix name"
	endif
	
	int numRowsInInputMatrix = DimSize(matIn, 0)
	int numColumnsInInputMatrix = DimSize(matIn, 1)
	
	if (requestedNumRowsOut < 1)
		return "ReduceMatrixSize: Invalid requestedNumRowsOut"
	endif
	TranslateIndices(matIn, 0, startRowIn, endRowIn)	// Translate negative inputs as relative to end of row dimension
	if (startRowIn<0 || startRowIn>=numRowsInInputMatrix)
		return "ReduceMatrixSize: Invalid startRowIn"
	endif
	if (endRowIn<0 || endRowIn>=numRowsInInputMatrix)
		return "ReduceMatrixSize: Invalid endRowIn"
	endif
	if (startRowIn > endRowIn)
		return "ReduceMatrixSize: startRowIn > endRowIn"
	endif
	int numRowsInInputRange = (endRowIn - startRowIn) + 1
	if (requestedNumRowsOut > numRowsInInputRange)
		return "ReduceMatrixSize: Invalid requestedNumRowsOut"
	endif

	if (requestedNumColumnsOut < 1)
		return "ReduceMatrixSize: Invalid requestedNumColumnsOut"
	endif
	TranslateIndices(matIn, 1, startColumnIn, endColumnIn)	// Translate negative inputs as relative to end of column dimension
	if (startColumnIn<0 || startColumnIn>=numColumnsInInputMatrix)
		return "ReduceMatrixSize: Invalid startColumnIn"
	endif
	if (endColumnIn<0 || endColumnIn>=numColumnsInInputMatrix)
		return "ReduceMatrixSize: Invalid endColumnIn"
	endif
	if (startColumnIn > endColumnIn)
		return "ReduceMatrixSize: startColumnIn > endColumnIn"
	endif
	int numColumnsInInputRange = (endColumnIn - startColumnIn) + 1
	if (requestedNumColumnsOut > numColumnsInInputRange)
		return "ReduceMatrixSize: Invalid requestedNumColumnsOut"
	endif
	
	return ""		// Parameters are valid
End

// ReduceMatrixSize(...)
// Creates an output matrix with the requested number of rows and columns.
// The output matrix is created in the same data folder as the input matrix.
// The output wave name must be distinct from the input wave name.
// If the the output wave already exists, it is overwritten.
// Returns a wave reference to the output matrix wave.
// If the input wave has dimension scaling in X and/or Y that is not "point scaling",
// the scaling of the corresponding output wave dimension is adjusted to reflect
// the reduction in dimension size. 
// ReduceMatrixSize aborts if the input parameters are invalid.
// Call ValidateReduceMatrixSizeParameters if you want to validate the input parameters yourself.
// If matIn is a 3D wave, ReduceMatrixSize treats it as a stack of matrices and
// each layer of the 3D wave is reduced as if it were a standalone matrix.
// See the descriptions of the parameters for further information.
Function/WAVE ReduceMatrixSize(matIn, startRowIn, endRowIn, requestedNumRowsOut, startColumnIn, endColumnIn, requestedNumColumnsOut, doAverage, outputMatrixName)
	WAVE/Z matIn
	int startRowIn				// Index of first row to include in output, negative is relative to end of row dimension
	int endRowIn				// Index of last row to include in output, negative is relative to end of row dimension
	int requestedNumRowsOut		// Requested number of output rows
	int startColumnIn			// Index of first column to include in output, negative is relative to end of column dimension
	int endColumnIn				// Index of last column to include in output, negative is relative to end of row dimension
	int requestedNumColumnsOut	// Requested number of output columns
	int doAverage				// 1=average the rows and columns, otherwise rows and columns are sampled
	String outputMatrixName
	
	String errorStr = ValidateReduceMatrixSizeParameters(matIn, startRowIn, endRowIn, requestedNumRowsOut, startColumnIn, endColumnIn, requestedNumColumnsOut, doAverage, outputMatrixName)
	if (strlen(errorStr) > 0)
		Abort errorStr
	endif
	
	int numRowsInInputMatrix = DimSize(matIn, 0)
	int numColumnsInInputMatrix = DimSize(matIn, 1)

	TranslateIndices(matIn, 0, startRowIn, endRowIn)		// Translate negative inputs as relative to end of row dimension
	TranslateIndices(matIn, 1, startColumnIn, endColumnIn)	// Translate negative inputs as relative to end of column dimension
	int numRowsInInputRange = (endRowIn - startRowIn) + 1
	int numColumnsInInputRange = (endColumnIn - startColumnIn) + 1

	// rowStride is intentionally truncated to an integer as the ImageInterpolate
	// /PXSZ flag truncates to integers. This means that, if numRowsInInputRange
	// is not evenly divisible by requestedNumRowsOut, the last output row will
	// be the average of fewer rows than the other output rows.
	int rowStride = numRowsInInputRange / requestedNumRowsOut	// Number of input rows to skip to get to the next band of rows
	if (rowStride < 1)
		rowStride = 1
	endif
	
	// Ceil mimics what ImageInterpolate does, i.e., including an output row for a partial
	// band of input rows at the end of the input matrix
	int actualNumRowsOut = ceil(numRowsInInputRange / rowStride)	// Actual number of output rows given integer stride
	
	// columnStride is intentionally truncated to an integer as the ImageInterpolate
	// /PXSZ flag truncates to integers. This means that, if numRowsInInputRange
	// is not evenly divisible by requestedNumColumnsOut, the last output column
	// will be the average of fewer columns than the other output columns.
	int columnStride = numColumnsInInputRange / requestedNumColumnsOut	// Number of input columns to skip to get to the next band of columns
	if (columnStride < 1)
		columnStride = 1
	endif
	
	// Ceil mimics what ImageInterpolate does, i.e., including an output column
	// for a partial band of input columns at the end of the input matrix
	int actualNumColumnsOut = ceil(numColumnsInInputRange / columnStride)	// Actual number of output columns given integer stride
	
	DFREF dfr = GetWavesDataFolderDFR(matIn)		// Output is created in input matrix's data folder
	
	#if 0	// For debugging only
		Printf "startCellIn=(%d,%d), endCellIn=(%d,%d), requestedNumCellsOut=(%d,%d), stride=(%d,%d), actualNumCellsOut=(%d,%d), average=%d\r", startRowIn, startColumnIn, endRowIn, endColumnIn, requestedNumRowsOut, requestedNumColumnsOut, rowStride, columnStride, actualNumRowsOut, actualNumColumnsOut, doAverage
	#endif
	
	// numLayers is 0 if matIn is 2D, >=1 if matIn is 3D
	int numLayers = DimSize(matIn,2)
	int startLayer=0, endLayer=numLayers-1		// Invalid if matIn is 2D
	
	// matOut is 2D if numLayers is 0, 3D if numLayers>=1
	int dataType = WaveType(matIn)
	Make/O/Y=(dataType)/N=(actualNumRowsOut,actualNumColumnsOut,numLayers) dfr:$outputMatrixName
	WAVE matOut = dfr:$outputMatrixName
	
	#if 0	// This code is valid but is disabled to allow testing code below with stride=(1,1)
		if (rowStride<=1 && columnStride<=1)		// Extracting a subset of cells without averaging?
			matOut = matIn[startRowIn+p][startColumnIn+q][r]	// [r] is ignored with 2D wave
			return matOut
		endif
	#endif
	
	WAVE origMatIn = matIn		// matIn is changed if we are averaging a subset
	
	if (doAverage == 1)
		if (numRowsInInputRange<numRowsInInputMatrix || numColumnsInInputRange<numColumnsInInputMatrix)
			// ImageInterpolate does not support working on a subset of the input matrix
			// so we need to create a temporary input matrix
			if (numLayers > 0)
				Duplicate/FREE/RMD=[startRowIn,endRowIn][startColumnIn,endColumnIn][startLayer,endLayer] matIn, subsetOfMatIn
			else
				Duplicate/FREE/RMD=[startRowIn,endRowIn][startColumnIn,endColumnIn] matIn, subsetOfMatIn
			endif
			WAVE matIn = subsetOfMatIn
			#if 0		// For debugging only
				Printf "Made temp copy of input range [%d,%d][%d,%d]\r", startRowIn, endRowIn, startColumnIn, endColumnIn
			#endif
		endif
		ImageInterpolate/PXSZ={rowStride,columnStride}/DEST=matOut Pixelate matIn
	else
		matOut = matIn[startRowIn+p*rowStride][startColumnIn+q*columnStride][r]	// [r] is ignored with 2D wave
	endif
	
	PossiblyAdjustScaling(origMatIn, startRowIn, rowStride, startColumnIn, columnStride, matOut)
	
	// Truncate output to requested number of rows instead of keeping
	// an extra row if mod(numRowsInInputMatrix,requestedNumRowsOut)!=0
	// and same for columns.
	if (actualNumRowsOut>requestedNumRowsOut || actualNumColumnsOut>requestedNumColumnsOut)
		Redimension/N=(requestedNumRowsOut,requestedNumColumnsOut,numLayers) matOut	
		#if 0		// For debugging only
			Printf "Redimensioned from %dx%d sized based on strides to requested size %dx%d\r", actualNumRowsOut, actualNumColumnsOut, requestedNumRowsOut, requestedNumColumnsOut
		#endif
	endif
	
	return matOut
End
