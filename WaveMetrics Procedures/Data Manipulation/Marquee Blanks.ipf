#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.011
#pragma moduleName=MarqueeBlanks

// Marquee Blanks.ipf
//
// Contains routines that set data in a graphed waveform or XY pair of waves to NaN over a selected x and/or y range.
//
// If you want to delete points, use Delete Marquee Points, instead:
//	#include <Delete Marquee Points>
//
// To use:
//		1) graph your data
//		2) Choose a trace from the Graph->Select Trace to Blank submenu
//		3) drag out a marquee around some of your data,
//		4) choose the Set <data> to Blank (NaN) item from the usual popup menu
//		   that appears when you click inside the marquee.
//		5) See the Edit menu for Undo and Redo Marquee Blanks menu items afterwards.
//
// version 9.011 - supports selecting one of the graph's traces for blanking, undo, and redo.
//					supports selecting values inside or outside of x and/or y range.

#include <Axis Utilities>

static StrConstant ksBackupYWaveName="YBackupWaveForUndo"
static StrConstant ksBackupXWaveName="XBackupWaveForUndo"

static StrConstant ksRedoYWaveName="YBackupWaveForRedo"
static StrConstant ksRedoXWaveName="XBackupWaveForRedo"


Menu "GraphMarquee", dynamic
	fDoBlankMarqueeMenuItem(),/Q, DoBlankMarqueeData()
End

Function/S fDoBlankMarqueeMenuItem()
	String graphName=WinName(0, -1)
	String trace= SelectedTrace(graphName)
	String menuItem = "\\M0Set "+trace+" to Blank (NaN)"
	return menuItem
End
	

Proc DoBlankMarqueeData()
	String win=WinName(0, -1)
	if (WinType(win) != 1)			// check that target window is a graph
		Abort "The target window must be a graph"
	endif
	
	GetMarquee/W=$win/Z				// check that a marquee is up
	if (V_Flag == 0)
		Abort "You must create a marquee before running this procedure"
	endif
	
	String traces= TraceNameList(win, ";", 1)
	Variable nTraces= ItemsInList(traces)
	if (nTraces < 1)
		Abort "The target graph must have at least one trace"
	endif
	BlankMarqueeData(win)
End

// DeleteMarqueeData(theYWave, deleteMode, checkMode)
//	This deletes points from the specified wave that is displayed against the
//	bottom/left axes of the active graph.
//
//	In its simplest form, the technique is to create a marquee in the graph that
//	encloses the points you want to delete and then run the macro. It will delete
//	the marqueed points.
//	To try this, do the following:
//		Make test=gnoise(1); Display test; Modify mode=2, lsize=3
//		(Now marquee some points and select DeleteMarqueeData from the Macros menu.)
//
//	There are several other ways to use it. These ways differ in the criteria
//	used to select which points will be deleted.
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
//	selecting points to delete.
//
//	If checkMode is 1, then only X values are tested.	(this will run quickly)
//	If checkMode is 2 then only Y values are tested.	(this can be very time consuming)
//	If checkMode is 3 then X and Y values are tested.	(this can be very time consuming)
//
//	deleteMode determines whether points inside the marquee or outside the marquee
//	will be deleted.
//	If deleteMode is 1 then inside points are deleted.
//	If deleteMode is 2 then outside points are deleted.
//
Function BlankMarqueeData(String graphName)
	
	// path to of the wave containing the Y values
	String traces= TraceNameList(graphName, ";", 1)
	String firstTrace= StringFromList(0,traces)
	String theTrace = StrVarOrDefault("root:Packages:MarqueeBlank:TraceNameSave", firstTrace) // can be trace not in graph, but in another graph
	Prompt theTrace, "Select the trace showing data from which you want to delete", popup, traces	// this lists only waves in the named graph, though

	Variable mode = NumVarOrDefault("root:Packages:MarqueeBlank:ModeSave", 1)
	Prompt mode, "Blank", popup, "Points Inside Marquee;Points Outside Marquee"
	
	Variable checkMode=NumVarOrDefault("root:Packages:MarqueeBlank:CheckModeSave", 3)
	Prompt checkMode, "Criteria for selecting points to blank", popup, "X Values;Y Values;X and Y Values"
	
	String helpStr = "Be careful to select the trace you wish to change."
	helpStr += " See the Edit menu for Undo and Redo Delete Marquee Data menu items."
	DoPrompt/HELP=(helpStr) "Blank Marquee Data", theTrace, mode, checkMode
	if (V_flag != 0)
		return -1
	endif

	// Save input parameters for next time
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MarqueeBlank
	String/G root:Packages:MarqueeBlank:TraceNameSave = theTrace
	Variable/G root:Packages:MarqueeBlank:ModeSave = mode
	Variable/G root:Packages:MarqueeBlank:CheckModeSave = checkMode
	
	FBlankMarqueeData(graphName, theTrace, mode, checkMode)
