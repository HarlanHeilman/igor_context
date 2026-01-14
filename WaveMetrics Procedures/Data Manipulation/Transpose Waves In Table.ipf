#pragma rtGlobals=1		// Use modern global access method.

//	Transpose Waves In Table
//	
//	Makes new waves (in the current data folder) that are the transpose of the waves in the top Igor table.
//	
//	Adds a "Transpose Waves In Top Table" item to the Table menu.
//	
//	To use it:
//	
//	1) Select the table containing the data you need to transpose so that it is
//	the top window.
//	
//	2) Pull down the Table menu and select Transpose Waves in Top Table.
//	
//	This will result in a simple dialog with a box to set a base name for the new
//	waves (initially set to the name of the table window) and a menu allowing
//	you to have the new waves displayed in a new table window.
//	
//	3) When you have made your choices, click the Continue button.
//	
//	The result will be as many waves as rows in the original table. The columns
//	(waves) will have names like "Table0_0", "Table0_1", etc. With the new
//	waves displayed in a table, you can easily give the new waves better names
//	by cmd-clicking (Macintosh) or Ctrl-clicking (Windows) in the name cell at
//	the top of a table column and selecting Rename Wave from the resulting menu.
//	
//	There is a restriction on the original table of waves: the rows and columns
//	must all be the same length. If necessary, you could edit the original
//	waves to insert blank cells in short columns.
//	
//	6/25/2003, JP: Initial shipping revision of code originally written by JW.
//
//	HR, 040813, 5.03: This file was inadvertently removed from the 5.0 distribution.
//	It was added back in 5.03.
//
//	HR, 040813, 5.03: The name of the table was hardwired to "Table0". I fixed this.
//
//	JW 120723 Made it work for a table selection consisting of all numeric waves or all text waves

Menu "Table"
	"Transpose Waves in Top Table", WMTransposeTableMenu()
end

Function WMTransposeTableMenu()
	String baseName = CleanupName(WinName(0, 2), 0 )[0,26]		// get the name of the top table to use as  the base name for the new waves
	Variable MakeTable
	Prompt baseName, "Base name for new waves:"
	Prompt MakeTable, "Make a table of new waves?", popup, "Yes;No"
	DoPrompt "Transpose Waves in Top Table", baseName, MakeTable
	if (V_flag == 1)
		return -1
	endif
	String tableName= WinName(0,2)
	String  ListOfWaves = WMTransposeWavesInTable(tableName, baseName)
	if (MakeTable == 1)
		// don't exceed the command line limit of 400 chars or so.
		Variable i=0, names=0
		String cmd= "Edit ", name
		do
			name=StringFromList(i,ListOfWaves,",")
			if( strlen(name) == 0 )
				if( names > 0 )
					Execute cmd
				endif
				break
			endif
			if( names > 0 )
				cmd += ","
			endif
			cmd += name
			names += 1
			if( strlen(cmd) > 100 )
				Execute cmd
				cmd= "AppendToTable "
				names= 0
			endif
			i+=1
		while(1)
	endif
	return 0
end	

//	WMTransposeWavesInTable creates a set of waves from the waves displayed in the top table.
// 	Each wave contains the contents of one row in the table.
//	OutBase is a string to use in creating the output wave names; the names will be
//	OutBasen where n is a number from 1 to the number of rows in the table.
//	That is, if OutBase="Out", the waves will be called Out0, Out1, Out2, etc.
//
//	There must be at least 2 waves in the table, and all the waves in the table
//	must have the same number of points.
//
// Returns a *comma*-separated list of waves. Comma is used so that the list can be conveniently
// used to construct, for instance, an Edit command to be passed the Execute.

