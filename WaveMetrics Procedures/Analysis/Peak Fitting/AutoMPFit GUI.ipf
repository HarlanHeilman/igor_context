#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma moduleName= WMAutoMPFGUI
#pragma version=1.06
#pragma IgorVersion=9.00
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#include <Multipeak Fitting>

//***************************************
// A graphical user interface for MPF2_AutoMPFit().
// Goes with the Multipeak Fitting package.
//
// Contents of the AutMPF_WaveList wave within Packages:MultiPeakFit2:
// Holds information about the X and Y waves to be fitted.
// Layer[0]: [0] Y name, [1] X name, [2] Y dim
// Layer[1]: [0] Y path, [1] X path, [2] X dim
//
// The GUI supports fitting the following data formats:
// - 1D Y waves		(X = calculated)
// - 1D XY pairs	(one X wave for each Y wave)
// - 2D Y waves		(X = calculated; will be temporarily split into 1D waves)
// - 2D XY pairs	(X = 1D or X = 2D with the same no. of points as the Y wave)
// - Any combination of the above
//
// Version 1.00, 08/08/2020, ST - initial version of this add-on
// Version 1.01, 09/12/2020, ST - added support for peak type lists
// Version 1.02, 23/03/2021, ST - added support for IntialGuessOptions = 6 (only guessing)
//							 ST - Fixed bug: AutoMPFitGUI could not start without Multipeak Fit folder present
// Version 1.03, 07/04/2021, ST - added support for negativePeakGuess parameter
// Version 1.04, 09/22/2021, ST - Fixed bug: Constraints waves were not properly loaded from the GUI.
// Version 1.04, 10/22/2021, ST - added error message -20: wrong size of constraints wave
// Version 1.05, 05/16/2022, ST - Fixed bug: MoveWindow may lead to cropped GUI on small screens => avoid and directly build the panel in the right position.
// Version 1.06, 07/12/2022, ST - Now the GUI remembers all settings, which will be re-set when re-opening the panel.
//
//***************************************

static StrConstant	kAutoMPF_WorkingDir	= "root:Packages:MultiPeakFit2:"
static Constant AutoMPFGUI_VERSION=1.00

Structure AutoMPFitInfoStruct
	String resultDFBase					// parameters of MPF2_AutoMPFit()
	String peakType
	String PeakCoefWaveFormat
	String BLType
	String BLCoefWaveName
	String yWaveList
	String xWaveList
	Variable InitialGuessOptions
	Variable noiseEst
	Variable smFact
	Variable noiseEstMult
	Variable smFactMult
	Variable minAutoFindFraction
	Variable negativePeakGuess
	Variable doDerivedResults
	Variable doFitCurves
	Wave/T constraints
	Variable startPoint
	Variable endPoint
	
	Variable printCode					// additional GUI-specific parameters
	Variable flip2D						// in which direction a 2D wave is expanded
	Wave/DF tmpFolders					// holds the paths to all temp folders of expanded 2D waves
	Variable version					// ST: 220712 - added version parameter for reloading the settings
EndStructure

//***************************************

static Function AutoMPFitInitialize(STRUCT AutoMPFitInfoStruct &s)					// ST: 220712 - added initialize function; at the same time, this sets the GUI defaults
	s.resultDFBase			= "result"
	s.peakType				= "Gauss"
	s.PeakCoefWaveFormat	= "peakcoef_%d"
	s.BLType				= "None"
	s.BLCoefWaveName		= "blcoef"
	s.InitialGuessOptions	= 5			// count from 0
	s.noiseEst				= -1
	s.smFact				= -1
	s.noiseEstMult			= 1
	s.smFactMult			= 1
	s.minAutoFindFraction	= 0.05
	s.negativePeakGuess		= 0
	s.doDerivedResults		= 0
	s.doFitCurves			= 0
	s.startPoint			= 0
	s.endPoint				= inf
	s.printCode				= 0
	s.flip2D				= 0
	s.version				= AutoMPFGUI_VERSION
	return 0
End

//***************************************

static Function/S AutoMPFit_SaveSettings(STRUCT AutoMPFitInfoStruct &s)				// ST: 220712 - saves the structure into a string
	String str = ""
	sprintf str, "%sresultDFBase:%s;", str, s.resultDFBase
	sprintf str, "%speakType:%s;", str, s.peakType
	sprintf str, "%sPeakCoefWaveFormat:%s;", str, s.PeakCoefWaveFormat
	sprintf str, "%sBLType:%s;", str, s.BLType
	sprintf str, "%sBLCoefWaveName:%s;", str, s.BLCoefWaveName
	sprintf str, "%sInitialGuessOptions:%d;", str, s.InitialGuessOptions
	sprintf str, "%snoiseEst:%g;", str, s.noiseEst
	sprintf str, "%ssmFact:%g;", str, s.smFact
	sprintf str, "%snoiseEstMult:%g;", str, s.noiseEstMult
	sprintf str, "%ssmFactMult:%g;", str, s.smFactMult
	sprintf str, "%sminAutoFindFraction:%g;", str, s.minAutoFindFraction
	sprintf str, "%snegativePeakGuess:%d;", str, s.negativePeakGuess
	sprintf str, "%sdoDerivedResults:%d;", str, s.doDerivedResults
	sprintf str, "%sdoFitCurves:%d;", str, s.doFitCurves
	sprintf str, "%sstartPoint:%g;", str, s.startPoint
	sprintf str, "%sendPoint:%g;", str, s.endPoint
	sprintf str, "%sprintCode:%d;", str, s.printCode
	sprintf str, "%sflip2D:%d;", str, s.flip2D
	sprintf str, "%sversion:%g;", str, s.version
	if (WaveExists(s.constraints))
		sprintf str, "%sconstraints:%s;", str, GetWavesDataFolder(s.constraints, 2)
	else
		sprintf str, "%sconstraints:%s;", str, ""
	endif
	return str
End

//***************************************

static Function AutoMPFit_LoadSettings(String str, STRUCT AutoMPFitInfoStruct &s)	// ST: 220712 - loads the structure from a string
	s.resultDFBase			= StringByKey("resultDFBase", str)
	s.peakType 				= StringByKey("peakType", str)
	s.PeakCoefWaveFormat	= StringByKey("PeakCoefWaveFormat", str)
	s.BLType				= StringByKey("BLType", str)
	s.BLCoefWaveName		= StringByKey("BLCoefWaveName", str)
	s.InitialGuessOptions	= NumberByKey("InitialGuessOptions", str)
	s.noiseEst				= NumberByKey("noiseEst", str)
	s.smFact				= NumberByKey("smFact", str)
	s.noiseEstMult			= NumberByKey("noiseEstMult", str)
	s.smFactMult			= NumberByKey("smFactMult", str)
	s.minAutoFindFraction	= NumberByKey("minAutoFindFraction", str)
	s.negativePeakGuess		= NumberByKey("negativePeakGuess", str)
	s.doDerivedResults		= NumberByKey("doDerivedResults", str)
	s.doFitCurves			= NumberByKey("doFitCurves", str)
	s.startPoint			= NumberByKey("startPoint", str)
	s.endPoint				= NumberByKey("endPoint", str)
	s.printCode				= NumberByKey("printCode", str)
	s.flip2D				= NumberByKey("flip2D", str)
	s.version				= NumberByKey("version", str)
	Wave/T/Z s.constraints	= $StringByKey("constraints", str)
	return 0
End

//***************************************