End

Function/S SelectedTrace(String win)
	String selectedTrace=""
	if( WinType(win) == 1 ) // graph
		String traces= TraceNameList(win, ";", 1)
		String firstTrace= StringFromList(0,traces)
		selectedTrace= StrVarOrDefault("root:Packages:MarqueeBlank:TraceNameSave",firstTrace) // could be trace in another graph
		Variable which = WhichListItem(selectedTrace, traces)
		if( which < 0 )
			selectedTrace= firstTrace
		endif
	endif
	return selectedTrace
End

//	FBlankMarqueeData assumes that the wave is sorted and increasing in the X direction.
//	If you are graphing an XY pair and if the X wave is not monotonically increasing,
//	use the Sort operation to sort it.
Function FBlankMarqueeData(graphName, traceName, mode, checkMode)
	String graphName
	String traceName
	Variable mode			// 1 = blank inside marquee, 2 = blank outside marquee
	Variable checkMode		// 1 = check X values, 2 = check Y values, 3 = check X and Y values
	
	WAVE yWave = TraceNameToWaveRef(graphName, traceName)
	// find the wave against which yWave is plotted, if any
	WAVE/Z xWave = XWaveRefFromTrace(graphName, traceName)
	Variable isParametric = WaveExists(xWave)	// y vs x
	
	// make (reset) a one-level backup for Undo
	KillMarqueeBlanksBackups()
	Backup(yWave, xWave, 0)

	String horizAxesList= HVAxisList(graphName,1)
	String hAxis = AxisForTrace(graphName,traceName,0,0) // normally "bottom"

	GetMarquee/W=$graphName $hAxis					// find horizontal marquee location is in terms of the bottom axis
	Variable minX= V_Left
	Variable maxX = V_right
	// for reversed axes or scaling (not strictly necessary)
	if( minX > maxX )
		Variable wasMinX = minX
		minX = maxX
		maxX = wasMinX
	endif
	
	Variable minPoint, maxPoint
	if (!isParametric)
		minPoint = x2pnt(yWave, V_left)
		maxPoint = x2pnt(yWave, V_right)
		// for reversed axes or scaling (not strictly necessary)
		if( minPoint > maxPoint )
			Variable wasMin = minPoint
			minPoint= maxPoint
			maxPoint= wasMin
		endif
	endif

	Variable checkX = checkMode %& 0x1
	Variable checkY = checkMode %& 0x2
	Variable checkBoth = checkx && checkY

	Variable minY, maxY
	if (checkY)				// do we care about Y values ?
		String yaxis = AxisForTrace(graphName,traceName,0,1) // normally "left"
		GetMarquee $yaxis			// find vertical marquee location is in terms of the left/right axis
		minY = V_bottom
		maxY = V_top
		// for reversed axes or scaling (not strictly necessary)
		if( minY > maxY )
			Variable wasMinY = minY
			minY = maxY
			maxX = wasMinY
		endif
	endif

	Variable inside = mode == 1
	Variable lastAtStart= minPoint-1
	Variable firstAtEnd = maxPoint+1
	Variable lastPoint = numpnts(xWave)-1
	
	// Note that we are not modifying xWave, only yWave
	if( !checkX ) // just check y
		if( inside )
			yWave = (yWave[p] >= minY) && (yWave[p] <= maxY) ? NaN : yWave[p]
		else
			yWave = (yWave[p] < minY) || (yWave[p] > maxY) ? NaN : yWave[p]
		endif
	else
		if( isParametric )
			if( checkBoth)	// check x and y
				if( inside )
					yWave = ((yWave[p] >= minY) && (yWave[p] <= maxY) && (xWave[p] >= minX) && (xWave[p] <= maxX)) ? NaN : yWave[p]
				else // outside marquee
					yWave = (yWave[p] < minY) || (yWave[p] > maxY) || (xWave[p] < minX) || (xWave[p] > maxX) ? NaN : yWave[p]
				endif
			elseif( checkX )	// just checkX
				if( inside )
					yWave = (xWave[p] >= minX) && (xWave[p] <= maxX) ? NaN : yWave[p]
				else // outside marquee
					yWave = (xWave[p] < minX) || (xWave[p] > maxX) ? NaN : yWave[p]
				endif
			endif
		else // waveform	
			if( checkBoth)	// check x and y
				if( inside )
					yWave[minPoint,maxPoint] = (yWave[p] >= minY) && (yWave[p] <= maxY) ? NaN : yWave[p]
				else // outside marquee
					if( lastAtStart >= 0 )
						yWave[0,lastAtStart] = (yWave[p] < minY) || (yWave[p] > maxY) ? NaN : yWave[p]	// blank before marquee x
					endif
					if( firstAtEnd <= lastPoint )
						yWave[firstAtEnd,] = (yWave[p] < minY) || (yWave[p] > maxY) ? NaN : yWave[p]	// blank after marquee x
					endif
				endif
			elseif( checkX )	// just checkX
				if( inside )
					yWave[minPoint,maxPoint] = NaN
				else // outside marquee
					if( lastAtStart >= 0 )
						yWave[0,lastAtStart] = NaN	// blank before marquee x
					endif
					if( firstAtEnd <= lastPoint )
						yWave[firstAtEnd,] = NaN	// blank after marquee x
					endif
				endif
			endif
		endif
	endif

	return 0
