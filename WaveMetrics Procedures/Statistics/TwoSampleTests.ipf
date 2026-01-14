#pragma rtGlobals=1		// Use modern global access method.
#include <WaveSelectorWidget>
#include <StatsPlots>

constant kRatioDataType=1
constant kOrdinalDataType=2
constant kNominalDataType=3

// 17FEB10 Removed Macros menu.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TSP=Two Sample Panel
//Menu "Macros"
//	"Two Populations Hypothesis Tests", TSP_OpenPanel()
//End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function TSP_OpenPanel()
	// See if the panel already exists.
	DoWindow/F TSP
	if (V_flag != 0)
		return -1
	endif

	// Create data folder used to store globals needed by the main panel.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S :TSP
	
	Variable initialTab = 0
	Variable/G gInitialTab = initialTab
	Variable/G gNumTabs=0
	Variable/G isPairedTest=0
	Variable/G dataType=kRatioDataType
	String/G selectedWave1Str=""
	String/G selectedWave2Str=""
	String/G notebookName=UniqueName("StatsTwoWaves", 10,0)
	Variable/G branch=0
	Variable/G alpha=0.05
	Variable/G ksMean=0
	Variable/G ksStdv=1
	Variable/G nominalStep1Completed=0
	Variable/G analysisComplete=0
	Variable/G allowTabChanging=0
	Variable/G equalVariances=0
	
	// Create the output Notebook
	NewNotebook/F=1/K=2/N=$notebookName/V=1 	// make the notebook difficult to close.
	String str=Date() +" " +time()+"\r"
	WM_catNotebookBold(notebookName,str)
	// Create the panel.
	NewPanel /K=1 /W=(150,50,695,424) as "Two Sample Tests"
	DoWindow/C TSP

	// Add common controls to the main panel.
	Button Help,pos={133,333},size={50,20},proc=HelpButtonProc,title="Help"
	Button Done,pos={21,333},size={100,20},proc=DoneButtonProc,title="Quit"
	Button NextButton,pos={425,333},size={100,20},proc=NextButtonProc,title="Next >>"
	Button backButton,pos={315,333},size={100,20},proc=backButtonProc,title="<< Back"
	
	// Create tab control.
	TabControl TSP_TabControl,pos={12,14},size={512,315},proc=TSP_TabProc
	
	// Add the tabs.
	TSP_AddTabs()
	
	// Activate initial tab.
	TabControl TSP_TabControl, value=0
	
	// Show the controls in the active tab.
	allowTabChanging=1
	TSP_TabProc("",0)
	allowTabChanging=0
	
	ModifyPanel/W=TSP fixedSize=1
	// Restore current data folder.
	SetDataFolder dfSave
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Prototype for a function that adds a tab.
Function TSP_ProtoAddTabFunc(tabNumber)
	Variable tabNumber
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function TSP_AddTabs()
	// Get list of functions that add panels.
	String/G gTabList = FunctionList("TSP_*_AddTab", ";", "KIND:2")

	// Remember the activate procs. This list must be analogous to gTabList. If we call FunctionList later,
	// and if the order of loading the procedure windows changed, then the order of this list would
	// not be consistent with the order of gTabList.
	String/G gTabActivateProcList = FunctionList("TSP_*_Activate", ";", "KIND:2")
	
	// Call each TSP_<TabName>_AddTab function.
	Variable numTabs= ItemsInList(gTabList)
	NVAR gNumTabs=root:Packages:TSP:gNumTabs
	gNumTabs=numTabs
	
	Variable tab
	for(tab=0; tab<numTabs; tab+=1)
		String funcName = StringFromList(tab, gTabList)
		
		// Create a function reference through which the TSP_<TabName>_AddTab function can be called.
		Funcref TSP_ProtoAddTabFunc func = $funcName

		// Then call it.
		func(tab)
	endfor
	
	Variable/G gNumberOfTabs = numTabs		// Current data folder is root:Packages:TSP (set by calling routine).
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Prototype for a function that sets tab controls.
Function TSP_ProtoActivateFunc(tabNumber)
	Variable tabNumber
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function TSP_TabProc(tabName,activeTab)
	String tabName
	Variable activeTab

	NVAR allowTabChanging=root:Packages:TSP:allowTabChanging
	if(allowTabChanging==0)
		String userDataStr=GetUserData("TSP","TSP_TabControl","lastActiveTab")
		Beep
		doAlert 0,"Use the Back and Next buttons to navigate between tabs."
		activeTab=str2num(userDataStr)
		TabControl TSP_TabControl,win=TSP,value=activeTab		 
		return 0
	endif
	
	// Get list of functions that activate/deactivate tabs as saved at the time of creation of the tabs.
	SVAR activateProcList = root:Packages:TSP:gTabActivateProcList
	
	// Call each TSP_<TabName>_Activate function.
	Variable numTabs= ItemsInList(activateProcList)
	Variable tab
	for(tab=0; tab<numTabs; tab+=1)
		String funcName = StringFromList(tab, activateProcList)

		// Create a function reference through which the TSP_<TabName>_Activate function can be called.
		Funcref TSP_ProtoActivateFunc func = $funcName
		
		// Then call it.
		func(tab==activeTab)
	endfor
	
	TabControl TSP_TabControl,userData(lastActiveTab)=num2str(activeTab)
		
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Action procedure for the Done button.
Function DoneButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	// Set initial tab for next time.
	Variable/G root:Packages:TSP:gInitialTab = 0	// always start from the left tab.
	
	// Kill the panel.
	DoWindow/K TSP
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Action procedure for the Help button.
Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayHelpTopic "Two Samples Tests"		// Display the Documentation. 15FEB10
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function NextButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	String str
	
	switch( ba.eventCode )
		case 2: // mouse up
			SVAR nb=root:Packages:TSP:notebookName
			ControlInfo/W=TSP  TSP_TabControl
			Variable tabNumber=V_Value+1
			NVAR gNumTabs=root:Packages:TSP:gNumTabs
			if(tabNumber>=gNumTabs)
				tabNumber=gNumTabs-1
				Beep
			endif
			
			if(allowStep(tabNumber))
				NVAR allowTabChanging=root:Packages:TSP:allowTabChanging
				// str="\rMoving to tab "+num2str(tabNumber)
				// WM_catNotebookBold(nb,str)
				allowTabChanging=1
				TSP_TabProc("TSP_TabControl",tabNumber)
				TabControl TSP_TabControl,win=TSP,value=tabNumber			// show it selected
				allowTabChanging=0
			else
				Beep
				if(tabNumber==2)
					doAlert 0,"You must first select one wave from each list."		// 17FEB10
				else
					doAlert 0,"You must select a conclusion from the popup menu."
				endif
			endif
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function backButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	String str
	switch( ba.eventCode )
		case 2: // mouse up
			SVAR nb=root:Packages:TSP:notebookName
			ControlInfo/W=TSP  TSP_TabControl
			Variable tabNumber=V_Value-1
			if(tabNumber<0)
				tabNumber=0
				Beep
			endif
			str="\rBack Selected.  Moving to tab "+num2str(tabNumber)
			WM_catNotebookBold(nb,str)
			NVAR allowTabChanging=root:Packages:TSP:allowTabChanging
			allowTabChanging=1
			TSP_TabProc("TSP_TabControl",tabNumber)
			TabControl TSP_TabControl,win=TSP,value=tabNumber			// show it selected
			allowTabChanging=0
			Button NextButton,proc=NextButtonProc,title="Next >>"			// recover from "finish"
			PopupMenu tspVariancesPop,mode=1,popvalue="Choose"			// reset the menus if they were changed
			PopupMenu step1Pop,mode=1,popvalue="Choose"
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function TSP_DT_AddTab(tabNumber)
	Variable tabNumber

	// Create data folder used to store globals needed by the tab.
	// The current data folder when we are called is root:Packages:TSP.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S :DT
	
	// Create the tab.
	TabControl TSP_TabControl,proc=TSP_TabProc
	TabControl TSP_TabControl,tabLabel(tabNumber)="General", value=tabNumber

	// Add the controls. Note that they are all initially deactivated (disable=1).
	PopupMenu dataTypePop,pos={66,56},size={91,20},disable=1,title="Data Type:",mode=1,popvalue="Ratio",value= #"\"Ratio;Ordinal;Nominal\""
	PopupMenu dataTypePop proc=dataTypePopMenuProc
	CheckBox PairedSamples,pos={67,90},size={91,14},disable=1,title="Paired Samples",variable=root:Packages:TSP:isPairedTest
	SetVariable alphaSetVar,pos={67,120},size={89,15},title="Alpha",disable=1
	SetVariable alphaSetVar,limits={0,1,0.01},value= root:Packages:TSP:alpha,bodyWidth= 60

	SetDataFolder dfSave
