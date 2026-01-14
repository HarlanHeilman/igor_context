#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version 1.11
#pragma IgorVersion=6.00
#pragma ModuleName=ODEPanelModule

#include <Wave Lists>
#include <WaveSelectorWidget>
#include <PopupWaveSelector>

//***********************************************
// Version History
//
//	1.01
//		Removed dependency on Strings as Lists procedure file
//	1.10
//		Substantial re-working of the UI bringing it up to more modern standards
//	1.11	JW 100830
//		Fixed bug: if your ODE function was already selected simply because it was the first in the list and you hadn't actually selected the function in the menu,
//			the function name wasn't put into the global string to be included in the generated command. The global has been eliminated, and the menu is read directly using ControlInfo.
//		Same was done for the ODE Method menu.
//***********************************************

//***********************************************
// Possible enhancements:
//
//	Checkbox to include/exclude XOP functions in Derivative Function menu (DerivFuncMenu)
//	Option to include only specially-named functions (ODE_xxx?)
//	Coefficient wave New option
//***********************************************

Menu "Analysis"
	"Integrate ODE",/Q, fODE_Panel()
	"Unload ODE Panel Package", /Q, fUnloadODEPanel()
end 

Function fODE_Panel()

	if (WinType("IntegrateODEPanel") == 0)
		ODEPanelModule#InitODEPanel()
		ODEPanelModule#fIntegrateODEPanel()
	else
		DoWindow/F IntegrateODEPanel
	endif

end

Function fUnloadODEPanel()

	if (WinType("IntegrateODEPanel") == 7)
		KillWindow IntegrateODEPanel
	endif
	Execute/P "DELETEINCLUDE <ODE Panel>"
	Execute/P "COMPILEPROCEDURES "
end

static Function InitODEPanel()

	String SaveDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_ODEPanel
	
	if ( !Exists("ODE_CoefWave") )
		String/G ODE_CoefWave=""
	endif
	if ( !Exists("ODE_ErrConstWave") )
		String/G ODE_ErrConstWave="_None_"
	endif
	if ( !Exists("ODE_XWaveName") )
		String/G ODE_XWaveName=""
	endif
	
	if ( !Exists("ODE_ResultsWaveList") )	
		String/G ODE_ResultsWaveList=""
	endif
	if ( !Exists("ODE_YWaveListWave") )
		Make/N=0/T ODE_YWaveListWave
	endif
	if ( !Exists("ODE_ResultsWaveListProposed") )
		String/G ODE_ResultsWaveListProposed=""
	endif
	if ( !Exists("ODE_ResultsWaveBaseName") )
		String/G ODE_ResultsWaveBaseName="ODEResults"
	endif

	if ( !Exists("ODE_Command") )
		String/G ODE_Command="IntegrateODE "
	endif
	
	if ( !Exists("ODE_NumEqs") )
		Variable/G ODE_NumEqs
	endif
	if ( !Exists("ODE_Error") )
		Variable/G ODE_Error=1e-6
	endif
	if ( !Exists("ODE_YErrChecked") )
		Variable/G ODE_YErrChecked=0
	endif
	if ( !Exists("ODE_dYErrChecked") )
		Variable/G ODE_dYErrChecked=0
	endif
	if ( !Exists("ODE_ConstErrChecked") )
		Variable/G ODE_ConstErrChecked=0
	endif

	if ( !Exists("ODE_StartP") )
		Variable/G ODE_StartP=0
	endif
	if ( !Exists("ODE_EndP") )
		Variable/G ODE_EndP=INF
	endif

	if ( !Exists("ODE_XValueMethod") )
		Variable/G ODE_XValueMethod=1
	endif
	if ( !Exists("ODE_X0") )
		Variable/G ODE_X0=0
	endif
	if ( !Exists("ODE_DeltaX") )
		Variable/G ODE_DeltaX=1
	endif
		
	if ( !Exists("ODE_ResultsMultiCol") )
		Variable/G ODE_ResultsMultiCol=0
	endif
	if ( !Exists("ODE_ResultsFromTarg") )
		Variable/G ODE_ResultsFromTarg=0
	endif
	if ( !Exists("ODE_MakeResultsNPnts") )
		Variable/G ODE_MakeResultsNPnts=100
	endif
	if ( !Exists("ODE_UpdateRate") )
		Variable/G ODE_UpdateRate=0
	endif

	SetDataFolder $SaveDF
end

