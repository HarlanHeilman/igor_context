// Version 1.01, 5/17/94
//	Used Wave/D instead of Wave in several places.
// Version 1.02, 7/7/94
//	Changed DisEstablishSplineDependency so that it correctly breaks the dependency.
// Version 1.10, 12/31/95
//	Updated for Igor Pro 3.0.
//	However, these procedures will work only if the source waves are in the current data folder.
// Version 1.11 2/13/02 JW
// Updated to use ControlBarManagerProcs

// Drag Spline
//	These procedures are designed to help you put a smooth curve through
//	a noisy data set with a large number of points.
//	To use them:
//		Choose Add Spline Controls from the Macros menu. This will add some controls to the top graph.
//		Choose a data set from the Input Data popup menu.
//		Click the Start Spline Drag button.
//		Drag the spline nodes (black dots) around.
//		Click Stop Spline Drag when you are done.
//	 See the example experiment "Drag Spline Demo" in the "Examples" folder for further details.

#pragma rtGlobals = 1

#pragma Version = 1.11

#include <Wave Lists>, menus=0
#include <Decimation>, menus=0
#include <ControlBarManagerProcs>

Menu "Macros"
	"Add Spline Controls"
	help = {"Adds some controls to the active graph. The controls make it easy to interactively put a smooth spline through a fairly large set of noisy data."}
End

// CheckDragSplineGlobals()
//	Creates global settings used by other routines if they do not already exist.
//	In most cases you will not need to tweak these globals.
Function CheckDragSplineGlobals()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:'Drag Spline'
	if (exists("root:Packages:'Drag Spline':gNumNodes") == 0)
		Variable/G root:Packages:'Drag Spline':gNumNodes=20					// number of nodes through which spline is to be drawn
		Variable/G root:Packages:'Drag Spline':gNumOutputPoints=200		// length of spline waves
		Variable/G root:Packages:'Drag Spline':gControlYDelta = 0				// JW 020213 support for ControlBarManagerProcs
		String/G root:Packages:'Drag Spline':CBIdentifier = ""						// JW 020213 identifier returned by ControlBarManagerProcs
	endif
End

// SetSplineDragWaves(xDataWave, yDataWave)
//	Sets the "Input Data" popup menu.
//	The menu may contain one or two items.
//	The first item is always "Choose Input Data".
//	If the user has never chosen input data then there will be no second item.
//	Otherwise, the second item will be something like:
//		"data"					if the input data is waveform data
//	or
//		"yData vs xData"		if the input data is XY data
//	All other routines determine the input data by interrogating this popup menu
//	which acts as graph-local storage for the drag spline routines.
Function SetSplineDragWaves(xDataWave, yDataWave)
	String xDataWave
	String yDataWave
	
	String s
	Variable selectedItem
	
	// Make sure that the names of the node and spline waves won't be too long
	if ((strlen(xDataWave) > 27) %| (strlen(yDataWave) > 27))
		Abort "Sorry, the input data wave names must not exceed 27 characters in length"
	endif
	
	s = "Choose Input Data...;"
	if (strlen(yDataWave) == 0)					// if yDataWave == "" then we are clearing data waves
		selectedItem = 1
	else
		selectedItem = 2
		if (strlen(xDataWave) > 0)					// XY data ?
			s += yDataWave + " vs " + xDataWave
		else											// waveform data
			s += yDataWave
		endif
	endif
	String cmd
	sprintf cmd, "PopupMenu DragSpline_DataWaves, mode=%d, value=%s", selectedItem, "\"" + s + "\""
	Execute cmd
End

// SplineDragIsXYData()
//	Returns true if the chosen input data is XY data, false if it is waveform data.
Function SplineDragIsXYData()
	String popupText
	
	ControlInfo DragSpline_DataWaves		// Sets S_value string
	popupText = S_value						// e.g. "yWave vs xWave"
	return strsearch(popupText, " vs ", 0) > 0
End