End

Function TSP_DT_Activate(isActivate)
	Variable isActivate		// 1 for activate, 0 for deactivate
	
	// Enable (show) or disable (hide) each control in the tab.
	PopupMenu dataTypePop,disable=!isActivate
	CheckBox PairedSamples,disable=!isActivate
	SetVariable alphaSetVar,disable=!isActivate
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function TSP_DS_AddTab(tabNumber)
	Variable tabNumber

	// Create data folder used to store globals needed by the tab.
	// The current data folder when we are called is root:Packages:TSP.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S :DT
	
	// Create the tab.
	TabControl TSP_TabControl,proc=TSP_TabProc
	TabControl TSP_TabControl,tabLabel(tabNumber)="Data Selection", value=tabNumber

	// Add the controls. Note that they are all initially deactivated (disable=1).
	TitleBox titleWave1,pos={26,45},size={41,20},title="Select Wave 1",disable=1
	TitleBox titleWave2,pos={273,45},size={41,20},title="Select Wave 2",disable=1
	ListBox wave1List,pos={25,71},size={237,243},proc=WaveSelectorListProc
	ListBox wave2List,pos={271,72},size={233,241},proc=WaveSelectorListProc
	MakeListIntoWaveSelector("TSP", "wave1List",content=WMWS_Waves, selectionMode=WMWS_SelectionSingle)
	WS_ClearSelection("TSP", "wave1List")
	MakeListIntoWaveSelector("TSP", "wave2List",content=WMWS_Waves, selectionMode=WMWS_SelectionSingle)
	WS_ClearSelection("TSP", "wave2List")

	SetDataFolder dfSave
