#pragma TextEncoding = "UTF-8"
// Make Sample Data Controls
//	These procedures are designed to help you generate test data which is useful
//	for testing analysis and number-crunching procedures.
//	To use them:
//		Hide this window.
//		Choose ‘Show Sample Data Panel’ from the Macros menu.
//		This will display a control panel.
//	 See the example experiment "Make Sample Data Demo" in the "Examples" folder for further details.

// HR, 12/95. Updated and revised for Igor Pro 3.0.
//		Used rtGlobals and data folders to store globals.
//		Simplified menu so that it just creates a single control panel.

// JW 2/13/95 Updated to add a Remove button to graph controls
// and to add support for ControlBarManager for graph controls

// NOTE that you can use AddSampleDataControls(2) on the control line to add controls to
// an existing graph, or AddSampleDataControls(1) to create a new graph with controls

#pragma rtGlobals=1
#pragma Version=1.1
#include <Make Sample Data>, menus=0
#include <ControlBarManagerProcs>, menus=0

Menu "Macros"
	"Show Sample Data Panel", ShowSampleDataPanel()
	help = {"Displays a control panel that makes it easy to generate test data."}
End

// InitSampleDataControlsGlobals()
//	Creates global settings used by other routines.
//	In most cases you will not need to tweak these globals.
Function InitSampleDataControlsGlobals()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	Variable/G gSetVarNumPoints = 500
	Variable/G gSetVarXMin = 0
	Variable/G gSetVarXMax = 6
	Variable/G gSetVarAmplitude = 1
	Variable/G gSetVarOffset = 0
	Variable/G gSetVarXNoise = 0
	Variable/G gSetVarYNoise = 0
	Variable/G gSetVarPhase = 0
	Variable/G gSetVarCycles = 1
	Variable/G gSetVarWidthInDegrees = 45
	Variable/G gSetVarTimeConstant = 1
	Variable/G gSetVarXCenter = 3
	Variable/G gSetVarFWHM = 1
	Variable/G gSetVarFunctionType=1
	Variable/G gSetVarGlobalsInited=1
	Variable/G gControlYDelta = 0
	String/G CBIdentifier = ""
	SetDataFolder dfSav
End

Function AddPeriodicControls()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	NVAR gControlYDelta
	PopupMenu MSD_Type,pos={190,gControlYDelta+4},mode=1,value= #"\"Sine;Square;Triangle;Sawtooth\""
	SetVariable MSD_Phase,pos={25,gControlYDelta+76},size={119,14},title="Phase (°)",font="Geneva",fSize=10
	SetVariable MSD_Phase,limits={-360,360,1},value=gSetVarPhase
	SetVariable MSD_Cycles,pos={155,gControlYDelta+76},size={103,14},title="Cycles",font="Geneva"
	SetVariable MSD_Cycles,fSize=10,limits={0,INF,1},value=gSetVarCycles
	SetDataFolder dfSav
End

Function RemovePeriodicControls()
	KillControl MSD_Type
	KillControl MSD_Phase
	KillControl MSD_Cycles
End

Function UpdatePeriodicData(xWave, yWave, mode, type, offset, amplitude)
	String xWave, yWave
	Variable mode, type, offset, amplitude

	Variable/D phase, cycles
	
	ControlInfo MSD_Phase; phase = V_value
	ControlInfo MSD_Cycles; cycles = V_value
	MakeSamplePeriodic(xWave, yWave, mode, type, offset, amplitude, phase, cycles)
End

Function AddPulseControls()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	NVAR gControlYDelta
	SetVariable MSD_Phase,pos={25,gControlYDelta+76},size={119,14},title="Phase (°)",font="Geneva",fSize=10
	SetVariable MSD_Phase,limits={-360,360,1},value=gSetVarPhase
	SetVariable MSD_Cycles,pos={155,gControlYDelta+76},size={103,14},title="Cycles",font="Geneva"
	SetVariable MSD_Cycles,fSize=10,limits={0,INF,1},value=gSetVarCycles
	SetVariable MSD_WidthInDegrees,pos={272,gControlYDelta+76},size={98,14},title="Width (°)",font="Geneva",fsize=10
	SetVariable MSD_WidthInDegrees value=gSetVarWidthInDegrees,format=""
	SetDataFolder dfSav
End

Function RemovePulseControls()
	KillControl MSD_Phase
	KillControl MSD_Cycles
	KillControl MSD_WidthInDegrees
End

Function UpdatePulseData(xWave, yWave, mode, offset, amplitude)
	String xWave, yWave
	Variable mode, offset, amplitude

	Variable/D phase, cycles, widthInDegrees
	
	ControlInfo MSD_Phase; phase = V_value
	ControlInfo MSD_Cycles; cycles = V_value
	ControlInfo MSD_WidthInDegrees; widthInDegrees = V_value
	MakeSamplePulse(xWave, yWave, mode, offset, amplitude, phase, cycles, widthInDegrees)