// SplineDragDataWave(xy)
//	Returns the name of the x or y input data wave.
//	If the input data is waveform rather than XY data, it returns "" for x wave name.
//	This works by interrogating the input data popup menu.
Function/S SplineDragDataWave(xy)
	Variable xy								// 1 for x, 2 for y
	
	String popupText
	String xw, yw
	
	ControlInfo DragSpline_DataWaves		// Sets S_value string
	popupText = S_value						// e.g. "yWave vs xWave"
	
	if (SplineDragIsXYData())				// for XY data popup contains "yData vs xData"
		if (xy == 1)
			return popupText[strsearch(popupText," vs",0)+4, strlen(popupText)]
		else
			return popupText[0, strsearch(popupText," vs",0)-1]
		endif
	else										// for waveform data popup contains "data"
		if (xy == 1)
			return ""							// signifies no x wave
		else
			return popupText
		endif
	endif
End

Function/S SplineDragXDataWave()			// returns x data wave name or "" for waveform data
	return SplineDragDataWave(1)
End

Function/S SplineDragYDataWave()			// returns y data wave
	return SplineDragDataWave(2)
End

Function/S NodeWaveSuffix()
	return "_N"
End

Function/S SplineWaveSuffix()
	return "_CS"
End

//  SplineDragPrefix(xy)
//	Prefixes are used for waveform data only.
//	If the input data wave name is "data" then the node and spline wave names will be:
//		xdata_N, ydata_N, xdata_CS and ydata_CS
Function/S SplineDragPrefix(xy)
	Variable xy								// 1 for x, 2 for y

	if (xy == 1)
		return "x"
	else
		return "y"
	endif
End	

// SplineDragNodeWave(xy)
//	If the input data is "yData vs xData" (XY data) then the node names will be:
//		xData_N, yData_N
//	If the input data is "data" (waveform data) then the node names will be:
//		xdata_N, ydata_N
Function/S SplineDragNodeWave(xy)	
	Variable xy								// 1 for x, 2 for y
	
	String s
	
	if (SplineDragIsXYData())
		s = SplineDragDataWave(xy)
	else
		s = SplineDragPrefix(xy) + SplineDragYDataWave()
	endif
	
	return s + NodeWaveSuffix()
End

// SplineDragSplineWave(xy)
//	If the input data is "yData vs xData" (XY data) then the spline names will be:
//		xData_CS, yData_CS
//	If the input data is "data" (waveform data) then the spline names will be:
//		xdata_CS, ydata_CS
Function/S SplineDragSplineWave(xy)
	Variable xy								// 1 for x, 2 for y
	
	String s
	
	if (SplineDragIsXYData())
		s = SplineDragDataWave(xy)
	else
		s = SplineDragPrefix(xy) + SplineDragYDataWave()
	endif
	
	return s + SplineWaveSuffix()
End

Function RecalcSpline(p, xNodeWave, yNodeWave, xSplineWave, ySplineWave, preaverageNodes)
	Variable p						// point number
	Wave xNodeWave				// x wave through which spline is to be drawn
	Wave yNodeWave				// y wave through which spline is to be drawn
	Wave xSplineWave			// x output wave
	Wave ySplineWave			// y output wave
	Variable preaverageNodes		// preaveraging -- normally zero for no preaveraging
	
	String cmd
	Variable numOutPoints
	
	if (p == 0)
		String xSW = PossiblyQuoteName(NameOfWave(xSplineWave))
		String ySW = PossiblyQuoteName(NameOfWave(ySplineWave))
		String xNW = PossiblyQuoteName(NameOfWave(xNodeWave))
		String yNW = PossiblyQuoteName(NameOfWave(yNodeWave))
		numOutPoints = numpnts(ySplineWave)
		sprintf cmd, "Interpolate/N=(%d)/A=(%d)/Y=%s/X=%s %s /X=%s", numOutPoints, preaverageNodes, ySW, xSW, yNW, xNW
		Execute cmd
	endif
	
	return ySplineWave[p]
End

Function EstablishSplineDependency(xNodeWave, yNodeWave, xSplineWave, ySplineWave)
	String xNodeWave, yNodeWave, xSplineWave, ySplineWave

	String formula
	
	// This establishes the dependency that causes the spline wave to be updated
	// when you drag the node wave
	String xSW = PossiblyQuoteName(xSplineWave)
	String ySW = PossiblyQuoteName(ySplineWave)
	String xNW = PossiblyQuoteName(xNodeWave)
	String yNW = PossiblyQuoteName(yNodeWave)
	sprintf formula, "RecalcSpline(p, %s, %s, %s, %s, 0)", xNW, yNW, xSW, ySW
	SetFormula $ySplineWave, formula