End

Function TSP_DS_Activate(isActivate)
	Variable isActivate		// 1 for activate, 0 for deactivate
	
	// Enable (show) or disable (hide) each control in the tab.
	ListBox wave1List disable=!isActivate
	ListBox wave2List disable=!isActivate
	TitleBox titleWave1 disable=!isActivate
	TitleBox titleWave2 disable=!isActivate
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function TSP_TS1_AddTab(tabNumber)
	Variable tabNumber

	// Create data folder used to store globals needed by the tab.
	// The current data folder when we are called is root:Packages:TSP.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S :DT
	
	// Create the tab.
	TabControl TSP_TabControl,proc=TSP_TabProc
	TabControl TSP_TabControl,tabLabel(tabNumber)="Step 1", value=tabNumber

	// Add the controls. Note that they are all initially deactivated (disable=1).
	
	Button br0_runsTest,pos={55,94},size={150,20},proc=branch0UnpairedS1ButtonProc,title="Perform Runs Test",disable=1
	Button br0_ksTest,pos={55,122},size={150,20},proc=branch0UnpairedS1ButtonProc,title="Perform KS Test",disable=1
	Button br0_jbTest,pos={55,152},size={150,20},proc=branch0UnpairedS1ButtonProc,title="Perform JB Test",disable=1
	SetVariable br0MeanSetVar,pos={234,125},size={87,15},title="Mean",disable=1
	SetVariable br0MeanSetVar,value= root:Packages:TSP:ksMean,bodyWidth= 60
	SetVariable br0StdvSetVar,pos={361,125},size={85,15},title="Stdv",disable=1
	SetVariable br0StdvSetVar,limits={0,inf,1},value= root:Packages:TSP:ksStdv,bodyWidth= 60
	PopupMenu step1Pop,pos={59,210},size={310,20},title="Are the inputs normally distributed random samples:"
	PopupMenu step1Pop,mode=1,popvalue="Choose",value= #"\"Choose;Yes;No\"",disable=1

	Button br2_runsTest,pos={55,94},size={150,20},proc=branch2NPRunsBProc,title="Perform NP Runs Test",disable=1
	Button tsp_SkipNPRuns,pos={54,129},size={150,20},proc=skipNPSRTestButtonProc,title="Skip Test",disable=1
	SetDataFolder dfSave
End

Function TSP_TS1_Activate(isActivate)
	Variable isActivate		// 1 for activate, 0 for deactivate
	
	// Enable (show) or disable (hide) each control in the tab.
	Button br0_runsTest disable=1
	Button br0_ksTest disable=1
	Button br0_jbTest disable=1
	SetVariable br0MeanSetVar disable=1
	SetVariable br0StdvSetVar disable=1
	PopupMenu step1Pop  disable=1
	Button br2_runsTest,  disable=1
	Button tsp_SkipNPRuns, disable=1
			
	NVAR branch=root:Packages:TSP:branch
	if(isActivate==1)
		if(branch==0)
			Button br0_runsTest disable=!isActivate
			Button br0_ksTest disable=!isActivate
			Button br0_jbTest disable=!isActivate
			SetVariable br0MeanSetVar disable=!isActivate
			SetVariable br0StdvSetVar disable=!isActivate
			PopupMenu step1Pop  disable=!isActivate
			
		elseif(branch==2)
			Button br2_runsTest,  disable=!isActivate
			Button tsp_SkipNPRuns, disable=!isActivate
		endif
	endif
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function TSP_TS2_AddTab(tabNumber)
	Variable tabNumber

	// Create data folder used to store globals needed by the tab.
	// The current data folder when we are called is root:Packages:TSP.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S :DT
	
	// Create the tab.
	TabControl TSP_TabControl,proc=TSP_TabProc
	TabControl TSP_TabControl,tabLabel(tabNumber)="Step 2", value=tabNumber

	// Add the controls. Note that they are all initially deactivated (disable=1).
	Button step2TTestButton,pos={56,91},size={150,20},proc=ttestPairedProc,title="Run T Test",disable=1
	Button step2FTestButton,pos={56,91},size={150,20},proc=varTestButtonProc,title="Test Variances",disable=1
	Button step2WSTestButton,pos={56,91},size={150,20},proc=wilcoxonSignedProc,title="Wilcoxon Signed Test",disable=1
	Button step2WRTestButton,pos={56,91},size={150,20},proc=wilcoxonRankProc,title="Wilcoxon Rank Test",disable=1
	Button step2SignTestButton,pos={56,91},size={150,20},proc=signTestProc,title="Sign Test",disable=1
	Button step2ChiTestButton,pos={51,102},size={150,20},proc=chiTestProc,title="Chi Test",disable=1
	Button tspContingencyButton,pos={51,71},size={150,20},proc=contingencyTableButtonProc,title="Contingency Table",disable=1
	PopupMenu tspVariancesPop,pos={147,132},size={138,20},proc=variancesPopPopMenuProc,title="Variances are:"
	PopupMenu tspVariancesPop,mode=1,popvalue="Choose",value= #"\"Choose;Equal;Unequal;\"",disable=1

	SetDataFolder dfSave