Function MPF_BuildAutoMPFitPanel()
	if (WinType("AutoMPFitGUIPanel") == 7)
		DoWindow/F AutoMPFitGUIPanel
		return 0
	endif
	
	DFREF saveDF = GetDataFolderDFR()
	if (!DataFolderExists(kAutoMPF_WorkingDir))		// if MPF was not started yet => create basic folder structure
		SetDataFolder root:
		Variable i
		for (i = 1; i < ItemsInList(kAutoMPF_WorkingDir,":"); i++)
			NewDataFolder/O/S $StringFromList(i,kAutoMPF_WorkingDir,":")
		endfor
		Variable/G currentSetNumber = 0
		SetDataFolder saveDF
	endif
	
	Wave/Z/T listwave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
	Wave/Z selwave	= $(kAutoMPF_WorkingDir+"AutoMPF_WaveSelect")
	
	if (!WaveExists(listwave) || !WaveExists(selwave))
		Make/O/T/N=(1,3,2) $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")/Wave=listwave
		Make/O/N=(1,3,2) $(kAutoMPF_WorkingDir+"AutoMPF_WaveSelect")/Wave=selwave
		listwave = ""
		selwave  = 0
		SetDimLabel 1, 0, 'Y Waves', listwave
		SetDimLabel 1, 1, 'X Waves', listwave
		SetDimLabel 1, 2, 'Dim', listwave
	endif
	
	STRUCT AutoMPFitInfoStruct info
	AutoMPFitInitialize(info)						// ST: 220712 - initialize structure and possibly load previous settings
	
	SVAR/Z settings = $(kAutoMPF_WorkingDir+"AutoMPF_PanelSettings")
	if (SVAR_Exists(settings))
		AutoMPFit_LoadSettings(settings,info)
		if (info.version != AutoMPFGUI_VERSION)		// make sure the contents are valid
			AutoMPFitInitialize(info)
		endif
	endif
	
	// --------------- center the panel in the monitor or the Windows MDI window
	Variable scrnL, scrnT, scrnR, scrnB, scrnW, scrnH
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		String scrnInfo = StringByKey("SCREEN1", IgorInfo(0))
		scrnInfo = scrnInfo[strsearch(scrnInfo, "RECT=", 0)+5, strlen(scrnInfo)-1]
		sscanf scrnInfo, "%d,%d,%d,%d", scrnL, scrnT, scrnR, scrnB
		scrnW = (scrnR-scrnL) * ScreenResolution/72
		scrnH = (scrnB-scrnT) * ScreenResolution/72
	elseif (CmpStr(IgorInfo(2), "Windows") == 0)
		GetWindow kwFrameInner, wsize
		scrnW = V_right-V_left
		scrnH = V_bottom-V_top
		if (ScreenResolution == 96)
			scrnW *= ScreenResolution/72
			scrnH *= ScreenResolution/72
		endif
	endif
	// --------------- 
	
	//Variable left	= 400
	//Variable top	= 100
	Variable width	= 760
	Variable height	= 620
	
	//NewPanel/W=(left,top,left+width,top+height)/K=1/N=AutoMPFitGUIPanel as "Auto Multipeak Fit User Interface"
	NewPanel/W=((scrnW-width)/2, (scrnH-height)/2, (scrnW+width)/2, (scrnH+height)/2)/K=1/N=AutoMPFitGUIPanel as "Auto Multipeak Fit User Interface"		// ST: 220516 - build the panel at the correct position right from the start
	ModifyPanel/W=AutoMPFitGUIPanel fixedSize=1
	
	Button AutoMPF_PopupSelectFolder	,pos={10.00,18.00}		,size={150.00,30.00}	,title="Add/Edit Waves ..."	,proc=AutoMPF_ShowDataSelectorButton
	Button AutoMPF_ShowHelpButton		,pos={410.00,18.00}		,size={50.00,30.00}		,title="Help"				,proc=AutoMPF_ShowHelpButton
	
	GroupBox AutoMPF_RangeLimitGroup	,pos={175.00,8.00}		,size={225.00,55.00}	
	TitleBox AutoMPF_RangeLimitTitle	,pos={185.00,20.00}		,size={110.00,15.00}	,title="Limit Data\rFit Range:"				,frame=0
	SetVariable AutoMPF_RangeFirstPoint	,pos={190.00,14.00}		,size={200.00,18.00}	,title="First Point:"
	SetVariable AutoMPF_RangeLastPoint	,pos={190.00,37.00}		,size={200.00,18.00}	,title="Last Point:"
	
	CheckBox AutoMPF_Flip2DWaves		,pos={175.00,65.00}		,size={215.00,15.00}	,title="2D Data: Fit Rows Instead of Columns"
	
	TitleBox AutoMPF_SelectWListTitle	,pos={10.00,70.00}		,size={110.00,15.00}	,title="Waves to Fit:"						,frame=0
	ListBox AutoMPF_SelectWaveList		,pos={10.00,85.00}		,size={450.00,height-135}
	
	GroupBox AutoMPF_NamesGroup			,pos={480.00,10.00}		,size={270.00,190.00}	,title="Output Naming"		,fStyle=1	,fColor=(0,0,65535)
	
	TitleBox AutoMPF_ResultFolderTitle	,pos={490.00,32.00}		,size={150.00,15.00}	,title="Output Folder Name Prefix:"			,frame=0
	SetVariable AutoMPF_ResultFolderName,pos={490.00,51.00}		,size={180.00,18.00}
	TitleBox AutoMPF_ResultFolderPostFix,pos={675.00,53.00}		,size={60.00,15.00}		,title="_0, _1, _2 ..."						,frame=0
	
	TitleBox AutoMPF_PeakCoefTitle		,pos={490.00,78.00}		,size={200.00,15.00}	,title="Peak Coefficient Wave Name Format:"	,frame=0
	SetVariable AutoMPF_PeakCoefName	,pos={490.00,97.00}		,size={180.00,18.00}
	TitleBox AutoMPF_PeakCoefPostFix	,pos={675.00,99.00}		,size={70.00,15.00}		,title="%d = 0,1,2,..."						,frame=0
	
	TitleBox AutoMPF_BLCoefTitle		,pos={490.00,124.00}	,size={180.00,15.00}	,title="Baseline Coefficient Wave Name:"	,frame=0
	SetVariable AutoMPF_BLCoefName		,pos={490.00,143.00}	,size={180.00,18.00}
	
	CheckBox AutoMPF_DoDerivedCheck		,pos={490.00,173.00}	,size={130.00,15.00}	,title="I Want Derived Values"
	CheckBox AutoMPF_DoFitCurvesCheck	,pos={634.00,173.00}	,size={130.00,15.00}	,title="I Want Fit Curves"
	
	GroupBox AutoMPF_FitSettingsGroup	,pos={480.00,210.00}	,size={270.00,160.00}	,title="Fit Settings"		,fStyle=1	,fColor=(65535,0,0)
	
	PopupMenu AutoMPF_PeakTypePop		,pos={500.00,234.00}	,size={240.00,19.00}	,title="Peak Type:"
	PopupMenu AutoMPF_BaselinePop		,pos={490.00,264.00}	,size={250.00,19.00}	,title="Baseline:"
	TitleBox AutoMPF_InitGuessTitle		,pos={490.00,297.00}	,size={180.00,15.00}	,title="Initial Guess Values:"				,frame=0
	Button AutoMPF_InitGuessExplainBtn	,pos={680.00,293.00}	,size={60.00,20.00}		,title="Explain"			,proc=AutoMPF_ExplainInitGuessButton
	PopupMenu AutoMPF_InitGuessPop		,pos={490.00,319.00}	,size={250.00,19.00}
	CheckBox AutoMPF_FindNegativePeaks	,pos={490.00,345.00}	,size={75.00,15.00}		,title="Auto-guess Negative Peaks"						// ST: 210407 - add checkbox for negative peak support
	
	GroupBox AutoMPF_OptionalGroup		,pos={480.00,385.00}	,size={270.00,200.00}	,title="Optional Settings"	,fStyle=1	,fColor=(1,26214,0)
	
	SetVariable AutoMPF_NoiseEstimate	,pos={495.00,406.00}	,size={240.00,18.00}	,title="Noise Level (for Auto-Guess):"
	SetVariable AutoMPF_SmoothEstimate	,pos={495.00,431.00}	,size={240.00,18.00}	,title="Smoothing (for Auto-Guess):"
	SetVariable AutoMPF_NoiseMultiplier	,pos={495.00,456.00}	,size={240.00,18.00}	,title="Multiply Estimated Noise Level:"
	SetVariable AutoMPF_SmoothMultiplier,pos={495.00,481.00}	,size={240.00,18.00}	,title="Multiply Estimated Smoothing:"
	SetVariable AutoMPF_MinFraction		,pos={495.00,506.00}	,size={240.00,18.00}	,title="Discard Peaks Below:"
	
	TitleBox AutoMPF_ConstraintsTitle	,pos={490.00,534.00}	,size={240.00,19.00}	,title="Constraints Wave:"					,frame=0
	Button AutoMPF_PopupSelectConstrWave,pos={590.00,532.00}	,size={145.00,20.00}	,title=""
	
	CheckBox AutoMPF_PrintCode			,pos={490.00,560.00}	,size={75.00,15.00}		,title="Print AutoMPFit Command"
	SetVariable AutoMPF_ShowErrors		,pos={480.00,593.00}	,size={270.00,15.00}	,title="Errors:"
	
	Button AutoMPF_StartFitButton		,pos={185.00,577.00}	,size={100.00,33.00}	,title="Do the Fit!"		,proc=AutoMPF_DoFit	,fColor=(32768,54615,65535)
	