End

Function AddExponentialControls()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	NVAR gControlYDelta
	SetVariable MSD_TimeConstant pos={5,gControlYDelta+76},size={139,14},title="Time Constant",font="Geneva"
	SetVariable MSD_TimeConstant fsize=10,value=gSetVarTimeConstant,format=""
	SetDataFolder dfSav
End

Function RemoveExponentialControls()
	KillControl MSD_TimeConstant
End

Function UpdateExponentialData(xWave, yWave, mode, offset, amplitude)
	String xWave, yWave
	Variable mode, offset, amplitude

	Variable/D tc
	
	ControlInfo MSD_TimeConstant; tc = V_value
	MakeSampleExponential(xWave, yWave, mode, offset, amplitude, tc)
End

Function AddGaussianControls()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	NVAR gControlYDelta
	SetVariable MSD_XCenter pos={32,gControlYDelta+76},size={112,14},title="X Center",font="Geneva"
	SetVariable MSD_XCenter fsize=10,value=gSetVarXCenter,format=""
	SetVariable MSD_FWHM,pos={154,gControlYDelta+76},size={104,14},title="FWHM",font="Geneva",fSize=10
	SetVariable MSD_FWHM,limits={-INF,INF,1},value=gSetVarFWHM
	SetDataFolder dfSav
End

Function RemoveGaussianControls()
	KillControl MSD_XCenter
	KillControl MSD_FWHM
End

Function UpdateGaussianData(xWave, yWave, mode, offset, amplitude)
	String xWave, yWave
	Variable mode, offset, amplitude

	Variable/D xCenter, fwhm
	
	ControlInfo MSD_XCenter; xCenter = V_value
	ControlInfo MSD_FWHM; fwhm = V_value
	MakeSampleGaussian(xWave, yWave, mode, offset, amplitude, xCenter, fwhm)
End

Function AddNoiseControls()
	String dfSav =  SetMakeSampleDataFolderCurrent()
	NVAR gControlYDelta
	PopupMenu MSD_Type,pos={167,gControlYDelta+4},mode=1,value= #"\"Normal;Even\""
	SetDataFolder dfSav
End

Function RemoveNoiseControls()
	KillControl MSD_Type
End

Function UpdateNoiseData(xWave, yWave, mode, offset, amplitude)
	String xWave, yWave
	Variable/D mode, offset, amplitude

	Variable/D type, whichWave
	
	ControlInfo MSD_Type; type = V_value
//	ControlInfo MSD_WhichWave; whichWave = V_value		// this control is not yet implemented
	whichWave = 2		// means add noise to y data
	MakeSampleNoise(xWave, yWave, mode, offset, amplitude, type, whichWave)
End

Function MSD_UpdateProc(ctrlName) : ButtonControl
	String ctrlName
	
	PauseUpdate; Silent 1
	
	NVAR gAutoDisplay = root:Packages:'Make Sample Data':gAutoDisplay

	Variable mode, type, numPoints
	String functionType
	Variable/D xMin, xMax, percentXNoise, percentYNoise
	Variable/D amplitude, offset
	String xWave, yWave
	Variable xIsNew = 0
	Variable yIsNew = 0
	
	Variable isPanelWindow 				// HR, 12/11/95. Need to know type of window containing controls below.
	isPanelWindow = WinType("")==7
	
	ControlInfo MSD_XOutWave; xWave = S_value
	ControlInfo MSD_YOutWave; yWave = S_value
	
	ControlInfo MSD_Mode; mode = V_value
	ControlInfo MSD_FunctionType; functionType = S_value
	ControlInfo MSD_Type; type = V_value
	ControlInfo MSD_NumPoints; numPoints = V_value
	ControlInfo MSD_XMin; xMin = V_value
	ControlInfo MSD_XMax; xMax = V_value
	ControlInfo MSD_XNoise; percentXNoise = V_value
	ControlInfo MSD_YNoise; percentYNoise = V_value
	ControlInfo MSD_Amplitude; amplitude = V_value
	ControlInfo MSD_Offset; offset = V_value

	SetSampleDataSettings(numPoints, xMin, xMax, percentXNoise, percentYNoise, gAutoDisplay)
	
	// If new x or y waves, force mode to "Set Output"
	if (CmpStr(xWave, "_new_") == 0)
		xIsNew = 1
		mode = 1
	endif
	if (CmpStr(yWave, "_new_") == 0)
		yIsNew = 1
		mode = 1
	endif
		
	if (CmpStr(functionType, "Periodic") == 0)
		UpdatePeriodicData(xWave, yWave, mode, type, offset, amplitude)
	endif
	
	if (CmpStr(functionType, "Pulse") == 0)
		UpdatePulseData(xWave, yWave, mode, offset, amplitude)
	endif
	
	if (CmpStr(functionType, "Exponential") == 0)
		UpdateExponentialData(xWave, yWave, mode, offset, amplitude)
	endif
	
	if (CmpStr(functionType, "Gaussian") == 0)
		UpdateGaussianData(xWave, yWave, mode, offset, amplitude)
	endif
	
	if (CmpStr(functionType, "Noise") == 0)
		UpdateNoiseData(xWave, yWave, mode, offset, amplitude)
	endif
	
	Variable totalNumberOfWaves
	if (xIsNew %| yIsNew)
		if (isPanelWindow)
			DoWindow/F $WinName(0,64)		// HR, 12/11/95. We will have created a new graph so bring panel back to the front.
		endif
		totalNumberOfWaves = 0
		do
			if (strlen(WaveName("",totalNumberOfWaves,4)) == 0)
				break
			endif
			totalNumberOfWaves += 1
		while (1)
		if (xIsNew)
			// menu contains "_new_;_none_;" + wavelist
			PopupMenu MSD_XOutWave,mode=totalNumberOfWaves + 1 + 1 - yIsNew
		endif
		if (yIsNew)
			// menu contains "_new_;" + wavelist
			PopupMenu MSD_YOutWave,mode=totalNumberOfWaves + 1
		endif
	endif