End

////////////// Undo/Redo Menu items

Menu "Edit", dynamic
	MarqueeBlanks#MenuItemForUndoRedo(0), /Q, MarqueeBlanks#UndoRedo(0)
	MarqueeBlanks#MenuItemForUndoRedo(1), /Q, MarqueeBlanks#UndoRedo(1)
End

static Function/S MenuItemForUndoRedo(Variable isRedo) 
	String menuItem = ""
	if( CanUndoRedo(isRedo) )
		[WAVE yWave, WAVE yBackup, WAVE xWave, WAVE xBackup, Variable isParametric] = GetUndoRedoWaves(isRedo)
		if( isRedo )
			menuItem = "Redo Marquee Blanks to "+NameOfWave(yWave)
		else
			menuItem = "Undo Marquee Blanks in "+NameOfWave(yWave)
		endif
	endif
	return menuItem
End

static Function CanUndoRedo(Variable isRedo)

	[WAVE yWave, WAVE yBackup, WAVE xWave, WAVE xBackup, Variable isParametric] = GetUndoRedoWaves(isRedo)

	// both the backup wave and the backed-up wave(s) must exist

	if( !WaveExists(yBackup) || !WaveExists(yWave) )
		return 0
	endif
	
	if( isParametric )
		if( !WaveExists(xBackup) || !WaveExists(xWave) )
			return 0
		endif
	endif
	
	return 1
End

////////////// Undo/Redo Backups

