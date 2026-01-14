#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.14
#pragma IgorVersion=6.10

#include <PopupWaveSelector>
#include <SaveRestoreWindowCoords>

//***********************************************
// Version History
//
//	1.10
//		Substantial re-working of the UI bringing it up to more modern standards
//	1.11	JW 100830
//		Fixed Windows layout problems caused by peculiar use of bold text.
//	1.12	LH 14-525
//		PanelResolution for Igor 7
//	1.13	 JP 160517
//		Uses SetWindow sizeLimit for Igor 7
//	1.14	JW 210809
//		Fixed duplicate case in a switch statement.
//***********************************************

Menu "Analysis"
	"Fit ODE", ODE_Fit_Panel()
end

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function ODE_IC_FunctionTemplate(w, yy)
	Wave w, yy
	
	yy[0][] = 0
end

// This is the fit function used by the Fit ODE control panel. You can use it, too, if you're willing to set up
// all the global variables it uses to find out how to do the ODE integration. More likely, you will want to
// use this function as a basis for developing your own special-purpose fitting function.

// Fitting function is implemented as an all-at-once function. The need to call IntegrateODE from within the
// function pretty much requires that it be an all-at-once function.

Function ODEFitFunc(w,ywave, xwave)
	Wave w,ywave, xwave
	
	// Global strings and variables. This function requires that these globals reside in a data folder
	// root:Packages:WM_FitODE. So you must make sure that entire data folder path exists, plus
	// you must populate the data folder with the globals.
	
	// A string variable containing the name of the derivative function to be passed to IntegrateODE
	SVAR ODE_Func=root:Packages:WM_FitODE:ODE_Func
	// Name of a wave to provide error control scaling. If you do not use this wave, set the string to ""
	SVAR ODE_ErrConstWave=root:Packages:WM_FitODE:ODE_ErrConstWave
	// If you use a function to set the initial conditions, this is the name of the function.
	SVAR ODE_InitCondFunc=root:Packages:WM_FitODE:ODE_InitCondFunc

	// The column in the IntegrateODE wave that contains the model values for the fit.
	NVAR ODE_ModelIsWhichCol=root:Packages:WM_FitODE:ODE_ModelIsWhichCol
	// The integration method to use. This number will be passed to IntegrateODE via the /M flag
	NVAR ODE_Method=root:Packages:WM_FitODE:ODE_Method
	// Error tolerance. IntegrateODE /E flag.
	NVAR ODE_Error=root:Packages:WM_FitODE:ODE_Error
	// Error control method. IntegrateODE /F flag.
	NVAR ODE_errMethod=root:Packages:WM_FitODE:ODE_errMethod
	// A number specifying the method to use to get the initial conditions. 0= pre-set; the initial conditions
	// must be in a wave called "InitY" residing in the current data folder. 1= fit coefficients. The initial conditions
	// are in the coefficient wave, after the coefficients for the ODE system. If you have N equations (your system is
	// of order N) the last N coefficients are the initial conditions. 2= set by a function.
	NVAR ODE_InitialConditionMethod = root:Packages:WM_FitODE:ODE_InitialConditionMethod
	// The order of the system (the number of equations or columns in the result).
	NVAR ODE_NumEqs=root:Packages:WM_FitODE:ODE_NumEqs

	// Make a multi-column wave to receive the results of the integration.
	Make/D/O/N=(numpnts(ywave), ODE_NumEqs) ODE_Res
	
	// Get the initial conditions from a source set by ODE_InitialConditionMethod (see the long comment above).
	// The initial conditions must go in the first row of ODE_Res
	if (ODE_InitialConditionMethod == 1)
		Wave initial=$"initY"
		ODE_Res[0][]=initial[q]
	else
		if (ODE_InitialConditionMethod == 2)
			Variable offset = numpnts(w)-ODE_NumEqs
			ODE_Res[0][]=w[q+offset]
		else
			FUNCREF ODE_IC_FunctionTemplate theFunc = $ODE_InitCondFunc
			theFunc(w, ODE_Res)
		endif
	endif
	
	// Look up the error scaling wave. If the name is "", it will make a null wave reference.
	Wave/Z errw=$ODE_ErrConstWave
	
	// Call IntegrateODE to compute the solution.
	if (WaveExists(errw))
		IntegrateODE/E=(ODE_Error)/F=(ODE_errMethod)/S=errw/U=1000000/M=(ODE_Method)/X=xwave $ODE_Func,w,ODE_Res
	else
		IntegrateODE/E=(ODE_Error)/F=(ODE_errMethod)/U=1000000/M=(ODE_Method)/X=xwave $ODE_Func,w,ODE_Res
	endif
	
	// Copy the solution results from the appropriate column into the fit function's output Y wave.
	ywave = ODE_Res[p][ODE_ModelIsWhichCol]
End

Proc ODE_Fit_Panel()

	if (WinType("ODEFitPanel") == 0)
		InitFitODE()
		fODEFitPanel()
	else
		DoWindow/F ODEFitPanel
	endif

end

