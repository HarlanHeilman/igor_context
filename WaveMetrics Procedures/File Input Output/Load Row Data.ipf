//	This file contains procedures for loading data from text files when you want
//	to store ROWs from the file in one or more 1D waves. The Igor file loaders normally
//	store COLUMNs in 1D waves.
//	Consider the following data:
//		400	0	1	2	3	4
//		405	5	6	7	8	9
//		410	10	11	12	13	14
//	The LoadRowDataInto1DWave routine loads this into a single 1D wave, optionally
//	treating the first column as X values instead of as data.
//	The LoadRowDataInto1DWaves routine loads this into a multiple 1D waves.

#pragma rtGlobals = 1

Menu "Macros"
	"Load Row Data Into One 1D Wave", LoadRowDataInto1DWave()
	"Load Row Data Into Multiple 1D Waves", LoadRowDataInto1DWaves()
End



//	The LoadRowDataInto1DWave procedure loads the contents of a row-oriented
//	text file into a single 1D wave. The text file is assumed to consist of values
//	written as:
//		<v00>	<v01>	<v02>	<v03> . . . <v0n>
//		<v10>	<v11>	<v12>	<v13> . . . <v1n>
//	and so on. The normal text file-loaders are column-oriented and would load
//	this into a number of 1D waves. However, this data is intended to be loaded into
//	a single 1D wave.
//	Two cases are handled.
//	In the first case, all of the data in each row is loaded into a 1D wave in row/column order.
//	In the second case, the first column is taken to contain X values and is not loaded into the
//	1D wave but instead is used to set the X scaling of the wave, on the assumption that the
//	values in this column are uniformly-spaced. The remaining columns are loaded, again
//	in row/column order.
//
//	To use the procedure, choose "Load Row Data Into One 1D Wave" from the Macros menu.

Function ExtractRowDataInto1DWave(mat, firstColNature, name)
	Wave mat						// Matrix containing row-oriented data
	Variable firstColNature			// 1 = first column contains data, 2 = first column contains x values.
	String name						// Name of output wave
	
	Variable numRows, numColumns
	Variable firstColIsX = firstColNature==2
	
	numRows = DimSize(mat, 0)
	numColumns = DimSize(mat, 1)
	
	// Find points and columns to be included in output wave.
	Variable firstCol = 0, lastCol = numColumns-1
	Variable numPoints = numRows * numColumns
	if (firstColIsX)
		numPoints -= numRows		// Points from column 0 will not go into Y wave.
		firstCol += 1
	endif

	Make/O/D/N=(numPoints) $name

	// Store matrix data in the output wave.
	Wave w = $name
	Variable row = 0
	Variable cols = lastCol-firstCol+1		// Number of columns to load.
	Variable startPoint = 0					// Start point in output wave for current row.
	do
		w[startPoint, startPoint+cols-1] = mat[row][firstCol+p-startPoint]
		startPoint += cols
		row += 1
	while (row <= numRows-1)

	// If the first column is X, use it to set X scaling.
	if (firstColIsX)
		Variable x0, dx
		x0 = mat[0][0]
		dx = (mat[1][0]-x0) / cols
		SetScale/P x x0, dx, "", w
	endif
End

Function FDeleteBlanksFromEnd(w)
	Wave w
	
	Variable n = numpnts(w)
	Variable i = n - 1
	do
		if (numtype(w[i]) != 2)			// Not a blank?
			break
		endif
		i -= 1
	while (i >= 0)
	
	Variable numBlanks = n - i - 1
	if (numBlanks > 0)						// Found some blanks?
		DeletePoints i+1, numBlanks, w
	endif
	return numBlanks						// Number of blanks removed
End

Function FLoadRowDataInto1DWave(pathName, fileName, firstColNature, linesToSkip, linesToLoad, deleteBlanksAtEnd, name, makeTable)
	String pathName						// Name of path or "" for dialog.
	String fileName							// Name of file or "" for dialog.
	Variable firstColNature					// 1 = first column contains data, 2 = first column contains x values.
	Variable linesToSkip					// Number of lines to skip at start of file.
	Variable linesToLoad					// Number of lines to load or 0 for auto (load all lines).
	Variable deleteBlanksAtEnd				// 1 = delete blanks, 2 = leave blanks at the end of the wave
	String name								// Name to use for new wave.
	Variable makeTable						// 1 == make a table showing new wave
	
	LoadWave/Q/J/M/D/N=tempLoadRowDataMatrix/P=$pathName/K=0/L={0,linesToSkip,0,0,0} fileName
	ExtractRowDataInto1DWave(tempLoadRowDataMatrix0, firstColNature, name)
	KillWaves tempLoadRowDataMatrix0
	if (deleteBlanksAtEnd)					// Useful when the last row of data is partial
		FDeleteBlanksFromEnd($name)
	endif
	if (makeTable == 1)
		Edit $name.id
	endif