static Function fIntegrateODEPanel() : Panel

	NVAR ODE_XValueMethod=root:Packages:WM_ODEPanel:ODE_XValueMethod
	NVAR ODE_YErrChecked=root:Packages:WM_ODEPanel:ODE_YErrChecked
	NVAR ODE_dYErrChecked=root:Packages:WM_ODEPanel:ODE_dYErrChecked
	NVAR ODE_ConstErrChecked=root:Packages:WM_ODEPanel:ODE_ConstErrChecked


	NewPanel /K=1 /W=(166,166,815,673) as "Integrate ODE"
	DoWindow/C IntegrateODEPanel
	
	GroupBox ODEInfoBox,pos={13,6},size={310,285},title="ODE Information",fSize=12
	GroupBox ODEInfoBox,fStyle=1

		TitleBox ODEPanel_DerivFuncTitle,pos={31,33},size={115,16},title="Derivative Function:"
		TitleBox ODEPanel_DerivFuncTitle,fSize=12,frame=0
	
		PopupMenu DerivFuncMenu,pos={52,53},size={130,20},proc=ODEPanelModule#ODEFuncMenuProc
		PopupMenu DerivFuncMenu,mode=1,bodyWidth= 130,value= #"FunctionList(\"*\", \";\", \"NPARAMS:4,KIND:6,VALTYPE:1\")"
	
		TitleBox ODEPanel_SystemOrderTitle,pos={32,87},size={224,16},title="System Order (How Many Equations?):"
		TitleBox ODEPanel_SystemOrderTitle,fSize=12,frame=0

		SetVariable SetNumEqs,pos={53,106},size={50,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title=" ",fSize=12
		SetVariable SetNumEqs,limits={1,inf,1},value= root:Packages:WM_ODEPanel:ODE_NumEqs,bodyWidth= 50

		Button ODEWavesButton,pos={34,141},size={130,20},proc=ODEPanelModule#ODEWavesButtonProc,title="Result Waves...",fSize=12
	
		ListBox ODEPanel_YWaveListbox,pos={52,166},size={231,62},listWave=root:Packages:WM_ODEPanel:ODE_YWaveListWave
	
		TitleBox ODEPanel_CoefWaveTitle,pos={32,239},size={102,16},title="Coefficient Wave:"
		TitleBox ODEPanel_CoefWaveTitle,fSize=12,frame=0
	
		SVAR ODE_CoefWave = root:Packages:WM_ODEPanel:ODE_CoefWave
		Button ODESetCoefWave,pos={52,257},size={135,20},title=" ",fsize=12
		MakeButtonIntoWSPopupButton("IntegrateODEPanel", "ODESetCoefWave", "ODESelectCoefWaveNotify", initialSelection=ODE_CoefWave)	
	
		Button EditCoefWave,pos={208,260},size={40,16},proc=ODEPanelModule#ODEEditCoefWaveButtonProc,title="Edit...",fSize=9
		
	GroupBox ODEPanel_InitialConditionsGroup,pos={13,299},size={310,131},title="Start/Stop",fSize=12,fStyle=1

		SetVariable SetICPointNum,pos={28,322},size={234,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title=" Row with Initial Conditions:",fSize=12
		SetVariable SetICPointNum,limits={0,inf,1},value= root:Packages:WM_ODEPanel:ODE_StartP,bodyWidth= 70
	
		SetVariable SetLastPointNum,pos={28,352},size={176,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title=" Last Solution Point:",fSize=12
		SetVariable SetLastPointNum,limits={1,inf,1},value= root:Packages:WM_ODEPanel:ODE_EndP,bodyWidth= 55
	
		Button ODERangeFromCursorsButton,pos={220,352},size={70,20},proc=ODEPanelModule#ODESetRangeFromCursorsProc,title="Cursors"
		Button ODERangeFromCursorsButton,fSize=9

		Button SetInitCondButton,pos={33,393},size={170,20},proc=ODEPanelModule#ODESetInitCondButtonProc,title="Set Initial Conditions...",fSize=12
	
	GroupBox ODESolutionBox,pos={330,6},size={300,126},title="Solution Control",fSize=12,fStyle=1
	
		TitleBox ODEPanel_SolutionMethodTitle,pos={350,32},size={98,16},title="Solution Method:",fSize=12,frame=0
	
		PopupMenu ODEMethodMenu,pos={368,51},size={170,20},proc=ODEPanelModule#ODESolutionMethodMenuProc,fSize=12
		PopupMenu ODEMethodMenu,mode=1,bodyWidth= 170,value= #"\"Runge-Kutta;Bulirsch-Stoers;Adams-Moulton;BDF (for stiff systems);\""

		TitleBox ODEPanel_UpdateDisplayTitle,pos={350,86},size={122,16},title="Update Display Every",fSize=12,frame=0

		SetVariable ODESetUpdateRate,pos={367,105},size={100,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title=" ",fSize=12
		SetVariable ODESetUpdateRate,limits={0,inf,1},value= root:Packages:WM_ODEPanel:ODE_UpdateRate,bodyWidth= 100

		TitleBox ODEPanel_SolutionPointsTitle,pos={468,106},size={85,16},title="solution points",fSize=12,frame=0

	GroupBox ODEErrorControlBox,pos={330,139},size={300,152},title="Error Control",fSize=12,fStyle=1

		TitleBox ODEPanel_ErrorIncludeTitle,pos={348,160},size={102,16},title="Include in Scaling:",fSize=12,frame=0
	
		CheckBox ODE_Err_Const_check,pos={367,183},size={52,15},proc=ODEPanelModule#ODEErrCheckboxesProc,title="Const"
		CheckBox ODE_Err_Const_check,fSize=12,value= ODE_ConstErrChecked
	
		SVAR ODE_ErrConstWave = root:Packages:WM_ODEPanel:ODE_ErrConstWave
		Button ODEPanel_SelectErrWave,pos={425,180},size={135,20},fSize=12
		MakeButtonIntoWSPopupButton("IntegrateODEPanel", "ODEPanel_SelectErrWave", "ODESelectErrWaveNotify", initialSelection=ODE_ErrConstWave)
		PopupWS_AddSelectableString("IntegrateODEPanel", "ODEPanel_SelectErrWave", "Make new wave")

		Button EditErrConstWave,pos={571,183},size={40,16},proc=ODEPanelModule#ODEEditConstErrButtonProc,title="Edit...",fSize=9

		CheckBox ODE_Err_Y_check,pos={367,207},size={26,15},proc=ODEPanelModule#ODEErrCheckboxesProc,title="Y"
		CheckBox ODE_Err_Y_check,fSize=12,value=ODE_YErrChecked
		
		CheckBox ODE_Err_DYDX_check,pos={367,231},size={53,15},proc=ODEPanelModule#ODEErrCheckboxesProc,title="dY/dx"
		CheckBox ODE_Err_DYDX_check,fSize=12,value=ODE_dYErrChecked
		
		SetVariable SetODEError,pos={348,258},size={139,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title="Error Limit:",fSize=12
		SetVariable SetODEError,limits={0,inf,0},value= root:Packages:WM_ODEPanel:ODE_Error,bodyWidth= 70
	
		CheckBox GlobalErrorCheck,pos={497,260},size={118,15},proc=ODEPanelModule#GlobalErrorCheckProc,title="Global Error Limit",fSize=12,value= 0
	
	GroupBox ODEXValuesBox,pos={330,299},size={300,131},title="X values",fSize=12,fStyle=1

		PopupMenu XValueMethodMenu,pos={348,322},size={221,20},proc=ODEPanelModule#XValueMethodMenuProc,title="X Value Method:",fSize=12
		PopupMenu XValueMethodMenu,mode=ODE_XValueMethod,bodyWidth= 123,value= "_Calculated_;From X wave;Specify Interval;Free Run;"
	
		SVAR ODE_XWaveName = root:Packages:WM_ODEPanel:ODE_XWaveName
		Button ODEPanel_SelectXWave,pos={368,351},size={135,20},proc=PopupWaveSelectorButtonProc,fSize=12
		MakeButtonIntoWSPopupButton("IntegrateODEPanel", "ODEPanel_SelectXWave", "ODESelectXWaveNotify", initialSelection=ODE_XWaveName)	
	
		SetVariable SetX0,pos={367,359},size={88,18},disable=1,proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title="X0:"
		SetVariable SetX0,fSize=12,value= root:Packages:WM_ODEPanel:ODE_X0

		SetVariable SetDeltaX,pos={464,359},size={109,18},disable=1,proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title="Delta X:"
		SetVariable SetDeltaX,fSize=12,value= root:Packages:WM_ODEPanel:ODE_DeltaX

		SetVariable ODEPanel_SetFreeRunX0,pos={368,380},size={177,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title="Initial Step Size:"
		SetVariable ODEPanel_SetFreeRunX0,fSize=12,value= _NUM:0,bodyWidth= 80

		SetVariable ODEPanel_FreeRunXMax,pos={387,406},size={158,18},proc=ODEPanelModule#ODE_SetVariableGenCommandsProc,title="Max X Value:"
		SetVariable ODEPanel_FreeRunXMax,fSize=12,value= _NUM:0,bodyWidth= 80

	GroupBox ODEPanel_CommandBox,pos={12,437},size={617,26},frame=0

	SetVariable ODE_SetCommand,pos={13,443},size={611,15},title=" ",fSize=9,frame=0, proc=ODEPanelModule#ODE_SetVariableGenCommandsProc
	SetVariable ODE_SetCommand,value= root:Packages:WM_ODEPanel:ODE_Command,noedit= 1

	Button ODEPanelDoItButton,pos={12,476},size={100,20},proc=ODEPanelModule#ODEDoItButtonProc,title="Do It"

	Button ODEPanelToCmdButton,pos={142,476},size={100,20},proc=ODEPanelModule#ODEDoItButtonProc,title="To Cmd"

	Button ODEPanel_ToClip,pos={278,476},size={100,20},title="To Clip",proc=ODEPanelModule#ODEDoItButtonProc
	
	Button ODEPanelHelpButton,pos={524,476},size={100,20},proc=ODEPanelModule#ODEPanelHelpButtonProc,title="Help"

	ODEErrCheckboxesProc("ODE_Err_Const_check", ODE_ConstErrChecked)
	XValueControls(ODE_XValueMethod)
	ODE_GenCommand()
End

static Function ODEPanelHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button ODEPanelHelpButton,title="Looking..."
	DisplayHelpTopic /K=1 "Integrate ODE Panel"
	Button ODEPanelHelpButton,title="Help"
End

static Function ODE_SetVariableGenCommandsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	ODE_GenCommand()
End

static Function GlobalErrorCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	ODE_GenCommand()
End

Function ODESelectCoefWaveNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	SVAR ODE_CoefWave = root:Packages:WM_ODEPanel:ODE_CoefWave
	ODE_CoefWave = wavepath

	ODE_GenCommand()
end

Function ODESelectErrWaveNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	SVAR ODE_ErrConstWave = root:Packages:WM_ODEPanel:ODE_ErrConstWave
	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs

	if (CmpStr(wavepath, "Make new wave") == 0)
		Make/O/N=(ODE_NumEqs) ODE_errScale=1
		Wave w = $"ODE_errScale"
		ODE_ErrConstWave = GetWavesDataFolder(w, 2)
		PopupWS_SetSelectionFullPath("IntegrateODEPanel", "ODEPanel_SelectErrWave", GetWavesDataFolder(w, 2))
	else
		ODE_ErrConstWave = wavepath
	endif

	ODE_GenCommand()
end

static Function ODESetRangeFromCursorsProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR ODE_StartP = root:Packages:WM_ODEPanel:ODE_StartP
	NVAR ODE_EndP = root:Packages:WM_ODEPanel:ODE_EndP
	
	Variable cA =  WaveExists(CsrWaveRef(A))
	Variable cB =  WaveExists(CsrWaveRef(B))
	if ( cA )
		ODE_StartP = pcsr(A)
	endif
	if ( cB )
		ODE_EndP = pcsr(B)
	endif
	if (cA %& cB)
		Variable temp=max(ODE_StartP, ODE_EndP)
		ODE_StartP = min(ODE_StartP, ODE_EndP)
		ODE_EndP = temp
	endif
	if (!( cA %| cB ) )
		doAlert 0, "There are no cursors on the top graph"
	endif
	ODE_GenCommand()
End


static Function ODEDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR ODE_Command=root:Packages:WM_ODEPanel:ODE_Command
	SVAR ODE_XWaveName=root:Packages:WM_ODEPanel:ODE_XWaveName
	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
	
	NVAR ODE_XValueMethod=root:Packages:WM_ODEPanel:ODE_XValueMethod
	
	String aYwaveName=""

	ODE_GenCommand()
	
	if (WinType("Set_Initial_Conditions"))
		ModifyTable/W=Set_Initial_Conditions entryMode=1
		LoadInitConditionsIntoYWaves()
	endif
	
	if (WinType("ODEEditCoefTable"))
		ModifyTable/W=ODEEditCoefTable entryMode=1
	endif
	
	if (WinType("EditErrScaleWave"))
		ModifyTable/W=EditErrScaleWave entryMode=1
	endif
	
	if (!CheckYWaves())
		return 0
	endif
	
	aYwaveName = StringFromList(0, ODE_ResultsWaveList)
	Wave/Z aYwave = $aYwaveName
	if (!WaveExists(aYwave))
		abort "You need to select waves to store the results. Click the Waves button at the top of the panel."
	endif
	Variable YWaveLen=DimSize(aYwave, 0)
	
	if (ODE_XValueMethod == 2)
		Wave/Z xWave = $ODE_XWaveName
		if (!WaveExists(xWave))
			abort "the X wave, "+ODE_XWaveName+", does not exist."
		endif
		if (DimSize(xWave, 0) != YWaveLen)
			abort "the length of the X wave, "+ODE_XWaveName+", does not match the results waves."
		endif
	endif
	
	if (CmpStr(ctrlName, "ODEPanel_ToClip") == 0)
		PutScrapText ODE_Command
		return 0
	endif
	if (CmpStr(ctrlName, "ODEPanelToCmdButton") == 0)
		ToCommandLine ODE_Command
		return 0
	endif
	
	Print "•" + ODE_Command
	
	Execute ODE_Command
End

static Function CheckYWaves()

	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList

	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	NVAR ODE_StartP=root:Packages:WM_ODEPanel:ODE_StartP

	Variable numYwaves=ItemsInList(ODE_ResultsWaveList)
	
	String aYwaveName = StringFromList(0, ODE_ResultsWaveList)
	Wave/Z aYwave = $aYwaveName
	if (!WaveExists(aYwave))
		abort "You need to select waves to store the results. Click the Waves button at the top of the panel."
	endif
	Variable YWaveLen=DimSize(aYwave, 0)
	
	// load initial conditions and do sanity checks on results waves
	if (numYwaves == 1)
		if ( (ODE_NumEqs == 1) %& (WaveDims(aYwave) != 1) )
			DoAlert 0, "You have set the number of ODE's to 1, but your results wave has more than one column"
			return 0
		endif
		if (ODE_NumEqs != 1)
			if (ODE_NumEqs != DimSize(aYwave,1) )
				DoAlert 0,  "You have set the number of ODE's to "+num2istr(ODE_NumEqs)+" but the results wave you selected has "+num2istr(DimSize(aYwave,1))+" columns."
				return 0
			endif
		endif
	else
		if (ODE_NumEqs != numYwaves)
			DoAlert 0,  "You have set the number of ODE's to "+num2istr(ODE_NumEqs)+" but there are "+num2istr(numYwaves)+" waves in the the results wave list. Click the Waves button at the top of the panel and select a new list of waves."
			return 0
		else
			Variable i = 0
			do
				aYwaveName = StringFromList(i, ODE_ResultsWaveList)
				Wave/Z aYwave = $aYwaveName
				if (!WaveExists(aYwave))
					DoAlert 0,  "One of your results waves, "+aYwaveName+", does not exist."
					return 0
				endif
				if (DimSize(aYwave, 0) != YWaveLen)
					DoAlert 0,  "One of your results waves, "+aYwaveName+", has mismatched length."
					return 0
				endif
				i += 1
			while(i < numYwaves)
		endif
	endif
	
	return 1
end

static Function LoadInitConditionsIntoYWaves()

	Wave InitY=root:Packages:WM_ODEPanel:InitY
	
	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	NVAR ODE_StartP=root:Packages:WM_ODEPanel:ODE_StartP

	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
	
	Variable numYwaves=ItemsInList(ODE_ResultsWaveList)
	
	String aYwaveName = StringFromList(0, ODE_ResultsWaveList)
	Wave aYwave = $aYwaveName
	if (numYwaves == 1)
		if (ODE_NumEqs == 1)
			aYwave[ODE_StartP] = InitY
		else
			aYwave[ODE_StartP][] = InitY[q]
		endif
	else
		Variable i = 0
		do
			aYwaveName = StringFromList(i, ODE_ResultsWaveList)
			Wave aYwave = $aYwaveName
			aYwave[ODE_StartP] = InitY[i]
			i += 1
		while(i < numYwaves)
	endif
end

static Function GetInitConditionsFromYWaves()

	Wave InitY=root:Packages:WM_ODEPanel:InitY

	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	NVAR ODE_StartP=root:Packages:WM_ODEPanel:ODE_StartP

	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
	
	Variable numYwaves=ItemsInList(ODE_ResultsWaveList)
	
	String aYwaveName = StringFromList(0, ODE_ResultsWaveList)
	Wave aYwave = $aYwaveName
	if (numYwaves == 1)
		if (ODE_NumEqs == 1)
			InitY = aYwave[ODE_StartP]
		else
			InitY = aYwave[ODE_StartP][p]
		endif
	else
		Variable i = 0
		do
			aYwaveName = StringFromList(i, ODE_ResultsWaveList)
			Wave aYwave = $aYwaveName
			InitY[i] = aYwave[ODE_StartP]
			i += 1
		while(i < numYwaves)
	endif
end

static Function/S ODE_GenCommand()

	SVAR ODE_Command=root:Packages:WM_ODEPanel:ODE_Command
	SVAR ODE_XWaveName=root:Packages:WM_ODEPanel:ODE_XWaveName
	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
	SVAR ODE_ErrConstWave=root:Packages:WM_ODEPanel:ODE_ErrConstWave
	SVAR ODE_CoefWave=root:Packages:WM_ODEPanel:ODE_CoefWave

	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	NVAR ODE_XValueMethod=root:Packages:WM_ODEPanel:ODE_XValueMethod
	NVAR ODE_X0=root:Packages:WM_ODEPanel:ODE_X0
	NVAR ODE_DeltaX=root:Packages:WM_ODEPanel:ODE_DeltaX
	NVAR ODE_StartP=root:Packages:WM_ODEPanel:ODE_StartP
	NVAR ODE_EndP=root:Packages:WM_ODEPanel:ODE_EndP
	NVAR ODE_UpdateRate=root:Packages:WM_ODEPanel:ODE_UpdateRate

	NVAR ODE_Error=root:Packages:WM_ODEPanel:ODE_Error
	NVAR ODE_YErrChecked=root:Packages:WM_ODEPanel:ODE_YErrChecked
	NVAR ODE_dYErrChecked=root:Packages:WM_ODEPanel:ODE_dYErrChecked
	NVAR ODE_ConstErrChecked=root:Packages:WM_ODEPanel:ODE_ConstErrChecked
	
	ControlInfo/W=IntegrateODEPanel ODEPanel_FreeRunXMax
	Variable freeRunXMax = V_value
	
	ControlInfo/W=IntegrateODEPanel ODEPanel_SetFreeRunX0
	Variable freeRunX0 = V_value
	
	String OneYWaveName = StringFromList(0, ODE_ResultsWaveList)
	Wave/Z OneYWave = $OneYWaveName
	if (!WaveExists(OneYWave))
		return "*** NO Y WAVES ***"
	endif
	Variable YPoints = DimSize(OneYWave,0)

	ODE_Command = "IntegrateODE "
	
	ControlInfo/W=IntegrateODEPanel ODEMethodMenu
	Variable ODE_Method = V_value-1
	ODE_Command += "/M="+num2istr(ODE_Method)+" "
	
	switch (ODE_XValueMethod)
		case 1:						// Calculated: nothing to do here
			break;
		case 2:						// X values from X wave
			if (!Exists(ODE_XWaveName))
				return "*** X WAVE DOES NOT EXIST ***"
			endif
			ODE_Command += "/X="+ODE_XWaveName+" "
			break;
		case 3:						// specify x0 and deltaX
			ODE_Command += "/X={"+num2str(ODE_X0)+","+num2str(ODE_DeltaX)+"} "
			break;
		case 4:						// free-run mode
			if (!Exists(ODE_XWaveName))
				return "*** X WAVE DOES NOT EXIST ***"
			endif
			ODE_Command += "/X="+ODE_XWaveName+" "
			ODE_Command += "/XRUN={"+num2str(freeRunX0)+","+num2str(freeRunXMax)+"}"
			break;
	endswitch
	
	if ( (ODE_StartP != 0) %| ((numtype(ODE_EndP) == 0) %& (ODE_EndP < YPoints-1)) )
		ODE_Command += "/R=["
		if (ODE_StartP != 0)
			ODE_Command += num2istr(ODE_StartP)
		endif
		ODE_Command += ","
		if ((numtype(ODE_EndP) == 0) %& (ODE_EndP < YPoints-1))
			ODE_Command += num2istr(ODE_EndP)
		endif
		ODE_Command += "] "
	endif
	
	ODE_Command += "/E="+num2str(ODE_Error)+" "
	Variable errMethod = ODE_ConstErrChecked + 2*ODE_YErrChecked + 4*ODE_dYErrChecked
	ControlInfo/W=IntegrateODEPanel GlobalErrorCheck
	errMethod += 8*V_value
	if (errMethod > 0)
		ODE_Command += "/F="+num2istr(errMethod)
	endif
	
	if ( ODE_ConstErrChecked %& (CmpStr(ODE_ErrConstWave, "_None_") != 0) )
		if (!Exists(ODE_ErrConstWave))
			return "*** The Error Wave does not exist ***"
		endif
		ODE_Command += "/S="+ODE_ErrConstWave+" "
	endif
	
	if (ODE_UpdateRate != 0)
		ODE_Command += "/U="+num2istr(ODE_UpdateRate)+" "
	endif
	
	ControlInfo/W=IntegrateODEPanel DerivFuncMenu
	String ODE_Func = S_value
	ODE_Command += ODE_Func+", "	
	ODE_Command += ODE_CoefWave+","
	
	String YSpec=""
	String comma=""
	Variable i=0
	do
		OneYWaveName = StringFromList(i, ODE_ResultsWaveList)
		if (strlen(OneYWaveName) == 0)
			break
		endif
		if (!Exists(OneYWaveName))
			return "*** The wave "+OneYWaveName+" does not exist. ***"
		endif
		YSpec += comma+OneYWaveName
		comma = ","
		i += 1
	while(1)
	if (i > 1)
		YSpec = "{"+YSpec+"}"
	endif
	ODE_Command += YSpec
	
	return ODE_Command
end



static Function ODESolutionMethodMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ODE_GenCommand()
End

static Function ODEFuncMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ODE_GenCommand()
End

static Function ODESetInitCondButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs

	if (CheckYWaves())
		Make/N=(ODE_NumEqs)/O/D root:Packages:WM_ODEPanel:InitY
		Wave InitY=root:Packages:WM_ODEPanel:InitY
		Make/N=(ODE_NumEqs)/O/T root:Packages:WM_ODEPanel:InitYLabels
		Wave/T InitYLabels=root:Packages:WM_ODEPanel:InitYLabels
		
		GetInitConditionsFromYWaves()
		
		if (WinType("Set_Initial_Conditions") != 0)
			DoWindow/K Set_Initial_Conditions
		endif
	
		Variable i=0
		do
			InitYLabels[i] = "Equation "+num2istr(i)
			i += 1
		while (i<ODE_NumEqs)
		
		ODESet_Initial_Conditions_Panel()
	endif
End

static Function ODESet_Initial_Conditions_Panel()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:WM_ODEPanel:
	NVAR/Z ICTableLeft
	NVAR/Z ICTableTop
	NVAR/Z ICTableRight
	NVAR/Z ICTableBottom
	Variable left=30, top=30, right=231, bottom=126
	if (NVAR_Exists(ICTableLeft))
		left = ICTableLeft
		top = ICTableTop
		right = ICTableRight
		bottom = ICTableBottom
	endif
	Edit/K=1/W=(left, top, right, bottom)  InitYLabels,InitY
	RenameWindow $S_name, Set_Initial_Conditions
	ModifyTable format(Point)=1,width(Point)=0,title(InitYLabels)=" ",width(InitY)=84
	ModifyTable title(InitY)="Initial value",alignment(InitYLabels)=1
	SetDataFolder fldrSav0
	
	SetWindow Set_Initial_Conditions,hook(killhook)=SetICTableKillHook
EndMacro

Function SetICTableKillHook(s)
	STRUCT WMWinHookStruct &s
	
	if (CmpStr(s.eventName, "kill") == 0)
		ModifyTable/W=Set_Initial_Conditions entryMode=1
		String fldrSav0= GetDataFolder(1)
		SetDataFolder root:Packages:WM_ODEPanel:
		GetWindow  $s.winName, wsize
		Variable/G ICTableLeft=V_left
		Variable/G ICTableTop=V_top
		Variable/G ICTableRight=V_right
		Variable/G ICTableBottom=V_bottom
		SetDataFolder fldrSav0
		LoadInitConditionsIntoYWaves()
	endif
	
	return 0
end

static Function ODEErrCheckboxesProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR ODE_ConstErrChecked=root:Packages:WM_ODEPanel:ODE_ConstErrChecked
	NVAR ODE_YErrChecked=root:Packages:WM_ODEPanel:ODE_YErrChecked
	NVAR ODE_dYErrChecked=root:Packages:WM_ODEPanel:ODE_dYErrChecked

	strswitch(ctrlName)
		case "ODE_Err_Const_check":
			ShowHideConstErrControls(checked)
			ODE_ConstErrChecked = checked
			break;
		case "ODE_Err_DYDX_check":
			ODE_dYErrChecked = checked
			break;
		case "ODE_Err_Y_check":
			ODE_YErrChecked = checked
			break;
	endswitch
	ODE_GenCommand()
End

static Function ShowHideConstErrControls(showThem)
	Variable showThem
	
	ModifyControlList "ODEPanel_SelectErrWave;EditErrConstWave;",disable=showThem==0
end

static Function ODEEditConstErrButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR ODE_ErrConstWave=root:Packages:WM_ODEPanel:ODE_ErrConstWave

	Wave/Z w=$ODE_ErrConstWave
	if (WaveExists(w))
		if (WinType("EditErrScaleWave"))
			DoWindow/K EditErrScaleWave
		endif
		
		String saveDF = GetDataFolder(1)
		SetDataFolder root:Packages:WM_ODEPanel:
		NVAR/Z ErrorScaleTableLeft
		NVAR/Z ErrorScaleTableTop
		NVAR/Z ErrorScaleTableRight
		NVAR/Z ErrorScaleTableBottom
		Variable left, top, right, bottom
		left = 30;top=30;right=244;bottom=230
		if (NVAR_Exists(ErrorScaleTableLeft))
			left = ErrorScaleTableLeft;top=ErrorScaleTableTop;right=ErrorScaleTableRight;bottom=ErrorScaleTableBottom
		endif	
		Edit/K=1/W=(left, top, right, bottom) w as "Edit error scaling wave"
		DoWindow/C EditErrScaleWave
		SetWindow EditErrScaleWave,hook(killhook)=EditErrorScaleHook
	else
		if (CmpStr(ODE_ErrConstWave, "_None_") == 0)
			DoAlert 0, "You have selected '_None_' as the error scaling wave, so you can't edit the wave."
		else
			DoAlert 0, "The wave name in the box below, "+ODE_ErrConstWave+", does not exist; it may have been killed or renamed."
		endif
	endif
End

Function EditErrorScaleHook(s)
	STRUCT WMWinHookStruct &s
	
	if (CmpStr(s.eventName, "kill") == 0)
		ModifyTable/W=EditErrScaleWave entryMode=1
		String fldrSav0= GetDataFolder(1)
		SetDataFolder root:Packages:WM_ODEPanel:
		GetWindow  $s.winName, wsize
		Variable/G ErrorScaleTableLeft=V_left
		Variable/G ErrorScaleTableTop=V_top
		Variable/G ErrorScaleTableRight=V_right
		Variable/G ErrorScaleTableBottom=V_bottom
		SetDataFolder fldrSav0
	endif
	
	return 0
end

static Function ODEEditCoefWaveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR ODE_CoefWave=root:Packages:WM_ODEPanel:ODE_CoefWave
	Wave/Z w=$ODE_CoefWave
	if (WaveExists(w))
		if (WinType("ODEEditCoefTable"))
			DoWindow/K ODEEditCoefTable
		endif
		MakeCoefTable()
	endif
End

static Function MakeCoefTable()

	String saveDF = GetDataFolder(1)
	SetDataFolder root:Packages:WM_ODEPanel:
	SVAR ODE_CoefWave=root:Packages:WM_ODEPanel:ODE_CoefWave
	Wave/Z w=$ODE_CoefWave
	NVAR/Z CoefTableLeft
	NVAR/Z CoefTableTop
	NVAR/Z CoefTableRight
	NVAR/Z CoefTableBottom
	Variable left, top, right, bottom
	left = 30;top=30;right=244;bottom=230
	if (NVAR_Exists(CoefTableLeft))
		left = CoefTableLeft;top=CoefTableTop;right=CoefTableRight;bottom=CoefTableBottom
	endif	
	Edit/K=1/W=(left, top, right, bottom) w as "Edit ODE parameters"
	DoWindow/C ODEEditCoefTable
	SetWindow ODEEditCoefTable,hook(killhook)=EditCoefsHook
end

Function EditCoefsHook(s)
	STRUCT WMWinHookStruct &s
	
	if (CmpStr(s.eventName, "kill") == 0)
		ModifyTable/W=ODEEditCoefTable entryMode=1
		String fldrSav0= GetDataFolder(1)
		SetDataFolder root:Packages:WM_ODEPanel:
		GetWindow  $s.winName, wsize
		Variable/G CoefTableLeft=V_left
		Variable/G CoefTableTop=V_top
		Variable/G CoefTableRight=V_right
		Variable/G CoefTableBottom=V_bottom
		SetDataFolder fldrSav0
	endif
	
	return 0
end

static Function XValueMethodMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR ODE_XValueMethod=root:Packages:WM_ODEPanel:ODE_XValueMethod

	XValueControls(popNum)
	ODE_XValueMethod = popnum
	ODE_GenCommand()
End

static Function XValueControls(method)
	Variable method		// 1=_Calculated_, 2=from X wave, 3= specify x0, deltaX
	
	switch(method)
		case 1:
			ShowHideXWaveControls(0)
			ShowHideXSpecControls(0)
			ShowHideFreeRunXControls(0)
			break;
		case 2:
			ShowHideXSpecControls(0)
			ShowHideXWaveControls(1)
			ShowHideFreeRunXControls(0)
			break;
		case 3:
			ShowHideXSpecControls(1)
			ShowHideXWaveControls(0)
			ShowHideFreeRunXControls(0)
			break;
		case 4:
			ShowHideXWaveControls(1)
			ShowHideXSpecControls(0)
			ShowHideFreeRunXControls(1)
			break;
	endswitch
end

static Function ShowHideXWaveControls(showThem)
	Variable showThem
	
	ModifyControl ODEPanel_SelectXWave,disable=showThem==0
end

static Function ShowHideFreeRunXControls(showThem)
	Variable showThem
	
	ModifyControlList "ODEPanel_SetFreeRunX0;ODEPanel_FreeRunXMax;",disable=showThem==0
end

Function ODESelectXWaveNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	SVAR ODE_XWaveName = root:Packages:WM_ODEPanel:ODE_XWaveName
	ODE_XWaveName = wavepath

	ODE_GenCommand()
end

static Function ShowHideXSpecControls(showThem)
	Variable showThem
	
	ModifyControlList "SetX0;SetDeltaX;", disable=showThem==0
end

static Function ODEWavesButtonProc(ctrlName) : ButtonControl 
	String ctrlName

	if (WinType("ODEWavesPanel"))
		DoWindow/F ODEWavesPanel
	else
		fODEWavesPanel()
	endif
End

static Function fODEWavesPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(195,350,686,774) as "Select ODE Results Waves"
	RenameWindow $S_name, ODEWavesPanel
	
	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	String/G root:Packages:WM_ODEPanel:ODESelect_InfoTitleStr
	SVAR infoStr = root:Packages:WM_ODEPanel:ODESelect_InfoTitleStr
	infoStr = "Your system is of order "+num2str(ODE_NumEqs)+"."
	infoStr += " You need to select "+num2str(ODE_NumEqs)+"\r1D waves,"
	infoStr += " or one matrix wave with "+num2str(ODE_NumEqs)+" columns."
	Make/T/N=0/O root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Make/N=0/O root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	NVAR ODE_ResultsMultiCol = root:Packages:WM_ODEPanel:ODE_ResultsMultiCol
	
	SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
	SVAR ODE_ResultsWaveListProposed=root:Packages:WM_ODEPanel:ODE_ResultsWaveListProposed
	ODE_ResultsWaveListProposed = ODE_ResultsWaveList

	NVAR ODE_ResultsMultiCol=root:Packages:WM_ODEPanel:ODE_ResultsMultiCol
	NVAR ODE_ResultsFromTarg=root:Packages:WM_ODEPanel:ODE_ResultsFromTarg

	TitleBox ODESelectWavesInfoTitle,pos={13,8},size={348,40},fSize=12
	TitleBox ODESelectWavesInfoTitle,variable= root:Packages:WM_ODEPanel:ODESelect_InfoTitleStr

//	Button ODEResultsMakeWavesButton,pos={332,17},size={124,20},proc=ODEPanelModule#ODEResultsMakeWavesButtonProc,title="Create Waves..."

	ListBox ODESelectWavesList,pos={14,60},size={170,177}
	MakeListIntoWaveSelector("ODEWavesPanel", "ODESelectWavesList", selectionMode=WMWS_SelectionNonContiguous, listoptions="DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")	
	
	ListBox ODESelectedWaveList,pos={283,60},size={191,90}
	ListBox ODESelectedWaveList,listWave=root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	ListBox ODESelectedWaveList,selWave=root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave,mode=9
	Variable nItems = ItemsInList(ODE_ResultsWaveList)
	if (nItems > 0)
		Redimension/N=0 ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
		Variable i
		ODE_ResultsMultiCol = 0
		for (i = 0; i < nItems; i += 1)
			String oneItem = StringFromList(i, ODE_ResultsWaveList)
			Wave/Z w = $oneItem
			if (!WaveExists(w))
				continue
			endif
			if (WaveDims(w) == 2)
				if (DimSize(w, 1) == ODE_NumEQs)
					if (i == 0)
						Redimension/N=(1) ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
						ODESelect_SelectedWavesListWave[0] = oneItem
						ODE_ResultsMultiCol = 1
						break;			// just need one correctly dimensioned multi-column wave
					endif
				endif
			elseif (WaveDims(w) == 1)
				Variable row = DimSize(ODESelect_SelectedWavesListWave, 0)
				InsertPoints row, 1, ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
				ODESelect_SelectedWavesListWave[i] = oneItem
				if (i == ODE_NumEQs-1)
					break;				// got enough waves
				endif
			endif
		endfor
		ODESelect_SelectedWavesSelWave = 0
	endif

	Button ODESelectWavesSelectButton,pos={193,95},size={80,20},proc=ODESelectWavesSelectButtonProc,title="Select->"

	PopupMenu ODESelect_MulticolumnOrNotMenu,pos={321,18},size={133,20},proc=ODESelect_MulticolumnMenuProc
	PopupMenu ODESelect_MulticolumnOrNotMenu,value= #"\"Multiple 1D Waves;One Multicolumn Wave;\""
	PopupMenu ODESelect_MulticolumnOrNotMenu,mode=(ODE_ResultsMultiCol ? 2 : 1)
	if (ODE_ResultsMultiCol)
		RebuildSelectResultsList(ODE_ResultsMultiCol, ODE_NumEQs)
	endif

	Button ODESelectWavesUpArrow,pos={284,163},size={190,20},proc=ODESelectArrowButtonProc,title="Move Selection UP \\W506"

	Button ODESelectWavesDownArrow,pos={284,188},size={190,20},proc=ODESelectArrowButtonProc,title="Move Selection DOWN \\W522"

	Button ODESelectWavesDelete,pos={284,212},size={190,20},proc=ODESelect_DeleteButtonProc,title="Delete Selection"

	GroupBox ODESelect_CreateNewBox,pos={14,250},size={460,135},title="Create New Waves"
	GroupBox ODESelect_CreateNewBox,fSize=12,fStyle=1

		SetVariable ODESelect_SetNewWaveBaseName,pos={82,278},size={324,18},title=" Base Name for New Waves",fSize=12
		SetVariable ODESelect_SetNewWaveBaseName,value= root:Packages:WM_ODEPanel:ODE_ResultsWaveBaseName,bodyWidth= 160
	
		SetVariable ODESelect_NewWaveRows,pos={54,303},size={108,18},title="Rows:",fSize=12
		SetVariable ODESelect_NewWaveRows,value= root:Packages:WM_ODEPanel:ODE_MakeResultsNPnts,bodyWidth= 70

		Button ODESelect_NewWavesDFButton,pos={280,302},size={150,20},title="xxx",fSize=12
		String initSelection = GetDataFolder(1)
		Variable len = strlen(initSelection)
		if (CmpStr(initSelection[len-1,len-1], ":") == 0)
			initSelection = initSelection[0,len-2]
		endif
		MakeButtonIntoWSPopupButton("ODEWavesPanel", "ODESelect_NewWavesDFButton", "", initialSelection=initSelection, content=WMWS_DataFolders)

		TitleBox ODESelect_NewWavesInDFTitle,pos={189,304},size={84,16},title="In Data Folder:"
		TitleBox ODESelect_NewWavesInDFTitle,fSize=12,frame=0

		SetVariable ODESelect_NewWaveX0,pos={224,329},size={100,18},title="X0",fSize=12
		SetVariable ODESelect_NewWaveX0,value= _NUM:0,bodyWidth= 80

		SetVariable ODESelect_NewWaveDeltaX,pos={332,329},size={126,18},title="Delta X"
		SetVariable ODESelect_NewWaveDeltaX,fSize=12,value= _NUM:1,bodyWidth= 80

		TitleBox ODESelect_NewWaveScalingTitle,pos={26,330},size={189,16},title="X Scale (Solution Point Spacing):"
		TitleBox ODESelect_NewWaveScalingTitle,fSize=12,frame=0

		Button ODESelect_MakeNewWavesButton,pos={181,357},size={130,20},title="Make Them Now",fSize=12,proc=ODEPanelModule#ODEMakeResultsWavesOKButtonProc

	Button ODESelect_OKButton,pos={14,393},size={50,20},proc=ODESelect_OKButtonProc,title="OK"

	Button ODESelect_CancelButton,pos={401,393},size={70,20},proc=ODESelect_CancelButtonProc,title="Cancel"

	Button ODESelect_HelpButton,pos={294,393},size={70,20},proc=ODEPanelModule#ODEResultsWavesHelpProc,title="Help"
EndMacro

static Function RebuildSelectResultsList(doMultiColumn, numEQs)
	Variable doMultiColumn, numEQs

	ControlInfo/W=ODEWavesPanel ODESelectWavesList
	KillControl/W=ODEWavesPanel ODESelectWavesList
	ListBox ODESelectWavesList,win=ODEWavesPanel,pos={V_left, V_top},size={V_width, V_height}
	
	String listOptions = "DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0"
	if (doMultiColumn)
		listOptions = "DIMS:2,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0,MINCOLS:"+num2istr(numEQs)+",MAXCOLS:"+num2istr(numEQs)
	endif
	MakeListIntoWaveSelector("ODEWavesPanel", "ODESelectWavesList", selectionMode=WMWS_SelectionNonContiguous, listoptions=listOptions)	
end

static Function ODEResultsWavesHelpProc(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayHelpTopic "Integrate ODE Panel[Results Waves]"
end

static Function ODEMakeResultsWavesOKButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR ODE_ResultsWaveListProposed=root:Packages:WM_ODEPanel:ODE_ResultsWaveListProposed
	SVAR ODE_ResultsWaveBaseName = root:Packages:WM_ODEPanel:ODE_ResultsWaveBaseName
	
	NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
	NVAR ODE_MakeResultsNPnts=root:Packages:WM_ODEPanel:ODE_MakeResultsNPnts
	NVAR ODE_ResultsMultiCol = root:Packages:WM_ODEPanel:ODE_ResultsMultiCol
	
	Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	
	ControlInfo/W=ODEWavesPanel ODESelect_NewWaveX0
	Variable x0=V_value
	ControlInfo/W=ODEWavesPanel ODESelect_NewWaveDeltaX
	Variable delta_x=V_value

	String saveDF = GetDataFolder(1)
	String theDF = PopupWS_GetSelectionFullPath("ODEWavesPanel", "ODESelect_NewWavesDFButton")
	SetDataFolder theDF+":"
	if (ODE_ResultsMultiCol)
		Make/O/N=(ODE_MakeResultsNPnts, ODE_NumEqs) $ODE_ResultsWaveBaseName
		Wave w=$ODE_ResultsWaveBaseName
		SetScale/P x x0, delta_x, w
		ODE_ResultsWaveListProposed = GetWavesDataFolder(w, 2)+";"
		
		Redimension/N=1 ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
		ODESelect_SelectedWavesListWave[0] = GetWavesDataFolder(w, 2)
	else
		Variable i=0
		String aName=""
		Redimension/N=(ODE_NumEqs) ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
		for (i = 0; i < ODE_NumEqs; i += 1)
			aName = ODE_ResultsWaveBaseName+"_"+num2istr(i)
			Make/O/N=(ODE_MakeResultsNPnts) $aName
			Wave w = $aName
			SetScale/P x x0, delta_x, w
			ODESelect_SelectedWavesListWave[i] = GetWavesDataFolder(w, 2)
		endfor
	endif
	SetDataFolder saveDF
	
	RebuildSelectResultsList(ODE_ResultsMultiCol, ODE_NumEqs)
	Button ODESelectWavesSelectButton, win=ODEWavesPanel,disable=2
end

static Function ODEDeleteSelectedResultsWaves()

	Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	Variable nRows = DimSize(ODESelect_SelectedWavesListWave, 0)
	Variable i
	for (i = nRows-1; i >= 0; i -= 1)
		if (ODESelect_SelectedWavesSelWave[i] & 9)
			DeletePoints i, 1, ODESelect_SelectedWavesListWave
		endif				
	endfor
	Redimension/N=(DimSize(ODESelect_SelectedWavesListWave, 0)) ODESelect_SelectedWavesSelWave
	ODESelect_SelectedWavesSelWave = 0
end	

static Function/S ODEListSelectedResultsWaves()

	Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	Variable nRows = DimSize(ODESelect_SelectedWavesListWave, 0)
	Variable i
	String theList = ""
	for (i = 0; i < nRows; i += 1)
		if (ODESelect_SelectedWavesSelWave[i] & 9)
			theList += ODESelect_SelectedWavesListWave[i]+";"
		endif				
	endfor
	
	return theList
end

static Function ODEfirstSelectedResultsWaveRow()

	Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
	Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
	Variable nRows = DimSize(ODESelect_SelectedWavesListWave, 0)
	Variable i
	String theList = ""
	for (i = 0; i < nRows; i += 1)
		if (ODESelect_SelectedWavesSelWave[i] & 9)
			return i
		endif				
	endfor
	
	return -1
end

Function ODESelect_DeleteButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ODEDeleteSelectedResultsWaves()
			Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
			NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
			if (DimSize(ODESelect_SelectedWavesListWave, 0) < ODE_NumEQs)
				button ODESelectWavesSelectButton, win=$ba.win,disable=0
			endif
			break
	endswitch

	return 0
End

Function ODESelectArrowButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
			Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave

			Variable rowIncrement = 1
			if (CmpStr(ba.ctrlName, "ODESelectWavesUpArrow") == 0)
				rowIncrement = -1
			endif
			String selections = ODEListSelectedResultsWaves()
			Variable row = ODEfirstSelectedResultsWaveRow()
			ODEDeleteSelectedResultsWaves()
			row += rowIncrement
			row = min(row, DimSize(ODESelect_SelectedWavesListWave, 0))
			
			Variable nSelections = ItemsInList(selections)
			InsertPoints row, nSelections, ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
			ODESelect_SelectedWavesSelWave = 0
			
			Variable i
			for (i = 0; i < nSelections; i += 1)
				ODESelect_SelectedWavesListWave[i+row] = StringFromList(i, selections)
				ODESelect_SelectedWavesSelWave[i+row] = 1
			endfor
			break
	endswitch

	return 0
End

Function ODESelect_MulticolumnMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			NVAR ODE_ResultsMultiCol = root:Packages:WM_ODEPanel:ODE_ResultsMultiCol
			if ( ((pa.popNum == 1) && (ODE_ResultsMultiCol)) || ((pa.popNum == 2) && (!ODE_ResultsMultiCol)) )
				Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
				Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
				Redimension/N=0 ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
				ODE_ResultsMultiCol = !ODE_ResultsMultiCol
				NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
				RebuildSelectResultsList(ODE_ResultsMultiCol, ODE_NumEqs)
			endif
			break
	endswitch

	return 0
End

static Function IsInTextWaveList(item, twaveList)
	String item
	Wave/T twaveList
	
	Variable i
	Variable nRows = DimSize(twaveList, 0)
	
	for (i = 0; i < nRows; i += 1)
		if (CmpStr(item, twaveList[i]) == 0)
			return 1
		endif
	endfor
	
	return 0
end

Function ODESelectWavesSelectButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
			Wave ODESelect_SelectedWavesSelWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesSelWave
			String selections = WS_SelectedObjectsList("ODEWavesPanel", "ODESelectWavesList")
			Variable nItems = ItemsInLIst(selections)
			Variable i
			String oneItem
			Variable numWavesAlready = DimSize(ODESelect_SelectedWavesListWave, 0)
			// check for waves that are already in the list, and remove them from the list of selections
			for (i = nItems-1; i >= 0; i -= 1)
				oneItem = StringFromList(i, selections)
				if (IsInTextWaveList(oneItem, ODESelect_SelectedWavesListWave))
					selections = RemoveListItem(i, selections)
				endif
			endfor
			nItems = ItemsInLIst(selections)
			
			NVAR ODE_NumEqs=root:Packages:WM_ODEPanel:ODE_NumEqs
			NVAR ODE_ResultsMultiCol = root:Packages:WM_ODEPanel:ODE_ResultsMultiCol
			if (ODE_ResultsMultiCol)
				if ( (numWavesAlready > 0) && (nItems > 0) )
					DoAlert 0, "You have selected to use a single multi-column wave and you already have one selected. To replace it, select the one you have and delete it, then select a new one."
					return 0
				endif
			else
				if ( (nItems + numWavesAlready > ODE_NumEqs) )
					DoAlert 0, "You need "+num2str(ODE_NumEqs)+" waves; you have selected "+num2str(nItems)+" new waves, and you already have "+num2str(numWavesAlready)+". That makes too many waves."
					return 0
				endif					
			endif
			
			// if in 1d wave mode, make sure all waves are the same length
			Variable wavelength = 0
			if (!ODE_ResultsMultiCol)
				if (numWavesAlready > 0)
					Wave w = $(ODESelect_SelectedWavesListWave[0])
				else
					Wave w = $StringFromList(0, selections)
				endif
				wavelength = DimSize(w, 0)
				for (i = 0; i < nItems; i += 1)
					Wave oneWave = $StringFromList(i, selections)
					if (DimSize(oneWave, 0) != wavelength)
						DoAlert 0, "The result waves must all have the same number of points. The wave "+NameOfWave(w)+" has "+num2istr(DimSize(w, 0))+" points, and "+NameOfWave(oneWave)+" has "+num2str(DimSize(oneWave,0))+" points."
						return 0
					endif
				endfor
			endif
			// now move them over
			for (i = 0; i < nItems; i += 1)
				oneItem = StringFromList(i, selections)
				Variable row = numWavesAlready
				InsertPoints row, 1, ODESelect_SelectedWavesListWave, ODESelect_SelectedWavesSelWave
				ODESelect_SelectedWavesListWave[row] = oneItem
				ODESelect_SelectedWavesSelWave = 0
			endfor
			
			// now, if we have enough waves, disable the select button
			if (DimSize(ODESelect_SelectedWavesListWave, 0) == ODE_NumEQs)
				button ODESelectWavesSelectButton, win=$ba.win,disable=2
			endif
			break
	endswitch

	return 0
End

Function ODESelect_OKButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			SVAR ODE_ResultsWaveList=root:Packages:WM_ODEPanel:ODE_ResultsWaveList
			Wave/T ODESelect_SelectedWavesListWave = root:Packages:WM_ODEPanel:ODESelect_SelectedWavesListWave
			Variable nWaves = DimSize(ODESelect_SelectedWavesListWave, 0)
			Variable i
			ODE_ResultsWaveList = ""
			for (i = 0; i < nWaves; i += 1)
				ODE_ResultsWaveList += ODESelect_SelectedWavesListWave[i]+";"
			endfor
			Wave/T ODE_YWaveListWave=root:Packages:WM_ODEPanel:ODE_YWaveListWave
			Redimension/N=(nWaves) ODE_YWaveListWave
			ODE_YWaveListWave = ODESelect_SelectedWavesListWave

			Execute/P/Q "KillWindow ODEWavesPanel"
			break
	endswitch

	return 0
End

Function ODESelect_CancelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Execute/P/Q "KillWindow ODEWavesPanel"
			break
	endswitch

	return 0
End