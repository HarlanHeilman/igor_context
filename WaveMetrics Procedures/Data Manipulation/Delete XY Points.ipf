// Delete XY Points.ipf
//
// Creates a control panel that allows you to draw a polygon to identify points in an XY pair for deletion.
//
// This Delete XY Points.ipf procedure can select points to delete in a non-rectangular region. 
//
// See also the DeletePointsXY() function the in Remove Points.ipf procedure file,
// And the Delete Marquee Points procedure file.
// Both of those are deleting points in a rectangular region.
// #include <Delete Points>
// #include <Delete Marquee Points>

#pragma rtGlobals = 1
#pragma version=9.01	// shipped with Igor 9.01

static Function GetFrontGraph(graphName, displayErrorMessage)
	String &graphName							// Passed by reference
	Variable displayErrorMessage				// If true, displays error message if no graphs.

	graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		if (displayErrorMessage)
			DoAlert 0, "There are no graphs"
		endif
		return -1
	endif
	
	return 0
End

static Function FirstTraceNotXYPairMessage(graphName)
	String graphName

	String message
	sprintf message, "The frontmost graph (%s) does not contain an XY pair as the first trace.", graphName
	message += "\r\rPlease correct this before proceeding."
	Abort message
End

static Function FirstTraceXYPairNotSameLength(graphName,xw,yw)
	String graphName
	Wave xw, yw	// must not be null
	
	String message
	String xName= NameOfWave(xw)
	String yName= NameOfWave(yw)
	Variable xpoints= numpnts(xw)
	Variable ypoints= numpnts(yw)
	sprintf message, "In the frontmost graph (%s), the first trace's X wave (%s) and Y wave (%s) have different lengths (%d vs %d).", graphName, xName, yName, xpoints, ypoints
	message += "\r\rPlease correct this before proceeding."
	Abort message
End

// returns "" if failure, graphName if success
static Function/S CheckFrontGraph()
	String graphName

	if (GetFrontGraph(graphName,1))
		return ""
	endif
	
	Wave/Z yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave/Z xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave
	if (!WaveExists(xw) || !WaveExists(yw))
		FirstTraceNotXYPairMessage(graphName)
		return ""
	endif
	
	if( numpnts(xw) != numpnts(yw) )
		FirstTraceXYPairNotSameLength(graphName,xw,yw)
		return ""
	endif

	return graphName
End

Function SelectPointsInPolygon(name)
	String name
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave
	
	// Work in the data folder containing the Y wave
	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	GraphNormal
	
	Wave/Z tempDeleteXYPointsYWave	// This was created by the GraphWaveDraw operation.
	if (!WaveExists(tempDeleteXYPointsYWave) || numpnts(tempDeleteXYPointsYWave) < 3)
		DoAlert 0, "The polygon could not be found or had too few points"		

		KillWaves/Z tempDeleteXYPointsXWave, tempDeleteXYPointsYWave, W_inPoly

		Button DrawOrSelectButton, win=DeleteXYPointsPanel, title="Start Drawing", proc=StartDrawSelectionPolygon
		Button DeleteSelectedPoints, win=DeleteXYPointsPanel, disable=2
	
		// Restore current data folder
		SetDataFolder dfSave
		
		return -1
	endif	
	
	Duplicate/O yw, tempDeleteXYPointsSelectorWave
	
	DoWindow/F $graphName
	FindPointsInPoly xw, yw, tempDeleteXYPointsXWave, tempDeleteXYPointsYWave
	DoWindow/F DeleteXYPointsPanel
	
	Wave W_inPoly							// W_inPoly is created by FindPointsInPoly
	
	Wave selector = tempDeleteXYPointsSelectorWave
	selector = W_inPoly[p] ? selector[p] : NaN

	RemoveFromGraph/W=$graphName tempDeleteXYPointsYWave
	KillWaves/Z tempDeleteXYPointsXWave, tempDeleteXYPointsYWave, W_inPoly
	
	CheckDisplayed/W=$graphName tempDeleteXYPointsSelectorWave
	if (V_flag == 0)
		AppendToGraph tempDeleteXYPointsSelectorWave vs xw
		ModifyGraph mode=3
		ModifyGraph marker(tempDeleteXYPointsSelectorWave)=2
		ModifyGraph lSize(tempDeleteXYPointsSelectorWave)=2
		ModifyGraph rgb(tempDeleteXYPointsSelectorWave)=(0,0,54272)
	endif
	
	// Restore current data folder
	SetDataFolder dfSave

	Button DrawOrSelectButton, win=DeleteXYPointsPanel, title="Start Drawing", proc=StartDrawSelectionPolygon
	Button DeleteSelectedPoints, win=DeleteXYPointsPanel, disable=0
End

Function StartDrawSelectionPolygon(name)
	String name
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave

	// Work in the data folder containing the Y wave
	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	DoWindow/F $graphName
	GraphWaveDraw/O/F tempDeleteXYPointsYWave, tempDeleteXYPointsXWave
	
	// Restore current data folder
	SetDataFolder dfSave

	Button DrawOrSelectButton, win=DeleteXYPointsPanel, title="Select Points", proc=SelectPointsInPolygon