Function InitFitODE()

	String SaveDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_FitODE
	
	String/G FIT_YWave=""
	String/G FIT_XWave=""
	String/G ODE_Func=""
	String/G ODE_InitCondFunc=""
	String/G ODE_CoefWave=""
	String/G ODE_ErrConstWave=""

	Variable/G ODE_NumEqs=0
	Variable/G ODE_ModelIsWhichCol=0
	Variable/G ODE_Method=1
	Variable/G ODE_Error=1e-6
	Variable/G ODE_errMethod=0
	
	Variable/G FIT_StartX=-INF
	Variable/G FIT_EndX=INF
	Variable/G FIT_StartP=-INF
	Variable/G FIT_EndP=INF
	
	Make/O/T/N=(0,6) FitODE_HoldListWave
	Make/O/N=(0,6) FitODE_HoldSelWave
	Make/O/T/N=5 FitODE_HoldListTitleWave={"Coefficient", "Initial Guess", "Hold", "Lower Bound", "Upper Bound", "Result"}
		
	SetDataFolder $SaveDF
end

Function FitODE_UpdateCoefficientList()

	Wave/T FitODE_HoldListWave = root:Packages:WM_FitODE:FitODE_HoldListWave
	Wave FitODE_HoldSelWave = root:Packages:WM_FitODE:FitODE_HoldSelWave
	NVAR ODE_NumEqs = root:Packages:WM_FitODE:ODE_NumEqs
	Wave/Z CoefWave = $PopupWS_GetSelectionFullPath("ODEFitPanel#ODEInfoTabPanel", "FitODE_CoefWaveMenuButton")
	if (!WaveExists(CoefWave))
		return 0
	endif
	
	Variable startingListRows = DimSize(FitODE_HoldListWave, 0)
	
	Variable numCoefs = numpnts(CoefWave)
	Variable numRows = numCoefs
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel InitialConditionMethodMenu
	Variable ICasFitCoefs = V_value == 2
	if (ICasFitCoefs)
		numRows += ODE_NumEqs
	endif
	Redimension/N=(numRows, -1) FitODE_HoldListWave, FitODE_HoldSelWave
	
	FitODE_HoldListWave[0,numCoefs-1][0] = NameOfWave(CoefWave)+"["+num2str(p)+"]"
	FitODE_HoldListWave[0,numCoefs-1][1] = num2str(CoefWave[p])
//	FitODE_HoldListWave[0,numCoefs-1][2] = ""
//	FitODE_HoldListWave[0,numCoefs-1][3] = ""
//	FitODE_HoldListWave[0,numCoefs-1][4] = ""
	if (ICasFitCoefs)
		Wave/Z initial=initY
		if (!WaveExists(initial))
			Make/O/D/N=(ODE_NumEqs) initY
			Wave initial=initY
		endif

		FitODE_HoldListWave[numCoefs,numRows-1][0] = "Initial Condition " + num2str(p-numCoefs)
		FitODE_HoldListWave[numCoefs,numRows-1][1] = num2str(initial[p-numCoefs])
	endif
	
	if (numRows > startingListRows)
		FitODE_HoldSelWave[startingListRows, numRows-1][] = 0
		FitODE_HoldSelWave[startingListRows, numRows-1][1] = 2
		FitODE_HoldSelWave[startingListRows, numRows-1][2] = 0x20
		FitODE_HoldSelWave[startingListRows, numRows-1][3] = 2
		FitODE_HoldSelWave[startingListRows, numRows-1][4] = 2
		FitODE_HoldSelWave[startingListRows, numRows-1][5] = 0
	endif
end

