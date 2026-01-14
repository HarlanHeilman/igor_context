#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#pragma IgorVersion=9.00
#pragma version=9.00 // ship with Igor 9
#include <WaveSelectorWidget>
#include <WMBatchCurveFitDefs>
#include <WMBatchCurveFitResults>
#include <WMSelectorControlSet>
#include <WMBatchCurveFit>

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// Panel Set-up /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function InitPanelVariables()
	///// Set up global variables /////
	///// Package directory /////
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	String packageDFRString = GetDataFolder(1, packageDFR)

	Variable /G packageDFR:WMfileSelectionTop = 5
	NVAR fileSelectionTop = packageDFR:WMfileSelectionTop
		
	String /G packageDFR:WMcurrCoefEntryProc = cCtrl_oneForAll
	String /G packageDFR:WMcurrConstrEntryProc = cCtrl_setWithControls
	String /G packageDFR:WMFitFunc = "gauss"
			
	/// state variables ///
	Variable /G packageDFR:WMdoMask = 0
	Variable /G packageDFR:WMdoWeight = 0
	Variable /G packageDFR:WMdoRange = 0
	
	Variable localVar = NumVarOrDefault(packageDFRString+"WMMainPanelLeft", 45)
	Variable /G packageDFR:WMMainPanelLeft = localVar
	NVAR left = packageDFR:WMMainPanelLeft
	localVar = NumVarOrDefault(packageDFRString+"WMMainPanelTop", 55)
	Variable /G packageDFR:WMMainPanelTop = localVar
	NVAR top = packageDFR:WMMainPanelTop
	localVar = NumVarOrDefault(packageDFRString+"WMMainPanelRight", left+885)
	Variable /G packageDFR:WMMainPanelRight = localVar
	NVAR right = packageDFR:WMMainPanelRight
	localVar = NumVarOrDefault(packageDFRString+"WMMainPanelBottom", top+625)
	Variable /G packageDFR:WMMainPanelBottom = localVar
	NVAR bottom = packageDFR:WMMainPanelBottom

	Variable /G packageDFR:WMlistBoxHeight=(bottom-top-(625-162*2))/2
	Variable /G packageDFR:WMlistBoxWidth=(right-left-(885-320*2)-40)/2	 
	
	localVar = NumVarOrDefault(packageDFRString+"WMtabRegionBotOffset", 70)
	Variable /G packageDFR:WMtabRegionBotOffset = localVar
		
	Make /O/T/N=0 packageDFR:WMcoefListBoxLW
	Make /O/B/N=0 packageDFR:WMcoefListBoxSW
	Make /O/T/N=0 packageDFR:WMcoefListBoxTitles
	
	/// Results Panel Variables
	String /G packageDFR:WMGOFFunctions  = "IOA=indexOfAgreement;"// Goodness of Fit functions, in [key=value;key=value;...] format
End

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Panel Hook Funcs ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function MainWindowHook(s)
	STRUCT WMWinHookStruct &s
	
	strswitch (s.eventName)
		case "activate":	
			//// Update panel
			String updatePanelStr = GetUserData("batchFitPanel", "", "BCF_UPDATEPANELVERSION")
			Variable updatePanelNum = str2num(updatePanelStr)
			if (numtype(updatePanelNum)==2)
				updatePanelNum = 0
			endif			
			if (updatePanelNum < BCF_UPDATEPANELVERSION)
				UpdateBatchCurveFitPanel(updatePanelNum)
			endif
			
		
			String functionStack = GetRTStackInfo(0)   // activate hook function gets called from inside WMUpdateBatchControlPanel sometimes.  
													    // If WMUpdate... is in the stack, don't call it again.  Block re-entry won't work because the first WMUpdate... is not due
													    // to a window hook event.
													    // If the window is activated from within a function it seems to cause the problem.  So only update if the function stack starts with MainWindowHook
													    // One version of the problematic stack trace is: 
													    // WMDoRenameButtonProc;WMUpdateBatchControlPanel;WMGenBatchRunsSummary;isUserFitFunc;getAllDimLabels;MainWindowHook;WMUpdateBatchControlPanel;WMGenBatchRunsSummary;
													    //  Easily reproduced now: create a BCF dialog, such as by clicking "Rename," then move that dialog over the BCF panel so that clicking a button 
													    //  leaves the mouse arrow over the panel.  Error occurs...
			if (StringMatch(functionStack, "MainWindowHook;*"))
				WMUpdateBatchControlPanel()
			endif
			break
		case "moved":	
		case "resize":	
			DFREF packageDFR = GetBatchCurveFitPackageDFR()
			String packageDFRString = GetDataFolder(1, packageDFR)
			String savedDataFolder = GetDataFolder(1)
			SetDataFolder packageDFRString
			
			NVAR mainPanelY = packageDFR:WMMainPanelTop
			NVAR mainPanelX = packageDFR:WMMainPanelLeft
			NVAR mainPanelRight =	packageDFR:WMMainPanelRight
			NVAR mainPanelBottom = packageDFR:WMMainPanelBottom
			
			GetWindow batchFitPanel wsize
			mainPanelY=V_top
			mainPanelX=V_left
			mainPanelRight= V_right
			mainPanelBottom= V_bottom
			
			SetDataFolder savedDataFolder
			break
		case "kill":
			WMSaveCurrentBatchSettings()
			break
		default:
			break
	endswitch
End

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Control Procedures //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function BatchDirWaveSelectorNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR batchDataDir = packageDFR:WMbatchDataDir

	batchDataDir=wavepath+":"
	
	WMUpdateBatchControlPanel()
	WMUpdateWaveSelectBoxes()
end

Function InitialGuessWaveSelectorNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR initGuessWaveFullPath = packageDFR:WMInitGuessWaveFullPath	
	initGuessWaveFullPath = PopupWS_GetSelectionFullPath(windowName, ctrlName)
End

Function ConstraintsWaveSelectorNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR constrWaveFullPath = packageDFR:WMConstrWaveFullPath
	constrWaveFullPath = PopupWS_GetSelectionFullPath(windowName, ctrlName)
End

// Tab Control Functions
Function BatchFitTabControlProc(TC_Struct)
	STRUCT WMTabControlAction &TC_Struct

	if (TC_Struct.eventCode == 2)	
		BatchFitSetTabControlContent(TC_Struct.tab)
		if (TC_Struct.tab==0)
			WMUpdateBatchControlPanel()
		endif
		if(TC_Struct.tab==2)
			//updateCoefListBox()			
			WMUpdateCoefControls()
		endif
		if (TC_Struct.tab==3)
			DFREF packageDFR = GetBatchCurveFitPackageDFR()
			Wave /T batchWaveNames = packageDFR:WMbatchWaveNames
			WMSCSGetSelectedWaveNames("YWaves", batchWaveNames)
		endif
		if (TC_Struct.tab==4)
			DFREF packageDFR = GetBatchCurveFitPackageDFR()
			Wave /T batchWaveNames = packageDFR:WMbatchWaveNames
			WMSCSGetSelectedWaveNames("YWaves", batchWaveNames)
		endif
	endif
End

// Mask and Weight setup
Function WMsetUseMaskWeightCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			
	
	WMsetUseMaskWeight(ctrlName, checked)
End	

Function WMsetRangeLimitCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WMsetUseMaskWeight("WMMaskChck", 0) 
	Checkbox WMMaskChck win=batchFitPanel#Tab4ContentPanel, disable=checked*2
	
	SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, disable=!checked*2
	SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, disable=!checked*2
End

Function WMsetUseMaskWeight(ctrlName,checked) 
	String ctrlName
	Variable checked	

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	NVAR doMask = packageDFR:WMdoMask
	NVAR doWeight = packageDFR:WMdoWeight
	NVAR doRange = packageDFR:WMdoRange

	if (!cmpStr(ctrlName, "WMMaskChck"))	
		doMask = checked
		WMSCSSetDisableControl("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", !checked*2)
		Checkbox WMRangeChck win=batchFitPanel#Tab4ContentPanel, disable=checked*2
		SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, disable=max(checked*2, !doRange*2)
		SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, disable=max(checked*2, !doRange*2)
	elseif (!cmpStr(ctrlName, "WMWeightChck"))	
		doWeight = checked
		WMSCSSetDisableControl("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", !checked*2)
	endif
End

Function SetFitTypeProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	if (PU_Struct.eventCode==2)
		UpdateFitType(PU_Struct.popStr)
	endif
End

Function UpdateFitType(fitType)
	String fitType
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	WAVE /T inArgsTxt = packageDFR:inputArgsTextDescription
	SVAR currFitFunc = packageDFR:WMFitFunc
	NVAR xoffset = packageDFR:WMXOffset
	WAVE WMInitCoefs = packageDFR:WMInitCoefs
	WAVE WMConstraints = packageDFR:$strConstConstrWaveName //WMConstraints
	SVAR constraintStr = packageDFR:WMConstraintStr

	PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel, popmatch=fitType

	if (CmpStr(currFitFunc, fitType))			// check if the value actually changed
		WMInitCoefs = NaN
		WMConstraints = NaN
		currFitFunc = fitType
		constraintStr = ""
	
		WAVE inArgs = packageDFR:nInputArgsHash
		Variable nCoefs = inArgs[%$currFitFunc]

		String currFormula = WMBCFGetCurrFormula(currFitFunc, nCoefs)
		if (!strlen(currFormula))
			currFormula = "(Formula not specified in function comments)"
		endif
		TitleBox FitFunctionFormula 	win=batchFitPanel#Tab2ContentPanel, title=currFormula
		
		Variable isUFit = isUserFitFunc(currFitFunc)
		if (!isUFit)
			SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, disable=!(numtype(nCoefs)==2)
		else	
			Struct curveFitDialogComments curveFitArgs
			GetCurveFitFuncInfo(currFitFunc, curveFitArgs)		
		
			if (curveFitArgs.isFromCurveFitDialogComplete)
				SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, disable=!(numtype(nCoefs)==2)
			else
				SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, disable=0
			endif
			NVAR WMnCoefs = packageDFR:WMnCoefs
			WMnCoefs = nCoefs						
		endif
		if (stringmatch(currFitFunc, "*xoffset*"))
			SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, disable=0
		else
			SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, disable=1
			xoffset = NaN
		endif
	
		updateCoefListBox()
	endif