// --------------- additional control options
	String IntialGuessOptions = "0: Provided. Same coefs for all data.;"			// not too long - description needs to fit into popup control
	IntialGuessOptions += "1: Provided. First only, then use fit result.;"
	IntialGuessOptions += "2: Provided. Coef set for each data.;"
	IntialGuessOptions += "3: Auto-guess of first data used for all.;"
	IntialGuessOptions += "4: Auto-guess of first, then use fit result.;"
	IntialGuessOptions += "5: Auto-guess for each data individually.;"
	IntialGuessOptions += "6: Just auto-guess for each data, don't fit.;"
	
	// ST: 220712 - now the panel loads everything from the info structure
	ListBox AutoMPF_SelectWaveList		,focusRing=0 	,widths={170,170,25},mode=4	,listWave=listwave ,selWave=selwave
	SetVariable AutoMPF_ResultFolderName				,value=_STR:info.resultDFBase
	SetVariable AutoMPF_PeakCoefName					,value=_STR:info.PeakCoefWaveFormat
	SetVariable AutoMPF_BLCoefName						,value=_STR:info.BLCoefWaveName
	SetVariable AutoMPF_NoiseEstimate	,bodyWidth=80	,value=_STR:SelectString(info.noiseEst == -1,num2str(info.noiseEst),"auto")
	SetVariable AutoMPF_SmoothEstimate	,bodyWidth=80	,value=_STR:SelectString(info.smFact == -1,num2str(info.smFact),"auto")
	SetVariable AutoMPF_ShowErrors		,bodyWidth=270	,value=_STR:""	,noedit=1
	SetVariable AutoMPF_RangeFirstPoint	,bodyWidth=80	,value=_NUM:info.startPoint					,limits={0,inf,1}		,format="%g"
	SetVariable AutoMPF_RangeLastPoint	,bodyWidth=80	,value=_NUM:info.endPoint					,limits={0,inf,1}		,format="%g"
	SetVariable AutoMPF_NoiseMultiplier	,bodyWidth=80	,value=_NUM:info.noiseEstMult				,limits={1e-05,inf,0}	,format="%g x"
	SetVariable AutoMPF_SmoothMultiplier,bodyWidth=80	,value=_NUM:info.smFactMult					,limits={1e-05,inf,0}	,format="%g x"
	SetVariable AutoMPF_MinFraction		,bodyWidth=80	,value=_NUM:info.minAutoFindFraction*100	,limits={1e-05,inf,0}	,format="%g %"
	PopupMenu AutoMPF_PeakTypePop		,bodyWidth=180	,mode=1			,value=MPF2_ListPeakTypeNames()+"Custom String List;"		,proc=AutoMPF_PopPeakTypeOption
	PopupMenu AutoMPF_BaselinePop		,bodyWidth=180	,mode=1			,value=MPF2_ListBaseLineTypeNames()
	PopupMenu AutoMPF_InitGuessPop		,bodyWidth=250	,mode=(info.InitialGuessOptions+1)	,value=#("\""+IntialGuessOptions+"\"")	,proc=AutoMPF_SwitchInitGuessOption
	CheckBox AutoMPF_DoDerivedCheck		,value=info.doDerivedResults	,help={"Selecting this option will compute the derived parameters for the given peak type, such as FWHM, Area, etc."}
	CheckBox AutoMPF_DoFitCurvesCheck	,value=info.doFitCurves			,help={"Selecting this option will output curve data such as the total fit, the individual peaks and the baseline."}
	CheckBox AutoMPF_FindNegativePeaks	,value=info.negativePeakGuess	,help={"Makes the peak finder look for negative instead of positive peaks."}		// ST: 210407 - help for checkbox
	CheckBox AutoMPF_PrintCode			,value=info.printCode			,help={"Prints the MPF_AutoMPFit function code used for the fit."}
	CheckBox AutoMPF_Flip2DWaves		,value=info.flip2D				,help={"Swaps rows and columns of 2D waves temporarily for the fit."}
	PopupMenu AutoMPF_PeakTypePop		,popMatch=info.peakType
	PopupMenu AutoMPF_BaselinePop		,popMatch=info.BLType
	
	MakeButtonIntoWSPopupButton("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave", "AutoMPF_SelectConstrWavePopupWSNotify", options=PopupWS_OptionFloat)
	PopupWS_MatchOptions("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave", listoptions="TEXT:1")
	PopupWS_AddSelectableString("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave", "_none_")
	
	if (WaveExists(info.constraints))
		PopupWS_SetSelectionFullPath("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave", GetWavesDataFolder(info.constraints, 2))
	else
		PopupWS_SetSelectionFullPath("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave", "_none_")
	endif
	
	// Variable PixWidth	= width		*PanelResolution("AutoMPFitGUIPanel")/screenResolution		// ST: 220516 - MoveWindow will not expand beyond the MDI window and may cut the panel
	// Variable PixHeight	= height	*PanelResolution("AutoMPFitGUIPanel")/screenResolution
	// MoveWindow/W=AutoMPFitGUIPanel (scrnWidth - PixWidth)/2, (scrnHeight - PixHeight)/2, (scrnWidth + PixWidth)/2, (scrnHeight + PixHeight)/2
	
	SetWindow AutoMPFitGUIPanel, hook(AutoMPFitPanelHook)=AutoMPF_GUIPanel_WindowHook				// ST: 220712 - new hook function
	return 0
End

Function AutoMPF_GUIPanel_WindowHook(STRUCT WMWinHookStruct &s)										// ST: 220712 - save all settings upon panel deactivate / closing
	if (s.EventCode == 1 || s.EventCode == 17)	// deactivate or killVote
		STRUCT AutoMPFitInfoStruct info
		Variable Error = AutoMPF_ReadAllPanelSettings(info)
		if (!Error)
			String/G $(kAutoMPF_WorkingDir+"AutoMPF_PanelSettings") = AutoMPFit_SaveSettings(info)
		endif
	endif
	return 0
End

Function AutoMPF_SelectConstrWavePopupWSNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName
	
	return 0
End

Function AutoMPF_ExplainInitGuessButton(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.EventCode == 2)
		String Explanation = "0: Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultName+_0. Use those values for every data set.\r\r"
		Explanation += "1: Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultName+_0. Use those values for the first data set, then use the previous result as initial guess for the next.\r\r"
		Explanation += "2: Do not run AutoPeakFind. Initial guesses will be pre-loaded for every data set in a series of data folders resultName+_n, n = 0,1,...\r\r"
		Explanation += "3: Run AutoPeakFind once on the first data set and use the result as the initial guess for every data set.\r\r"
		Explanation += "4: Run AutoPeakFind once on the first data set and use the result as the initial guess for the first data set. For every other data set, use the result of the previous fit as the initial guess for the next.\r\r"
		Explanation += "5: Run AutoPeakFind on every data set to generate initial guesses for each fit.\r\r"
		Explanation += "6: Same as 5, but doesn't run the fit. Generated guesses can be used, e.g., with InitialGuessOptions = 2."
		DoAlert/T="Explanation of the Initial Guess Modes" 0, Explanation
	endif
	return 0
End

Function AutoMPF_ShowHelpButton(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.EventCode == 2)
		DisplayHelpTopic "Automatic Multipeak Batch Fitting"
	endif
	return 0
End

Function AutoMPF_ShowDataSelectorButton(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.EventCode == 2)
		AutoMPF_BuildDataSetSelector()
	endif
	return 0
End

Function AutoMPF_PopPeakTypeOption(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	if (s.EventCode == 2 && CmpStr(s.popStr,"Custom String List") == 0)									// displays a prompt to set the custom string list
		String TypeList = StrVarOrDefault(kAutoMPF_WorkingDir+"AutoMPF_PeakTypeList","")
		String TypeHelp = "The string list is used to assign a different type to each peak (in ascending order starting from the first peak). If the number of peaks is exceeding the number of provided peak types then the first peak type in the list is used for all remaining peaks."
		Prompt Typelist, "Enter peak types as string list (example: \"Gauss;Gauss;Voigt;\")"
		DoPrompt/Help=TypeHelp "Specify a list of peak types for AutoMPFit",TypeList
		if (V_Flag == 0 && strlen(TypeList) > 0)
			String/G $(kAutoMPF_WorkingDir+"AutoMPF_PeakTypeList") = TypeList
		else
			PopupMenu AutoMPF_PeakTypePop, win=AutoMPFitGUIPanel, popMatch="Gauss"						// reset selection
		endif
	endif
	return 0
End

Function AutoMPF_SwitchInitGuessOption(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	if (s.EventCode == 2)
		SetVariable AutoMPF_NoiseEstimate	,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)				// just for display: additional parameters are disabled for the non-automatic guess options, since they are not used
		SetVariable AutoMPF_SmoothEstimate	,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)
		SetVariable AutoMPF_NoiseMultiplier	,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)
		SetVariable AutoMPF_SmoothMultiplier,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)
		SetVariable AutoMPF_MinFraction		,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)
		CheckBox AutoMPF_FindNegativePeaks	,win=AutoMPFitGUIPanel	,disable=2*(s.popNum<4)				// ST: 210407 - negative peaks are only useful for guess modes
	endif
	return 0
End