Function fODEFitPanel()

	NewPanel/K=1/W=(20,50,658,350) as "Curve Fit to ODE"
	RenameWindow $S_name, ODEFitPanel

	DefineGuide UGV0={FL,8},UGH0={FT,24},UGV1={FR,-12},UGH1={FB,-48},UGH2={FB,-40}

	TabControl FitODE_TabControl,pos={5,1},size={623,253},proc=FitODE_TabProc
	TabControl FitODE_TabControl,tabLabel(0)="ODE Information"
	TabControl FitODE_TabControl,tabLabel(1)="Fit Information"
	TabControl FitODE_TabControl,tabLabel(2)="Fit Output",value= 0
	
	NewPanel/W=(0,75,479,225)/FG=(,UGH2,FR,FB)/HOST=# 
	ModifyPanel frameStyle=0, frameInset=0
	RenameWindow #,FitODE_HelpDoItPanel
	
		Button ODEFitHelpButton,pos={544,10},size={80,20},proc=ODEFitHelpButtonProc,title="Help"

		Button FitDoItButton,pos={7,10},size={80,20},proc=FitODE_DoItButtonProc,title="Do It"

	SetActiveSubwindow ##

	NewPanel/W=(8,23,625,251)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=ODEFitPanel
	ModifyPanel frameStyle=0, frameInset=0
	RenameWindow #,ODEInfoTabPanel

		PopupMenu DerivFuncMenu,pos={13,63},size={298,21},title="Derivative Function:",fSize=10
		PopupMenu DerivFuncMenu,mode=1,bodyWidth= 200,value= #"FunctionList(\"*\", \";\", \"NPARAMS:4,KIND:6\")"
	
		SetVariable SetNumEqs,pos={13,5},size={223,16},title="System Order (How Many Equations?)",fSize=10
		SetVariable SetNumEqs,limits={1,inf,1},value= root:Packages:WM_FitODE:ODE_NumEqs,bodyWidth= 40,proc=FitODE_SetNumEqsProc

		PopupMenu ModelDataPopup,pos={60,31},size={176,21},title="Fit model is which equation?",fSize=10
		PopupMenu ModelDataPopup,mode=1,bodyWidth= 40,value= #"ODE_ListOfNumbers(root:Packages:WM_FitODE:ODE_NumEqs, 0)"

		TitleBox FitODE_CoefWaveTitle,pos={23,99},size={85,13},title="Coefficient Wave:"
		TitleBox FitODE_CoefWaveTitle,fSize=10,frame=0

		Button FitODE_CoefWaveMenuButton,pos={110,95},size={200,20},title="xxx",fSize=10
		MakeButtonIntoWSPopupButton("ODEFitPanel#ODEInfoTabPanel", "FitODE_CoefWaveMenuButton", "FitODE_CorYWaveSelectedNotify")

		PopupMenu ODEMethodMenu,pos={333,11},size={228,21},title="ODE Method:",fSize=10
		PopupMenu ODEMethodMenu,mode=1,bodyWidth= 160,value= #"\"Runge-Kutta;Bulirsch-Stoers;Adams-Moulton;BDF (for stiff systems);\""

		GroupBox ODEInitialConditionBox,pos={337,62},size={277,72},title="Initial Conditions",fSize=10

			PopupMenu InitialConditionMethodMenu,pos={359,81},size={69,21},proc=InitConditionMethodMenuProc
			PopupMenu InitialConditionMethodMenu,mode=2,value= #"\"Pre-set;Fit Param;set by Function\""
		
			Button SetInitCondButton,pos={359,109},size={170,20},proc=SetInitCondButtonProc,title="Set Initial Guesses...",fSize=10
		
			PopupMenu SetInitCondFuncMenu,pos={401,108},size={201,19},disable=1,proc=InitCondFuncPopMenuProc,title="Function:"
			PopupMenu SetInitCondFuncMenu,mode=1,bodyWidth= 150,value= #"FunctionList(\"*\",\";\",\"KIND:2,NPARAMS:2\")"

		GroupBox ODEErrorBox,pos={5,141},size={609,82},title="ODE Error Control",fSize=10

			SetVariable SetODEError,pos={20,165},size={150,16},title="Error level:"
			SetVariable SetODEError,limits={0,inf,0},value= root:Packages:WM_FitODE:ODE_Error
		
			TitleBox FitODE_IncludeErrorScalingTIt,pos={20,200},size={112,13},title="Include in Error Scaling:"
			TitleBox FitODE_IncludeErrorScalingTIt,fSize=10,frame=0
		
			CheckBox ODE_Err_Const_check,pos={145,200},size={45,14},proc=ODE_Err_Const_CheckProc,title="Const"
			CheckBox ODE_Err_Const_check,value= 0
		
			CheckBox ODE_Err_Y_check,pos={217,200},size={25,14},title="Y",value= 0
		
			CheckBox ODE_Err_DYDX_check,pos={269,200},size={47,14},title="dY/dx",value= 0
		
			TitleBox FitODE_ConstErrorWaveTitle,pos={327,167},size={87,13},title="Const Error Wave:"
			TitleBox FitODE_ConstErrorWaveTitle,fSize=10,frame=0

			Button FitODE_ConstErrorWaveMenu,pos={419,163},size={168,20},title="_none_",fSize=10
			MakeButtonIntoWSPopupButton("ODEFitPanel#ODEInfoTabPanel", "FitODE_ConstErrorWaveMenu", "FitODE_CErrWaveSelectedNotify")
			PopupWS_AddSelectableString("ODEFitPanel#ODEInfoTabPanel", "FitODE_ConstErrorWaveMenu", "_None_")
			PopupWS_AddSelectableString("ODEFitPanel#ODEInfoTabPanel", "FitODE_ConstErrorWaveMenu", "Make one, please")
			PopupWS_SetSelectionFullPath("ODEFitPanel#ODEInfoTabPanel", "FitODE_ConstErrorWaveMenu", "_None_")

			Button EditErrConstWave,pos={538,195},size={50,20},proc=EditConstErrButtonProc,title="Edit...",fSize=9

	SetActiveSubwindow ##

	NewPanel/W=(7,24,625,252)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=# /HIDE=1 
	ModifyPanel frameStyle=0, frameInset=0
	RenameWindow #,FitInfoTabPanel

		GroupBox ODEFitWavesBox,pos={8,4},size={602,122},title="Waves",fSize=10
	
			GroupBox FitODE_InputDataGroup,pos={19,27},size={262,80},title="Data to Fit",fSize=10

				TitleBox FitODE_YWaveTitle,pos={41,53},size={39,13},title="\\JRY Wave:",fSize=10,frame=0
	
				Button FitODE_YDataMenuButton,pos={86,50},size={178,20},title="xxx",fSize=10
				MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_YDataMenuButton", "FitODE_CorYWaveSelectedNotify")
	
				TitleBox FitODE_XWaveMenuButton,pos={41,81},size={39,13},title="\\JRX Wave:",fSize=10,frame=0
	
				Button FitODE_XDataMenuButton,pos={86,77},size={178,20},title="_calculated_",fSize=10
				MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_XDataMenuButton", "")
				PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_XDataMenuButton", "_calculated_")
				PopupWS_SetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_XDataMenuButton", "_calculated_")

			TitleBox FitODE_WeightWaveTitle,pos={332,32},size={67,13},title="\\JRWeight Wave:"
			TitleBox FitODE_WeightWaveTitle,fSize=10,frame=0

			Button FitODE_WeightMenuButton,pos={404,28},size={178,20},title="_None_",fSize=10
			MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_WeightMenuButton", "")	
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_WeightMenuButton", "_None_")
			PopupWS_SetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_WeightMenuButton", "_None_")

			TitleBox FitODE_EpsWaveTitle,pos={332,55},size={66,13},title="\\JREpsilon Wave:"
			TitleBox FitODE_EpsWaveTitle,fSize=10,frame=0

			Button FitODE_EpsilonMenuButton,pos={404,51},size={178,20},title="_None_",fSize=10
			MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_EpsilonMenuButton", "")	
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_EpsilonMenuButton", "_None_")
			PopupWS_SetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_EpsilonMenuButton", "_None_")

			TitleBox FitODE_DestTitle,pos={340,78},size={58,13},title="\\JRDestination:"
			TitleBox FitODE_DestTitle,fSize=10,frame=0

			Button FitODE_DestMenuButton,pos={404,74},size={178,20},title="_None_",fSize=10
			MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton", "")	
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton", "_None_")
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton", "_Auto Trace_")
			PopupWS_SetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton", "_Auto Trace_")

			TitleBox FitODE_ResidualTitle,pos={356,102},size={44,13},title="\\JRResidual:"
			TitleBox FitODE_ResidualTitle,fSize=10,frame=0

			Button FitODE_ResidualMenuButton,pos={404,98},size={178,20},title="_None_",fSize=10
			MakeButtonIntoWSPopupButton("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", "")	
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", "_None_")
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", "_Auto Trace_")
			PopupWS_AddSelectableString("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", "_Auto Wave_")
			PopupWS_SetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", "_None_")

			ListBox FitODE_HoldConstrainList,pos={10,131},size={600,92}, userColumnResize=1,proc=FitODE_HoldListBoxProc
			ListBox FitODE_HoldConstrainList,editStyle=1,widths={4,4,1,4,4,4}
			ListBox FitODE_HoldConstrainList,listWave=root:Packages:WM_FitODE:FitODE_HoldListWave
			ListBox FitODE_HoldConstrainList,selWave=root:Packages:WM_FitODE:FitODE_HoldSelWave
			ListBox FitODE_HoldConstrainList,titleWave=root:Packages:WM_FitODE:FitODE_HoldListTitleWave

		SetActiveSubwindow ##
		
	NewNotebook /F=0 /N=ODEFitResults /W=(11,66,605,250)/FG=(UGV0,UGH0,UGV1,UGH1) /HOST=#/OPTS=8
	Notebook kwTopWin, defaultTab=20, statusWidth=3, autoSave= 0
	RenameWindow #,ODEFitResults
	Notebook ODEFitPanel#ODEFitResults, visible=0
	setwindow ODEFitPanel#ODEFitResults, hide=1
	
	SetWindow ODEFitPanel, hook = WC_WindowCoordinatesHook
	SetWindow ODEFitPanel, hook(FitODEPanelHook) = FitODEPanelHook

	WC_WindowCoordinatesRestore("ODEFitPanel")