End

Function TSP_TS2_Activate(isActivate)
	Variable isActivate		// 1 for activate, 0 for deactivate
	
	// Enable (show) or disable (hide) each control in the tab.
	NVAR branch=root:Packages:TSP:branch
	NVAR isPairedTest=root:Packages:TSP:isPairedTest

	Button step2TTestButton,disable=1
	Button step2FTestButton,disable=1
	Button step2WSTestButton,disable=1
	Button step2WRTestButton,disable=1
	Button step2SignTestButton,disable=1
	Button step2ChiTestButton,disable=1
	Button tspContingencyButton,disable=1
	PopupMenu tspVariancesPop,disable=1
	
	if(branch==0)
		if(isPairedTest)
			Button step2TTestButton,disable=!isActivate
		else
			Button step2FTestButton,disable=!isActivate
			PopupMenu tspVariancesPop,disable=!isActivate
		endif
	elseif(branch==1)
		if(isPairedTest)
			Button step2WSTestButton,disable=!isActivate
		else
			Button step2WRTestButton,disable=!isActivate
		endif
		
	elseif(branch==2)
		if(isPairedTest)
			Button step2SignTestButton,disable=!isActivate
		else
			Button step2ChiTestButton,disable=!isActivate
			Button tspContingencyButton,disable=!isActivate
		endif
	endif
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function TSP_TS3_AddTab(tabNumber)
	Variable tabNumber

	// Create data folder used to store globals needed by the tab.
	// The current data folder when we are called is root:Packages:TSP.
	String dfSave = GetDataFolder(1)
	NewDataFolder/O/S :DT
	
	// Create the tab.
	TabControl TSP_TabControl,proc=TSP_TabProc
	TabControl TSP_TabControl,tabLabel(tabNumber)="Step 3", value=tabNumber

	// Add the controls. Note that they are all initially deactivated (disable=1).
	Button step3TTestButton,pos={56,91},size={150,20},proc=ttestUnPairedProc,title="Run T Test",disable=1

	SetDataFolder dfSave
End