Function AutoMPF_DoFit(s) : ButtonControl			// the main function where everything comes together
	STRUCT WMButtonAction &s
	if (s.EventCode != 2)
		return 0
	endif
	
	Variable Error = 0
	String ErrorMsg = ""
	
	STRUCT AutoMPFitInfoStruct info
	Error = AutoMPF_ReadAllPanelSettings(info)		// MUST come before wave extraction to correctly set info.flip2D state
	if (Error == -1)
		Abort "Peak type list does not exist or has wrong format."
	endif
	Error = AutoMPF_LoadAllWaves(info)				// may expand 2D data into an 1D column set
	if (Error == -1)
		Abort "No data waves in the list! Press Add/Edit Waves to add data."
	endif
	if (Error == -2)
		Abort "It seems at least one 2D data XY pair has different dimensions for the Y and X data. Either pair all XY waves with the same number of columns or use an 1D X wave."
	endif

	String/G $(kAutoMPF_WorkingDir+"AutoMPF_PanelSettings") = AutoMPFit_SaveSettings(info)	// ST: 220712 - save all settings
	Error = AutoMPF_DoTheFit(info)
	ErrorMsg = AutoMPF_UpdateErrorDisplay(Error)	// indicate the error in the panel
	AutoMPF_PrintCodeToHistory(info, ErrorMsg)
	Error = AutoMPF_CleanupTempFolders()			// cleanup 2D expansion temp folders
	
	return 0
End

Function  AutoMPF_DoTheFit(info)
	STRUCT AutoMPFitInfoStruct &info
	
	Variable NoiseAndSmooth = (info.noiseEst != -1)* 2^0 + (info.smFact != -1) * 2^1		// a value of -1 indicates that they are not used
	Variable Error = 0
	Switch (NoiseAndSmooth)							// AutoMPFit will always use noiseEst or smFact if they are provided and is only automatic if they are omitted - need to define four calls; one for each case
		case 0:	// both automatic
			Error = MPF2_AutoMPFit(info.resultDFBase, info.peakType, info.PeakCoefWaveFormat, info.BLType, info.BLCoefWaveName, info.yWaveList, info.xWaveList, info.InitialGuessOptions, 												  noiseEstMult = info.noiseEstMult, smFactMult = info.smFactMult, minAutoFindFraction = info.minAutoFindFraction, negativePeakGuess = info.negativePeakGuess, doDerivedResults = info.doDerivedResults, doFitCurves = info.doFitCurves, constraints = info.constraints, startPoint = info.startPoint, endPoint = info.endPoint)
		break
		case 1:	// only noiseEst
			Error = MPF2_AutoMPFit(info.resultDFBase, info.peakType, info.PeakCoefWaveFormat, info.BLType, info.BLCoefWaveName, info.yWaveList, info.xWaveList, info.InitialGuessOptions, noiseEst = info.noiseEst, 					  noiseEstMult = info.noiseEstMult, smFactMult = info.smFactMult, minAutoFindFraction = info.minAutoFindFraction, negativePeakGuess = info.negativePeakGuess, doDerivedResults = info.doDerivedResults, doFitCurves = info.doFitCurves, constraints = info.constraints, startPoint = info.startPoint, endPoint = info.endPoint)
		break
		case 2:	// only smFact
			Error = MPF2_AutoMPFit(info.resultDFBase, info.peakType, info.PeakCoefWaveFormat, info.BLType, info.BLCoefWaveName, info.yWaveList, info.xWaveList, info.InitialGuessOptions, 							smFact = info.smFact, noiseEstMult = info.noiseEstMult, smFactMult = info.smFactMult, minAutoFindFraction = info.minAutoFindFraction, negativePeakGuess = info.negativePeakGuess, doDerivedResults = info.doDerivedResults, doFitCurves = info.doFitCurves, constraints = info.constraints, startPoint = info.startPoint, endPoint = info.endPoint)
		break
		case 3:	// both set
			Error = MPF2_AutoMPFit(info.resultDFBase, info.peakType, info.PeakCoefWaveFormat, info.BLType, info.BLCoefWaveName, info.yWaveList, info.xWaveList, info.InitialGuessOptions, noiseEst = info.noiseEst, smFact = info.smFact, noiseEstMult = info.noiseEstMult, smFactMult = info.smFactMult, minAutoFindFraction = info.minAutoFindFraction, negativePeakGuess = info.negativePeakGuess, doDerivedResults = info.doDerivedResults, doFitCurves = info.doFitCurves, constraints = info.constraints, startPoint = info.startPoint, endPoint = info.endPoint)
		break
	EndSwitch
	return Error
End

Function AutoMPF_ReadAllPanelSettings(info)			// read all GUI controls into the AutoMPFit structure including some rudimentary checks and fallback values
	STRUCT AutoMPFitInfoStruct &info

	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_ResultFolderName
	info.resultDFBase = CleanupName(S_Value, 1)
	if (strlen(info.resultDFBase) == 0)
		info.resultDFBase = "result"
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_PeakCoefName
	info.PeakCoefWaveFormat = CleanupName(S_Value, 1)
	if (strlen(info.PeakCoefWaveFormat) == 0)
		info.PeakCoefWaveFormat = "peakcoef_%d"
	endif
	if (strsearch(info.PeakCoefWaveFormat, "%d", 0) == -1)
		info.PeakCoefWaveFormat += "%d"
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_BLCoefName
	info.BLCoefWaveName = CleanupName(S_Value, 1)
	if (strlen(info.BLCoefWaveName) == 0)
		info.BLCoefWaveName = "blcoef"
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_PeakTypePop
	if (CmpStr(S_Value,"Custom String List") == 0)
		SVAR/Z TypeList = $(kAutoMPF_WorkingDir+"AutoMPF_PeakTypeList")
		if ( SVAR_Exists(TypeList))
			TypeList += ";"
			TypeList = RemoveFromList("",TypeList)
			if ( strlen (TypeList) > 0 )
				info.peakType=TypeList
			else
				return -1							// Abort
			endif
		else
			return -1								// Abort
		endif
	else
		info.peakType=S_Value
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_BaselinePop
	info.BLType=S_Value
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_InitGuessPop
	info.InitialGuessOptions=V_Value-1
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_DoDerivedCheck
	info.doDerivedResults=V_Value

	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_DoFitCurvesCheck
	info.doFitCurves=V_Value
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_FindNegativePeaks	// ST: 210407 - negative peak support
	info.negativePeakGuess=V_Value
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_PrintCode
	info.printCode=V_Value
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_Flip2DWaves
	info.flip2D=V_Value
	
	Wave/Z/T info.constraints = $PopupWS_GetSelectionFullPath("AutoMPFitGUIPanel", "AutoMPF_PopupSelectConstrWave")
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_RangeFirstPoint
	info.startPoint=V_Value
	if (info.startPoint < 0 || numtype(info.startPoint) != 0)
		info.startPoint = 0
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_RangeLastPoint
	info.endPoint=V_Value
	if (info.endPoint < 0 || numtype(info.endPoint) != 0)
		info.endPoint = inf
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_NoiseEstimate		// a value of -1 indicates that this parameter is on automatic
	String NoiseEstStr=S_Value
	if (CmpStr(NoiseEstStr,"auto") != 0 || strlen(NoiseEstStr) != 0)
		info.noiseEst = str2num(NoiseEstStr)
		if (numtype(info.noiseEst) != 0)
			info.noiseEst = -1
		endif
	else
		info.noiseEst = -1
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_SmoothEstimate		// a value of -1 indicates that this parameter is on automatic
	String SmthEstStr=S_Value
	if (CmpStr(SmthEstStr,"auto") != 0 || strlen(SmthEstStr) != 0)
		info.smFact = str2num(SmthEstStr)
		if (numtype(info.smFact) != 0)
			info.smFact = -1
		endif
	else
		info.smFact = -1
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_NoiseMultiplier
	info.noiseEstMult=V_Value
	if (info.noiseEstMult == 0 || numtype(info.noiseEstMult) != 0)
		info.noiseEstMult = 1
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_SmoothMultiplier
	info.smFactMult=V_Value
	if (info.smFactMult == 0 || numtype(info.smFactMult) != 0)
		info.smFactMult = 1
	endif
	
	ControlInfo/W=AutoMPFitGUIPanel AutoMPF_MinFraction
	info.minAutoFindFraction=V_Value/100
	if (numtype(info.minAutoFindFraction) != 0)
		info.minAutoFindFraction = 0.05							// fallback value as defined inside AutoMPfit(); might change in the future
	endif
	
	info.version = AutoMPFGUI_VERSION							// ST: 220712 - GUI version indicator
	
	return 0
End