Function/S WMTransposeWavesInTable(TableName, OutBase)
	String TableName	// can be "" for top table
	String OutBase
	
	OutBase= OutBase[0,26]	// leave room for _ and 3 digits
	
	if( strlen(TableName) == 0 )
		TableName=WinName(0,2)	// ensure we get the top TABLE (if any)
	endif
	
	String ListofWaves=WMTransposeGetTableWaveList(TableName,1,";")
	Variable type = AllWavesTextOrNumeric(ListOfWaves)
	if (type == 0)
		DoAlert 0, "The selected waves are  not all text or all numeric."
		return ""
	endif
	
	String OutputWaveList = ""
		
	WAVE/Z w= $StringFromList(0,listofWaves)
	if( !WaveExists(w) )
		return ""
	endif
	
	String ThisWaveName = NameOfWave(w)
	Variable NumRows=numpnts(w)
	
	Variable i = 0
	do
		WAVE/Z w= $StringFromList(i,listofWaves)
		if( !WaveExists(w) )
			break
		endif
		if (numpnts(w) != NumRows)
			DoAlert 0, "Waves must all have same length"
			return ""
		endif
		i += 1
	while(1)
	
	Variable NumCols=i
	
	if (NumCols < 2)
		DoAlert 0,  "Must have at least two input waves"
		return ""
	endif

	i = 0
	do
		ThisWaveName = CleanupName(OutBase+"_"+num2istr(i),1)
		if (type == 1)
			Make/O/N=(NumCols)/D $ThisWaveName
		else
			Make/O/N=(NumCols)/T $ThisWaveName
		endif
		OutputWaveList += PossiblyQuoteName(ThisWaveName)+","
		i += 1
	while (i < NumRows)
	
	i = 0
	do
		if (type == 1)
			WAVE wIn= $StringFromList(i,listofWaves)
		else
			Wave/T wTIn = $StringFromList(i,listofWaves)
		endif
		
		Variable j = 0
		do
			ThisWaveName = CleanupName(OutBase+"_"+num2istr(j),1)
			if (type == 1)
				WAVE wOut = $ThisWaveName
				wOut[i] = wIn[j]
			else
				Wave/T wTOut = $ThisWaveName
				wTOut[i] = wTIn[j]
			endif
			j += 1
		while (j < NumRows)
	
		i += 1
	while (i< NumCols)
	
	// remove trailing comma, which would be bad for an Edit command
	OutputWaveList = OutputWaveList[0, strlen(OutputWaveList)-2]
	return OutputWaveList
End

Function/S WMTransposeGetTableWaveList(table,wantPaths,listSeparator)
	String table				// table window name. Note that "" will work for top window if the top window is a table.
	Variable wantPaths		// if true, use path to wave, no just the name of the wave
	String listSeparator		// normally ";" or ","
	
	Variable wtype= WinType(table)
	if( wtype != 2 )
		return ""	// not a table, or there isn't a window with that name. 
	endif
	
	Variable i=0
	String list="", path
	do
		// HR, 040813, 5.03: The name of the table was previously hardwired to "Table0".
		WAVE/Z w= WaveRefIndexed(table,i,1)	// just .d columns, ignore .i columns
		if( !WaveExists(w) )
			break
		endif
		if( wantPaths )
			path=GetWavesDataFolder(w,2)	// returns partial path including possibly quoted wave name
		else
			path= NameOfWave(w)
		endif
		list += path + listSeparator
		i += 1
	while(1)
	return list
End

// returns 0 if mixed text and numeric; 1 for all numeric, 2 for all text
Function AllWavesTextOrNumeric(wlist)
	String wlist
	
	Variable nwaves = itemsInList(wlist)
	Variable i
	
	Wave/Z onewave = $StringFromList(0, wlist)
	Variable allsame = WaveType(onewave, 1)
	if (allsame != 1 && allsame != 2)
		return 0
	endif
	for (i = 1; i < nwaves; i += 1)
		Wave/Z onewave = $StringFromList(i, wlist)
		Variable type = WaveType(onewave, 1)
		if (type != allsame)
			return 0
		endif
	endfor
	
	return allsame
end