Function TSP_TS3_Activate(isActivate)
	Variable isActivate		// 1 for activate, 0 for deactivate
	
	// Enable (show) or disable (hide) each control in the tab.
	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	NVAR branch=root:Packages:TSP:branch

	Button step3TTestButton,disable=1
	
	if(branch==0)
		if(isPairedTest)
		else
			Button step3TTestButton,disable=!isActivate
		endif
	endif
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function allowStep(tabNumber)
	Variable &tabNumber
	
	NVAR branch=root:Packages:TSP:branch
	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	variable result=0
	switch(tabNumber)
		case 1:		
			reportStep0Choices()
			result=1
		break
		
		case 2:		// Wave Selection
			result=checkSourceWaves()
			if(branch==1)
				tabNumber=3
				Button NextButton,proc=finishButtonProc,title="Finish"
			endif
		break
		
		case 3:		// Step 1
			result=checkStep1Completion()
			if(result)
				if(branch==1 || branch==2 || (branch==0 && isPairedTest==1))
					// 	Button NextButton,pos={425,333},size={100,20},proc=NextButtonProc,title="Next >>"
					Button NextButton,proc=finishButtonProc,title="Finish"
				endif
			endif
		break
		
		case 4:		// step 2
			result=checkStep2Completion()
			if(isPairedTest==0 && branch==0)
				NVAR equalVariances=root:Packages:TSP:equalVariances
				if(equalVariances==0)
					tabNumber=3
					branch=1
				endif
			endif
			if(result)
				Button NextButton,proc=finishButtonProc,title="Finish"
			endif
		break
	endswitch
	
	return result
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function variancesPopPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			NVAR equalVariances=root:Packages:TSP:equalVariances
			if(popNum==2)
				equalVariances=1
			elseif(popNum==3)
				equalVariances=0
			endif
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function reportStep0Choices()

	SVAR nb=root:Packages:TSP:notebookName
	NVAR alpha=root:Packages:TSP:alpha
	String str
	ControlInfo dataTypePop
	str="\rData type is "+S_Value
	ControlInfo PairedSamples
	if(V_Value)
		str+=";  The two samples are dependent (paired)."
	else
		str+=";  The two samples are independent."
	endif
	WM_catNotebookBold(nb,str)
	
	str="\rSignificance level: alpha="+num2str(alpha)+".\r"
	WM_catNotebookBold(nb,str)
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function checkStep2Completion()

	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	if(isPairedTest==0)
		ControlInfo tspVariancesPop
		if(V_Value==1)
			Beep
			return 0
		endif
	endif
	return 1
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static Function checkStep1Completion()

	NVAR dataType=root:Packages:TSP:dataType
	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	NVAR branch=root:Packages:TSP:branch
	NVAR nominalStep1Completed=root:Packages:TSP:nominalStep1Completed

	if(dataType==kOrdinalDataType)
		return 1
	endif
	
	if(dataType==kNominalDataType)
		return nominalStep1Completed
	endif
	
	if(dataType==kRatioDataType)
		ControlInfo step1Pop
		if(V_value==1)
			return 0
		endif
		
		if(V_Value==2)
			branch=0
		else
			branch=1
		endif
		return 1
	endif
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function checkSourceWaves()
	
	SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
	SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
	
	selectedWave1Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave1List"))
	selectedWave2Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave2List"))
	NVAR dataType=root:Packages:TSP:dataType
	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	
	String str
	Wave/Z w1=$selectedWave1Str
	Wave/Z w2=$selectedWave2Str
	
	if(WaveExists(w1)==0 || WaveExists(w2)==0)
		return 0
	endif
	
	if(isPairedTest)
		if(numpnts(w1)!=numpnts(w2))
			doAlert 0,"Paired samples test require equal number of data points."
			return 0
		endif
	endif
	
	if(dataType==kNominalDataType)
		if(WaveType(w1)!=0 || WaveType(w2)!=0)
			doAlert 0,"Text waves are required for nominal data."
			return 0
		endif
	endif
	
	if(dataType!=kNominalDataType)
		if(WaveType(w1)==0 || WaveType(w2)==0)
			DoAlert 0, "Expected numeric wave input"
			return 0
		endif
		
		if((WaveType(w1)&0x01) || (WaveType(w2)&0x01))
			doAlert 0, "Complex waves are not supported"
			return 0
		endif
		
		WaveStats/Q/M=1 w1
		if(V_numNans>0)
			str="The wave "+selectedWave1Str +"contains NaNs.  You must remove the NaNs before proceeding with any test"
			doAlert 0,str
			return 0
		endif
		
		WaveStats/Q/M=1 w2
		if(V_numNans>0)
			str="The wave "+selectedWave2Str +"contains NaNs.  You must remove the NaNs before proceeding with any test"
			doAlert 0,str
			return 0
		endif
	endif
	
	SVAR nb=root:Packages:TSP:notebookName
	str="\rSelected waves: wave1="+selectedWave1Str+", wave2="+selectedWave2Str
	WM_catNotebookBold(nb,str)
	
	return 1
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function branch0UnpairedS1ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			strswitch(ba.ctrlName)
				case "br0_runsTest":
					doBranch0RunsTest()
				break
				
				case "br0_ksTest":
					doBranch0KSTest()
				break
				
				case "br0_jbTest":
					doBranch0JBTest()
				break
			endswitch
			SetDataFolder curDF
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function branch2NPRunsBProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			SVAR nb=root:Packages:TSP:notebookName
			NVAR alpha=root:Packages:TSP:alpha
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
			
			StatsNPNominalSRTest /ALPH=(alpha)/Q w1
			Wave W_StatsNPSRTest
			String str="\r\rNon Parametric Serial Randomness Test for "+selectedWave1Str 
			WM_catNotebookBold(nb,str)
			String tableName=UniqueName("NPSRTable",7,0)
			Edit/K=1/W=(20,50,550,250)/N=$tableName W_StatsNPSRTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_StatsNPSRTest[%u]>=W_StatsNPSRTest[%Critical_low] && W_StatsNPSRTest[%u]<=W_StatsNPSRTest[%Critical_high])
				WM_catNotebookPlain(nb,"\rCritical_low<= u <= Critical_high; do not reject the hypothesis of random sequence")
			else
				WM_catNotebookPlain(nb,"\rCritical_low> u or u> Critical_high; reject the hypothesis of random sequence")
			endif
			
			StatsNPNominalSRTest /ALPH=(alpha)/Q w2
			Wave W_StatsNPSRTest
			str="\r\rNon Parametric Serial Randomness Test for "+selectedWave2Str 
			WM_catNotebookBold(nb,str)
			Edit/K=1/W=(20,50,550,250)/N=$tableName W_StatsNPSRTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_StatsNPSRTest[%u]>=W_StatsNPSRTest[%Critical_low] && W_StatsNPSRTest[%u]<=W_StatsNPSRTest[%Critical_high])
				WM_catNotebookPlain(nb,"\rCritical_low<= u <= Critical_high; do not reject the hypothesis of random sequence")
			else
				WM_catNotebookPlain(nb,"\rCritical_low> u or u> Critical_high; reject the hypothesis of random sequence")
			endif

			NVAR nominalStep1Completed=root:Packages:TSP:nominalStep1Completed
			nominalStep1Completed=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function doBranch0RunsTest()

	SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
	SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
	NVAR alpha=root:Packages:TSP:alpha
	selectedWave1Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave1List"))
	selectedWave2Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave2List"))
	NVAR branch=root:Packages:TSP:branch
	SVAR nb=root:Packages:TSP:notebookName

	Wave/Z w1=$selectedWave1Str
	StatsSRTest/ALPH=(alpha) /NP/Q w1
	Wave W_StatsSRTest
	String tableName=UniqueName("SRTable",7,0)
	String str="\r\rSerial Randomness Test for "+selectedWave1Str 
	WM_catNotebookBold(nb,str)
	Edit/K=1/W=(5,44,310,329)/N=$tableName W_StatsSRTest.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(abs(W_StatsSRTest[%Prob]>alpha))
		WM_catNotebookPlain(nb,"\rP>alpha so do not reject the hypothesis that the data are random.")
	else
		WM_catNotebookPlain(nb,"\rP<alpha so reject the hypothesis that the data are random.")
	endif

	Wave/Z w2=$selectedWave2Str
	StatsSRTest/ALPH=(alpha) /NP/Q w2
	Wave W_StatsSRTest
	str="\r\rSerial Randomness Test for "+selectedWave2Str 
	WM_catNotebookBold(nb,str)
	Edit/K=1/W=(5,44,310,329)/N=$tableName W_StatsSRTest.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(abs(W_StatsSRTest[%Prob]>alpha))
		WM_catNotebookPlain(nb,"\rP>alpha so do not reject the hypothesis that the data are random.")
	else
		WM_catNotebookPlain(nb,"\rP<alpha so reject the hypothesis that the data are random.")
	endif