EndMacro

static Function FitODE_IsMinimized(windowName)
	String windowName
	
	if (strsearch(WinRecreation(windowName, 0), "MoveWindow 0, 0, 0, 0", 0, 2) > 0)
		return 1
	endif
	
	return 0
end

Function FitODEPanelHook(s)
	STRUCT WMWinHookStruct & s

	strswitch(s.eventName)
		case "resize":
			if (FitODE_IsMinimized("ODEFitPanel"))
				break;
			endif
			
			FitODE_MainPanelMinWindowSize()
			
			Variable bottom = NumberByKey("POSITION", GuideInfo("ODEFitPanel", "UGH1" )) 
			Variable top = NumberByKey("POSITION", GuideInfo("ODEFitPanel", "UGH0" )) 
			Variable left = NumberByKey("POSITION", GuideInfo("ODEFitPanel", "UGV0" )) 
			Variable right = NumberByKey("POSITION", GuideInfo("ODEFitPanel", "UGV1" )) 
			
			TabControl FitODE_TabControl, win=ODEFitPanel, size={right-left+5, bottom-top+25}
			ListBox FitODE_HoldConstrainList,win=ODEFitPanel#FitInfoTabPanel,size={right-left-18, bottom-top-136}
			break;
	endswitch
end

// all dimensions are in points
static Function FitODE_MainPanelMinWindowSize()

	GetWindow ODEFitPanel, wsize
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if (minimized)
		return 0
	endif
	
	Variable width= (V_right - V_left)
	Variable height= (V_bottom - V_top)
	Variable minWidthPoints= 638*PanelResolution("ODEFitPanel")/ScreenResolution
	Variable minHeightPoints= 300*PanelResolution("ODEFitPanel")/ScreenResolution