End

Function MSD_FunctionTypeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	PauseUpdate; Silent 1
	String dfSav =  SetMakeSampleDataFolderCurrent()

	Variable newFunctionType, oldFunctionType
	
	NVAR gSetVarFunctionType = gSetVarFunctionType
	
	newFunctionType = popNum
	oldFunctionType = gSetVarFunctionType
	if (newFunctionType == oldFunctionType)
		SetDataFolder dfSav
		return 0
	endif
	
	RemovePeriodicControls()
	RemovePulseControls()
	RemoveExponentialControls()
	RemoveGaussianControls()
	RemoveNoiseControls()
	
	if (newFunctionType == 1)
		AddPeriodicControls()
	endif
	if (newFunctionType == 2)
		AddPulseControls()
	endif
	if (newFunctionType == 3)
		AddExponentialControls()
	endif
	if (newFunctionType == 4)
		AddGaussianControls()
	endif
	if (newFunctionType == 5)
		AddNoiseControls()
	endif
	
	gSetVarFunctionType = newFunctionType
	SetDataFolder dfSav
End

Function/S AddSampleDataControlsPrompt()
	String s
	
	s = "New Graph;"
	if (strlen(WinName(0, 1)) == 0)		// no graphs exist ?
		s += "\\M1"							// HR, 12/11/95: Enable disabling of popup menu items.
		s += "("								// causes "Top Graph" to be disabled
	endif
	s += "Top Graph;"
	s += "New Panel"
	
	return s
End

static constant ControlBarDelta = 97

Function AddSampleDataControls(graphOrPanel)
	Variable graphOrPanel					// 1 = new graph, 2 = top graph, 3 = new panel, 4 = existing panel

	MakeSampleDataGeneralGlobals()

	String dfSav =  SetMakeSampleDataFolderCurrent()
	
	if (exists("gSetVarGlobalsInited") == 0)
		InitSampleDataControlsGlobals()
	endif
	
	NVAR gControlYDelta
	SVAR CBIdentifier
	String CBIdent

	if (graphOrPanel == 1)					// new graph ?
		Display/W=(5, 40, 595, 350) as "Make Sample Data Output"
	endif
	
	if (graphOrPanel == 2)					// top graph ?
		DoWindow/F $WinName(0, 1)		// Bring top graph up
		ControlInfo MSD_FunctionType
		if (V_flag != 0)
			SetDataFolder dfSav
			Abort "The graph already has sample data controls."
		endif
	endif
	
	if (graphOrPanel == 3)					// new panel ?
		NewPanel/K=1/W=(5,250,595,350) as "Sample Data Controls"
	endif
	
	if (graphOrPanel == 4)					// existing panel ?
		DoWindow/F MakeSampleDataControlsPanel
		if (V_flag == 0)
			if (exists("MakeSampleDataControlsPanel") == 5)
				Execute "MakeSampleDataControlsPanel()"			// Execute recreation macro.
			else
				NewPanel/W=(5,250,595,350) as "Sample Data Controls"
				DoWindow/C MakeSampleDataControlsPanel
			endif
		endif
	endif
	
	if (WinType("") == 1)					// adding controls to a graph ?
		gControlYDelta = ExtendControlBar(WinName(0, 1), ControlBarDelta, CBIdent)
		CBIdentifier = CBIdent