Function AutoMPF_LoadAllWaves(info)								// reads out the list of waves into info.yWaveList and info.xWaveList, and optionally expands 2D waves into 1D columns or rows
	STRUCT AutoMPFitInfoStruct &info
	Wave/T listwave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
	Wave selwave	= $(kAutoMPF_WorkingDir+"AutoMPF_WaveSelect")
	if (AllFieldsAreBlank(listwave, 0))
		return -1
	endif

	// ListWave format:
	// Layer[0]: [0] Y name, [1] X name, [2] Y dim
	// Layer[1]: [0] Y path, [1] X path, [2] X dim

	Duplicate/T/Free/RMD=[,][0,0][1,1]  listwave, yWaves
	Duplicate/T/Free/RMD=[,][1,1][1,1]  listwave, xWaves
	Duplicate/T/Free/RMD=[,][2,2][0,0]  listwave, yWDim
	Duplicate/T/Free/RMD=[,][2,2][1,1]  listwave, xWDim
	Redimension/N=(-1,0,0) yWaves, xWaves, yWDim, xWDim
	
	String yWDimList, xWDimList, yWList, xWList					// check the dimensions and count how many 2D waves are there
	wfprintf yWDimList, "%s;", yWDim
	wfprintf xWDimList, "%s;", xWDim							// not used at the moment
	wfprintf yWList, "%s;", yWaves
	wfprintf xWList, "%s;", xWaves
	Variable Num_Waves2D	= ItemsInList(RemoveFromList("1D", yWDimList))
	Variable Num_WavesTot	= ItemsInList(yWList)
	Variable Num_xWaves		= ItemsInList(RemoveFromList("",xWList))
	
	info.yWaveList = yWList										// if it's just a bunch of 1D waves then we're done
	info.xWaveList = xWList
	
	if (Num_Waves2D > 0)										// some 2D waves which need to be expanded
		Variable wpos, wline, curr2Dwave = 0
		Make/O/DF/N=(Num_Waves2D) $(kAutoMPF_WorkingDir+"AutoMPF_tmpFolderList")/WAVE=tmpFolders		// saves all then temporary folders with the expanded data, which will be deleted after the fit is done
		
		for ( wpos=0; wpos<Num_Waves2D; wpos+=1 )
			curr2Dwave	 = WhichListItem("2D", yWDimList, ";", curr2Dwave)
			String ywStr = StringFromList(curr2Dwave, yWList)
			String xwStr = StringFromList(curr2Dwave, xWList)
			Wave yw		 = $ywStr
			Wave/Z xw	 = $xwStr
			
			String ywNameStr = ReplaceString("'",ParseFilePath(0, ywStr, ":", 1, 0),"")
			String tmpDirStr = "root:tmp_"+CleanupName(ywNameStr,0)
			
			NewDataFolder/O $tmpDirStr							// make a temp folder for 1D waves which gets cleaned up later
			DFREF tmpDir	= $tmpDirStr
			tmpFolders[wpos]= tmpDir

			String yLineList = ""
			String xLineList = ""
			Variable yLines = DimSize(yw,1-info.flip2D)
			Variable xLines = -1
			
			if(WaveExists(xw))
				xLines = DimSize(xw,1-info.flip2D)				// should be 0 (1D) or same size as y wave (2D)
			endif
			
			if (xLines > 0 && xLines != yLines)					// dimension mismatch between selected x wave and y wave
				AutoMPF_CleanupTempFolders()
				return -2
			endif
			
			for ( wline=0; wline<yLines; wline+=1 )
				String currPath = tmpDirStr+":line_"+num2str(wline)
				if (info.flip2D)
					Duplicate/O/R=[wline][] yw, $(currPath+"_y")
					MatrixTranspose $(currPath+"_y")
				else
					Duplicate/O/R=[][wline] yw, $(currPath+"_y")
				endif
				Redimension/N=-1 $(currPath+"_y")
				yLineList += currPath+"_y;"
				
				if (xLines == 0)								// 1D x wave
					xLineList += xwStr + ";"					// simply repeat the path in the list
				elseif (xLines > 0)								// 2D x wave
					if (info.flip2D)
						Duplicate/O/R=[wline][] xw, $(currPath+"_x")
						MatrixTranspose $(currPath+"_x")
					else
						Duplicate/O/R=[][wline] xw, $(currPath+"_x")
					endif
					Redimension/N=-1 $(currPath+"_x")
					xLineList += currPath+"_x;"
				endif
			endfor
			
			info.yWaveList = ReplaceString(ywStr+";",info.yWaveList,yLineList)	// replace the 2D wave's path with the column list
			info.xWaveList = ReplaceString(xwStr+";",info.xWaveList,xLineList)
				
			curr2Dwave += 1
		endfor
	endif
	
	return 0
End

Function AutoMPF_CleanupTempFolders()
	Variable Error = 0
	
	Wave/Z/DF tmpFolders = $(kAutoMPF_WorkingDir+"AutoMPF_tmpFolderList")
	if (WaveExists(tmpFolders))
		Variable i
		for (i=0; i<DimSize(tmpFolders,0); i+=1)
			DFREF curr = tmpFolders[i]
			KillDataFolder/Z curr
			if (V_Flag)
				Error = V_Flag
			endif
		endfor
		KillWaves tmpFolders
	endif
	
	return Error
End

Function/S AutoMPF_UpdateErrorDisplay(Variable Error)
	if (WinType("AutoMPFitGUIPanel") != 7)
		return ""
	endif
	
	// Error codes:
	//MPF2_Err_NoError = 0
	//MPF2_Err_NoSuchBLType = -1
	//MPF2_Err_BLCoefWaveNotFound = -2
	//MPF2_Err_NoSuchPeakType = -3
	//MPF2_Err_PeakCoefWaveNotFound = -4
	//MPF2_Err_BadNumberOfFunctions = -5
	//MPF2_Err_BadNumberOfCWaves = -6
	//MPF2_Err_XYListLengthMismatch = -7
	//MPF2_Err_NoDataSets = -8
	//MPF2_Err_MissingDataSet = -9
	//MPF2_Err_NoDataFolder = -10
	//MPF2_Err_BLCoefWrongNPnts = -11
	//MPF2_Err_PeakCoefWrongNPnts = -12
	//MPF2_Err_UserCancelledBatchRun = -13
	//MPF2_Err_SingularMatrixError = -14
	//MPF2_Err_NaNorInf = -15
	//MPF2_Err_IterationLimit = -16
	//MPF2_Err_OutOfMemory = -17
	//MPF2_Err_NoPeaksToFit = -18
	//MPF2_Err_WrongGuessMode = -19
	//MPF2_Err_BadSizeOfContraints = -20
	//MPF2_ErrorFromDoMPFit = -10000

	String ErrorMessages = "0: Fit succeeded without problems;"
	ErrorMessages += "-1: Not a valid baseline name;"
	ErrorMessages += "-2: Baseline coef wave not found;"
	ErrorMessages += "-3: Not a valid peak type name;"
	ErrorMessages += "-4: Peak coef wave not found;"
	ErrorMessages += "-5: No. of peaks vs. functions mismatch;"
	ErrorMessages += "-6: No. of peaks vs. coef waves mismatch;"
	ErrorMessages += "-7: No. of x- vs. y-data entries mismatch;"
	ErrorMessages += "-8: No data sets were found;"
	ErrorMessages += "-9: An input data set missing;"
	ErrorMessages += "-10: Provided data folder missing;"
	ErrorMessages += "-11: Wrong no. of baseline coef values;"
	ErrorMessages += "-12: Wrong no. of peak coef values;"
	ErrorMessages += "-13: User canceled batch run;"
	ErrorMessages += "-14: Quit with singular matrix error;"
	ErrorMessages += "-15: Fit resulted in NaN or Inf;"
	ErrorMessages += "-16: Fit reached iteration limit;"
	ErrorMessages += "-17: Out of memory;"
	ErrorMessages += "-18: No peak found for some data;"
	ErrorMessages += "-19: Wrong initial guess mode;"
	ErrorMessages += "-20: Wrong no. of columns in constraints wave;"
	
	String ErrorMsg = ""
	if (Error < -10000)
		ErrorMsg = num2str(Error)+": Internal Fit error in DoMPFit"
		SetVariable AutoMPF_ShowErrors	,win=AutoMPFitGUIPanel	,value=_STR:ErrorMsg
	else
		ErrorMsg = StringFromList(abs(Error),ErrorMessages)
		SetVariable AutoMPF_ShowErrors	,win=AutoMPFitGUIPanel	,value=_STR:ErrorMsg
	endif

	return ErrorMsg
End

