#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.01			// circa Igor 9.01
#pragma IgorVersion=9			// long names, multiple return syntax
#pragma moduleName=DeleteMarqueePoints // for access to static function from user code
#include <Remove Points>, version >= 9.01

// Delete Marquee Points.ipf
//
// Contains routines that delete data from a waveform or an XY pair of waves.
//
// To use:
//		1) Graph your data
//		2) Drag out a marquee around some of your data,
//		3) Choose the Delete Marquee menu item from the usual popup menu
//		   that appears when you click inside the marquee.
//		4) A dialog is then presented that allows you to delete data values inside or outside the marquee.
//		   Be careful to select the trace from which you wish to remove data.
//		5) See the Edit menu for Undo and Redo Delete Marquee Data menu items afterwards.
//
// Version 1.01, 5/17/94
//	Used Wave/D instead of Wave in several places.
//
// Version 1.10, 12/31/95. Update for Igor Pro 3.0.
//	Got rid of /D which is no longer needed.
//
// Igor Pro 5.0: Used GraphMarquee menu instead of GraphMarquee procedure subtype keyword.
//
// Igor Pro 9.01: Changes to work with DebugOnError set, better axis name detection,
//	works with waves not in the current data folder, added one-level undo and redo,
//	X wave no longer needs to be sorted.

#include <Axis Utilities>

Menu "GraphMarquee"
	"Delete Marquee Data from Wave",/Q, DoDeleteMarqueeData()
End

// FDeleteMarqueeData(graphName, traceName, deleteMode, checkMode)
//
//	Deletes points from the waves displayed as traceName in the named graph.
//	graphName can be "" for the top active graph.
//
//	In its simplest form, the technique is to create a marquee in the graph that
//	encloses the points you want to delete and then run the macro. It will delete
//	the marqueed points.
//
//	To try this, do the following:
//
//		Make test=gnoise(1); Display test; Modify mode=2, lsize=3
//
//		(Now marquee some points and select DeleteMarqueeData from the Macros menu.)
//
//	There are several other ways to use it. These ways differ in the criteria
//	used to select which points will be deleted:
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

Function FDeleteMarqueeData(graphName, traceName, deleteMode, checkMode)
	String graphName
	String traceName
	Variable deleteMode			// 1 = delete inside marquee, 2 = delete outside marquee
	Variable checkMode			// 1 = check X values, 2 = check Y values, 3 = check X and Y values

	Wave yWave = TraceNameToWaveRef(graphName, traceName)
	// find the wave against which yWave is plotted, if any
	WAVE/Z xWave = XWaveRefFromTrace(graphName, traceName)
	Variable isParametricPlot = WaveExists(xWave)
	String fromWho = NameOfWave(yWave)
	if( isParametricPlot )
		fromWho += " and "+NameOfWave(xWave)
	endif

	// make (reset) a one-level backup for Undo
	KillDeleteMarqueeBackups()
	Backup(yWave, xWave, 0)

	Variable minX, maxX
	
	// Get point range for deleting by x
	if (checkMode & 1)										// do we care about X values ?
		String xaxis = AxisForTrace(graphName,traceName,0,0)	// normally "bottom"
		GetMarquee $xaxis										// horizontal marquee location is in terms of the bottom/top axis
		minX= V_left
		maxX= V_right
		// for reversed scaling
		if( minX > maxX )
			Variable wasMinX = minX
			minX= maxX
			maxX= wasMinX
		endif
	endif
	
	Variable minY, maxY, val
	if (checkMode & 2)											// do we care about Y values ?
		String yaxis = AxisForTrace(graphName,traceName,0,1)	// normally "left"
		GetMarquee $yaxis										// vertical marquee location is in terms of the left/right axis
		minY = V_bottom
		maxY = V_top
		// for reversed axes or scaling
		if( minY > maxY )
			Variable wasMinY = minY
			minY= maxY
			maxY= wasMinY
		endif
	endif

	Variable numDeleted = DeletePointsXY(xWave, yWave, deleteMode, checkMode, minX, maxX, minY, maxY)
	if( numDeleted )
		Printf "%d points deleted from %s\r", numDeleted, fromWho
	endif
	
	Printf "Length of %s = %d\r", fromWho, numpnts(yWave)
	return 0
End


Proc DoDeleteMarqueeData()
	String win=WinName(0, 1, 1)	// top visible graph
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
	
	DeleteMarqueeData(win)
End