#if IgorVersion() >= 7
	SetWindow ODEFitPanel sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	width= max(width, minWidthPoints)
	height= max(height, minHeightPoints)
	MoveWindow/W=ODEFitPanel V_left, V_top, V_left+width, V_top+height
#endif
End

Static Function FitODE_ChangeTab(theTab)
	Variable theTab
	
	setwindow ODEFitPanel#ODEInfoTabPanel, hide=(theTab!=0)
	setwindow ODEFitPanel#FitInfoTabPanel, hide=(theTab!=1)
	setwindow ODEFitPanel#ODEFitResults, hide=(theTab!=2)
	Notebook ODEFitPanel#ODEFitResults, visible=(theTab==2)
	if (theTab == 1)
		FitODE_UpdateCoefficientList()
	endif
end

Function FitODE_TabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			FitODE_ChangeTab(tca.tab)
			break
	endswitch

	return 0
End

Function FitODE_CErrWaveSelectedNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	if (event == WMWS_SelectionChanged)
		SVAR ODE_ErrConstWave = root:Packages:WM_FitODE:ODE_ErrConstWave
		NVAR ODE_NumEqs=root:Packages:WM_FitODE:ODE_NumEqs

		if (CmpStr(wavepath, "Make one, please") == 0)
			Make/D/O/N=(ODE_NumEqs) ODE_errScale=1
			ODE_ErrConstWave = "ODE_errScale"
			PopupWS_SetSelectionFullPath("ODEFitPanel#ODEInfoTabPanel", "FitODE_ConstErrorWaveMenu", GetWavesDataFolder(ODE_errScale, 2))
		else
			Wave/Z w = $wavepath
			if (WaveExists(w))
				ODE_ErrConstWave = wavepath
			else
				ODE_ErrConstWave = ""
			endif
		endif
		
	endif
end

Function FitODE_CorYWaveSelectedNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	if (event == WMWS_SelectionChanged)		
		Wave/Z w = $wavepath
		if (!WaveExists(w))
			return 0
		endif
		String selectionOptions = "DIMS:1,BYTE:0,CMPLX:0,INTEGER:0,MAXROWS:"+num2str(numpnts(w))
		selectionOptions += ",MINROWS:"+num2str(numpnts(w))
		selectionOptions += ",TEXT:0,WORD:0"
		if (CmpStr(ctrlName, "FitODE_CoefWaveMenuButton") == 0)
			PopupWS_MatchOptions("ODEFitPanel#FitInfoTabPanel", "FitODE_EpsilonMenuButton", listoptions=selectionOptions)
		elseif(CmpStr(ctrlName, "FitODE_YDataMenuButton") == 0)
			PopupWS_MatchOptions("ODEFitPanel#FitInfoTabPanel", "FitODE_XDataMenuButton", listoptions=selectionOptions)
			PopupWS_MatchOptions("ODEFitPanel#FitInfoTabPanel", "FitODE_WeightMenuButton", listoptions=selectionOptions)
			PopupWS_MatchOptions("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton", listoptions=selectionOptions)
			PopupWS_MatchOptions("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton", listoptions=selectionOptions)
		endif
		FitODE_UpdateCoefficientList()
	endif
end

Function/S ODE_ListOfNumbers(N, First_Num)
	Variable N, First_Num
	
	Variable i=0
	String theList=""
	do
		theList += num2istr(i+First_Num)+";"
		i += 1
	while (i < N)
	
	return theList
end