End

Function ClearSelectionProc(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave

	// Work in the data folder containing the Y wave
	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	if (WaveExists(tempDeleteXYPointsSelectorWave))
		RemoveFromGraph/Z/W=$graphName, tempDeleteXYPointsSelectorWave
		KillWaves/Z tempDeleteXYPointsSelectorWave
	endif
	
	// Delete polygon waves if they are there.
	if (WaveExists(tempDeleteXYPointsYWave))
		RemoveFromGraph/Z/W=$graphName, tempDeleteXYPointsXWave, tempDeleteXYPointsYWave
		KillWaves/Z tempDeleteXYPointsXWave, tempDeleteXYPointsYWave
	endif

	Button DrawOrSelectButton, win=DeleteXYPointsPanel, title="Start Drawing", proc=StartDrawSelectionPolygon
	Button DeleteSelectedPoints, win=DeleteXYPointsPanel, disable=2
	
	// Restore current data folder
	SetDataFolder dfSave
End

Function DeleteSelectedPoints(xw, yw, selector)
	Wave xw, yw				// XY pair
	Wave selector				// Contains 1 if corresponding point is selected for deletion
	
	Variable numPoints = numpnts(xw)		// Assumed same as yw and selector
	Variable numDeleted = 0
	Variable i
	
	for(i=0; i<numPoints; i+=1)
		if (selector[i] != 0)
			numDeleted += 1
		else
			xw[i-numDeleted] = xw[i]
			yw[i-numDeleted] = yw[i]
			selector[i-numDeleted] = 0
		endif
	endfor
	
	Redimension/N=(numPoints-numDeleted) xw, yw, selector
End

Function DeleteSelectedPointsProc(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave

	// Work in the data folder containing the Y wave
	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	Wave/Z selector = tempDeleteXYPointsSelectorWave				// Currently contains NaN forpoints not selected.
	
	if (WaveExists(selector))
		selector = NumType(selector)==2 ? 0:1		// Put 1 in points to be deleted.
		DeleteSelectedPoints(xw, yw, selector)
		selector = NaN
		RemoveFromGraph/W=$graphName, tempDeleteXYPointsSelectorWave
		KillWaves/Z selector
		Button DeleteSelectedPoints, win=DeleteXYPointsPanel, disable=2
	else
		DoAlert 0, "Selector wave is missing"
	endif
	
	// Restore current data folder
	SetDataFolder dfSave
End

Function DeleteXYPointsActivate()
	String xWave = "<First trace in top graph must be XY pair>"
	String yWave = xWave
	
	String graphName
	if (GetFrontGraph(graphName,0) == 0)
		Wave/Z yw = WaveRefIndexed(graphName, 0, 1)						// Get first Y wave
		if (WaveExists(yw))
			Wave/Z xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave
			if (WaveExists(xw))
				xWave = NameOfWave(xw)
				yWave = NameOfWave(yw)
			endif
		endif
	endif

	TitleBox xWaveReadout, title="X Wave: "+xWave
	TitleBox yWaveReadout,title="Y Wave: "+yWave
End

Function DeleteXYPointsPanelHook(infoStr)
	String infoStr

	String sourceTrace

	Variable statusCode = 0
	String event = StringByKey("EVENT", infoStr)
	strswitch(event)
		case "activate":
			DeleteXYPointsActivate()
			break
			
		case "kill":
			Execute/P "DELETEINCLUDE <Delete XY Points>"
			Execute/P "COMPILEPROCEDURES "
			break;
	endswitch

	return statusCode
End

Function DeletePointsInPolyCreateBackup(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave

	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	NewDataFolder/O/S DeleteXYPointsBackup
	
	Duplicate/O xw, $NameOfWave(xw)
	Duplicate/O yw, $NameOfWave(yw)
	
	// Restore current data folder
	SetDataFolder dfSave
End

Function DeletePointsInPolyRevert(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName= CheckFrontGraph()
	if( !strlen(graphName) )
		return -1
	endif
	
	Wave yw = WaveRefIndexed(graphName, 0, 1)					// Get first Y wave
	Wave xw = XWaveRefFromTrace(graphName, NameOfWave(yw))	// Get corresponding X wave
	
	String dfSave = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(yw, 1)
	
	if (!DataFolderExists("DeleteXYPointsBackup"))
		DoAlert 0, "No backup data exists"
	else
		SetDataFolder DeleteXYPointsBackup
		
		Wave/Z xBackup = $NameOfWave(xw)
		Wave/Z yBackup = $NameOfWave(yw)
		
		if (WaveExists(xBackup) && WaveExists(yBackup))
			ClearSelectionProc("")
			SetDataFolder GetWavesDataFolder(xw, 1)
			Duplicate/O xBackup, $NameOfWave(xw)
			SetDataFolder GetWavesDataFolder(yw, 1)
			Duplicate/O yBackup, $NameOfWave(yw)
		else
			DoAlert 0, "No backup data exists"
		endif
		
	endif
	
	// Restore current data folder
	SetDataFolder dfSave
End

Function DeleteXYPointsHelpProc(ctrlName) : ButtonControl
	String ctrlName
	
	ShowDeleteXYPointsHelp()
End

Window DeleteXYPointsPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(469,137,739,406) as "Delete XY Points"
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine 9,154,259,154
	SetDrawEnv linethick= 2
	DrawLine 9,39,259,39
	Button DrawOrSelectButton,pos={48,167},size={169,20},proc=StartDrawSelectionPolygon,title="Start Drawing"
	Button DeleteSelectedPoints,pos={33,237},size={200,20},disable=2,proc=DeleteSelectedPointsProc,title="Delete Selected Points"
	Button Help,pos={101,7},size={65,20},proc=DeleteXYPointsHelpProc,title="Help"
	Button ClearSelection,pos={33,203},size={200,20},proc=ClearSelectionProc,title="Clear Selection"
	Button CreateBackup,pos={48,91},size={170,20},proc=DeletePointsInPolyCreateBackup,title="Create Backup"
	Button CreateBackup,help={"Makes a copy of the target data."}
	Button RevertToBackup,pos={48,123},size={170,20},proc=DeletePointsInPolyRevert,title="Revert To Backup"
	Button RevertToBackup,help={"Restores the target data by reverting to the backup data."}
	TitleBox xWaveReadout,pos={107,48},size={53,12},title="X Wave: xp",frame=0
	TitleBox xWaveReadout,anchor= MC
	TitleBox yWaveReadout,pos={107,66},size={53,12},title="Y Wave: yp",frame=0
	TitleBox yWaveReadout,anchor= MC
	SetWindow kwTopWin,hook=DeleteXYPointsPanelHook
EndMacro

Function ShowDeleteXYPointsPanel()
	DoWindow/F DeleteXYPointsPanel
	if (V_Flag == 0)
		Execute "DeleteXYPointsPanel()"
	endif
End

Function ShowDeleteXYPointsHelp()
	String nb = "DeleteXYPointsHelp"
	
	DoWindow/F $nb
	if (V_flag != 0)
		return 0			// The help notebook already exists.
	endif
	
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(11,44,512,444) as "Delete XY Points Help"
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 2147483647}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=Topic, justification=0, margins={0,13,468}, spacing={6,6,0}, tabs={72}, rulerDefaults={"Geneva",12,5,(0,0,0)}
	Notebook $nb newRuler=TopicBody1a, justification=0, margins={13,13,468}, spacing={0,6,0}, tabs={27,72,216}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=TopicBody1, justification=0, margins={13,13,468}, spacing={0,0,0}, tabs={27,72,216}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=Steps, justification=0, margins={13,27,432}, spacing={3,0,0}, tabs={72,216}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Topic, fStyle=0, text="*\t", fStyle=-1, text="Delete XY Points\r"
	Notebook $nb ruler=TopicBody1a
	Notebook $nb text="This control panel allows you to select points by drawing a polygon and then to delete the selected poin"
	Notebook $nb text="ts. The control panel is created by the Delete XY Points.ipf procedure file.\r"
	Notebook $nb fStyle=1, text="IMPORTANT\r"
	Notebook $nb fStyle=-1, text="The panel works only on XY pairs, not on waveforms.\r"
	Notebook $nb ruler=TopicBody1
	Notebook $nb text="It works on the first trace in the frontmost graph, which must by an XY pair. It is recommended that you"
	Notebook $nb text=" create a graph containing just the XY pair you want to edit.\r"
	Notebook $nb text="\r"
	Notebook $nb ruler=TopicBody1a, text="Here is the procedure:\r"
	Notebook $nb ruler=Steps, text="1.\tActivate the graph containing the XY pair to be edited.\r"
	Notebook $nb text="2.\tActivate the Delete XY Points control panel.\r"
	Notebook $nb text="3.\tClick the Create Backup button. This creates a data folder containing backups of your X and Y waves. "
	Notebook $nb text="If you make a mistake in editing, you can click the Revert To Backup button.\r"
	Notebook $nb text="4.\tClick the Start Drawing button. This activates the graph again and puts it in polygon-drawing mode.\r"
	Notebook $nb text="5.\tIn the graph, use the mouse to draw a polygon around the points you want to delete.\r"
	Notebook $nb text="6.\tActivate the panel again.\r"
	Notebook $nb text="7.\tClick the Select Points button.\r"
	Notebook $nb text="8.\tClick the Delete Selected Points button.\r"
	Notebook $nb ruler=Normal, text="\r"
	Notebook $nb ruler=TopicBody1
	Notebook $nb text="The Create Backup button creates a data folder named DeleteXYPointsBackup. When you are finished "
	Notebook $nb text="editing, you may want to delete this folder manually using the Data Browser.\r"
End

