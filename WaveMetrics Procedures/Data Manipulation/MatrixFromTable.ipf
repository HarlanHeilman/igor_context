#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma independentModule=MatrixFromTable

Menu "Table", dynamic, hideable
	TableMenuItemIfSelection("Matrix from Table Selection"), /Q, MatrixFromTable#MenuMatrixFromTableSelection(0)
	TableMenuItemIfSelection("Table Row to 1D Wave"), /Q, MatrixFromTable#MenuMatrixFromTableSelection(1)
End

Function/S TableMenuItemIfSelection(menuText)
	String menuText

	String itemText="\\M0:(:"+menuText
	String tableName= ActiveTableWindowOrSubWindow()
	if( strlen(tableName) )
		GetSelection table, $tableName, 2 // (2) S_Selection is list of column names.
		if( strlen(S_Selection) )
			itemText= menuText
		endif
	endif

	return itemText
End

#if IgorVersion() >= 9
Menu "TablePopup", dynamic
	TableMenuItemForPopup("Matrix from Table Selection"), /Q, MatrixFromTable#ContextualMatrixFromTableSelection(0)
	TableMenuItemForPopup("Table Row to 1D Wave"), /Q, MatrixFromTable#ContextualMatrixFromTableSelection(1)
End

Function/S TableMenuItemForPopup(menuText)
	String menuText

	String itemText=""
	String tableName= TableClicked()
	if( strlen(tableName) )
		GetSelection table, $tableName, 2 // (2) S_Selection is list of column names. Note that a table embedded in a layout doesn't show the selection.
		if( strlen(S_Selection) )
			itemText= menuText
		endif
	endif

	return itemText
End
#endif

Function/S TableClicked()
	String tableName
#if IgorVersion() >= 9
	GetLastUserMenuInfo // requires Igor 9
	tableName= S_tableName // clicked-on table
	// tableName can be stale if the last contextual menu was for a now-deceased window
	Variable type= WinType(tableName) // works with subwindow syntax and page layout page syntax
	if( type != 2 )
		tableName= ""
	endif
#else
	tableName= ActiveTableWindowOrSubWindow()
#endif
	return tableName
End

Function ContextualMatrixFromTableSelection(MakeRowWave)
	Variable MakeRowWave // 0 for matrix, 1 for 1D wave

	String TableName= TableClicked()
	return PromptMatrixFromTableSelection(TableName, MakeRowWave)
End

Function MenuMatrixFromTableSelection(MakeRowWave)
	Variable MakeRowWave // 0 for matrix, 1 for 1D wave

	String TableName= ActiveTableWindowOrSubWindow()
	return PromptMatrixFromTableSelection(TableName, MakeRowWave)
End

Function PromptMatrixFromTableSelection(TableName, MakeRowWave)
	String TableName
	Variable MakeRowWave // 0 for matrix, 1 for 1D wave

	if( strlen(TableName) )
		String MakeWhat = SelectString(MakeRowWave, "Matrix", "Wave")
		String FromWhat = SelectString(MakeRowWave, "from Table Selection", "from first Selected Row")
		String BaseName = SelectString(MakeRowWave, "M_TableSelection", "W_TableSelection")
		String NameForNewWave = UniqueName(BaseName, 1, 0)
		Prompt NameForNewWave, "Name for new "+MakeWhat+":"
		Variable NewTablePop=1 // "Yes"
		Prompt NewTablePop, "Show new "+MakeWhat+" in another table?", popup, "Yes;No;" // 1 is "yes"
		String text= MakeWhat+" "+FromWhat
		DoPrompt text, NameForNewWave, NewTablePop
		if (V_flag == 1)
			return -1
		endif
	
		Variable err = MatrixFromTableSelection(TableName, NameForNewWave, MakeRowWave)
		if( err == 0 && newTablePop == 1 )
			WAVE/Z w = $NameForNewWave
			if( WaveExists(w) )
				Edit w
				String hostWin= HostWinFromHostChildSpec(TableName)
				AutoPositionWindow/M=0/R=$hostWin $S_name
			endif
		endif
		return 0
	endif
	return -1