Function FitODE_DoItButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR FIT_YWave=root:Packages:WM_FitODE:FIT_YWave
	SVAR FIT_XWave=root:Packages:WM_FitODE:FIT_XWave
	SVAR ODE_Func=root:Packages:WM_FitODE:ODE_Func

	NVAR ODE_NumEqs=root:Packages:WM_FitODE:ODE_NumEqs
	NVAR ODE_ModelIsWhichCol=root:Packages:WM_FitODE:ODE_ModelIsWhichCol
	NVAR ODE_Method=root:Packages:WM_FitODE:ODE_Method
	NVAR ODE_errMethod=root:Packages:WM_FitODE:ODE_errMethod

	Wave/T FitODE_HoldListWave = root:Packages:WM_FitODE:FitODE_HoldListWave
	Wave FitODE_HoldSelWave = root:Packages:WM_FitODE:FitODE_HoldSelWave
	
	// If any auxiliary panels are open, make sure they are in consistent state (like, a table window in editing mode
	// should have the edits accepted)
	DoWindow Set_Initial_Conditions
	if (V_flag)
		ModifyTable/W=Set_Initial_Conditions entryMode=1
	endif
	DoWindow FitODE_EditCoefWave
	if (V_flag)
		ModifyTable/W=FitODE_EditCoefWave entryMode=1
	endif

	FIT_YWave = PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_YDataMenuButton")
	FIT_XWave = PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_XDataMenuButton")

	Wave srcYData = $FIT_YWave
	Wave/Z srcXData = $FIT_XWave

	String CoefWaveName = PopupWS_GetSelectionFullPath("ODEFitPanel#ODEInfoTabPanel", "FitODE_CoefWaveMenuButton")
	Wave/Z CoefWave = $CoefWaveName
	if (!WaveExists(CoefWave))
		DoAlert 0, "You must select a coefficient wave"
		return -1
	endif
	
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel ModelDataPopup
	ODE_ModelIsWhichCol = V_value-1
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel DerivFuncMenu
	ODE_Func = S_value
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel ODEMethodMenu
	ODE_Method = V_value-1
	
	String FitCommand = "FuncFit "

	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel InitialConditionMethodMenu
	Variable/G root:Packages:WM_FitODE:ODE_InitialConditionMethod=V_value
	NVAR ODE_InitialConditionMethod=root:Packages:WM_FitODE:ODE_InitialConditionMethod

	Variable dummyBound, numConstraints=0
	Variable i=0
	Variable numCoefListRows=DimSize(FitODE_HoldListWave, 0)
	Variable nHolds = 0
	String holdString = PadString("", numCoefListRows, char2num("0"))
	for (i = 0; i < numCoefListRows; i += 1)
		if (FitODE_HoldSelWave[i][2] & 0x10)
			sscanf (FitODE_HoldListWave[i][3]), "%g", dummyBound
			if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][3]) > 0))
				DoAlert 0, "You cannot hold and constrain the same fit coefficient. See row "+FitODE_HoldListWave[i][0]+" in the coefficient list."
				TabControl FitODE_TabControl,win=ODEFitPanel,value=1
				FitODE_ChangeTab(1)
				return -1
			endif
			sscanf (FitODE_HoldListWave[i][4]), "%g", dummyBound
			if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][4]) > 0))
				DoAlert 0, "You cannot hold and constrain the same fit coefficient"
				TabControl FitODE_TabControl,win=ODEFitPanel,value=1
				FitODE_ChangeTab(1)
				DoAlert 0, "You cannot hold and constrain the same fit coefficient. See row "+FitODE_HoldListWave[i][0]+" in the coefficient list."
				return -1
			endif
			nHolds += 1
			holdString[i,i]="1"
		endif
	endfor
	if (nHolds > 0)
		FitCommand += "/H=\""+holdString+"\" "
	endif
	
	if (ODE_InitialConditionMethod == 2)		// initial conditions need to be part of coefficient wave
		Make/D/N=(ODE_NumEqs+numpnts(CoefWave))/O CombinedCoefWave
		Wave initial=$"initY"
		CombinedCoefWave[] = str2num(FitODE_HoldListWave[p][1])
		CoefWaveName = "CombinedCoefWave"
	else
		CoefWave = str2num(FitODE_HoldListWave[p][1])
	endif
	
	FitCommand += "ODEFitFunc,"+CoefWaveName+","+FIT_YWave
	if (WaveExists(srcXData))
		FitCommand += " /X="+FIT_XWave
	endif
	
	String WeightWaveName = PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_WeightMenuButton")
	Wave/Z WeightWave=$WeightWaveName
	if (WaveExists(WeightWave))
		FitCommand += " /W="+WeightWaveName
	endif
	
	String EpsilonWaveName = PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_EpsilonMenuButton")
	Wave/Z EpsilonWave=$EpsilonWaveName
	if (WaveExists(EpsilonWave))
		FitCommand += " /E="+EpsilonWaveName
	endif
	
	String ResidualWaveName = PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_ResidualMenuButton")
	Wave/Z ResidualWave=$ResidualWaveName
	if (WaveExists(ResidualWave))
		FitCommand += " /R="+ResidualWaveName
	else
		if (CmpStr(ResidualWaveName, "_Auto Trace_") == 0)
			FitCommand += "/R"
		else
			if (CmpStr(ResidualWaveName, "_Auto Wave_") == 0)
				FitCommand += "/R/A=0"
			endif
		endif
	endif
	
	String DestWaveName=PopupWS_GetSelectionFullPath("ODEFitPanel#FitInfoTabPanel", "FitODE_DestMenuButton")
	if (CmpStr(DestWaveName, "_Auto Trace_") == 0)
		FitCommand += " /D"
	else
		Wave/Z DestWave = $DestWaveName
		if (WaveExists(DestWave))
			FitCommand += " /D="+DestWaveName
		endif
	endif
	
	for (i = 0; i < numCoefListRows; i += 1)
		sscanf (FitODE_HoldListWave[i][3]), "%g", dummyBound
		if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][3]) > 0))
			numConstraints += 1
		endif
		sscanf (FitODE_HoldListWave[i][4]), "%g", dummyBound
		if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][4]) > 0))
			numConstraints += 1
		endif
	endfor
	if (numConstraints > 0)
		Make/N=(numConstraints)/T/O ODE_Fit_Constraints
		Variable index=0
		for (i = 0; i < numCoefListRows; i += 1)
			sscanf (FitODE_HoldListWave[i][3]), "%g", dummyBound
			if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][3]) > 0))
				ODE_Fit_Constraints[index] = "K"+num2istr(i)+">"+num2str(dummyBound)
				index += 1
			endif
			sscanf (FitODE_HoldListWave[i][4]), "%g", dummyBound
			if (numtype(dummyBound) == 0 && (strlen(FitODE_HoldListWave[i][4]) > 0))
				ODE_Fit_Constraints[index] = "K"+num2istr(i)+"<"+num2str(dummyBound)
				index += 1
			endif
		endfor
		FitCommand += " /C=ODE_Fit_Constraints"
	endif

	ODE_errMethod=0
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel ODE_Err_Const_check
	if (V_value)
		ODE_errMethod += 1
	endif
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel ODE_Err_Y_check
	if (V_value)
		ODE_errMethod += 2
	endif
	ControlInfo/W=ODEFitPanel#ODEInfoTabPanel ODE_Err_DYDX_check
	if (V_value)
		ODE_errMethod += 4
	endif

	Variable HistoryCapture = CaptureHistoryStart()
	print "ODE Fit starting..."
	print "\tY Data Wave: "+FIT_YWave
	print "\tX Data Wave: "+FIT_XWave
	print "\tDestination: "+DestWaveName
	print "\tResidual: "+ResidualWaveName
	print "\tDerivative Function: "+ODE_Func
	print "\tODE Coefficient Wave: "+GetWavesDataFolder(CoefWave, 2)
	print "\tFit Coefficient Wave: "+CoefWaveName
	print "\tWeight wave: "+WeightWaveName
	print "\tEpsilon wave: "+EpsilonWaveName
	printf "\tODE error controls: "
	if (ODE_errMethod & 1)
		printf "Constant; "
	endif
	if (ODE_errMethod & 2)
		printf "Y value; "
	endif
	if (ODE_errMethod & 4)
		printf "Derivative Values;"
	endif
	printf "Error limit: %g\r", ODE_errMethod
	switch (ODE_InitialConditionMethod)
		case 0:
			print "\tInitial conditions are pre-set."
			break;
		case 2:
			print "\tInitial conditions are fit coefficients."
			break;
		case 1:
			SVAR ODE_InitCondFunc=root:Packages:WM_FitODE:ODE_InitCondFunc
			print "\tInitial conditions are set by function "+ODE_InitCondFunc
			break;
	endswitch
	print "\tFit model is column ",ODE_ModelIsWhichCol
	printf "\tODE solution method: "
	switch(ODE_Method)
		case 0:
			printf "Runge-Kutta"
			break;
		case 1:
			printf "Bulirsch-Stoers"
			break;
		case 2:
			printf "Adams-Moulton"
			break;
		case 3:
			printf "BDF"
			break;
	endswitch
	printf "\r"
	if (numConstraints>0)
		print "\tConstrained fit; constraint wave: "+GetWavesDataFolder(ODE_Fit_Constraints, 2)
	endif
	print "\r*** "+FitCommand
	Variable/G V_FitQuitReason=0,V_FitError=0
	Execute FitCommand
	if ( (V_FitError == 0) && (V_fitQuitReason == 0) )
		Wave w = $coefWaveName
		FitODE_HoldListWave[][5] = num2str(w[p])
		if (ODE_InitialConditionMethod == 2)		// initial conditions are part of coefficient wave
			CoefWave = w[p]
		endif
	else
		if (V_FitError)
			if (V_FitError & 2)
				DoAlert 0, "ODE fit stopped due to a singular matrix error."
			elseif (V_FitError & 4)
				DoAlert 0, "ODE fit stopped due to a out of memory error."
			elseif (V_FitError & 8)
				DoAlert 0, "ODE fit stopped because one of your fitting functions returned NaN or INF."
			endif
		endif
		
		switch(V_FitQuitReason)
			case 1:
				print "ODE Fit stopped because the limit of iterations was reached."
				break;
			case 2:
				print "ODE Fit was stopped by the user."
				break;
			case 3:
				print "ODE Fit stopped because the limit of iterations with no decrease in chi-square was reached."
		endswitch
	endif
	String fitResults = CaptureHistory(HistoryCapture, 1)
	Notebook ODEFitPanel#ODEFitResults selection={startOfFile, endOfFile},text=fitResults