Function DeleteMarqueeData(String graphName)
	
	// path to of the wave containing the Y values
	String traces= TraceNameList(graphName, ";", 1)
	String firstTrace= StringFromList(0,traces)
	String theTrace = StrVarOrDefault("root:Packages:'Delete Marquee Points':gDeleteMarqueeTraceNameSave", firstTrace) // can be trace not in graph, but in another graph
	Prompt theTrace, "Select the trace showing data from which you want to delete", popup, traces	// this lists only waves in the named graph, though

	Variable deleteMode = NumVarOrDefault("root:Packages:'Delete Marquee Points':gDeleteMarqueeModeSave", 1)
	Prompt deleteMode, "Delete", popup, "Points Inside Marquee;Points Outside Marquee"
	
	Variable checkMode=NumVarOrDefault("root:Packages:'Delete Marquee Points':gDeleteMarqueeCheckModeSave", 3)
	Prompt checkMode, "Criteria for selecting points to delete", popup, "X Values;Y Values;X and Y Values"
	
	String helpStr = "Be careful to select the trace from which you wish to remove data."
	helpStr += " See the Edit menu for Undo and Redo Delete Marquee Data menu items."
	DoPrompt/HELP=(helpStr) "Delete Marquee Data", theTrace, deleteMode, checkMode
	if (V_flag != 0)
		return -1
	endif

	// Save input parameters for next time
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:'Delete Marquee Points'
	String/G root:Packages:'Delete Marquee Points':gDeleteMarqueeTraceNameSave = theTrace
	Variable/G root:Packages:'Delete Marquee Points':gDeleteMarqueeModeSave = deleteMode
	Variable/G root:Packages:'Delete Marquee Points':gDeleteMarqueeCheckModeSave = checkMode
	
	FDeleteMarqueeData(graphName, theTrace, deleteMode, checkMode)
End

// Matrix of Conditions for DeleteMarqueeData
//
//	Parametric (XY) data
//		Delete Inside Points
//			Check X Values
//			Check Y Values
//			Check X and Y Values
//		Delete Outside Points
//			Check X Values
//			Check Y Values
//			Check X and Y Values
//
//	Normal (Waveform) data
//		Delete Inside Points
//			Check X Values
//			Check Y Values
//			Check X and Y Values
//		Delete Outside Points
//			Check X Values
//			Check Y Values
//			Check X and Y Values


////////////// Undo/Redo Menu items

static StrConstant ksBackupYWaveName="YBackupWaveForUndo"
static StrConstant ksBackupXWaveName="XBackupWaveForUndo"

static StrConstant ksRedoYWaveName="YBackupWaveForRedo"
static StrConstant ksRedoXWaveName="XBackupWaveForRedo"

Menu "Edit", dynamic
	DeleteMarqueePoints#MenuItemForUndoRedo(0), /Q, DeleteMarqueePoints#UndoRedo(0)
	DeleteMarqueePoints#MenuItemForUndoRedo(1), /Q, DeleteMarqueePoints#UndoRedo(1)
End

static Function/S MenuItemForUndoRedo(Variable isRedo) 
	String menuItem = ""
	if( CanUndoRedo(isRedo) )
		[WAVE yWave, WAVE yBackup, WAVE xWave, WAVE xBackup, Variable isParametric] = GetUndoRedoWaves(isRedo)
		if( isRedo )
			menuItem = "Redo Delete Marquee Data to "+NameOfWave(yWave)
		else
			menuItem = "Undo Delete Marquee Data from "+NameOfWave(yWave)
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
	String command = SelectString(isReDo, "Undo:", "Redo:")
	Printf "%s Length of %s = %d\r", command, fromWho, numpnts(yWave)

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
	NewDataFolder/O root:Packages:'Delete Marquee Points'
	WAVE/Z yBackup = root:Packages:'Delete Marquee Points':$yBackupName
	if( WaveExists(yBackup) )
		String pathToYWave= note(yBackup)
		WAVE/Z yWave= $pathToYWave
	endif
	Variable isParametric = 0
	WAVE/Z xBackup = root:Packages:'Delete Marquee Points':$(xBackupName)
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
	NewDataFolder/O root:Packages:'Delete Marquee Points'
	Duplicate/O yWave, root:Packages:'Delete Marquee Points':$(yBackupName)
	WAVE yBackup = root:Packages:'Delete Marquee Points':$(yBackupName)
	Note/K yBackup, GetWavesDataFolder(yWave,2)	// remember what it is the backup of

	Variable isParametricPlot = WaveExists(xWave)
	if( isParametricPlot )
		Duplicate/O xWave, root:Packages:'Delete Marquee Points':$(xBackupName)
		WAVE xBackup = root:Packages:'Delete Marquee Points':$(xBackupName)
		Note/K xBackup, GetWavesDataFolder(xWave,2)	// remember what it is the backup of
	else
		WAVE/Z oldXBackup = root:Packages:'Delete Marquee Points':$(xBackupName)
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

Function KillDeleteMarqueeBackups()
	RemoveBackup(0)
	RemoveBackup(1)
End