End

Function DisEstablishSplineDependency(ySplineWave)
	String ySplineWave

	SetFormula $ySplineWave, ""
End

Function MakeNodeAndSplineWaves()
	CheckDragSplineGlobals()

	String xDataWave, yDataWave
	
	xDataWave = SplineDragXDataWave()			// x data wave name or "" for waveform data()
	yDataWave = SplineDragYDataWave()
	
	NVAR numOutputPoints = root:Packages:'Drag Spline':gNumOutputPoints		// typically 200
	NVAR numNodes=root:Packages:'Drag Spline':gNumNodes						// typically 20
	Variable decimationFactor = numpnts($yDataWave)/numNodes
	
	String xNodeWave					// x wave through which spline is to be drawn
	String yNodeWave					// y wave through which spline is to be drawn
	String xSplineWave				// x output wave
	String ySplineWave				// y output wave

	// Create x node wave by decimating input data
	xNodeWave = SplineDragNodeWave(1)
	if (strlen(xDataWave) > 0)		// XY data ?
		FDecimate($xDataWave, xNodeWave, decimationFactor)
	else
		Duplicate/O $yDataWave, tempXDataWave9999 
		tempXDataWave9999 = x
		FDecimate(tempXDataWave9999, xNodeWave, decimationFactor)
		KillWaves/Z tempXDataWave9999
	endif

	// Create y node wave by decimating input data
	yNodeWave = SplineDragNodeWave(2)
	FDecimate($yDataWave, yNodeWave, decimationFactor)

	// Create output spline waves
	xSplineWave = SplineDragSplineWave(1)
	ySplineWave = SplineDragSplineWave(2)
	Make/O/N=(numOutputPoints) $xSplineWave, $ySplineWave
	Wave xW = $xSplineWave
	xW = NaN
	Wave yW = $ySplineWave
	yW = NaN
	RecalcSpline(0, $xNodeWave, $yNodeWave, $xSplineWave, $ySplineWave, 0)
End

Function AppendNodeAndSplineWaves()
	String xNodeWave, yNodeWave
	String xSplineWave, ySplineWave
	
	xNodeWave = SplineDragNodeWave(1)
	yNodeWave = SplineDragNodeWave(2)
	CheckDisplayed $yNodeWave
	if (V_flag == 0)
		AppendToGraph $yNodeWave vs $xNodeWave
		ModifyGraph rgb($yNodeWave)=(0, 0, 0), mode($yNodeWave)=3, marker($yNodeWave)=19, msize($yNodeWave)=3
	endif
	
	xSplineWave = SplineDragSplineWave(1)
	ySplineWave = SplineDragSplineWave(2)
	CheckDisplayed $ySplineWave
	if (V_flag == 0)
		AppendToGraph $ySplineWave vs $xSplineWave
		ModifyGraph rgb($ySplineWave)=(0, 0, 65535), lsize($ySplineWave)=2
	endif
End

Function RemoveAndKillNodeSplineWaves()
	String xNodeWave				// x wave through which spline is to be drawn
	String yNodeWave				// y wave through which spline is to be drawn

	xNodeWave = SplineDragNodeWave(1)
	yNodeWave = SplineDragNodeWave(2)
	CheckDisplayed $yNodeWave
	if (V_flag != 0)
		RemoveFromGraph $yNodeWave
	endif
	KillWaves/Z $xNodeWave, $yNodeWave
End

Proc ChooseSplineWavesDialog(yDataWave)
	String yDataWave = SplineDragYDataWave()
	Prompt yDataWave, "Y Data Wave", popup GraphWaveList("", "*", 0, 1, ";")
	
	String xDataWave
	xDataWave = XWaveName("", yDataWave)		// will be wave name for XY data or "" for waveform data
	SetSplineDragWaves(xDataWave, yDataWave)
End