End

Function SetInitCondButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR ODE_NumEqs=root:Packages:WM_FitODE:ODE_NumEqs

	if (WinType("Set_Initial_Conditions") != 0)
		DoWindow/K Set_Initial_Conditions
	endif
	
	Make/D/N=(ODE_NumEqs)/O/D InitY
	Make/D/N=(ODE_NumEqs)/O/t InitYLabels
	
	Variable i=0
	do
		InitYLabels[i] = "Equation "+num2istr(i)
		i += 1
	while (i<ODE_NumEqs)
	
	FITODE_Set_Initial_Conditions()
End

Function FITODE_Set_Initial_Conditions()
	PauseUpdate; Silent 1		// building window...
	Edit/K=1/W=(5,42,280,287) InitYLabels,InitY as "Set Initial Conditions"
	DoWindow/C Set_Initial_Conditions
	ModifyTable alignment(InitYLabels)=1,title(InitYLabels)=" ",width(InitY)=90,title(InitY)="Initial value"
	SetWindow Set_Initial_Conditions, hook(editHook)=FitODE_InitConditionEditHook
EndMacro

Function FitODE_InitConditionEditHook(s)
	STRUCT WMWinHookStruct &s
	
	strswitch (s.eventName)
		case "deactivate":
		case "kill":
		case "hide":
			ModifyTable/W=Set_Initial_Conditions entryMode=1
			FitODE_UpdateCoefficientList()
			break;
		case "keyboard":
			switch (s.keyCode)
				case 30:	// up arrow
				case 31:	// down arrow
				case 13:	// carriage return
				case 9:		// tab key
					ModifyTable/W=Set_Initial_Conditions entryMode=1
					FitODE_UpdateCoefficientList()
			endswitch
	endswitch
	
	return 0