End

Function MatrixFromTableSelection(WindowName, NameForNewWave, MakeRowWave)
	String WindowName, NameForNewWave
	Variable MakeRowWave
	
	if (strlen(WindowName) == 0)
		WindowName = ActiveTableWindowOrSubWindow()
	endif
	
	if (strlen(WindowName) == 0)
		DoAlert 0, "There is no table to work on"
		return -1
	endif
	
	GetSelection table, $WindowName, 7
	if (V_flag == 0)
		DoAlert 0, "There is no selection in table "+WindowName
		return -2
	endif
	
#if 0	// Igor 9: allow 1-point waves.

	// If Matrix is selected, it will have 1 row and 1 column
	// If 1D wave is selected, it will have 1 row and 0 columns
	if (V_startCol == V_endCol)
		DoAlert 0, "Only one column selected"
		return -3
	endif
	
	if ((MakeRowWave == 0) && (V_startRow == V_endRow))
		DoAlert 0, "Only one row selected"
		return -4
	endif
#endif
	
	Variable numColsSelected = ItemsInList(S_selection)
	Variable numRowsSelected = V_endRow - V_startRow + 1
	Variable i, j
	Variable dotPos, tempPos
	Variable Row, Column, Layer, Chunk
	Variable EmptyDimNumber=0, numDims=1
	Variable tableColumn
	
	String theColumn
	
	if (MakeRowWave)
		Make/O/N=(numColsSelected) $NameForNewWave
	else
		Make/O/N=(numRowsSelected, numColsSelected) $NameForNewWave
	endif
	Wave w = $NameForNewWave
	Make/O/N=(numColsSelected) DeleteCols=0
	
	for (i = 0; i < numColsSelected; i += 1)
		theColumn = StringFromList(i, S_selection)
		// is it a data column?
		dotPos = FindLastDot(theColumn)
		if (CmpStr(theColumn[dotPos+1], "d") == 0)		// is it a data column? only work on data columns
			// is it part of matrix wave?
			if (CmpStr(theColumn[dotPos-1], "]") == 0)	// is it a multi-D wave?
				numDims = GetDimNumbers(theColumn, Row, Column, Layer, Chunk, EmptyDimNumber)
			else
				// reset for assignment from 1D wave
				Row=0; Column=0; Layer=0; Chunk=0; EmptyDimNumber=0; numDims=1;
			endif
			tableColumn = i+V_startCol
			Wave TableWave = WaveRefIndexed(WindowName, tableColumn, 3)
			if (MakeRowWave)
				if( V_startRow >= DimSize(TableWave,EmptyDimNumber) )
					DeleteCols[i] = 1
					continue
				endif
				switch (EmptyDimNumber)
					case 0:
						w[i] = TableWave[V_startRow][Column][Layer][Chunk]
						break
					case 1:
						w[i] = TableWave[Row][V_startRow][Layer][Chunk]
						break
					case 2:
						w[i] = TableWave[Row][Column][V_startRow][Chunk]
						break
					case 3:
						w[i] = TableWave[Row][Column][Layer][V_startRow]
						break
				endswitch
 			else
				switch (EmptyDimNumber)
					case 0:
						w[][i] = TableWave[V_startRow+p][Column][Layer][Chunk]
						break
					case 1:
						w[][i] = TableWave[Row][V_startRow+p][Layer][Chunk]
						break
					case 2:
						w[][i] = TableWave[Row][Column][V_startRow+p][Chunk]
						break
					case 3:
						w[][i] = TableWave[Row][Column][Layer][V_startRow+p]
						break
				endswitch
			endif
		else
			DeleteCols[i] = 1
		endif
	endfor
	
	i = 0
	Column = 0
	for (i = 0; i < numColsSelected; i += 1)
		if (DeleteCols[i] == 1)
			if (MakeRowWave)
				DeletePoints/M=0 Column, 1, w
			else
				DeletePoints/M=1 Column, 1, w
			endif
		else
			Column += 1
		endif
	endfor
	
	KillWaves/Z DeleteCols
	return 0 // success