End

Function setConstraintEntryProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	
	String popStr
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	String /G packageDFR:WMcurrConstrEntryProc = popStr
	
	WMUpdateCoefControls()	
End

Function setCoefficientEntryProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	
	String popStr
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	String /G packageDFR:WMcurrCoefEntryProc = popStr
	
	WMUpdateCoefControls()
End

Function WMSetNCoefsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName		// name of variable

	// Let User Fit functions vary n coefficients
	DFREF packageDFR = GetBatchCurveFitPackageDFR() 
	SVAR currFitFunc = packageDFR:WMFitFunc
	Variable isUFit = isUserFitFunc(currFitFunc)
	if (isUFit)
		WAVE inArgs = packageDFR:nInputArgsHash
		inArgs[%$currFitFunc] = varNum
	endif
	
	WMUpdateCoefControls()
End

Function WMUpdateCoefControls()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()

	// update the fit function 
	SVAR currFitFunc = packageDFR:WMFitFunc
	NVAR WMnCoefs = packageDFR:WMnCoefs

	String currFormula = WMBCFGetCurrFormula(currFitFunc, WMnCoefs)
	if (!strlen(currFormula))
		currFormula = "(Formula not specified in function comments)"
	endif
	TitleBox FitFunctionFormula 	win=batchFitPanel#Tab2ContentPanel, title=currFormula

	SVAR currCoefEntryProc = packageDFR:WMcurrCoefEntryProc	
	strswitch (currCoefEntryProc)
		case cCtrl_oneForAll:
		case cCtrl_lastSuccess:			
			// show the listbox, change the title, show the general constraint controls
			TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=0
			SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, disable=0
			TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel,	disable=0
			
			// hide the constraint text wave selector			
			TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=2
			SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, disable=2	
			
			break
		case cCtrl_2DWave:			
			TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=2
			SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, disable=2
			TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel,	disable=2
			
			// show the constraint text wave selector	
			TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=0
			SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, disable=0	
			
			break
		default:
			break
	endswitch

	SVAR currConstrEntryProc = packageDFR:WMcurrConstrEntryProc
	strswitch (currConstrEntryProc)
		case cCtrl_setWithControls:			
			SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, disable=2
			TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=2
			SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, disable=0
			TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=0			
			break
		case cCtrl_setWithTextWave:	
			TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=0	
			SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, disable=0
			TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, disable=2
			SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, disable=2			
			break
		default:
			break
	endswitch

	updateCoefListBox()   
End