End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function doBranch0KSTest()
	
	SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
	SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
	NVAR alpha=root:Packages:TSP:alpha
	
	selectedWave1Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave1List"))
	selectedWave2Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave2List"))
	NVAR isPairedTest=root:Packages:TSP:isPairedTest
	
	Wave/Z w1=$selectedWave1Str
	NVAR ksMean=root:Packages:TSP:ksMean
	NVAR ksStdv=root:Packages:TSP:KsStdv
	NVAR branch=root:Packages:TSP:branch

	StatsKSTest/ALPH=(alpha) /CDFF=getKSUserCDF /Q w1
	Wave W_KSResults
	
	SVAR nb=root:Packages:TSP:notebookName
	String str="\r\rKS Test for "+selectedWave1Str +" against a normal distribution with mean="+num2str(ksMean)+" and stdv="+num2str(ksStdv)
	WM_catNotebookBold(nb,str)
	String tableName=UniqueName("KSTable",7,0)
	Edit/K=1/W=(16,44,371,270)/N=$tableName W_KSResults.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(W_KSResults[%D] > W_KSResults[%Critical])
		WM_catNotebookPlain(nb,"\rD>=Critical value -- hypothesis of normal distribution is rejected.")
	else
		WM_catNotebookPlain(nb,"\rD<Critical value -- hypothesis of normal distribution is not rejected.")
	endif
	
	Wave/Z w2=$selectedWave2Str
	StatsKSTest/ALPH=(alpha) /CDFF=getKSUserCDF /Q w2
	Wave W_KSResults
	
	str="\r\rKS Test for "+selectedWave2Str +" against a normal distribution with mean="+num2str(ksMean)+" and stdv="+num2str(ksStdv)
	WM_catNotebookBold(nb,str)
	Edit/K=1/W=(16,44,371,270)/N=$tableName W_KSResults.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(W_KSResults[%D] > W_KSResults[%Critical])
		WM_catNotebookPlain(nb,"\rD>=Critical value -- hypothesis of normal distribution is rejected.")
	else
		WM_catNotebookPlain(nb,"\rD<Critical value -- hypothesis of normal distribution is not rejected.")
	endif

	StatsKSTest/ALPH=(alpha) /Q w1,w2
	Wave W_KSResults
	str="\r\rKS Test for "+selectedWave1Str +" against " + selectedWave2Str
	WM_catNotebookBold(nb,str)
	Edit/K=1/W=(16,44,371,270)/N=$tableName W_KSResults.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(W_KSResults[%D] > W_KSResults[%Critical])
		WM_catNotebookPlain(nb,"\rD>=Critical value -- hypothesis of equal distributions is rejected.")
	else
		WM_catNotebookPlain(nb,"\rD<Critical value -- hypothesis of equal distribution is not rejected.")
	endif
	
	KillWaves/Z W_KSResults
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Function doBranch0JBTest()

	SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
	SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
	NVAR alpha=root:Packages:TSP:alpha
	SVAR nb=root:Packages:TSP:notebookName
	selectedWave1Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave1List"))
	selectedWave2Str= StringFromList(0,WS_SelectedObjectsList("TSP", "wave2List"))
	String tableName=UniqueName("JBTable",7,0)
	Wave/Z w1=$selectedWave1Str

	String str="\r\rJarque-Bera test for "+selectedWave1Str
	WM_catNotebookBold(nb,str)
	StatsJBTest/ALPH=(alpha)/Q w1
	Wave W_JBResults
	Edit/K=1/W=(16,44,352,244)/N=$tableName W_JBResults.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	if(W_JBResults[%JBStatistic]<W_JBResults[%Critical])
		WM_catNotebookPlain(nb,"\rJarque-Bera Statistic < Critical value => can't reject the hypothesis of a normal distribution.")
	else
		WM_catNotebookPlain(nb,"\rJarque-Bera Statistic >= Critical value => reject the hypothesis of a normal distribution.")
	endif

	str="\r\rJarque-Bera test for "+selectedWave2Str
	WM_catNotebookBold(nb,str)
	Wave/Z w2=$selectedWave2Str
	StatsJBTest/ALPH=(alpha)/Q w2
	Wave W_JBResults
	Edit/K=1/W=(16,44,352,244)/N=$tableName W_JBResults.ld
	Modifytable /w=$tableName autosize={0,0,-1,0,0}
	Notebook $nb ruler=Normal, picture={$tableName, -5, 1}

	if(W_JBResults[%JBStatistic]<W_JBResults[%Critical])
		WM_catNotebookPlain(nb,"\rJarque-Bera Statistic < Critical value => can't reject the hypothesis of a normal distribution.")
	else
		WM_catNotebookPlain(nb,"\rJarque-Bera Statistic >= Critical value => reject the hypothesis of a normal distribution.")
	endif
	
	KillWaves/Z W_JBResults
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function getKSUserCDF(inX)
	Variable inX
	
	NVAR ksMean=root:Packages:TSP:ksMean
	NVAR ksStdv=root:Packages:TSP:KsStdv
	return statsNormalCDF(inX,ksMean,KsStdv)
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function dataTypePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			NVAR dataType=root:Packages:TSP:dataType
			NVAR branch=root:Packages:TSP:branch
			dataType=pa.popNum
			branch=dataType-1
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function ttestPairedProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("TTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
			
			String str="\r\rT test for paired samples "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			StatsTTest/ALPH=(alpha)/CI/PAIR/Q  w1,w2
			Wave W_StatsTTest
			Edit/K=1/W=(5,44,510,251)/N=$tableName W_StatsTTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_StatsTTest[%critical]>abs(W_StatsTTest[%tValue]))
				WM_catNotebookPlain(nb,"\rAbs(tValue)<Critical => there is no significant difference between the populations")
			else
				WM_catNotebookPlain(nb,"\rAbs(tValue)>Critical => there is a significant difference between the populations")
			endif

			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function ttestUnPairedProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("TTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
			
			String str="\r\rT test for independent samples "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			StatsTTest/ALPH=(alpha)/CI/Q  w1,w2
			Wave W_StatsTTest
			Edit/K=1/W=(5,44,333,420)/N=$tableName W_StatsTTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(abs(W_StatsTTest[%t_statistic])>=abs(W_StatsTTest[%highCritical]))
				WM_catNotebookPlain(nb,"\rAbs(t_statistic)>=Critical => there is significant difference between the populations")
			else
				WM_catNotebookPlain(nb,"\rAbs(t_statistic)<Critical => there is no significant difference between the populations")
			endif
			
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function varTestButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("FTTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rF test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			StatsFTest /ALPH=(alpha)/Q w1,w2
			Wave W_StatsFTest
			Edit/K=1/W=(5,44,362,342)/N=$tableName W_StatsFTest.ld
			ModifyTable format(Point)=1,width(W_StatsFTest.l)=124
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_StatsFTest[%F]<=W_StatsFTest[%lowCriticalValue] || W_StatsFTest[%F]>=W_StatsFTest[%highCriticalValue])
				WM_catNotebookPlain(nb,"\rF statistic outside the critical range => reject hypothesis of equal variances.")
			else
				WM_catNotebookPlain(nb,"\rF statistic inside the critical range => do not reject hypothesis of equal variances.")
			endif
			SetDataFolder curDF
		break
	endswitch

	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function wilcoxonSignedProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("WSTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rWilcoxon Signed test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			StatsWilcoxonRankTest/ALPH=(alpha) /WSRT/Q w1,w2
			Wave W_WilcoxonTest
			Edit/K=1/W=(20,50,550,250)/N=$tableName W_WilcoxonTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_WilcoxonTest[%P_two_tail]<=alpha)
				WM_catNotebookPlain(nb,"\rP_two_tail<alpha so the hypothesis that the two samples are the same is rejected.")
			else
				WM_catNotebookPlain(nb,"\rP_two_tail>alpha so the hypothesis that the two samples are the same can't be rejected.")
			endif
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function wilcoxonRankProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("WRTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rWilcoxon Rank test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			StatsWilcoxonRankTest /ALPH=(alpha)/APRX=2/TAIL=7/Q w1,w2
			Wave W_WilcoxonTest
			Edit/K=1/W=(20,50,550,250)/N=$tableName W_WilcoxonTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_WilcoxonTest[%P_TwoTail]<=alpha)
				WM_catNotebookPlain(nb,"\rP_two_tail<alpha so the hypothesis that the two samples are the same is rejected.")
			else
				WM_catNotebookPlain(nb,"\rP_two_tail>alpha so the hypothesis that the two samples are the same can't be rejected.")
			endif
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch


	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function signTestProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("WSTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rSign test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)
			
			// if text waves need to convert to numeric representation
			if(WaveType(w1)==0)
				Wave w1=$convertTextWave($selectedWave1Str)
			endif
			
			if(WaveType(w2)==0)
				Wave w2=$convertTextWave($selectedWave2Str)
			endif
			
			StatsSignTest/ALPH=(alpha)/Q w1,w2
			Wave W_SignTest

			Edit/K=1/W=(20,50,550,250)/N=$tableName W_SignTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_SignTest[%P]<alpha)
				WM_catNotebookPlain(nb,"\rP<alpha => Reject H0 (i.e., the two samples are different.")
			else
				WM_catNotebookPlain(nb,"\rP>alpha => Do not reject H0 (i.e., there is no difference between the samples.")
			endif
			
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// The following function converts an arbitrary category text wave into numeric representation 
Function/S convertTextWave(inWave)
	Wave/T inWave
	
	String name=UniqueName("TC"+NameOfWave(inWave), 1, 0)
	Variable numPoints=numpnts(inWave)
	Make/O/N=(numPoints) $name,tmp=p
	Wave w=$name
	Duplicate/T/O inWave,ttmp
	Sort ttmp,ttmp,tmp
	Variable i=0,uniqueStrings=1		// starting with 1 so that there is no zero (chiTest will fail on zeros).
	Variable j
	String str0,str

	do
		str0=ttmp[i]
		w[tmp[i]]=uniqueStrings
		for(j=i+1;j<numPoints;j+=1)
			str=ttmp[j]
			if(cmpstr(str,str0))
				uniqueStrings+=1
				break
			else
				w[tmp[j]]=uniqueStrings
			endif
		endfor
		i=j
	while(i<numPoints)

	KillWaves/z tmp,ttmp
	return name
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function chiTestProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("CTTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rChi-square test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)

			// if text waves need to convert to numeric representation
			if(WaveType(w1)==0)
				Wave w1=$convertTextWave($selectedWave1Str)
			endif
			
			if(WaveType(w2)==0)
				Wave w2=$convertTextWave($selectedWave2Str)
			endif

			StatsChiTest/Q w1,w2
			Wave W_StatsChiTest

			Edit/K=1/W=(20,50,550,250)/N=$tableName W_StatsChiTest.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_StatsChiTest[%Chi_Squared]<W_StatsChiTest[%Critical])
				WM_catNotebookPlain(nb,"\rChi_Squared<Critical => the two samples are independent.")
			else
				WM_catNotebookPlain(nb,"\rChi_Squared>Critical => the two samples are not independent.")
			endif
			
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function finishButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR analysisComplete=root:Packages:TSP:analysisComplete
	if(analysisComplete)
		DoWindow/K TSP
	else
		doAlert 0,"Analysis has not been completed."
	endif
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function skipNPSRTestButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			NVAR nominalStep1Completed=root:Packages:TSP:nominalStep1Completed
			nominalStep1Completed=1
		break
	endswitch

	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Convert the data into numeric values and store them in a 2 row multi-column 2D wave used as an input to the contingency table
// analysis.
Function contingencyTableButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=GetDataFolder(1)
			SetDataFolder root:Packages:TSP
			SVAR selectedWave1Str=root:Packages:TSP:selectedWave1Str
			SVAR selectedWave2Str=root:Packages:TSP:selectedWave2Str
			NVAR alpha=root:Packages:TSP:alpha
			SVAR nb=root:Packages:TSP:notebookName
			String tableName=UniqueName("CTTable",7,0)
			Wave/Z w1=$selectedWave1Str
			Wave/Z w2=$selectedWave2Str
		
			String str="\r\rChi-square test for "+selectedWave1Str+" and "+selectedWave2Str
			WM_catNotebookBold(nb,str)

			// if text waves need to convert to numeric representation
			if(WaveType(w1)==0)
				Wave w1=$convertTextWave($selectedWave1Str)
			endif
			
			if(WaveType(w2)==0)
				Wave w2=$convertTextWave($selectedWave2Str)
			endif

			Concatenate/O {w1,w2}, conTableInput
			StatsContingencyTable/ALPH=(alpha)/Q conTableInput
			Wave W_ContingencyTableResults
			
			Edit/K=1/W=(20,50,550,250)/N=$tableName W_ContingencyTableResults.ld
			Modifytable /w=$tableName autosize={0,0,-1,0,0}
			Notebook $nb ruler=Normal, picture={$tableName, -5, 1}
			DoWindow/K $tableName
			if(W_ContingencyTableResults[%Chi_Squared]<W_ContingencyTableResults[%Critical_Value])
				WM_catNotebookPlain(nb,"\rChi_squared<Critical => the two samples are independent.")
			else
				WM_catNotebookPlain(nb,"\rChi_Squared>Critical => the two samples are not independent.")
			endif
			
			NVAR analysisComplete=root:Packages:TSP:analysisComplete
			analysisComplete=1
			SetDataFolder curDF
		break
	endswitch

	return 0
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
