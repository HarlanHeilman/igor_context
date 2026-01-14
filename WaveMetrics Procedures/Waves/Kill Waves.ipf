// WARNING: Routines in this file can kill wave files.
//	See the warnings below. Make sure you understand them before using these procedures.
//	NOTE: Some of these functions work on waves in the current data folder only.

#pragma rtGlobals=1
#pragma version=6.30	// Shipped with Igor 6.30

#include <Execute Cmd On List>	// revised

// KillMatchingWaves(matchStr, flags)
//	matchStr is "*" for all waves or "wave*" for all waves whose name starts with "wave".
//	flags is:
//		bit 0: set to kill wave files (KillWaves/F)
//		bit 2:	set to kill waves in all data folders.
//				To set bit 0, set flags=1
//				To set bit 2, set flags=4
//				To set bits 0 and 2, set flags=5
//		bit 3:	RESERVED (used to indicate recursion in progress)
//
//	WARNING: KillMatchingWaves can kill wave FILES, too. 
//		We strongly recommend that you copy waves rather than share them.
//		See "Sharing Versus Copying Igor Binary Files" and KillWaves/F for details.
//
//		Make sure you know what you are doing when you set bit 0 to 1.
//
//	NOTE: without bit 2 set, this function works on waves in only the current data folder.
//
Function KillMatchingWaves(matchStr, flags)
	String matchStr
	Variable flags
	
	Variable inAllDataFolders= flags & 4
	if( !inAllDataFolders )
		return KillMatchingWavesInDF(matchStr, flags)
	endif
	
	String saveDF= GetDataFolder(1)
	String startDF= saveDF

	Variable recursionInProgress= flags & 8
	if( !recursionInProgress )
		// start recursion at the top
		startDF= "root:"
		SetDataFolder startDF
		flags= flags | 8
	endif
	
	// kill matching waves in current data folder
	KillMatchingWavesInDF(matchStr, flags)
	
	// recurse into each data folder (if any)
	Variable index=0
	do
		String subDF= GetIndexedObjName("", 4, index)
		if (strlen(subDF) == 0)
			break
		endif
		SetDataFolder subDF
		KillMatchingWaves(matchStr, flags)	// recursion
		SetDataFolder startDF	
		index += 1
	while(1)	// exit via break	
	SetDataFolder saveDF
	return 0
End

// KillMatchingWavesInDF(matchStr, flags)
//	matchStr is "*" for all waves or "wave*" for all waves whose name starts with "wave".
//	flags is:
//		bit 0: set to kill wave files (KillWaves/F)
//		bit 2:	set to kill waves in all data folders.
//				To set bit 0, set flags=1
//				To set bit 2, set flags=4.
//				To set bits 0 and 2, set flags=5.
//
//	WARNING: KillMatchingWavesInDF can kill wave FILES, too. 
//		We strongly recommend that you copy waves rather than share them.
//		See "Sharing Versus Copying Igor Binary Files" and KillWaves/F for details.
//
//		Make sure you know what you are doing when you set bit 0 to 1.
//
//	NOTE: without bit 2 set, this function works on waves in only the current data folder.
Function KillMatchingWavesInDF(matchStr, flags)
	String matchStr
	Variable flags
	
	String cmdTemplate
	
	if (flags %& 1)
		cmdTemplate = "KillWaves/Z/F %s"
	else
		cmdTemplate = "KillWaves/Z %s"
	endif

	String list=WaveList(matchStr, ";", "")
	ExecuteCmdOnQuotedList(cmdTemplate, list)
	return ItemsInList(list)
End

// RemoveWavesFromGraph(graphName, matchStr)
//	This is a building-block for RemoveWavesFromWindow.
//	NOTE: This function NOW WORKS reliably if the graph contains waves from other than the current data folder.
//	NOTE: This function no longer brings the graph to the front.
Function RemoveWavesFromGraph(graphNameStr, matchStr)	
	String graphNameStr					// name of a graph
	String matchStr						// "*" to remove all waves

	if( strlen(graphNameStr) == 0 )
		graphNameStr= WinName(0,1,1)
	endif
	
	DoWindow $graphNameStr
	if (V_flag)
		String listOfTraces= TraceNameList(graphNameStr,";",1)	// ignore traces that belong to contour plots
		Variable i,n= ItemsInList(listOfTraces)
		for(i=n-1;i>=0;i-=1)	// work backwards so that removing wave#0 doesn't rename wave#1
			String traceNameStr= StringFromList(i,listOfTraces)
			Wave wy= TraceNameToWaveRef(graphNameStr, traceNameStr )
			// could change next line to
			// if( stringmatch(traceNameStr, matchStr) )
			// to allow removing multiple instances with matchStr= "*#*"
			if( stringmatch(NameOfWave(wy), matchStr) )
				RemoveFromGraph/W=$graphNameStr $traceNameStr
			endif
		endfor
	endif