Function AutoMPF_PrintCodeToHistory(info, ErrorMsg)
	STRUCT AutoMPFitInfoStruct &info
	String ErrorMsg
	
	if (!info.printCode)
		return 0
	endif
	
	Print "-------------- AutoMPFit() started at " + time() + " ---------------"
	
	String yWaves = info.yWaveList
	String xWaves = info.xWaveList
	if (strlen(info.yWaveList) > 120)
		yWaves = info.yWaveList[0,120] + " ..."
	endif
	if (strlen(info.xWaveList) > 120)
		xWaves = info.xWaveList[0,120] + " ..."
	endif
	
	Print "String ywList = \""+yWaves+"\""
	if (ItemsInList(RemoveFromList("",info.xWaveList)) > 0)
		Print "String xwList = \""+xWaves+"\""
	endif
	
	String Command = "Variable error = MPF2_AutoMPFit("
	Command += "\""+info.resultDFBase+"\", "
	if (ItemsInList(info.peakType) > 1)
		Print "String pTypes = \""+info.peakType+"\""
		Command += "pTypes, "
	else
		Command += "\""+info.peakType+"\", "
	endif
	Command += "\""+info.PeakCoefWaveFormat+"\", "
	Command += "\""+info.BLType+"\", "
	Command += "\""+info.BLCoefWaveName+"\", "
	Command += "ywList, "
	if (ItemsInList(RemoveFromList("",info.xWaveList)) > 0)
		Command += "xwList, "
	else
		Command += "\"\", "
	endif
	Command += num2str(info.InitialGuessOptions)
	
	if (info.noiseEst > -1)
		Command += ", noiseEst = "+num2str(info.noiseEst)
	endif
	if (info.smFact > -1)
		Command += ", smFact = "+num2str(info.smFact)
	endif
	
	if (info.noiseEstMult != 1)
		Command += ", noiseEstMult = "+num2str(info.noiseEstMult)
	endif
	if (info.smFactMult != 1)
		Command += ", smFactMult = "+num2str(info.smFactMult)
	endif
	if (info.minAutoFindFraction != 0.05)
		Command += ", minAutoFindFraction = "+num2str(info.minAutoFindFraction)
	endif
	if (info.negativePeakGuess != 0)											// ST: 210407 - negative peak support
		Command += ", negativePeakGuess = "+num2str(info.negativePeakGuess)
	endif
	
	if (info.doDerivedResults)
		Command += ", doDerivedResults = "+num2str(info.doDerivedResults)
	endif
	if (info.doFitCurves)
		Command += ", doFitCurves = "+num2str(info.doFitCurves)
	endif
	if (WaveExists(info.constraints))
		Print "Wave/T ConstrWave = "+GetWavesDataFolder(info.constraints, 2)
		Command += ", constraints = ConstrWave"
	endif

	if (info.startPoint > 0)
		Command += ", startPoint = "+num2str(info.startPoint)
	endif
	if (numtype(info.endPoint) != 1)
		Command += ", endPoint = "+num2str(info.endPoint)
	endif
	Command += ")"
	
	Print Command
	
	Print "print error => " + ErrorMsg
	Print "--------------------------------------------------------------"

	return 0
End

//***********************************
//
// Data Wave Selector
// => slightly modified version of the GlobalFit data selector
//
//***********************************

Function AutoMPF_BuildDataSetSelector()
	if (WinType("AutoMPF_SelectDataSetsPanel") == 7)
		DoWindow/F AutoMPF_SelectDataSetsPanel
		return 0
	endif
	
	Make/O/N=(0,2)/T $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")/WAVE=SelectedDataSetsListWave
	Make/O/N=(0,2) $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")/WAVE=SelectedDataSetsSelWave
	SetDimLabel 1,0,'Y waves',SelectedDataSetsListWave
	SetDimLabel 1,1,'X waves',SelectedDataSetsListWave
	
	Wave/T DataSetListWave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
	Variable nrows = DimSize(DataSetListWave, 0)
	if ( (nrows == 1) && AllFieldsAreBlank(DataSetListWave, 0))
		nrows = 0
	endif
	if (nrows > 0)
		Redimension/N=(nrows, 2) SelectedDataSetsListWave, SelectedDataSetsSelWave
		SelectedDataSetsListWave[][] = DataSetListWave[p][q][1]		// layer 1 contains full paths
	endif

	Variable left	= 300
	Variable top	= 300
	Variable width	= 620
	Variable height	= 470
	
	NewPanel/W=(left,top,left+width,top+height)/K=1/N=AutoMPF_SelectDataSetsPanel as "Add/Remove Data Sets"
	ModifyPanel/W=AutoMPF_SelectDataSetsPanel fixedSize=1
	
	CheckBox DataSets_FromTargetCheck		,pos={270.00,12.00}		,size={81.00,15.00}		,title="From Target"
	
	TitleBox SelectData_YWavesTitle			,pos={95.00,10.00}		,size={100.00,20.00}	,title="Select Y Waves"
	ListBox SelectDataSetsYSelector			,pos={15.00,35.00}		,size={260.00,180.00}
	PopupMenu NewData_YListSortMenu			,pos={15.00,220.00}		,size={19.00,19.00}
	SetVariable DataSets_YListFilterString	,pos={50.00,220.00}		,size={130.00,18.00}	,title="Filter"
	PopupMenu DataSets_YListSelectMenu		,pos={195.00,220.00}	,size={80.00,19.00}		,title="Select"
	
	TitleBox SelectData_XWavesTitle			,pos={425.00,10.00}		,size={100.00,20.00}	,title="Select X Waves"
	ListBox SelectDataSetsXSelector			,pos={345.00,35.00}		,size={260.00,180.00}
	PopupMenu NewData_XListSortMenu			,pos={345.00,220.00}	,size={19.00,19.00}
	SetVariable DataSets_XListFilterString	,pos={380.00,220.00}	,size={130.00,18.00}	,title="Filter"
	PopupMenu DataSets_XListSelectMenu		,pos={525.00,220.00}	,size={80.00,19.00}		,title="Select"
	
	Button SelectDataSetsArrowBtn			,pos={245.00,250.00}	,size={130.00,25.00}	,title="XY Set \\f01↓\\f00"
	Button SelectDataSetsYArrowBtn			,pos={95.00,250.00}		,size={100.00,25.00}	,title="Y wave \\f01↓\\f00"
	Button SelectDataSetsXArrowBtn			,pos={425.00,250.00}	,size={100.00,25.00}	,title="X wave \\f01↓\\f00"
	
	ListBox SelectedDataSetsList			,pos={15.00,280.00}		,size={590.00,150.00}
	
	GroupBox SelectData_MoverBox			,pos={165.00,435.00}	,size={200.00,32.00}
		Button SelectData_MoveUpButton		,pos={282.00,439.00}	,size={35.00,22.00}		,title="\\f01↑\\f00"
		Button SelectData_MoveDnButton		,pos={322.00,439.00}	,size={35.00,22.00}		,title="\\f01↓\\f00"
		TitleBox SelectData_MoverTitle		,pos={184.00,443.00}	,size={81.00,15.00}		,title="Move Selection"
	
	Button DataSets_SelectAll				,pos={376.00,437.00}	,size={85.00,25.00}		,title="Select \f04A\f00ll"
	Button DataSets_OKButton				,pos={20.00,437.00}		,size={100.00,25.00}	,title="OK"
	Button DataSets_CancelButton			,pos={500.00,437.00}	,size={100.00,25.00}	,title="Cancel"
	
	String SortOptions = "All;Every Other;Every Other starting with second;Every Third;Every Third starting with second;Every Third starting with third;"
	
	CheckBox DataSets_FromTargetCheck						,fSize=12	,value=0							,proc=AutoMPF_DSFromTargetCheckProc
	
	TitleBox SelectData_YWavesTitle							,fSize=14	,frame=0	,fStyle=1
	TitleBox SelectData_XWavesTitle							,fSize=14	,frame=0	,fStyle=1
	TitleBox SelectData_MoverTitle							,fSize=12	,frame=0
	
	PopupMenu NewData_YListSortMenu																			,proc=AutoMPF_DSSelectPopupMenuProc
	PopupMenu NewData_XListSortMenu																			,proc=AutoMPF_DSSelectPopupMenuProc
	PopupMenu DataSets_YListSelectMenu		,bodyWidth=80	,mode=0		,value=#("\"" + SortOptions + "\"")	,proc=AutoMPF_DSSelectPopupMenuProc
	PopupMenu DataSets_XListSelectMenu		,bodyWidth=80	,mode=0		,value=#("\"" + SortOptions + "\"")	,proc=AutoMPF_DSSelectPopupMenuProc

	SetVariable DataSets_YListFilterString	,bodyWidth=100	,fSize=12	,value=_STR:"*"						,proc=AutoMPF_DSSelectorFilterSetVarProc
	SetVariable DataSets_XListFilterString	,bodyWidth=100	,fSize=12	,value=_STR:"*"						,proc=AutoMPF_DSSelectorFilterSetVarProc
	
	ListBox SelectedDataSetsList			,mode= 10		,editStyle= 1									,proc=AutoMPF_SelectedDataListBoxProc
	ListBox SelectedDataSetsList			,listWave=SelectedDataSetsListWave		,selWave=SelectedDataSetsSelWave
	
	Button SelectDataSetsArrowBtn			,proc=AutoMPF_SelectDataSetsArrowButtonProc
	Button SelectDataSetsYArrowBtn			,proc=AutoMPF_SelectDataSetsArrowButtonProc
	Button SelectDataSetsXArrowBtn			,proc=AutoMPF_SelectDataSetsArrowButtonProc
	Button SelectData_MoveUpButton			,proc=AutoMPF_DataSetsMvSelectedWavesUpOrDown
	Button SelectData_MoveDnButton			,proc=AutoMPF_DataSetsMvSelectedWavesUpOrDown
	Button DataSets_SelectAll				,proc=AutoMPF_ActionButtonProc
	Button DataSets_OKButton				,proc=AutoMPF_ActionButtonProc
	Button DataSets_CancelButton			,proc=AutoMPF_ActionButtonProc
	
	MakeListIntoWaveSelector("AutoMPF_SelectDataSetsPanel", "SelectDataSetsYSelector", selectionMode=WMWS_SelectionNonContiguous, listoptions="MAXCHUNKS:0,MAXLAYERS:0,TEXT:0,WAVE:0,DF:0,CMPLX:0")
	MakeListIntoWaveSelector("AutoMPF_SelectDataSetsPanel", "SelectDataSetsXSelector", selectionMode=WMWS_SelectionNonContiguous, listoptions="MAXCHUNKS:0,MAXLAYERS:0,TEXT:0,WAVE:0,DF:0,CMPLX:0")
	WS_AddSelectableString("AutoMPF_SelectDataSetsPanel", "SelectDataSetsXSelector", "_calculated_")
	MakePopupIntoWaveSelectorSort("AutoMPF_SelectDataSetsPanel", "SelectDataSetsYSelector", "NewData_YListSortMenu")
	MakePopupIntoWaveSelectorSort("AutoMPF_SelectDataSetsPanel", "SelectDataSetsXSelector", "NewData_XListSortMenu")
	
	SetWindow AutoMPF_SelectDataSetsPanel, hook(DataSetsSelectorHook)=AutoMPF_SelectDataSets_WindowHook