Function ChooseSplineWaves(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (popNum == 1)									// The popup has two items. The first is Choose...
		Execute("ChooseSplineWavesDialog()")		// and the second identifies the actual waves chosen
		MakeNodeAndSplineWaves()
		AppendNodeAndSplineWaves()
	endif
End

static constant ControlBarDelta = 60

Function AddSplineControls()
	CheckDragSplineGlobals()
	
	if (Wintype("") != 1)
		Abort "Activate a graph before showing the spline controls"
	endif
	
	ControlInfo DragSpline_DataWaves		// don't add the controls twice
	if (V_value == 3)							// this should be a popup menu
		Abort "The controls are already in the active graph"
	endif
	
	NVAR top = root:Packages:'Drag Spline':gControlYDelta 
	SVAR CBIdentifier = root:Packages:'Drag Spline':CBIdentifier
	String CBIdent
		
	ShowTools
//	ControlBar 60
	top = ExtendControlBar(WinName(0,1), ControlBarDelta, CBIdent)	// CBIdent must be a local variable, because it is a pass-by-reference parameter
	CBIdentifier = CBIdent
	Button StartStopSplineDrag,pos={27,top+30},size={140,20},proc=StartSplineDrag,title="Start Spline Drag"
	PopupMenu DragSpline_DataWaves,pos={24,top+5},size={211,19},proc=ChooseSplineWaves,title="Input Data:"
	PopupMenu DragSpline_DataWaves,mode=1,value= #"\"Choose Input Data...\""
	Button RemoveSplineControls,pos={249,top+30},size={65,20},proc=RemoveSplineControls,title="All Done"
End

Function RemoveSplineControls(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo PauseResumeSplineDrag		// button will exist if dragging was started
	if (V_flag != 0)
		StopSplineDrag(ctrlName)
	endif
	
	// Node waves will be in graph if the user chose the input data but never started the spline drag.
	RemoveAndKillNodeSplineWaves()
	
	KillControl RemoveSplineControls
	KillControl StartStopSplineDrag
	KillControl DragSpline_DataWaves
	SVAR CBIdentifier = root:Packages:'Drag Spline':CBIdentifier
	ContractControlBar(WinName(0,1), CBIdentifier, ControlBarDelta)
//	ControlBar 0
	HideTools
End

Function PauseSplineDrag(ctrlName) : ButtonControl
	String ctrlName

	GraphNormal
	Button PauseResumeSplineDrag, title="Resume", proc=ResumeSplineDrag
End

Function ResumeSplineDrag(ctrlName) : ButtonControl
	String ctrlName
	
	String yNodeWave = SplineDragNodeWave(2)

	Button PauseResumeSplineDrag, title="Pause", proc=PauseSplineDrag
	GraphWaveEdit $yNodeWave
End

Function StartSplineDrag(ctrlName) : ButtonControl
	String ctrlName
	
	String xNodeWave, yNodeWave, xSplineWave, ySplineWave
	Variable yNodeWaveMissing, ySplineWaveMissing
	NVAR top = root:Packages:'Drag Spline':gControlYDelta 

	xNodeWave = SplineDragNodeWave(1)
	yNodeWave = SplineDragNodeWave(2)
	xSplineWave = SplineDragSplineWave(1)
	ySplineWave = SplineDragSplineWave(2)
	
	if (exists(ySplineWave) != 1)
		Abort "You need to choose input data. Use the Input Data popup menu."
	endif
	
	CheckDisplayed $yNodeWave; yNodeWaveMissing = V_flag==0
	CheckDisplayed $ySplineWave; ySplineWaveMissing = V_flag==0
	if (yNodeWaveMissing %| ySplineWaveMissing)
		MakeNodeAndSplineWaves()
		AppendNodeAndSplineWaves()
	endif
	
	EstablishSplineDependency(xNodeWave, yNodeWave, xSplineWave, ySplineWave)
	Button startStopSplineDrag, title="Stop Spline Drag", proc=StopSplineDrag
	Button PauseResumeSplineDrag,pos={175,top+30},size={65,20},proc=PauseSplineDrag,title="Pause"
	GraphWaveEdit $yNodeWave
End

Function StopSplineDrag(ctrlName) : ButtonControl
	String ctrlName
	
	DisEstablishSplineDependency(SplineDragSplineWave(2))
	Button startStopSplineDrag, title="Start Spline Drag", proc=StartSplineDrag
	KillControl PauseResumeSplineDrag
	GraphNormal
	RemoveAndKillNodeSplineWaves()
End