End

// RemoveWavesFromTable(tableName, matchStr)
//	This is a building-block for RemoveWavesFromWindow.
//	NOTE: This function NOW WORKS reliably if the table contains waves from other than the current data folder.
//	NOTE: This function no longer brings the table to the front.
Function RemoveWavesFromTable(tableName, matchStr)
	String tableName						// name of a table
	String matchStr						// "*" to remove all waves
	
	if( strlen(tableName) == 0 )
		tableName= WinName(0,2,1)
	endif
	DoWindow $tableName
	if (V_flag)
		Variable i=0
		String listOfWavePaths=""
		String pathToWave
		do
			WAVE/Z w= WaveRefIndexed(tableName,i,3)
			if (!WaveExists(w))
				break										// all done
			endif
			String wn = NameOfWave(w)
			if( stringmatch(wn, matchStr) )
				pathToWave= GetWavesDataFolder(w,2)
				if( WhichListItem(pathToWave, listOfWavePaths) < 0 )	// avoid duplicates
					listOfWavePaths += pathToWave+";"
				endif
			endif
			i += 1
		while (1)
		i=0
		do
			pathToWave= StringFromList(i,listOfWavePaths)
			if( strlen(pathToWave) == 0 )
				break
			endif
			RemoveFromTable/W=$tableName $(pathToWave).l
			RemoveFromTable/W=$tableName $(pathToWave).i
			RemoveFromTable/W=$tableName $(pathToWave).d
			i += 1
		while (1)
	endif
End


// RemoveWavesFromWindow(windowName, matchStr)
//	Removes waves whose names match the matchStr parameter from the named graph or table window.
//	NOTE: This function removes waves from only the top-level window, not any subwindows.
//	NOTE: This function NOW WORKS reliably if the window contains waves from other than the current data folder.
//	NOTE: This function no longer brings the window to the front.
Function RemoveWavesFromWindow(windowName, matchStr)
	String windowName
	String matchStr						// "*" to remove all waves
	
	DoWindow $windowName
	if (V_flag)
		if (WinType(windowName) == 1)			// this is a graph?
			RemoveWavesFromGraph(windowName, matchStr)
		endif
		if (WinType(windowName) == 2)			// this is a table?
			RemoveWavesFromTable(windowName, matchStr)
		endif
	endif
End

// RemoveWavesFromWindows(winMatchStr, matchStr)
//	Removes matching waves from matching windows.
//	winMatchStr is "*" for all waves or "Graph*" for all waves whose name starts with "Graph".
//	matchStr is "*" for all waves or "wave*" for all waves whose name starts with "wave".
//	NOTE: This function removes waves from only the top-level windows, not any subwindows.
//	NOTE: This function NOW WORKS reliably if the windows contain waves from other than the current data folder.
//	NOTE: This function no longer brings the windows to the front.
Function RemoveWavesFromWindows(winMatchStr, waveMatchStr)
	String winMatchStr					// "*" for all windows					
	String waveMatchStr					// "*" to remove all waves
	
	String cmdTemplate
	sprintf cmdTemplate, "RemoveWavesFromWindow(\"%%s\", \"%s\")", waveMatchStr
	ExecuteCmdOnList(cmdTemplate, WinList(winMatchStr,";","WIN:3"))
End

// KillAllWaves(flags)
//	Optionally, removes all waves from all graphs and tables.
//	Then kills all waves that are not in use.
//	flags is:
//		bit 0:	set to kill wave files (KillWaves/F)
//		bit 1:	set to remove all waves from graphs and tables
//		bit 2:	set to kill waves in all data folders.
//				To set bit 0, set flags=1
//				To set bit 1, set flags=2
//				To set bit 2, set flags=4
//				To set bits 0, 1 and 2, set flags=7
//
//	WARNING: KillAllWaves can kill wave FILES, too. 
//		We strongly recommend that you copy waves rather than share them.
//		See "Sharing Versus Copying Igor Binary Files" and KillWaves/F for details.
//
//		Make sure you know what you are doing when you set bit 0 to 1.
//
//	NOTE: This function removes waves from only the top-level windows, not any subwindows.
//	NOTE: This function NOW WORKS reliably if the windows contain waves from other than the current data folder.
//	NOTE: This function no longer brings the windows to the front.
Function KillAllWaves(flags)
	Variable flags
	
	if (flags %& 2)
		RemoveWavesFromWindows("*", "*")
	endif
	KillMatchingWaves("*", flags)
End