End

Function AutoMPF_SelectDataSets_WindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable returnValue = 0
	
	strswitch (s.eventName)
		case "keyboard":
			if ( (s.keycode == 8) || (s.keycode == 127) )			// delete or forward delete
				Wave/T listwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")
				Wave selwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")
				Variable nrows = DimSize(listwave, 0)
				Variable i
				for (i = nrows-1; i >= 0; i -= 1)
					if ( (selwave[i][0] & 9) || ((selwave[i][1] & 9)) )
						DeletePoints i, 1, listwave, selwave
					endif
				endfor
				if (DimSize(listwave, 0) == 0)
					Redimension/N=(0,2) listwave, selwave
				endif
				SelectData_CheckForDupYWaves()
				returnValue = 1
			endif
			break;
	endswitch
	
	return returnValue
End

// Takes in currentOptionsString and modifies it to add or remove "WIN:"+targetname. Returns the resulting string.
// If fromTarget is non-zero, it is added; if zero, it is removed if present
static Function/S MakeTargetOptions(String currentOptionsString, Variable fromTarget)
	Variable WINpos = StrSearch(currentOptionsString, "WIN:", 0)
	if (WINpos >= 0)
		currentOptionsString = RemoveByKey("WIN", currentOptionsString, ":", ",")
	endif
	if (fromTarget)
		String targetWin = WinName(0, 3)		// 3 = graphs and tables
		if (strlen(targetWin) > 0)
			Variable fstrlen = StrLen(currentOptionsString)
			if (fstrlen > 0)
				if (CmpStr(currentOptionsString[fstrlen-1], ",") != 0)
					currentOptionsString += ","
				endif
			endif
			currentOptionsString += "WIN:"+targetWin
		endif
	endif
	
	return currentOptionsString
End

Function AutoMPF_DSFromTargetCheckProc(s)
	STRUCT WMCheckboxAction &s	
	if (s.eventCode == 2)		// mouse up
		String listboxName, currentOptions
		
		listboxName = "SelectDataSetsYSelector"
		currentOptions = WS_GetListOptionsStr(s.win, listboxName)
		WS_SetListOptionsStr(s.win, listboxName, MakeTargetOptions(currentOptions, s.checked))
		
		listboxName = "SelectDataSetsXSelector"
		currentOptions = WS_GetListOptionsStr(s.win, listboxName)
		WS_SetListOptionsStr(s.win, listboxName, MakeTargetOptions(currentOptions, s.checked))
	endif
End

Function AutoMPF_DSSelectorFilterSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			string listboxName = "SelectDataSetsYSelector"
			if (CmpStr(sva.ctrlName, "DataSets_XListFilterString") == 0)
				listboxName = "SelectDataSetsXSelector"
			endif
			if (strlen(sva.sval) == 0)
				sva.sval="*"
				SetVariable $sva.ctrlName,win=$sva.win,value= _STR:"*"
			endif
			WS_SetFilterString(sva.win, listboxName, sva.sval)
			break
	endswitch

	return 0
End

Function AutoMPF_DSSelectPopupMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	switch( s.eventCode )
		case 2: // mouse up
			String indexedPath = "", listofPaths = ""
			Variable index=0
			string listboxName = "SelectDataSetsYSelector"
			if (CmpStr(s.ctrlName, "DataSets_XListSelectMenu") == 0)
				listboxName = "SelectDataSetsXSelector"
				index=1
			endif
			switch (s.popNum)
				case 1:			// select all
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 1
					while (1)
					break;
				case 2:			// select every other
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 2
					while (1)
					break;
				case 3:			// select every other starting with second
					index += 1
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 2
					while (1)
					break;
				case 4:			// select every third
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
				case 5:			// select every third starting with second
					index += 1
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
				case 6:			// select every third starting with third
					index += 2
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
			endswitch
			WS_ClearSelection(s.win, listboxName)
			WS_SelectObjectList(s.win, listboxName, listofPaths)
			break
	endswitch
End

static Function SelectData_CheckForDupYWaves()
	Wave/T listwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")
	Wave selwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")
	Variable nrows = DimSize(listwave, 0)
	Variable i,j

	nrows = DimSize(listwave, 0)
	if (nrows < 2)
		return 0
	endif
	
	for (i = 0; i < nrows-1; i += 1)								// look for duplicate Y waves, an N^2 operation!
		for (j = i+1; j < nrows; j += 1)
			if (CmpStr(listwave[i][0], listwave[j][0]) == 0)		// found a duplicate
				selwave = 0
				selwave[i][0] = selwave[i][0] | 1
				selwave[j][0] = selwave[j][0] | 1
				DoUpdate
				DoAlert 0, "Found duplicate Y waves."
				return 1
				break;
			endif
		endfor
	endfor
	
	return 0
End

Function AutoMPF_SelectDataSetsArrowButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String YWaves = WS_SelectedObjectsList(s.win, "SelectDataSetsYSelector")
		String XWaves = WS_SelectedObjectsList(s.win, "SelectDataSetsXSelector")
		Variable nwaves = ItemsInList(YWaves)
		Variable nXwaves = ItemsInList(Xwaves)
		
		if (nXwaves == 1)
			String singleXwave = StringFromList(0, XWaves)
		endif
		
		Wave/T listwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")
		Wave selwave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")
		Variable nrows = DimSize(listwave, 0)
		Variable i, j, index, startWave=0
		Variable DoingX=0, DoingY=0
		
		if (CmpStr(s.ctrlName, "SelectDataSetsYArrowBtn") == 0)
			// first insert selections into cells that are selected
			index = 0
			for (i = 0; i < nrows; i += 1)
				if ( (strlen(listWave[i][0]) == 0) || (selwave[i][0] & 9) )
					listWave[i][0] = StringFromList(index, YWaves)
					index += 1
					if (index >= nwaves)
						break;
					endif
				endif
			endfor
			startWave = index
			// if any are left over, add rows to receive the waves, and leave the X cells blank
			DoingY = 1
		elseif  (CmpStr(s.ctrlName, "SelectDataSetsXArrowBtn") == 0)
			if (nXwaves > 1)
				for (i = 0; i < nrows; i += 1)
					if ( (strlen(listWave[i][1]) == 0) || (selwave[i][1] & 9) )
						listWave[i][1] = StringFromList(index, XWaves)
						index += 1
						if (index >= nXwaves)
							break;
						endif
					endif
				endfor
				startWave = index
				DoingX = 1
				nwaves = nXwaves
			else
				for (i = 0; i < nrows; i += 1)
					if ( (strlen(listWave[i][1]) == 0) || (selwave[i][1] & 9) )
						listWave[i][1] = singleXwave
					endif
				endfor
			endif
		else
			if ( (nwaves != nXwaves) && (nXwaves != 1) )
				DoAlert 0, "You have selected "+num2str(nwaves)+" Y waves, but "+num2str(ItemsInList(Xwaves))+" X waves."
				return -1
			endif
			DoingX = 1
			DoingY = 1
		endif

		if (DoingX || DoingY)
			if (startWave < nwaves)
				Variable firstNewRow = nrows
				InsertPoints firstNewRow, nwaves-startWave, listwave, selwave
				for (i = startWave; i < nWaves; i += 1)
					index = firstNewRow+i
					if (DoingY)
						listwave[index][0] = StringFromList(i, YWaves)
					endif
					if (DoingX)
						if (nXwaves == 1)
							listwave[index][1] = singleXwave
						else
							listwave[index][1] = StringFromList(i, XWaves)
						endif
					endif
				endfor
			endif
		endif
		
		SelectData_CheckForDupYWaves()
	endif