End

Macro LoadRowDataInto1DWave(pathName, fileName, firstColNature, linesToSkip, deleteBlanksAtEnd, name, makeTable)
	String pathName = "_none_"
	Prompt pathName "Path", popup "_none_;" + PathList("*",";","")
	String fileName = ""
	Prompt fileName "File (\"\" for dialog)"
	Variable firstColNature = 2
	Prompt firstColNature "First column contains", popup "Data;X Values"
	Variable linesToSkip = 0
	Prompt linesToSkip "Lines to skip at start of file"
	Variable deleteBlanksAtEnd = 1
	Prompt deleteBlanksAtEnd, "Delete blanks at end of wave?", popup "Yes;No"
	String name = "wave0"
	Prompt name "Name for output wave"
	Variable makeTable = 1
	Prompt makeTable "Make table", popup "Yes;No"
	
	PauseUpdate; Silent 1
	
	if (CmpStr(pathName, "_none_") == 0)
		pathName = ""					// Causes LoadWave to display dialog.
	endif
	FLoadRowDataInto1DWave(pathName, fileName, firstColNature, linesToSkip, 0, deleteBlanksAtEnd, name, makeTable)
End


//	The LoadRowDataInto1DWaves procedure loads the contents of a row-oriented
//	text file into multiple 1D waves. The text file is assumed to consist of values
//	written as:
//		<v00>	<v01>	<v02>	<v03> . . . <v0n>
//		<v10>	<v11>	<v12>	<v13> . . . <v1n>
//	LoadRowDataInto1DWaves would load this into two 1D waves.
//	To use the procedure, choose "Load Row Data Into Multiple 1D Waves" from the Macros menu.

Function ExtractRowDataInto1DWaves(mat, baseName)
	Wave mat						// Matrix containing row-oriented data
	String baseName				// Base name of output waves
	
	Variable numRows, numColumns
	Variable row
	String name
	
	numRows = DimSize(mat, 0)
	numColumns = DimSize(mat, 1)
	
	row = 0
	do
		name = baseName + num2istr(row)
		Make/O/D/N=(numColumns) $name
	
		// Store matrix data in the output wave.
		Wave w = $name
		w = mat[row][p]
		row += 1
	while (row <= numRows-1)
End

Function FLoadRowDataInto1DWaves(pathName, fileName, linesToSkip, linesToLoad, columnsToSkip, columnsToLoad, baseName, makeTable)
	String pathName						// Name of path or "" for dialog.
	String fileName							// Name of file or "" for dialog.
	Variable linesToSkip					// Number of lines to skip at start of file.
	Variable linesToLoad					// Number of lines to load or 0 for auto (load all lines).
	Variable columnsToSkip					// Number of columns to skip.
	Variable columnsToLoad					// Number of columns to load or 0 for auto (load all columns).
	String baseName						// Base name to use for new waves.
	Variable makeTable						// 1 == make a table showing new waves.
	
	LoadWave/Q/J/M/D/A=tempLoadRowDataMatrix/P=$pathName/K=0/L={0,linesToSkip,linesToLoad,columnsToSkip,columnsToLoad} fileName
	ExtractRowDataInto1DWaves(tempLoadRowDataMatrix0, baseName)
	Variable numRows = DimSize(tempLoadRowDataMatrix0, 0)
	KillWaves tempLoadRowDataMatrix0
	if ((makeTable==1) %& (numRows>0))
		Variable row = 0
		String name
		Edit
		do
			name = baseName + num2istr(row)
			AppendToTable $name
			row += 1
		while (row <= numRows-1)
	endif
End

Macro LoadRowDataInto1DWaves(pathName, fileName, linesToSkip, columnsToSkip, baseName, makeTable)
	String pathName = "_none_"
	Prompt pathName "Path", popup "_none_;" + PathList("*",";","")
	String fileName = ""
	Prompt fileName "File (\"\" for dialog)"
	Variable linesToSkip = 0
	Prompt linesToSkip "Lines to skip at start of file"
	Variable columnsToSkip = 0
	Prompt columnsToSkip "Columns to skip"
	String baseName = "wave"
	Prompt baseName "Base name for output waves"
	Variable makeTable = 1
	Prompt makeTable "Make table", popup "Yes;No"
	
	PauseUpdate; Silent 1
	
	if (CmpStr(pathName, "_none_") == 0)
		pathName = ""					// Causes LoadWave to display dialog.
	endif
	FLoadRowDataInto1DWaves(pathName, fileName, linesToSkip, 0, columnsToSkip, 0, baseName, makeTable)
End