/////// Event handler for the Functions and Coefficients tab -> Input Initial Guesses listbox //////
Function WMInitialGuessProc(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct
	
	Variable i, isUFit
	
	///////// response to click in the Initial Guess column ///////
	if (LB_Struct.eventCode==4 && LB_Struct.col==1)		// Cell selection
		DFREF packageDFR = GetBatchCurveFitPackageDFR()
		SVAR currFitFunc = packageDFR:WMFitFunc
		
		isUFit = isUserFitFunc(currFitFunc)
		WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW

		if (LB_Struct.row < DimSize(coefListBoxLW,0))	
			if (numtype(str2num(coefListBoxLW[LB_Struct.row][LB_Struct.col]))==2 && LB_Struct.row < DimSize(coefListBoxLW, 0))
				coefListBoxLW[LB_Struct.row][1] = ""
				ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, listWave=coefListBoxLW
		
				///// a vicious hack to make the hint text disappear and the edit cell to keep the focus without the set code (LB_Struct.eventCode==7) getting
				///// executed in response to the controlUpdate.
				Variable /G packageDFR:ignoreEndEdit =1
				controlUpdate /W=batchFitPanel#Tab2ContentPanel coefInitGuessDirect
				ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, setEditCell={LB_Struct.row, 1, 0, 0}	
			endif
		endif
	endif
	
	///////// response to click in the Hold column ///////
	if (LB_Struct.eventCode==2 && LB_Struct.col==2)		// Mouse up on hold checkbox
		updateCoefListBox()
	endif
	
	if (LB_Struct.eventCode==7 && (LB_Struct.col==1 || LB_Struct.col==3 || LB_Struct.col==4 || LB_Struct.col==5))		//Finish Edit
		DFREF packageDFR = GetBatchCurveFitPackageDFR()
		NVAR /Z ignoreEndEdit = packageDFR:ignoreEndEdit  /// the purpose of ignoreEndEdit is explained under the "vicious hack" comment above
		if (NVAR_Exists(ignoreEndEdit) && ignoreEndEdit)
			ignoreEndEdit=0
			return 0
		endif
		
		SVAR currFitFunc = packageDFR:WMFitFunc
		isUFit = isUserFitFunc(currFitFunc)
		WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW
		WAVE WMInitCoefs = packageDFR:WMInitCoefs	
		WAVE WMConstraints = packageDFR:$strConstConstrWaveName //WMConstraints

		if (LB_Struct.row < DimSize(coefListBoxLW,0))
			Variable newVal = str2num(coefListBoxLW[LB_Struct.row][LB_Struct.col])

			if (LB_struct.col==1) 	
				if (numtype(newVal)==2)
					if (isUFit)
						coefListBoxLW[LB_Struct.row][1] = "[init guess required]"
					else
						coefListBoxLW[LB_Struct.row][1] = "[auto guess]"			
					endif
				endif
				WMInitCoefs[LB_Struct.row]=newVal
			elseif (LB_struct.col==3) 	// min constraint
				Variable maxVal = str2num(coefListBoxLW[LB_Struct.row][4])
				if (numtype(newVal)==2)
					coefListBoxLW[LB_Struct.row][3] = ""
				elseif (numType(maxVal)!=2 &&  newVal > maxVal)
					newVal = maxVal
					coefListBoxLW[LB_Struct.row][3] = num2str(newVal)					
				endif
				WMConstraints[LB_Struct.row][0] = newVal
			elseif (LB_struct.col==4)	// max constraint
				Variable minVal = str2num(coefListBoxLW[LB_Struct.row][3])
				if (numtype(newVal)==2)
					coefListBoxLW[LB_Struct.row][4] = ""
				elseif (numType(minVal)!=2 &&  newVal < minVal)
					newVal = minVal
					coefListBoxLW[LB_Struct.row][4] = num2str(newVal)
				endif
				WMConstraints[LB_Struct.row][1] = newVal				
			elseif (LB_struct.col==5 && isUFit)		
				if (numtype(newVal)==2)
					coefListBoxLW[LB_Struct.row][5] = "1e-6"
					newVal = 1e-6
				endif
//				WMInitCoefs[LB_Struct.row]=newVal
			endif
		endif
	endif
	
End

Function WMHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName
		
	DisplayHelpTopic "Batch Curve Fitting"
End

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Update Functions ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function WMUpdateBatchControlPanel()

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR batchDataDir = packageDFR:WMbatchDataDir

	SVAR currBatchName = packageDFR:WMcurrBatchName
	
	WMSaveCurrentBatchSettings()	
	
	Wave /T batchRunsSummary = WMGenBatchRunsSummary()
	
	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel, listWave=batchRunsSummary
	
	if (DimSize(batchRunsSummary, 0))
		Duplicate /FREE /R=[][0, 0] batchRunsSummary batchNames
		Redimension /N=(numpnts(batchNames)) batchNames
		FindValue /TEXT=currBatchName /TXOP=2 /Z batchNames
		
		Variable iCurrBatchName = V_Value
		
		if (iCurrBatchName < 0)
			ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB 
			Variable currSelRow = V_Value
			if (currSelRow >= DimSize(batchRunsSummary,0))
				currSelRow = DimSize(batchRunsSummary,0)-1
			endif
		
			currBatchName = batchRunsSummary[currSelRow][0]
			ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel, listWave=batchRunsSummary, selRow=currSelRow
			WMLoadBatch(currBatchName)
		else 	
			ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel, selRow=iCurrBatchName			
		endif
	else
		currBatchName = UniqueName("NewBatchCurveFit", 11, 0)
	endif
End

Function /Wave WMGetBatchRunsSummary()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	Wave /T/Z batchRunsSummary = packageDFR:WMBatchRunsSummary
	if (!waveExists(batchRunsSummary))
		Make /N=(0,6) packageDFR:WMBatchRunsSummary
		Wave /T/Z batchRunsSummary = packageDFR:WMBatchRunsSummary   
	endif
	return batchRunsSummary
End

Function /Wave WMGenBatchRunsSummary()	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()	
	SVAR currBatchName = packageDFR:WMcurrBatchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir
	
	DFREF batchRunsDFR = $(ReplaceString("::", currDataFolder+":"+constBatchRunsDirName, ":"))
		
	Variable nBatchDirs = CountObjectsDFR(batchRunsDFR, 4)
	nBatchDirs = numtype(nBatchDirs)==2 ? 0 : nBatchDirs
	
	KillWaves /Z packageDFR:WMBatchRunsSummary
	Make /O/T/N=(nBatchDirs, 6) packageDFR:WMBatchRunsSummary
	Wave /T batchRunsSummary = packageDFR:WMBatchRunsSummary

	Variable i,j
	Struct batchDataStruct batchInfo
	initBatchDataStruct(batchInfo)
	
	for (i=0; i<nBatchDirs; i+=1)
		batchRunsSummary[i][0] = GetIndexedObjNameDFR(batchRunsDFR, 4, i)
		getBatchData(currDataFolder, batchRunsSummary[i][0], batchInfo)
		
		Variable wDate	
		String dataFolderStr = ReplaceString("::", currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(batchRunsSummary[i][0]), ":")
		String utilityWaveName = dataFolderStr+":WMBatchResultsMatrix"
		if (waveExists($utilityWaveName))
			wDate = ModDate($utilityWaveName)
			batchRunsSummary[i][1] = Secs2Date(wDate, 0)+" "+Secs2Time(wDate,2)
		else
			batchRunsSummary[i][1] = "no results"
		endif
		
		if (strlen(batchInfo.fitFunc) > 0)
			batchRunsSummary[i][2] = batchInfo.fitFunc
		else
			batchRunsSummary[i][2] = "no fit func specified"			
		endif
		
		String coefString=""
		
		if (waveExists(batchInfo.coefWave))				  		// coefficient's originally designed to have a possible wave for each batch, hence wave o' waves.  		
			Variable nCoefWaves =	DimSize(batchInfo.coefWave, 0)														
			for (j=0; j< nCoefWaves; j+=1)	// UI simplicity suggested only coef for initial or same for all  
				if (numtype(batchInfo.coefWave[j])!=2)
					Variable util = batchInfo.coefWave[j]
					sprintf coefString, "%s%g;", coefString, util
				elseif (isUserFitFunc(batchInfo.fitFunc))
					coefString += "N;"
				else
					coefString += "A;"
				endif
			endfor	
		endif
		
		batchRunsSummary[i][3] = coefString
		
		String holdString = ""
		if (waveExists(batchInfo.coefHold))  						// coefficient's originally designed to have a possible wave for each batch, hence wave o' waves.  
			Variable nHoldWaves = DimSize(batchInfo.coefHold, 0)	
			for (j=0; j<nHoldWaves; j+=1)	// UI simplicity suggested only coef for initial or same for all 
				if (numtype(batchInfo.coefHold[j])!=2)
					holdString += num2str(batchInfo.coefHold[j])+";"
				else
					holdString += "0;"
				endif
			endfor	
		endif
		
		batchRunsSummary[i][4] = holdString
		
		String weightMaskString = "    "
		if (numtype(batchInfo.weightSourceType)==2)
			weightMaskString += "N        "
		elseif (batchInfo.weightSourceType)
			weightMaskString += "Y         "
		else
			weightMaskString += "N         "
		endif
		if (numtype(batchInfo.maskSourceType)==2)
			weightMaskString += "N"
		elseif (batchInfo.maskSourceType)
			weightMaskString += "Y"
		else
			weightMaskString += "N"
		endif
		
		batchRunsSummary[i][5] = weightMaskString
		
	endfor
	SetDimLabel 1, 0, 'Run Name', batchRunsSummary
	SetDimLabel 1, 1, 'Run Date', batchRunsSummary
	SetDimLabel 1, 2, 'Fit Func', batchRunsSummary
	SetDimLabel 1, 3, 'Initial Guess', batchRunsSummary
	SetDimLabel 1, 4, 'Hold?', batchRunsSummary
	SetDimLabel 1, 5, 'Weight? Mask?', batchRunsSummary
	
	return batchRunsSummary
End

Function WMNewBatchButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	GetWindow batchFitPanel wsize
	
	Variable roffset = (V_right-WMBCFRenamePanelWidth+V_left)/2
	Variable toffset = (V_bottom-WMBCFRenamePanelHeight+V_top)/2
	NewPanel /FLT=1 /K=1 /N=renamePanel /W=(roffset, toffset, roffset+WMBCFRenamePanelWidth, toffset+WMBCFRenamePanelHeight) as " "	
	
	SetVariable setBatchName, win=renamePanel, pos={20,25}, size={WMBCFRenamePanelWidth-40,25}, title="New Batch Name", fSize=14, value=_STR:""//, proc=newEnter
	DrawText 138,71,"Note: Batch names are limited to 28 chars"	
	
	Button WMNewBatchCancelButton, win=renamePanel,pos={75,100},size={75,20}, title="Cancel", proc=WMCreateButtonProc
	Button WMNewBatchCreateButton, win=renamePanel,pos={WMBCFRenamePanelWidth-145,100},size={75,20}, title="Create", proc=WMCreateButtonProc
End

// Simply to make hitting "Enter" function as you'd imagine: it creates the batch given the current name
//Function newEnter(SV_Struct) : SetVariableControl
//	STRUCT WMSetVariableAction &SV_Struct
//
//	if (SV_Struct.eventCode==2) // enter key
//		WMCreateButtonProc("WMNewBatchCreateButton")
//	endif
//End

Function WMCreateButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Variable closePanel = 1
	if (!CmpStr(ctrlName, "WMNewBatchCreateButton"))
		ControlInfo /W=renamePanel setBatchName
		closePanel = WMCreateNewBatch(S_value)
	endif
	
	if (closePanel)
		Execute/P/Q/Z "DoWindow/W=renamePanel/K renamePanel"
	endif
End

Function WMCreateNewBatch(newBatchName)
	String newBatchName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currDataFolder = packageDFR:WMbatchDataDir
	SVAR currBatchName = packageDFR:WMcurrBatchName
	
	STRUCT batchDataStruct batchInfo
	initBatchDataStruct(batchInfo)
	
	if (strlen(newBatchName)==0)
		DoAlert /T="Create Error" 0, "Error: No batch name specified."
		return 0
	elseif (strlen(newBatchName)>28)
		DoAlert /T="Batch Name Too Big" 0, "Batch names are limited to 28 chars.  The  name "+newBatchName+" has "+num2str(strlen(newBatchName))+" chars."
		return 0
	elseif (DataFolderExists(ReplaceString("::",  currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(newBatchName), ":")))
		DoAlert /T="Batch Exists" 2, "Folder "+PossiblyQuoteName(newBatchName)+" already exists.  Click Yes to load it, No to overwrite the existing batch, or Cancel to do nothing."
	
		switch (V_flag)
			case 1:
				WMLoadBatch(PossiblyQuoteName(newBatchName))
				break
			case 2:
				currBatchName = newBatchName
				
				batchInfo.batchDir = currDataFolder
								
				WMStoreBatchData(batchInfo, currBatchName)
				WMInitializeControls()
				break
			case 3:
				break
			default:
		endswitch
	else
		currBatchName = NewBatchName
		
		batchInfo.batchDir = currDataFolder		
		WMStoreBatchData(batchInfo, currBatchName)
		WMInitializeControls()
	endif
	WMUpdateBatchControlPanel()//0, "")
	
	return 1
End

Function WMInitializeControls()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currDataFolder = packageDFR:WMbatchDataDir
	
	///// Batch Control Tab
	Make /Free /T /N=0 emptyWave
	WMSCSSetSelected(currDataFolder, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", emptyWave)	
	WMSCSSetInputFormat("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", convertTextToFormatVar(WMSCSInForm1Dset1Dset))
	WMSCSSetSelected(currDataFolder, "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel", emptyWave)
	Wave /Z noWave
	WMSCSSetFilterSettings("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", noWave)
	WMSCSSetFilterSettings("XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel", noWave)
	
	///// functions and coefficients	
	NVAR WMnCoefs = packageDFR:WMnCoefs
	WMnCoefs = 4
	UpdateFitType("gauss")
	NVAR WMXOffset = packageDFR:WMXOffset
	WMXOffset = NaN
	
	WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW
	WAVE coefListBoxSW = packageDFR:WMcoefListBoxSW
	WAVE WMInitCoefs = packageDFR:WMInitCoefs
	WAVE WMConstraints = packageDFR:$strConstConstrWaveName //WMConstraints
	
	Redimension /N=(WMnCoefs) WMInitCoefs
	WMInitCoefs = NaN
	Redimension /N=(WMnCoefs, 2) WMConstraints
	WMConstraints = NaN
	
	Redimension /N=(WMnCoefs, 6) coefListBoxLW, coefListBoxSW
	Variable i
	for (i=0; i<WMnCoefs; i+=1)
		coefListBoxSW[i][2] = 32 
	endfor	
	
	WMSCSSetSelected(currDataFolder, "weightWaves", "batchFitPanel#Tab2ContentPanel#weightWavesPanel", emptyWave)
	WMSCSSetSelected(currDataFolder, "maskWaves", "batchFitPanel#Tab3ContentPanel#maskWavesPanel", emptyWave)	
		
	WMsetUseMaskWeight("WMMaskChck",0) 
	WMsetUseMaskWeight("WMWeightChck",0)
	
	SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, value=_NUM:0
	SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, value=_NUM:0	
End

Function WMRenameButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	SVAR batchDataDir = packageDFR:WMbatchDataDir
	Wave /T batchRunsSummary = WMGetBatchRunsSummary()
	
	ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB
	Variable currSelectedRow=V_Value
	if (currSelectedRow < 0)
		DoAlert /T="No batch selected" 0, "Please select a batch to be renamed and try again"
	else
		GetWindow batchFitPanel wsize
	
		Variable roffset = (V_right-WMBCFRenamePanelWidth+V_left)/2
		Variable toffset = (V_bottom-WMBCFRenamePanelHeight+V_top)/2

		NewPanel /K=1 /FLT=1 /N=renamePanel /W=(roffset, toffset, roffset+WMBCFRenamePanelWidth, toffset+WMBCFRenamePanelHeight) as " "	
		SetVariable setBatchName, pos={20,11}, size={WMBCFRenamePanelWidth-40,25}, title="Batch Name", fSize=14, value=_STR:batchRunsSummary[currSelectedRow][0], proc=renameEnter
		Button WMRenameBatchCancelButton, win=renamePanel,pos={75,80},size={75,20}, title="Cancel", proc=WMDoRenameButtonProc
		Button WMRenameBatchRenameButton, pos={WMBCFRenamePanelWidth-145,80},size={75,20}, title="Rename", proc=WMDoRenameButtonProc
	endif
End

Function renameEnter(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct

	if (SV_Struct.eventCode==2) // enter key
		WMDoRenameButtonProc("WMRenameBatchRenameButton")
	endif
End

Function WMDoRenameButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Variable doKill = 1
	
	if (!CmpStr(ctrlName, "WMRenameBatchRenameButton"))		
		DFREF packageDFR = GetBatchCurveFitPackageDFR()
		SVAR batchDataDir = packageDFR:WMbatchDataDir
		Wave /T batchRunsSummary = WMGetBatchRunsSummary()

		ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB		
		Variable selectedRow = V_Value
		
		ControlInfo /W=renamePanel setBatchName 
		String newName = S_Value
		
		if (strLen(newName) > 0 && selectedRow >= 0 && selectedRow < DimSize(batchRunsSummary, 0))
			Variable doRename = 1	
			if (strlen(newName)>28)
				DoAlert /T="Batch Name Too Big" 0, "Batch names are limited to 28 chars.  The  name "+newName+" has "+num2str(strlen(newName))+" chars."
				doRename=0
				doKill=0
			endif          
		
			String batchDir = ReplaceString("::", batchDataDir+":"+constBatchRunsDirName+":", ":")
			String oldName = PossiblyQuoteName(batchRunsSummary[selectedRow][0])
			
			if (DataFolderExists(batchDir+PossiblyQuoteName(newName)))
				DoAlert /T="Batch Name Already Exists" 0, "Batch name "+newName+" already exists.  Batch not renamed."	
				doRename=0
				doKill = 0
			endif
			
			if (doRename)
				batchRunsSummary[selectedRow][0] = newName				
				RenameDataFolder $(batchDir+oldName), $newName
			endif
		endif
	endif
	
	if (doKill)
		Execute/P/Q/Z "DoWindow/W=renamePanel/K renamePanel"
		WMUpdateBatchControlPanel()
	endif
End

Function WMcurrentBatchLBProc(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct
	
	if (LB_Struct.eventCode==4)
		DFREF packageDFR = GetBatchCurveFitPackageDFR()
		SVAR batchDataDir = packageDFR:WMbatchDataDir
		Wave /T batchRunsSummary = WMGetBatchRunsSummary()
		
		if (LB_Struct.row>=0 && LB_Struct.row < DimSize(batchRunsSummary,0))
			WMLoadBatch(batchRunsSummary[LB_Struct.row][0])
		endif
	endif
End

//// Only copy the set-up, not the results.  The intended use is to make copies for experimenting.
Function WMCopyBatchButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currBatchName = packageDFR:WMcurrBatchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir

	Wave /T batchRunsSummary = WMGetBatchRunsSummary()
	
	ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB
	String selectedBatchName = batchRunsSummary[V_Value][0]
	String batchBaseName = selectedBatchName
	
	WMSaveCurrentBatchSettings()		// Copy will get batch info from the batch's data folder.  This function will first save the current batch settings 
	
	Variable copyPos = strsearch(batchBaseName, "Copy", strlen(batchBaseName), 1)
	if (copyPos > 0)
		Variable i, isCopy=1
		for (i=copyPos+4; i<strlen(batchBaseName); i+=1)
			if (numType(str2num(batchBaseName[i]))==2)
				isCopy=0
			endif
		endfor	
		if (isCopy)
			batchBaseName = batchBaseName[0,copyPos-1]
		endif
	endif
	
	String oldDataFolder = ReplaceString("::", currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(selectedBatchName),":")
	String batchFolder = ReplaceString("::", currDataFolder+":"+constBatchRunsDirName, ":")
	
	if (DataFolderExists(oldDataFolder))
		String newName, baseName
		String currFolder = GetDataFolder(1)
		SetDataFolder(batchFolder)
		
		///// No way to be sure how many chars UniqueName will add.   
		newName = getUniqueStrLimNameAndTag(batchBaseName, "Copy", 28, 11)

		SetDataFolder(currFolder)

		Struct batchDataStruct batchInfo
		initBatchDataStruct(batchInfo)
		
		getBatchData(currDataFolder, selectedBatchName, batchInfo)		
		WMStoreBatchData(batchInfo, newName)
		
		WMUpdateBatchControlPanel()
	endif
End

Function WMLoadBatch(batchName)
	String batchName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currBatchName = packageDFR:WMcurrBatchName
	currBatchName = batchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir

	DFREF batchRunsDFR = getBatchFolderDFR(currDataFolder, "")
	Wave /T batchRunsSummary = WMGetBatchRunsSummary() //packageBatchRunsDFR:WMBatchRunsSummary

	Struct batchDataStruct batchInfo
	initBatchDataStruct(batchInfo)
	
	getBatchData(currDataFolder, batchName, batchInfo)
	
	////// Set the data folder for the selector control sets
	WMSCSSetFolder(currDataFolder, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel") 
	WMSCSSetFolder(currDataFolder, "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSSetFolder(currDataFolder, "maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	WMSCSSetFolder(currDataFolder, "weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	WMSCSSetInputFormat("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", batchInfo.yValsSourceType + batchInfo.xValsSourceType*2^WMconstSlaveShiftFactor) 
	WMSCSSetInputFormat("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", batchInfo.maskSourceType)
	WMSCSSetInputFormat("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", batchInfo.weightSourceType)
	
	//// set the selected waves - making an error message for waves that no longer exist in the original data folder ////
	WMSCSSetSelected(currDataFolder, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", batchInfo.batchYWaveNames)
	WMSCSSetSelected(currDataFolder, "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel", batchInfo.batchXWaveNames)
	WMSCSSetSelected(currDataFolder, "maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", batchInfo.batchMaskWaveNames)
	WMSCSSetSelected(currDataFolder, "weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", batchInfo.batchWeightWaveNames)
	
	WMSCSSetFilterSettings("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", batchInfo.yFilterSettings)
	WMSCSSetFilterSettings("XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel", batchInfo.xFilterSettings)
	WMSCSSetFilterSettings("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", batchInfo.maskFilterSettings)
	WMSCSSetFilterSettings("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", batchInfo.weightFilterSettings)
	
	Wave /T batchWaveNames = packageDFR:WMbatchWaveNames
	if (WaveExists(batchInfo.batchYWaveNames))
		Duplicate /O/T batchInfo.batchYWaveNames batchWaveNames
	else
		Redimension /N=0 batchWaveNames	
	endif

	//// update fit function and coefficients	
	SVAR fitFunc = packageDFR:WMFitFunc
	
	if (!strlen(batchInfo.fitFunc))
		fitFunc = "gauss"
	else
		fitFunc = batchInfo.fitFunc
	endif
	WAVE /T inArgsTxt = packageDFR:inputArgsTextDescription
	String currFormula = inArgsTxt[%$(fitFunc)]	
	TitleBox FitFunctionFormula 	win=batchFitPanel#Tab2ContentPanel, title=currFormula

	PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel, popMatch = fitFunc

	NVAR WMnCoefs = packageDFR:WMnCoefs
	if (batchInfo.nInCoefs)
		WMnCoefs = batchInfo.nInCoefs
	else
		WMnCoefs = 4  // the number of args in a gauss func
	endif
	NVAR WMXOffset = packageDFR:WMXOffset
	WMXOffset = batchInfo.xoffset
	
	WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW
	WAVE coefListBoxSW = packageDFR:WMcoefListBoxSW
	WAVE WMInitCoefs = packageDFR:WMInitCoefs
	WAVE WMConstraints = packageDFR:$strConstConstrWaveName //WMConstraints
	
	Variable i
	Redimension /N=(WMnCoefs) WMInitCoefs
	Redimension /N=(WMnCoefs, 2) WMConstraints
	Redimension /N=(WMnCoefs, 6) coefListBoxLW, coefListBoxSW
	
	if (waveExists(batchInfo.coefHold))
		coefListBoxSW[][2] = 32 + (!!batchInfo.coefHold[p] * 16)
	else	
		coefListBoxSW[][2] = 32 
	endif
	
	///// coefficient initial guesses /////
	switch (batchInfo.coefStyle)
		case WMcoefStyleOneForAll:
			String /G packageDFR:WMcurrCoefEntryProc = cCtrl_oneForAll
			break
		case WMcoefStyleLastGood:
			String /G packageDFR:WMcurrCoefEntryProc = cCtrl_lastSuccess	
			break
		case WMcoefStylePerFitWave:
			String /G packageDFR:WMcurrCoefEntryProc = cCtrl_2DWave
			break
	endswitch
	PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, mode=batchInfo.coefStyle

	SVAR coefWaveName = packageDFR:WMInitGuessWaveName
	SVAR coefWavePath = packageDFR:WMInitGuessWaveFullPath	
	Wave /Z testCoefWave = $(batchInfo.coefWaveFullPath)
	if (WaveExists(testCoefWave))
		coefWavePath = batchInfo.coefWaveFullPath
		coefWaveName = ParseFilePath(0, coefWavePath, ":", 1, 0)
	else	
		coefWavePath = ""
		coefWaveName = ""	
	endif
	
	if (waveExists(batchInfo.coefWave))
		WMInitCoefs = batchInfo.coefWave[p]	
	else
		WMInitCoefs = NaN
	endif
	
	///// constraint initial guesses /////
	switch (batchInfo.constrEntryStyle)
		case WMconstrStyleControls:
			String /G packageDFR:WMcurrConstrEntryProc = cCtrl_setWithControls
			break
		case WMcoefStyleLastGood:
			String /G packageDFR:WMcurrConstrEntryProc = cCtrl_setWithTextWave	
			break
	endswitch
	PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, mode=batchInfo.constrEntryStyle	

	if (waveExists(batchInfo.constraintsControlWave))
		WMConstraints = batchInfo.constraintsControlWave[p][q]
	else
		WMConstraints = NaN
	endif
	
	SVAR constraintStr = packageDFR:WMConstraintStr
	constraintStr = batchInfo.constraintStr

	if (isUserFitFunc(fitFunc))
	      if (WaveExists(batchInfo.epsilon))
			coefListBoxLW[][5] = num2str(batchInfo.epsilon[p])
		else
			for (i=0; i<WMnCoefs; i+=1)
				coefListBoxLW[][5] = "1e-6"
			endfor
		endif
	endif
	
	UpdateFitType(fitFunc)
	UpdateCoefListBox()
	
	//// update weighting and masking set-up
	NVAR doMask = packageDFR:WMdoMask
	NVAR doWeight = packageDFR:WMdoWeight
	doMask = !!(batchInfo.maskSourceType)
	doWeight = !!(batchInfo.weightSourceType)
	
	NVAR doRange = packageDFR:WMdoRange
	doRange = batchInfo.doRange
	Variable minRange = batchInfo.minRange
	Variable maxRange = batchInfo.maxRange
	SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, value=_NUM:minRange, disable=!doRange*2
	SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, value=_NUM:maxRange, disable=!doRange*2
		
	WMsetUseMaskWeight("WMMaskChck",doMask)
	WMsetUseMaskWeight("WMWeightChck",doWeight)
End

Function WMViewBatchButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currBatchName = packageDFR:WMcurrBatchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir

	Wave /T batchRunsSummary = WMGetBatchRunsSummary()

	ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB
	String selectedBatchName = batchRunsSummary[V_Value][0]
	
	CreateResultsPanel(currDataFolder, selectedBatchName)
End

Function WMDeleteBatchButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR currBatchName = packageDFR:WMcurrBatchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir

	Wave /T batchRunsSummary = WMGetBatchRunsSummary()

	ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB
	Variable selectedIndex = V_Value
	String selectedBatchName = batchRunsSummary[selectedIndex][0]
	
	DoAlert /T="Delete Batch Curve Fit?" 1, "Delete "+selectedBatchName+" from folder "+currDataFolder+"?"
	if (V_flag==1)
		String dfrToDelete = ReplaceString("::", currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(selectedBatchName),":")
		KillDataFolder /Z $dfrToDelete
		Wave /T batchRunsSummary = WMGenBatchRunsSummary()
		ListBox currentBatchRunsLB, win=batchFitPanel#Tab0ContentPanel, listWave=batchRunsSummary
		
		Variable nBatches = DimSize(batchRunsSummary, 0)
		if (nBatches == 0)
			currBatchName = "NewBatch0"
		elseif (selectedIndex < nBatches-1)
			ListBox currentBatchRunsLB, win=batchFitPanel#Tab0ContentPanel, selRow=selectedIndex
			currBatchName = batchRunsSummary[selectedIndex][0]
		else
			ListBox currentBatchRunsLB, win=batchFitPanel#Tab0ContentPanel, selRow=selectedIndex
			currBatchName = batchRunsSummary[nBatches-1][0]
		endif
	endif
End
 
Function WMRenameBatchProc()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	SVAR currDataFolder = packageDFR:WMbatchDataDir	
	SVAR currBatchName = packageDFR:WMcurrBatchName
	ControlInfo /W=renamePanel setBatchName
	
	String newName = S_Value  
	String oldDataFolder = ReplaceString("::", currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(currBatchName),":")
	
	if (DataFolderExists(oldDataFolder))
		DoAlert /T="New Folder Already Exists" 0, "A batch named "+currBatchName+" already exists."
	else
		currBatchName=newName
		RenameDataFolder $oldDataFolder $(ReplaceString("::", currDataFolder+":"+constBatchRunsDirName+":"+PossiblyQuoteName(newName),":"))
	endif
End

Function BatchFitSetTabControlContent(whichTab)
	Variable whichTab
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	switch(whichTab)
		case 0:
			SetWindow batchFitPanel#Tab0ContentPanel hide=0
			SetWindow batchFitPanel#Tab1ContentPanel hide=1	
			SetWindow batchFitPanel#Tab2ContentPanel hide=1
			SetWindow batchFitPanel#Tab3ContentPanel hide=1
			SetWindow batchFitPanel#Tab4ContentPanel hide=1
			break
		case 1:
			SetWindow batchFitPanel#Tab0ContentPanel hide=1
			SetWindow batchFitPanel#Tab2ContentPanel hide=1
			SetWindow batchFitPanel#Tab3ContentPanel hide=1
			SetWindow batchFitPanel#Tab4ContentPanel hide=1
			SetWindow batchFitPanel#Tab1ContentPanel hide=0	
			SetWindow batchFitPanel#Tab1ContentPanel#YWavesPanel hide=0	// necessary for saved experiments with open panels
			Variable xInputType = WMSCSGetInputType("XWaves")
			if (!(xInputType & WMconstXyPairsInput || xInputType & WMconstWaveScalingInput)) 
				SetWindow batchFitPanel#Tab1ContentPanel#XWavesPanel hide=0	
			endif
			
			break
		case 2:
			SetWindow batchFitPanel#Tab0ContentPanel hide=1
			SetWindow batchFitPanel#Tab1ContentPanel hide=1
			SetWindow batchFitPanel#Tab3ContentPanel hide=1
			SetWindow batchFitPanel#Tab4ContentPanel hide=1
			SetWindow batchFitPanel#Tab2ContentPanel hide=0
			break
		case 3:
			NVAR doWeight = packageDFR:WMdoWeight
			SetWindow batchFitPanel#Tab0ContentPanel hide=1
			SetWindow batchFitPanel#Tab1ContentPanel hide=1
			SetWindow batchFitPanel#Tab2ContentPanel hide=1
			SetWindow batchFitPanel#Tab4ContentPanel hide=1		
			SetWindow batchFitPanel#Tab3ContentPanel hide=0
			SetWindow batchFitPanel#Tab3ContentPanel#weightWavesPanel hide=doWeight*2
			break
		case 4:
			NVAR doMask = packageDFR:WMdoMask
			SetWindow batchFitPanel#Tab0ContentPanel hide=1
			SetWindow batchFitPanel#Tab1ContentPanel hide=1
			SetWindow batchFitPanel#Tab2ContentPanel hide=1
			SetWindow batchFitPanel#Tab3ContentPanel hide=1
			SetWindow batchFitPanel#Tab4ContentPanel hide=0		
			SetWindow batchFitPanel#Tab4ContentPanel#maskWavesPanel hide=doMask*2
			break
	endswitch
	SetActiveSubwindow batchFitPanel
end

Function WMsetDataDirProc(SelectedItem, EventCode, OwningWindowName, ListboxControlName)
	String SelectedItem			// string with full path to the item clicked on in the wave selector
	Variable EventCode			// the ListBox event code that triggered this notification
	String OwningWindowName	// String containing the name of the window containing the listbox
	String ListboxControlName	// String containing the name of the listbox control
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR batchDataDir = packageDFR:WMbatchDataDir

	Variable doResetUpdate = cmpStr(batchDataDir, SelectedItem+":")

	batchDataDir=SelectedItem+":"
	
	WMUpdateWaveSelectBoxes()

	return 0            // other return values reserved
End

Function WMUpdateWaveSelectBoxes()
	Variable doResetUpdate

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	SVAR batchDataDir = packageDFR:WMbatchDataDir
	Wave /T batchWaveNames = packageDFR:WMbatchWaveNames

	WMSCSSetFolder(batchDataDir, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel")
	WMSCSSetFolder(batchDataDir, "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSSetFolder(batchDataDir, "MaskWaves", "batchFitPanel#Tab4ContentPanel#MaskWavesPanel")
	WMSCSSetFolder(batchDataDir, "WeightWaves", "batchFitPanel#Tab3ContentPanel#WeightWavesPanel")

	WMSCSGetSelectedWaveNames("YWaves", batchWaveNames)
End

Function updateCoefListBox()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()

	updateFitFunctions()  

	SVAR currCoefEntryProc = packageDFR:WMcurrCoefEntryProc
	SVAR currConstrEntryProc = packageDFR:WMcurrConstrEntryProc
	SVAR currFitFunc = packageDFR:WMFitFunc
	NVAR WMnCoefs = packageDFR:WMnCoefs
	NVAR xoffset = packageDFR:WMXOffset

	if ((!CmpStr(currFitFunc, "poly") || !CmpStr(currFitFunc, "poly_XOffset")) && (WMnCoefs<3) || numtype(WMnCoefs)==2)
		WMnCoefs = 3
	endif

	WAVE inArgs = packageDFR:nInputArgsHash
	Variable nCoefs = inArgs[%$currFitFunc]

	Variable i, isUFit = isUserFitFunc(currFitFunc)

	if (numtype(nCoefs)==2)	
		nCoefs = WMnCoefs
	endif
	
	WMnCoefs = nCoefs

	WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW
	WAVE coefListBoxSW = packageDFR:WMcoefListBoxSW
	WAVE /T coefListBoxTitles = packageDFR:WMcoefListBoxTitles
	WAVE WMInitCoefs = packageDFR:WMInitCoefs
	WAVE WMConstraints = packageDFR:$strConstConstrWaveName //WMConstraints

	ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, disable=0, listWave=coefListBoxLW, selWave=coefListBoxSW
			
	Redimension /N=(nCoefs, 6) coefListBoxLW
	Redimension /N=(nCoefs, 6) coefListBoxSW	
	Variable currNCoefs = numpnts(WMInitCoefs)
	Redimension /N=(nCoefs) WMInitCoefs
	Redimension /N=(nCoefs, 2) WMConstraints

	// if nCoefs increased need to init WMInitCoefs to NaN
	for (i=currNCoefs; i<nCoefs; i+=1)
		WMInitCoefs[i]=NaN
		WMConstraints[i][0]=NaN
		WMConstraints[i][1]=NaN
	endfor
	
	Wave /T coefNames = GetCoefNames(currFitFunc, nCoefs)
			
	for (i=0; i<nCoefs; i+=1)
		if (DimSize(coefNames,0)>i)
			coefListBoxLW[i][0] = coefNames[i]
		else
			coefListBoxLW[i][0] = "K"+num2str(i)
		endif
		coefListBoxSW[i][0] = 0
		
		if (!CmpStr(currCoefEntryProc, cCtrl_2DWave))// using a 2D wave for initial guesses
			coefListBoxLW[i][1] = "[using 2D wave]"
			coefListBoxSW[i][1] = 0
		else	
			coefListBoxSW[i][1] = 2
			if (numtype(WMInitCoefs[i])==2)
				if (isUFit)
					coefListBoxLW[i][1] = "[init guess required]"
				else
					coefListBoxLW[i][1] = "[auto guess]"			
				endif
			else
				coefListBoxLW[i][1] = num2str(WMInitCoefs[i])
			endif
		endif
		
		Variable isHeld = (coefListBoxSW[i][2] & 16)/16
		coefListBoxLW[i][2] = ""
		coefListBoxSW[i][2] = 32 + (isHeld* 16)// set to checkbox
		
		if (!CmpStr(currConstrEntryProc, cCtrl_setWithTextWave))// using a 2D text wave for constraints
			coefListBoxSW[i][3] = 0
			coefListBoxSW[i][4] = 0
			coefListBoxLW[i][3] = "[using 2D text wave]"
			coefListBoxLW[i][4] = "[using 2D text wave]"			
		else
			if (isHeld)	
				coefListBoxSW[i][3] = 0
				coefListBoxSW[i][4] = 0
				coefListBoxLW[i][3] = "[held]"
				coefListBoxLW[i][4] = "[held]"		
			else
				coefListBoxSW[i][3] = 2
				coefListBoxSW[i][4] = 2
				if (numtype(WMConstraints[i][0])==2)
					coefListBoxLW[i][3] = ""
				else	
					coefListBoxLW[i][3] = num2str(WMConstraints[i][0])
				endif
				if (numtype(WMConstraints[i][1])==2)
					coefListBoxLW[i][4] = ""
				else
					coefListBoxLW[i][4] = num2str(WMConstraints[i][1])
				endif
			endif
		endif
		
		if (isUFit)
			if (numtype(str2num(coefListBoxLW[i][3])))
				coefListBoxLW[i][5] = "1e-6"
			endif
			coefListBoxSW[i][5] = 2
		else
			coefListBoxLW[i][5] = ""
			coefListBoxSW[i][5] = 0
		endif
	endfor		
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Save Current Settings Function /////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// This function is basically a copy of the beginning of WMLaunchBatchButtonProc(ctrlName) - basically
// everything except the launch.
Function WMSaveCurrentBatchSettings()

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	String batchDataDir = WMSCSGetInputSourceFolder("YWaves")
	DFREF batchDataDirDFR = $batchDataDir
	SVAR batchName = packageDFR:WMcurrBatchName

	// create the struct and waves to return values
	STRUCT batchDataStruct batchInfo
	initBatchDataStruct(batchInfo)
	
	Make /WAVE/FREE /N=0 yWaves
	Make /WAVE/FREE /N=0 xWaves
	Make /O/WAVE/FREE /N=0 mWaves
	Make /O/WAVE/FREE /N=0 wWaves

	WMCollectCurrentBatchSettings(batchInfo, yWaves, xWaves, mWaves, wWaves, 0)
	WMStoreBatchData(batchInfo, batchName, yWaves=yWaves, xWaves=xWaves, maskWaves=mWaves, weightWaves=wWaves) //, yFilterWave=yFilt, xFilterWave=xFilt, maskFilterWave=mFilt, weightFilterWave=wFilt)
End


// All args, except doChecks, are not read and are only for return values
// return 0 or positive value upon success,negative value if there is a failure or termination 
Function WMCollectCurrentBatchSettings(batchInfo, yWaves, xWaves, mWaves, wWaves, doChecks)
	STRUCT batchDataStruct & batchInfo
	WAVE /WAVE yWaves, xWaves, mWaves, wWaves 	// Y waves, X waves, Mask Waves, Weight Waves
	Variable doChecks									// Check and advise that batch settings are valid

	Variable ret = 1						

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	String batchDataDir = WMSCSGetInputSourceFolder("YWaves")
	DFREF batchDataDirDFR = $batchDataDir
	SVAR batchName = packageDFR:WMcurrBatchName
	
	DFREF batchOutDirDFR = getBatchFolderDFR(batchDataDir, batchName)//, 1)
	String batchOutDirDFRString = GetDataFolder(1, batchOutDirDFR)
	
	WMSCSGetSelectedWaves("YWaves", yWaves)
	WMSCSGetSelectedWaves("XWaves", xWaves)
	NVAR xoffset = packageDFR:WMXOffset
	
	Variable ySource = WMSCSGetInputType("YWaves")
	Variable xSource = WMSCSGetInputType("XWaves")
	Variable maskSource = WMSCSGetInputType("MaskWaves")
	Variable weightSource = WMSCSGetInputType("WeightWaves")

	WMSCSGetSelectedWaves("maskWaves", mWaves)
	WMSCSGetSelectedWaves("weightWaves", wWaves)
	NVAR doMask = packageDFR:WMdoMask
	NVAR doWeight = packageDFR:WMdoWeight
	NVAR doRange = packageDFR:WMdoRange
	NVAR doCovar = packageDFR:WMdoCovar
	
	SVAR currCoefEntryProc = packageDFR:WMcurrCoefEntryProc
	SVAR FitF = packageDFR:WMFitFunc
	WAVE /T coefListBoxLW = packageDFR:WMcoefListBoxLW
	WAVE coefListBoxSW = packageDFR:WMcoefListBoxSW
	
	SVAR currConstrEntryProc = packageDFR:WMcurrConstrEntryProc	
	SVAR constraintStr = packageDFR:WMConstraintStr

	Variable nYWaves, nXWaves, nMaskWaves, nWeightWaves, i
	String epStr = ReplaceString("::", batchDataDir+":WMBatchEpsilonVals", ":")
	nYWaves = DimSize(yWaves, 0)
	nXWaves = DimSize(xWaves, 0)
	nMaskWaves = DimSize(mWaves, 0)
	nWeightWaves = DimSize(wWaves, 0)

	if ((xSource & WMconstSingle2DInput) && DimSize(xWaves, 0))
		Redimension /N=1 xWaves
		nXWaves = floor(DimSize(xWaves[0], 1)/(1+(xSource & WMconstXyPairsInput)/WMconstXyPairsInput))
	elseif (xSource & WMconstXyPairsInput)
		ySource = ySource | WMconstXyPairsInput
	endif

	if (ySource & WMconstSingle2DInput)  
		nYWaves = floor(DimSize(yWaves[0], 1)/(1+(ySource & WMconstXyPairsInput)/WMconstXyPairsInput))
		if (numtype(nYWaves)!=2)
			Redimension /N=1 yWaves
		endif
	endif

	// If necessary, get the mask and weight waves gathered up too
	if (doMask && DimSize(mWaves, 0) && (maskSource & WMconstSingle2DInput))
		Redimension /N=1 mWaves
		nMaskWaves = floor(DimSize(mWaves[0], 1)/(1+(maskSource & WMconstXyPairsInput)/WMconstXyPairsInput)) 
	endif
	if (doWeight && DimSize(wWaves, 0) && (weightSource & WMconstSingle2DInput))
		Redimension /N=1 wWaves
		nWeightWaves = floor(DimSize(wWaves[0], 1)/(1+(weightSource & WMconstXyPairsInput)/WMconstXyPairsInput)) 
	endif
	
	// if necessary get the min and max range values
	Variable minRange = NaN
	Variable maxRange = NaN
	if (doRange)
		ControlInfo /W=batchFitPanel#Tab4ContentPanel WMminRange
		minRange = V_Value
		ControlInfo /W=	batchFitPanel#Tab4ContentPanel WMmaxRange
		maxRange = V_Value
	endif
		
	Variable nCoefs = DimSize(coefListBoxLW, 0)		
	Variable coefStyle
	strswitch (currCoefEntryProc)
		case cCtrl_oneForAll:
			Make /O/N=(nCoefs)/D batchOutDirDFR:$strConstCoefWaveName //WMcoefWave		
			coefStyle = WMcoefStyleOneForAll
			break
		case cCtrl_lastSuccess:
			Make /O/N=(nCoefs)/D batchOutDirDFR:$strConstCoefWaveName //WMcoefWave
			coefStyle = WMcoefStyleLastGood
			break
		case cCtrl_2dWave:
			SVAR coefsWaveName = packageDFR:WMInitGuessWaveFullPath
			WAVE /Z originalCoefsWave = $coefsWaveName
			if (waveExists(originalCoefsWave))
				Duplicate /O originalCoefsWave batchOutDirDFR:$strConstCoefWaveName //WMcoefWave
			else
				Make /O/N=0/D batchOutDirDFR:$strConstCoefWaveName //WMcoefWave
			endif
			coefStyle = WMcoefStylePerFitWave
			break
		default:
			coefStyle = -1
			break
	endswitch	
			
	Make /O/N=(nCoefs) batchOutDirDFR:$strConstCoefHoldWaveName //WMcoefHold
	WAVE coefWave = batchOutDirDFR:$strConstCoefWaveName //WMcoefWave
	WAVE coefHold = batchOutDirDFR:$strConstCoefHoldWaveName //WMcoefHold	
	Make /O/N=(nCoefs, 2) batchOutDirDFR:$strConstConstrWaveName //WMconstraints
	WAVE constraintsWave = batchOutDirDFR:$strConstConstrWaveName //WMconstraints
		
	Variable isUserFFunc = isUserFitFunc(FitF)
	if (isUserFFunc)
		Make /O/N=(nCoefs)/D $epStr
		WAVE epsilonWave = $epStr  
	endif
	Variable epsilonIsZeroOrNan = 0
	for (i=0; i<nCoefs; i+=1)
		// set input coefficients
		if (CmpStr(currCoefEntryProc, cCtrl_2dWave))			// Evaluates to false if the two are equal, i.e. the user elected to use a 2D wave not the UI for initial guess values
			coefWave[i] = str2num(coefListBoxLW[i][1])			// what the user sees on screen should be the initial guess
		endif
		// set holds
		coefHold[i] = coefListBoxSW[i][2] & 16  ? 1 : 0			/// 4th bit in coefListBoxSW is set if the checkbox is checked
		
		constraintsWave[i][0] = str2num(coefListBoxLW[i][3])
		constraintsWave[i][1] = str2num(coefListBoxLW[i][4])		
		
		if (isUserFFunc)
			Variable currEpsilon = str2num(coefListBoxLW[i][5])
			if (numType(currEpsilon)==2 || currEpsilon==0)
				epsilonWave[i] = 1e-6
				epsilonIsZeroOrNaN = 1
			else
				epsilonWave[i] = currEpsilon
			endif 			
		endif
	endfor
	if (epsilonIsZeroOrNan && doChecks)
		DoAlert /T="Batch Fit Warning" 0, "Warning, user fit function epsilon is 0 or NaN: set to default of 1e-6"
	endif

	// create or duplicate the constraints wave and give an error if some are not valid
	Variable constrStyle
	Wave /Z/T constraintsTextWave
	if (!CmpStr(currConstrEntryProc, cCtrl_setWithTextWave))
		constrStyle = WMConstrStyle2DWave
		SVAR /Z constrWavePath = packageDFR:WMConstrWaveFullPath
		if (SVAR_Exists(constrWavePath))
			Wave /T/Z constrWave = $constrWavePath
			if (WaveExists(constrWave))
				Duplicate /O constrWave batchOutDirDFR:WMconstraintsTextWave
			else
				if (doChecks)
					DoAlert /T="Constraints Error" 1, "Constraint Wave "+constrWavePath+" does not exist.\rContinue fittings with no constraints?"
					if (V_flag == 2)
						ret = -1
					endif
				endif
				Make /T/O/N=0 batchOutDirDFR:WMconstraintsTextWave
			endif
		else 
			Make /T/O/N=0 batchOutDirDFR:WMconstraintsTextWave
		endif		
		WAVE /T constraintsTextWave = batchOutDirDFR:WMconstraintsTextWave
	else
		constrStyle = WMConstrStyleControls
		Make /T/O/N=0 batchOutDirDFR:WMconstraintsTextWave
		WAVE /T constraintsTextWave = batchOutDirDFR:WMconstraintsTextWave	
		String constraintErrStr = ValidateConstraints(constraintsTextWave, coefHold, constraintWave = constraintsWave, constraintStr = constraintStr)
		if (doChecks && strlen(constraintErrStr))
			DoAlert /T="Constraints Error" 1, constraintErrStr+"Continue using only valid constraints?"
			if (V_flag == 2)
				ret = -1
			endif
		endif	
	endif

	////// Global settings: currently halt on error and max iterations for each fit
	NVAR haltOnErr = packageDFR:WMHaltOnErr
	NVAR maxIter = packageDFR:WMMaxIterations

	Make /Free/T/N=3 yFilt
	WMSCSGetFilterSettings("YWaves", yFilt)
	Make /Free/T/N=3 xFilt
	WMSCSGetFilterSettings("XWaves", xFilt)
	Make /Free/T/N=3 mFilt
	WMSCSGetFilterSettings("maskWaves", mFilt)
	Make /Free/T/N=3 wFilt
	WMSCSGetFilterSettings("maskWaves", wFilt)
		
	batchInfo.batchDir = batchDataDir
	Wave batchInfo.coefWave = coefWave
	Wave batchInfo.coefHold = coefHold
	batchInfo.yValsSourceType = ySource
	batchInfo.xValsSourceType = xSource
	batchInfo.maskSourceType = maskSource*doMask
	batchInfo.weightSourceType = weightSource*doWeight
	batchInfo.coefStyle = coefStyle
	batchInfo.fitFunc = fitF
	batchInfo.nInCoefs = nCoefs
	batchInfo.xoffset = xoffset
	
	batchInfo.constrEntryStyle = constrStyle
	WAVE batchInfo.constraintsControlWave = constraintsWave
	batchInfo.constraintStr = constraintStr
		
	batchInfo.doRange=doRange
	batchInfo.minRange=minRange
	batchInfo.maxRange=maxRange
	batchInfo.doCovar=doCovar
		
	Wave /Z batchInfo.epsilon = $epStr
	batchInfo.haltOnErr = haltOnErr
	batchInfo.maxIter = maxIter
	SVAR /Z constrWavePath = packageDFR:WMConstrWaveFullPath
	if (SVAR_Exists(constrWavePath))
		batchInfo.constrTextWaveFullPath = constrWavePath
	else
		batchInfo.constrTextWaveFullPath = ""
	endif
	
	Wave /T batchInfo.constraintsTextWave = constraintsTextWave
	Wave /T batchInfo.yFilterSettings = yFilt
	Wave /T batchInfo.xFilterSettings = xFilt
	Wave /T batchInfo.maskFilterSettings = mFilt
	Wave /T batchInfo.weightFilterSettings = wFilt
	
	Return ret
End



////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Launch Button //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function WMLaunchBatchButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	String batchDataDir = WMSCSGetInputSourceFolder("YWaves")
	DFREF batchDataDirDFR = $batchDataDir
	SVAR batchName = packageDFR:WMcurrBatchName
	
	DFREF batchOutDirDFR = getBatchFolderDFR(batchDataDir, batchName)//, 1)
	String batchOutDirDFRString = GetDataFolder(1, batchOutDFR)
	
	WMSaveCurrentBatchSettings()
	STRUCT batchDataStruct batchInfo
	getBatchData(batchDataDir, batchName, batchInfo)
	
	Make /WAVE /N=0 /FREE yWaves
	Make /WAVE /N=0 /FREE xWaves
	getYandXBatchData(batchDataDir, batchName, yWaves, xWaves)
	Make /WAVE /N=0 /FREE maskWaves
	Make /WAVE /N=0 /FREE weightWaves
	
	if (DimSize(yWaves,0)>0)
		// Assign all these local variables because including "batchinfo." in the WMLaunchBatchCurveFit() arguments pushes the command length over 400 chars
		
		Variable ret = WMCollectCurrentBatchSettings(batchInfo, yWaves, xWaves, maskWaves, weightWaves, 1)
		if (ret >= 0)	
			String fitF = batchInfo.fitFunc
			Variable ySource = batchInfo.yValsSourceType
			Variable xSource = batchInfo.xValsSourceType
			Variable maskSource= batchInfo.maskSourceType
			Variable weightSource = batchInfo.weightSourceType
		
			Wave coefWave = batchInfo.coefWave
			Wave /Z coefHold = batchInfo.coefHold
			Wave /Z/T constraintsTextWave = batchInfo.constraintsTextWave
			Variable nCoefs = batchInfo.nInCoefs 
			Variable coefStyle = batchInfo.coefStyle
			Variable xoffset = batchInfo.xoffset
			String epStr=""
			if (WaveExists(batchInfo.epsilon))
				epStr = GetWavesDataFolder(batchInfo.epsilon, 2)
			endif 
			Variable haltOnErr = batchInfo.haltOnErr
			Variable maxIter = batchInfo.maxIter
			Variable doRange = batchInfo.doRange
			Variable minRange = batchInfo.minRange
			Variable maxRange = batchInfo.maxRange
			Variable doCovar = batchInfo.doCovar
		
			ret = WMLaunchBatchCurveFit(batchDataDir, batchName, FitF, yWaves, ySource, xWaves, xSource, maskWaves, maskSource, weightWaves, weightSource, coefWave, coefHold, constraintsTextWave, coefStyle, nCoefs, xoffset, epStr, haltOnErr=haltOnErr, maxIter=maxIter, doRange=doRange, minRange=minRange, maxRange=maxRange, doCovar=doCovar)
		
			WMUpdateBatchControlPanel()

			if (!ret)
				CreateResultsPanel(batchDataDir, batchName)
			endif
		endif
	else
		DoAlert /T="Batch Fit Error" 0, "You must specify y waves\r"
	endif	
End

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// functions for popupMenus ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function /S listFitTypes()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()

	WAVE niah = packageDFR:nInputArgsHash
	String fitTypesStrList = getAllDimLabels(niah, 0)
	
	return fitTypesStrList
End

Function /S listInputOptions(KeysValuesString)
	String KeysValuesString
		
	String packageDirStr = GetDataFolder(1, GetBatchCurveFitPackageDFR())
	
	SVAR kvs = $(packageDirStr + KeysValuesString)

	return getStringListKeysOrValues(kvs) 
End


////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// Update Function ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function UpdateBatchCurveFitPanel(updatePanelNum)
	Variable updatePanelNum
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()	
	if (updatePanelNum < 1.2)
		packageDFR = GetBatchCurveFitPackageDFR(doInitialization=1)
	endif
	String packageDFRString = GetDataFolder(1, packageDFR)	
	
	if (updatePanelNum < 1.1)
		DoAlert /T="Batch Curve Fit Panel update" 0, "The Batch Curve Fit Panel has been updated.  If you experience any minor issues you may want to kill the panel and re-open it."
		SVAR /Z currConstrEntryProc = packageDFR:WMcurrConstrEntryProc
		if (!SVAR_exists(currConstrEntryProc))
			String /G packageDFR:WMcurrConstrEntryProc=cCtrl_setWithControls
		endif
		NVAR /Z doRange = packageDFR:WMdoRange
		if (!NVAR_exists(doRange))
			Variable /G packageDFR:WMdoRange = 0
		endif
		
		///// Panel Variables /////
		/// controls //
		NVAR left = packageDFR:WMMainPanelLeft
		NVAR top = packageDFR:WMMainPanelTop
		NVAR right = packageDFR:WMMainPanelRight
		NVAR bottom = packageDFR:WMMainPanelBottom
		NVAR listBoxHeight = packageDFR:WMlistBoxHeight 
		NVAR listBoxWidth = packageDFR:WMlistBoxWidth
		NVAR tabRegionBotOffset = packageDFR:WMtabRegionBotOffset	

		String cmd=GetIndependentModuleName()+"#getInitialGuesses()"
		PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, title="Initial Guess Mode", value=#cmd 
		PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, pos={10, 105}, size={(right-left)/2-50, 30}

		cmd=GetIndependentModuleName()+"#getCoefInputMethod()"
		PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, title="Constraint Entry Mode", value=#cmd
		PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, Proc=setConstraintEntryProc, pos={(right-left)/2-10, 105}, size={(right-left)/2-10, 30}, fsize=WMBCFBaseFontSize, fstyle=1

		TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, title="2D Initial Guess Wave", fixedSize=1, frame=0, pos={30, 125}; DelayUpdate
		TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, size={130, 20}, fsize=WMBCFBaseFontSize, fstyle=1, fixedSize=1
		SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, pos={160, 125}, size={(right-left)/2-230, 20}, value=packageDFR:WMInitGuessWaveName, fsize=WMBCFBaseFontSize, fixedSize=1, title=" "; DelayUpdate
		SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, help={"A 2D numerical wave containing initial guesses for each fit.  Set to NaN for no initial guess."}
		MakeSetVarIntoWSPopupButton("batchFitPanel#Tab2ContentPanel", "setInitialGuessWave", "InitialGuessWaveSelectorNotify", packageDFRString+"WMInitGuessWaveName",content=WMWS_Waves)
		PopupWS_SetPopupFont("batchFitPanel#Tab2ContentPanel", "setInitialGuessWave", fontSize=WMBCFBaseFontSize)
	
		TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, title="2D Coefficients Text Wave", fixedSize=1, frame=0, pos={(right-left)/2+10, 125}; DelayUpdate
		TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, size={160, 20}, fsize=WMBCFBaseFontSize, fstyle=1, fixedSize=1
		SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, pos={(right-left)/2+170, 125}, size={(right-left)/2-230, 20}, fsize=WMBCFBaseFontSize, fixedSize=1, value=packageDFR:WMConstrWaveName, title="  "; DelayUpdate
		SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, help={"A 2D text wave containing constraint expressions for each fit.  Set to empty string for no initial guess."}
		MakeSetVarIntoWSPopupButton("batchFitPanel#Tab2ContentPanel", "setCoefficientsWave", "ConstraintsWaveSelectorNotify", packageDFRString+"WMConstrWaveName",content=WMWS_Waves)
		PopupWS_SetPopupFont("batchFitPanel#Tab2ContentPanel", "setCoefficientsWave", fontSize=WMBCFBaseFontSize)	

		TitleBox coefficientInitialGuessesTitle win=batchFitPanel#Tab2ContentPanel, title="Input Initial Guesses", fixedSize=1, frame=0, pos={10, 160}, size={right-left-20,25},fsize=WMBCFBaseFontSize+1, fstyle=1

		// Input via listbox and general constraint string
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, pos={10, 185}, widths={60, 40, 10, 50, 50, 30}, size={right-left-40, bottom-top-tabRegionBotOffset-280}, disable=0, fsize=WMBCFBaseFontSize  
																												
		Make /O/T/N=6 packageDFR:initGuessTitles = {"Coefficient", "Guess", "Hold?", "Min", "Max", "Epsilon"}
		Wave /T initGuessTitles = packageDFR:initGuessTitles
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, titleWave=initGuessTitles, proc=WMinitialGuessProc
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, help={"User fit functions require initial guesses. For built in fit funcs leave Guess blank for auto generated initial guesses. The Hold checkbox makes the init guess a fit constant.  For user fits funcs Epsilon sets the change between iterations"}

		SVAR constraintStr = packageDFR:WMConstraintStr
		TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, title="General Constraints", fixedSize=1, frame=0, pos={10, bottom-top-tabRegionBotOffset-90}, size={right-left-20,20},fsize=WMBCFBaseFontSize+1, fstyle=1	
		SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, pos={10, bottom-top-tabRegionBotOffset-70}, size= {right-left-40, 25}, fsize=WMBCFBaseFontSize, value=constraintStr, title=" "
		TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel, pos={10, bottom-top-tabRegionBotOffset-50}, size= {right-left-40, 25}, fsize=WMBCFBaseFontSize, fcolor=(32500, 32500, 32500); DelayUpdate
		TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel, frame=0, title="Example: K1 > K2 + 10; K0 < K2-K3"

		//// Reset the Resize Info ////
		PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel,userdata(ResizeControlsInfo)= A"!!#;-!!#;-!!#@i!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!#Bu!!#;-!!#Ap!!#=+z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!#D*^]6YC!!#AH!!#=+z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox FitFunctionFormulaTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#>.!!#Dc5QF*kz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox FitFunctionFormulaTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox FitFunctionFormulaTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox FitFunctionFormula win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#?;!!#Dc5QF+>z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox FitFunctionFormula win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox FitFunctionFormula win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#@6!!#BdJ,hm.z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,I>!!#@6!!#C9!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#o2B4uAezz"
		PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu setConstraintEntry win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,CT!!#@^!!#@f!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox setInitialGuessWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,G0!!#@^!!#Ac!!#<Pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
		SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable setInitialGuessWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		Button PopupWS_Button0 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,HtJ,hq4!!#<X!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		Button PopupWS_Button0 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button PopupWS_Button0 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,IH!!#@^!!#A/!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox setCoefficientsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,J*!!#@^!!#Ac!!#<Pz!!#`-A7TLfzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable setCoefficientsWave win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		Button PopupWS_Button1 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,J^^]6^t!!#<X!!#<8z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button PopupWS_Button1 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button PopupWS_Button1 win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox coefficientInitialGuessesTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#A/!!#Dh5QF*kz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox coefficientInitialGuessesTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox coefficientInitialGuessesTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#AH!!#Dc5QF0.J,fQL!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		ListBox coefInitGuessDirect win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
		TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#CMJ,hu>5QF*Cz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		TitleBox constraintsWaveTitle win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
		SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#CWJ,hu95QF*;z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		SetVariable constraintsStrSetVar win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
		TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#CaJ,hr8!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		TitleBox constraintStrExample win=batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
		SetWindow batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#Dh5QF1Szzzzzzzzzzzzzzzzzzzzz"
		SetWindow batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow batchFitPanel#Tab2ContentPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	endif
	
	if (updatePanelNum < 1.2)
		Checkbox WMMaskChck win=batchFitPanel#Tab4ContentPanel, pos={20, 35}

		Variable /G packageDFR:WMdoRange = 0
		NVAR doRange = packageDFR:WMdoRange
		Checkbox WMRangeChck win=batchFitPanel#Tab4ContentPanel, title="Limit Fit Range by Points", fsize=WMBCFBaseFontSize+1, pos={20, 70}, variable=doRange, proc=WMsetRangeLimitCheckBox	
		SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, title="Range Min Index", fsize=WMBCFBaseFontSize+1, pos={40, 90}, size={185, 20}, value=_NUM:0, disable=2, limits={0, inf, 1}
		SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, title="Range Max Index", fsize=WMBCFBaseFontSize+1, pos={235, 90}, size={185, 20}, value=_NUM:0, disable=2, limits={0, inf, 1}
	
		DefineGuide /W=batchFitPanel#Tab4ContentPanel maskSelectLeft={FL, 0.5, FR}
	endif
	
	SetWindow batchFitPanel userdata(BCF_UPDATEPANELVERSION)=num2str(BCF_UPDATEPANELVERSION)
End