End

Function AutoMPF_SelectedDataListBoxProc(s) : ListBoxControl
	STRUCT WMListboxAction &s

	Variable row = s.row
	Variable col = s.col
	WAVE/T/Z listWave = s.listWave
	WAVE/Z selWave = s.selWave

	switch( s.eventCode )
		case -1:// control being killed
			break
		case 1: // mouse down
			if ( (s.row >= 0) && (s.row < DimSize(listWave, 0)) && (s.eventMod & 16) )
				// right click menu space	
			endif
			break
		case 2:	// mouse up
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 12:// key stroke
			if ( (s.row == 8) || (s.row == 127) )			// delete or forward delete
				Variable nrows = DimSize(listwave, 0)
				Variable i
				for (i = nrows-1; i >= 0; i -= 1)
					if ( (selwave[i][0] & 9) || ((selwave[i][1] & 9)) )
						DeletePoints i, 1, listwave, selwave
					endif
				endfor
				if (DimSize(listwave, 0) == 0)
					Redimension/N=(0,2) listwave, selwave
				endif
				SelectData_CheckForDupYWaves()
			elseif ( ((s.row == char2num("a")) || (s.row == char2num("A"))) && (s.eventMod & 8) )		// select all
				selwave = selwave[p][q] | 1
			else
				//print "Listbox char code = ", s.row
			endif
			break;
	endswitch

	return 0
End

Function AutoMPF_DataSetsMvSelectedWavesUpOrDown(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode != 2)
		return 0
	endif

	Wave/T SelectedWavesListWave= $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")
	Wave SelectedWavesSelWave	= $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")
	
	Duplicate/O/T/FREE SelectedWavesListWave, DuplicateSelectedWaveListWave
	Duplicate/O/FREE SelectedWavesSelWave, DuplicateSelectedWavesSelWave
	
	Variable rowsInSelectedList = DimSize(SelectedWavesSelWave, 0)
	Variable firstSelectedRow	= rowsInSelectedList
	Variable lastSelectedRow 	= rowsInSelectedList
	Variable nSelectedRows		= 0
	Variable lastRow			= rowsInSelectedList-1
	Variable moveUp				= CmpStr(s.ctrlName, "SelectData_MoveUpButton") == 0
	Variable i
	
	if (moveUp)
		if ( (SelectedWavesSelWave[0][0] & 0x01) || (SelectedWavesSelWave[0][1] & 0x01) )
			return 0		// a cell in the top row is selected; can't move up
		endif
	else
		if ( (SelectedWavesSelWave[lastRow][0] & 0x01) || (SelectedWavesSelWave[lastRow][1] & 0x01) )
			return 0		// a cell in the bottom row is selected; can't move down
		endif
	endif
	
	Variable col
	for (col = 0; col < 2; col += 1)
		nSelectedRows = 0
		
		if (moveUp)
			for (i = 0; i < rowsInSelectedList; i += 1)
				if (SelectedWavesSelWave[i][col] & 0x09)
					SelectedWavesListWave[i-1][col]	= DuplicateSelectedWaveListWave[i][col]
					SelectedWavesSelWave[i-1][col]	= DuplicateSelectedWavesSelWave[i][col]
					SelectedWavesListWave[i][col]	= DuplicateSelectedWaveListWave[i-1][col]
					SelectedWavesSelWave[i][col]	= DuplicateSelectedWavesSelWave[i-1][col]
				endif
			endfor
		else
			for (i = rowsInSelectedList-1; i >= 0; i -= 1)
				if (SelectedWavesSelWave[i][col] & 0x09)
					SelectedWavesListWave[i+1][col]	= DuplicateSelectedWaveListWave[i][col]
					SelectedWavesSelWave[i+1][col]	= DuplicateSelectedWavesSelWave[i][col]
					SelectedWavesListWave[i][col]	= DuplicateSelectedWaveListWave[i+1][col]
					SelectedWavesSelWave[i][col]	= DuplicateSelectedWavesSelWave[i+1][col]
				endif
			endfor
		endif
	endfor
end

Function AutoMPF_ActionButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T SelectedWavesListWave = $(kAutoMPF_WorkingDir+"SelectedDataSetsListWave")
			Wave SelectedWavesSelWave = $(kAutoMPF_WorkingDir+"SelectedDataSetsSelWave")
			strswitch( ba.ctrlName )
				case "DataSets_SelectAll":
					SelectedWavesSelWave = SelectedWavesSelWave[p][q] | 1
					break
				case "DataSets_OKButton":
					Variable nSelected = DimSize(SelectedWavesListWave, 0)
					Variable i
					
					// Some sanity checks
					for (i = 0; i < nSelected; i += 1)
						if (CmpStr(SelectedWavesListWave[i][0], SelectedWavesListWave[i][1]) == 0)
							SelectedWavesSelWave = 0
							SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
							SelectedWavesSelWave[i][1] = SelectedWavesSelWave[i][1] | 1
							DoUpdate
							DoAlert 0, "You have selected the same wave for both the Y and the X waves."
							return 0
						endif
						Wave/Z w = $(SelectedWavesListWave[i][0])
						if (!WaveExists(w))
							SelectedWavesSelWave = 0
							SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
							DoUpdate
							DoAlert 0, "One of your Y waves is missing."
							return 0
						endif
						Wave/Z xw = $(SelectedWavesListWave[i][0])
						if (WaveExists(xw) && (numpnts(w) != numpnts(xw)))
							SelectedWavesSelWave = 0
							SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
							SelectedWavesSelWave[i][1] = SelectedWavesSelWave[i][1] | 1
							DoUpdate
							DoAlert 0, "The number of points in your Y wave does not match the number of points in the X wave."
							return 0
						endif
					endfor
		
					Wave/T listwave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
					Wave selwave	= $(kAutoMPF_WorkingDir+"AutoMPF_WaveSelect")
					Redimension/N=(1, -1, -1) listwave, selwave
					listwave = ""
					selwave = 0
					
					for (i = 0; i < nSelected; i += 1)
						Wave w = $(SelectedWavesListWave[i][0])
						Wave/Z xw = $(SelectedWavesListWave[i][1])
		
						AutoMPF_AddYWaveToList(w, xw)
					endfor
					// no break
				case "DataSets_CancelButton":
					KillWaves/Z SelectedWavesListWave, SelectedWavesSelWave
					DoWindow/K $(ba.win)
					break
			endswitch
		break
	endswitch

	return 0
End

static Function AllFieldsAreBlank(w, row)
	Wave/T w
	Variable row
	
	Variable i
	Variable lastRow = DimSize(w, 1)
	for (i  = 0; i < lastRow; i += 1)
		if (strlen(w[row][i][0]) != 0)
			return 0
		endif
	endfor
	
	return 1
end

static Function AutoMPF_AddYWaveToList(w, xw)
	Wave w
	Wave/Z xw
	
	Wave/T listwave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
	Wave selwave	= $(kAutoMPF_WorkingDir+"AutoMPF_WaveSelect")
	
	Variable nextRow
	
	if (DimSize(listWave, 0) == 1)
		if (AllFieldsAreBlank(listWave, 0))
			nextRow = 0
		else
			nextRow = 1
		endif
	else
		nextRow = DimSize(listWave, 0)
	endif
	
	Redimension/N=(nextRow+1, -1, -1) listWave, selWave
	selWave[nextRow] = 0
	listWave[nextRow] = ""
	
	AutoMPF_SetYWaveForRowInList(w, xw, nextRow)
end

static Function AutoMPF_SetYWaveForRowInList(w, xw, row)
	Wave/Z w
	Wave/Z xw
	Variable row
	
	Wave/T ListWave = $(kAutoMPF_WorkingDir+"AutoMPF_WaveList")
	
	// ListWave format:
	// Layer[0]: [0] Y name, [1] X name, [2] Y dim
	// Layer[1]: [0] Y path, [1] X path, [2] X dim

	if (WaveExists(w))
		ListWave[row][0][0] = NameOfWave(w)
		ListWave[row][0][1] = GetWavesDataFolder(w, 2)
		ListWave[row][2][0] = num2str(WaveDims(w))+"D"
	else
		ListWave[row][0][0] = ""
		ListWave[row][2][0] = ""
		ListWave[row][0][1] = ""
	endif
	if (WaveExists(xw))
		ListWave[row][1][0] = NameOfWave(xw)
		ListWave[row][1][1] = GetWavesDataFolder(xw, 2)
		ListWave[row][2][1] = num2str(WaveDims(xw))+"D"
	else
		ListWave[row][1][0] = "_calculated_"
		ListWave[row][1][1] = ""
		ListWave[row][2][1] = ""
	endif
end