end

Function ODE_Err_Const_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

End

Function EditConstErrButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR ODE_ErrConstWave=root:Packages:WM_FitODE:ODE_ErrConstWave

	Wave/Z w=$ODE_ErrConstWave
	if (WaveExists(w))
		Edit/K=1 w
	endif
End

Function InitConditionMethodMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// =1 for Pre-set; =2 for Fit Parameters; =3 for set by Function
	String popStr

	if (popNum == 1)
		Button SetInitCondButton,win=ODEFitPanel#ODEInfoTabPanel,title="Set Initial Conditions...", disable=0
		PopupMenu SetInitCondFuncMenu,win=ODEFitPanel#ODEInfoTabPanel, disable=1
	endif
	if (popNum == 2)
		Button SetInitCondButton,win=ODEFitPanel#ODEInfoTabPanel,title="Set Initial Guesses...", disable=0
		PopupMenu SetInitCondFuncMenu,win=ODEFitPanel#ODEInfoTabPanel, disable=1
	endif
	if (popNum == 3)
		Button SetInitCondButton,win=ODEFitPanel#ODEInfoTabPanel, disable=1
		PopupMenu SetInitCondFuncMenu,win=ODEFitPanel#ODEInfoTabPanel,disable=0
	endif
	FitODE_UpdateCoefficientList()
End

Function InitCondFuncPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR ODE_InitCondFunc=root:Packages:WM_FitODE:ODE_InitCondFunc
	ODE_InitCondFunc = popStr
End

Function ODEFitHelpButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)		// mouse up
		Button ODEFitHelpButton,win=$(s.win),title="Searching"
		DisplayHelpTopic "Fit ODE Panel"
		Button ODEFitHelpButton,win=$(s.win),title="Help"
	endif
End

Function FitODE_SetNumEqsProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			FitODE_UpdateCoefficientList()
			break
	endswitch

	return 0
End

Function FitODE_HoldListBoxProc(s) : ListBoxControl
	STRUCT WMListboxAction &s

	Variable row = s.row
	Variable col = s.col
	WAVE/T/Z listWave = s.listWave
	WAVE/Z selWave = s.selWave

	String wname

	if (s.eventCode == 1)							// mouse down
		if ( (row < 0) && (s.eventMod & 16) )		// is it a right-click in the title row?
			switch (col)
				case 1:								// initial guess column
					PopupContextualMenu "Copy Result Column;Save to Wave...;Load From Wave;"
					if (V_flag > 0)
						switch (V_flag)
							case 1:
								listWave[][1] = listWave[p][5]
								break
							case 2:
								wname = "SavedFitODEInitialGuesses"
								Prompt wname, "Name for the wave:"
								DoPrompt "Fit ODE Save Initial Guesses", wname
								if (V_flag == 0)
									Make/D/N=(DimSize(listWave, 0))/O $wname
									Wave w = $wname
									w = str2num(listWave[p][1])
								endif
								break
							case 3:
								String wlist = WaveList("*", ";", "DIMS:1,MINROWS:"+num2str(DimSize(listWave, 0))+",MAXROWS:"+num2str(DimSize(listWave, 0)))
								if (strlen(wlist) == 0)
									DoAlert 0, "None available in the current data folder with the right number of rows."
								else
									PopupContextualMenu wlist
									if (V_flag>0)
										Wave w=$S_selection
										listWave[][1] = num2str(w[p])
									endif
								endif
								break
						endswitch
					endif
					break;
				case 2:								// hold checkboxes
					PopupContextualMenu "Check All;Uncheck All;"
					switch(V_flag)
						case 1:
							selWave[][2] = selWave[p][2] | 16
							break;
						case 2:
							selWave[][2] = selWave[p][2] & ~16
							break;
					endswitch
					break;
				case 5:								 // result column
					PopupContextualMenu "Copy to Initial Guess Column;Save to Wave...;"
					if (V_flag > 0)
						switch (V_flag)
							case 1:
								listWave[][1] = listWave[p][5]
								break
							case 2:
								wname = "SavedFitODEResult"
								Prompt wname, "Name for the wave:"
								DoPrompt "Fit ODE Save Results", wname
								if (V_flag == 0)
									Make/D/N=(DimSize(listWave, 0))/O $wname
									Wave w = $wname
									w = str2num(listWave[p][5])
								endif
								break
						endswitch
					endif
					break;
			endswitch
		endif
	endif

	return 0
End