end

Function/S ActiveTableWindowOrSubWindow()
	
	String tableName= WinName(0,2,1) // topmost visible table

	GetWindow/Z kwTopWin activeSW
	String subWin= S_Value
	Variable type= WinType(subWin)
	if( type == 2 ) // table
		tableName= subWin
	endif
	return tableName
End

Function/S HostWinFromHostChildSpec(spec)
	String spec // "Table0", "Panel0#Table0" or "Layout0[1]#Table0"
	String host= StringFromList(0,spec,"#") // "Table0", "Panel0" or "Layout0[1]"
	Variable pos= strsearch(host, "[", 0)
	if( pos >= 0 )
		host[pos,inf]=""
	endif
	return host
End

Function FindLastDot(inputString)
	String inputString
	
	Variable startPos = strlen(inputString)-1
	Variable  dotPos = strsearch(inputString, ".", startPos, 1) // search backwards
	
	return dotPos // -1 if not found
end

// This function assumes that at least one set of brackets are present in the column name
Function GetDimNumbers(TableColumn, Row, Column, Layer, Chunk, EmptyDimNumber)
	String TableColumn
	Variable &Row, &Column, &Layer, &Chunk, &EmptyDimNumber
	
	String temp
	Variable leftBracket, rightBracket
	
	Row = 0
	Column = 0
	Layer = 0
	Chunk = 0
	EmptyDimNumber = 0
	
	leftBracket = StrSearch(TableColumn, "[", 0)
	rightBracket = StrSearch(TableColumn, "]", 0)
	if ( (leftBracket > 0) && (rightBracket > leftBracket) )
		sscanf TableColumn[leftBracket, rightBracket], "[%d]", Row
		if (V_flag == 0)
			Row = 0
			EmptyDimNumber = 0
		endif
	else
		return 0
	endif
	leftBracket = StrSearch(TableColumn, "[", rightBracket)
	rightBracket = StrSearch(TableColumn, "]", leftBracket)
	if ( (leftBracket > 0) && (rightBracket > leftBracket) )
		sscanf TableColumn[leftBracket, rightBracket], "[%d]", Column
		if (V_flag == 0)
			Column = 0
			EmptyDimNumber = 1
		endif
	else
		return 1
	endif
	leftBracket = StrSearch(TableColumn, "[", rightBracket)
	rightBracket = StrSearch(TableColumn, "]", leftBracket)
	if ( (leftBracket > 0) && (rightBracket > leftBracket) )
		sscanf TableColumn[leftBracket, rightBracket], "[%d]", Layer
		if (V_flag == 0)
			Layer = 0
			EmptyDimNumber = 2
		endif
	else
		return 2
	endif
	leftBracket = StrSearch(TableColumn, "[", rightBracket)
	rightBracket = StrSearch(TableColumn, "]", leftBracket)
	if ( (leftBracket > 0) && (rightBracket > leftBracket) )
		sscanf TableColumn[leftBracket, rightBracket], "[%d]", Chunk
		if (V_flag == 0)
			Chunk = 0
			EmptyDimNumber = 3
		endif
	else
		return 3
	endif
	
	return 4
end

#if 0
Function testGetDimNumbers(TableColumn)
	String TableColumn
	
	Variable Row, Column, Layer, Chunk, numdims, EmptyDim
	numdims = GetDimNumbers(TableColumn, Row, Column, Layer, Chunk, EmptyDim)
	print Row, Column, Layer, Chunk, EmptyDim
	return numdims
end
#endif