static Function UndoRedo(Variable isRedo)

	[WAVE yWave, WAVE yBackup, WAVE xWave, WAVE xBackup, Variable isParametric] = GetUndoRedoWaves(isRedo)

	Backup(yWave, xWave, !isRedo)

	// overwrite the wave with the backup
	if( WaveExists(yBackup) && WaveExists(yWave) )
		Duplicate/O yBackup, yWave 
	endif
	
	if( isParametric )
		if( WaveExists(xBackup) && WaveExists(xWave) )
			Duplicate/O xBackup, xWave 
		endif
	endif

	String fromWho = NameOfWave(yWave)
	if( isParametric )
		fromWho += " and "+NameOfWave(xWave)
	endif
	String command = SelectString(isReDo, "Undo", "Redo")
	Printf "%s  setting blanks in %s\r", command, fromWho

	RemoveBackup(isRedo)
End

static Function [WAVE/Z yWaveOut, WAVE/Z yBackupOut, WAVE/Z xWaveOut, WAVE/Z xBackupOut, Variable isParametricOut] GetUndoRedoWaves(Variable isReDo)

	String yBackupName= ksBackupYWaveName
	String xBackupName= ksBackupXWaveName
	if( isRedo )
		yBackupName= ksRedoYWaveName
		xBackupName= ksRedoXWaveName
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MarqueeBlank


	WAVE/Z yBackup = root:Packages:MarqueeBlank:$yBackupName
	if( WaveExists(yBackup) )
		String pathToYWave= note(yBackup)
		WAVE/Z yWave= $pathToYWave
	endif
	Variable isParametric = 0
	WAVE/Z xBackup = root:Packages:MarqueeBlank:$(xBackupName)
	if( WaveExists(xBackup) ) // beware: it may be a neutered x backup, in which case the data was not parametric (not y vs x)
		String pathToXWave= note(xBackup)
		isParametric = strlen(pathToXWave) > 0
		WAVE/Z xWave= $pathToXWave
	endif
	return [yWave, yBackup, xWave, xBackup, isParametric]
End

static Function Backup(WAVE yWave, WAVE/Z xWave, Variable isReDo )

	// make a one-level backup for Undo (or Redo)
	String yBackupName= ksBackupYWaveName
	String xBackupName= ksBackupXWaveName
	if( isRedo )
		yBackupName= ksRedoYWaveName
		xBackupName= ksRedoXWaveName
	endif
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MarqueeBlank
	Duplicate/O yWave, root:Packages:MarqueeBlank:$(yBackupName)
	WAVE yBackup = root:Packages:MarqueeBlank:$(yBackupName)
	Note/K yBackup, GetWavesDataFolder(yWave,2)	// remember what it is the backup of

	Variable isParametricPlot = WaveExists(xWave)
	if( isParametricPlot )
		Duplicate/O xWave, root:Packages:MarqueeBlank:$(xBackupName)
		WAVE xBackup = root:Packages:MarqueeBlank:$(xBackupName)
		Note/K xBackup, GetWavesDataFolder(xWave,2)	// remember what it is the backup of
	else
		WAVE/Z oldXBackup = root:Packages:MarqueeBlank:$(xBackupName)
		if( WaveExists(oldXBackup) )
			Note/K oldXBackup		// if we can't kill the backup (it may have been put into a table or graph), we can at least neuter it.
			KillWaves/Z oldXBackup 	// may fail
		endif
	endif
End

static Function RemoveBackup(Variable isRedo)

	[WAVE yWave, WAVE yBackup, WAVE xWave, WAVE xBackup, Variable isParametric] = GetUndoRedoWaves(isRedo)
	if( WaveExists(yBackup) )
		Note/K yBackup		// if we can't kill the backup (it may have been put into a table or graph), we can at least neuter it.
		KillWaves/Z yBackup // may fail
	endif
	if( WaveExists(xBackup) )
		Note/K xBackup
		KillWaves/Z xBackup
	endif
End

Function KillMarqueeBlanksBackups()
	RemoveBackup(0)
	RemoveBackup(1)
End