//		ControlBar 97
	else
		gControlYDelta = 0
		GetWindow kwTopWin, wsize
		MoveWindow V_left,V_top,V_left+590,V_top+100		// adding controls to a panel
	endif
	PopupMenu MSD_FunctionType,pos={7,gControlYDelta+4},size={198,19},proc=MSD_FunctionTypeProc,title="Function Type"
	PopupMenu MSD_FunctionType,mode=1,value= #"\"Periodic;Pulse;Exponential;Gaussian;Noise\""
	PopupMenu MSD_Mode,pos={279,gControlYDelta+4},size={127,19}
	PopupMenu MSD_Mode,mode=1,value= #"\"Set Output;Add to Output;Multiply Output\""
	PopupMenu MSD_XOutWave,pos={413,gControlYDelta+4},size={135,19},title="X Output"
	PopupMenu MSD_XOutWave,mode=2,value= #"\"_new_;_none_;\" + WaveList(\"*\", \";\", \"\")"
	PopupMenu MSD_YOutWave,pos={413,gControlYDelta+27},size={133,19},title="Y Output"
	PopupMenu MSD_YOutWave,mode=1,value= #"\"_new_;\" + WaveList(\"*\", \";\", \"\")"
	SetVariable MSD_NumPoints,pos={20,gControlYDelta+30},size={124,14},title="NumPoints",font="Geneva"
	SetVariable MSD_NumPoints,fSize=10
	SetVariable MSD_NumPoints,limits={10,10000,10},value=gSetVarNumPoints
	SetVariable MSD_XMin,pos={158,gControlYDelta+29},size={100,14},title="X Min",font="Geneva",fSize=10
	SetVariable MSD_XMin,limits={-INF,INF,1},value=gSetVarXMin
	SetVariable MSD_XMax,pos={278,gControlYDelta+29},size={100,14},title="X Max",font="Geneva",fSize=10
	SetVariable MSD_XMax,limits={-INF,INF,1},value=gSetVarXMax
	SetVariable MSD_Amplitude,pos={24,gControlYDelta+53},size={120,14},title="Amplitude",font="Geneva"
	SetVariable MSD_Amplitude,fSize=10,limits={-INF,INF,1},value=gSetVarAmplitude
	SetVariable MSD_Offset,pos={158,gControlYDelta+52},size={100,14},title="Offset",font="Geneva"
	SetVariable MSD_Offset,fSize=10,limits={-INF,INF,1},value=gSetVarOffset
	SetVariable MSD_XNoise,pos={272,gControlYDelta+53},size={105,14},title="X Noise (%)",font="Geneva"
	SetVariable MSD_XNoise,fSize=10,limits={-INF,INF,1},value=gSetVarXNoise
	SetVariable MSD_YNoise,pos={392,gControlYDelta+53},size={105,14},title="Y Noise (%)",font="Geneva"
	SetVariable MSD_YNoise,fSize=10,limits={-INF,INF,1},value=gSetVarYNoise
	AddPeriodicControls()
	if (graphOrPanel < 3)
		Button MSD_Update,pos={393,gControlYDelta+73},size={60,20},proc=MSD_UpdateProc,title="Update"
		Button SampleDataRemoveButton,pos={462,gControlYDelta+73},size={70,20},proc=SampleDataRemoveButtonProc,title="Remove"
	else
		Button MSD_Update,pos={488,gControlYDelta+73},size={60,20},proc=MSD_UpdateProc,title="Update"
	endif
	SetDataFolder dfSav
End

Proc AddSampleDataControlsDialog(graphOrPanel)
	Variable graphOrPanel=3
	Prompt graphOrPanel, "Add controls to", popup AddSampleDataControlsPrompt()

	AddSampleDataControls(graphOrPanel)
End

Function ShowSampleDataPanel()
	AddSampleDataControls(4)				// Displays panel or makes new panel if none already exists.
End

Function SampleDataRemoveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	RemoveSampleDataControls()
End

Function RemoveSampleDataControls()
	
	if (WinType("") == 1)					// removing controls from a graph
		String dfSav =  SetMakeSampleDataFolderCurrent()
		SVAR CBIdentifier
		SetDataFolder dfSav
//		ControlBar 0
		ContractControlBar(WinName(0,1), CBIdentifier, ControlBarDelta)
		KillControl MSD_FunctionType
		KillControl MSD_Mode
		KillControl MSD_XOutWave
		KillControl MSD_YOutWave
		KillControl MSD_NumPoints
		KillControl MSD_XMin
		KillControl MSD_XMax
		KillControl MSD_Amplitude
		KillControl MSD_Offset
		KillControl MSD_XNoise
		KillControl MSD_YNoise
		KillControl MSD_Update
		KillControl SampleDataRemoveButton
		RemovePeriodicControls()
		RemovePulseControls()
		RemoveExponentialControls()
		RemoveGaussianControls()
		RemoveNoiseControls()
	else										// removing entire panel
		DoWindow/K $WinName(0,64)
	endif
End
