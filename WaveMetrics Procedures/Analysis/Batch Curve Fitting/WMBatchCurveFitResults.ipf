#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma IgorVersion=9.00
#pragma version=9.00 // ship with Igor 9
#include <WMBatchCurveFitDefs>
#include <PopupWaveSelector>, version>=1.18 

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Change Log /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// 10-17-2014 - Changed the default size of the Results Panel, including all the ResizeControlInfo  userdata
// 10-20-2014 - Made the default and minimum size smaller, again updating ResizeControlInfo userdata
//  9-2-2015 - Made the sorting of curve fit result lines only occur when the fit is not limited to a point range
//  12-2015 - Added Results support for all at once fit functions
// JW 190415 Fixed compile error at line 2402 that only showed up after the TextBox compile was fixed to check for bad input
// JW 210507 Version 9 For IP9 only added Voigt and dblexp_peak built-in fit functions

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// The Main Results Panel Function /////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

// Creates a Batch Curve Fit results panel with a tab showing individual fit results and a tab showing a summary of all the fits.
// BatchDataDir is the folder with the data on which batch fits are run.  The batchName is a name for a particular batch fit on that data.
// Will work with a directory set up via the Batch Curve Fit Dialog.  It should also work on a batch fit that has had WMStoreBatchData(...) run on it.
Function CreateResultsPanel(batchDataDir, batchName)
	String batchDataDir, batchName//, resultsMatrixStr
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	DFREF batchDataDFR = $(batchDataDir)
	DFREF batchDFR = getBatchFolderDFR(batchDataDir, batchName)
	DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDataDir, batchName)
	
	NVAR resultsPanelX = packageBatchDFR:WMresultsPanelX
	NVAR resultsPanelY = packageBatchDFR:WMresultsPanelY
	NVAR resultsPanelWidth = packageBatchDFR:WMresultsPanelWidth 
	resultsPanelWidth = max(resultsPanelWidth, 600)
	NVAR resultsPanelHeight = packageBatchDFR:WMresultsPanelHeight 
	resultsPanelHeight = max(resultsPanelHeight, 615)
	
	String /G packageBatchDFR:WMDisplayErrMessage="" 
	SVAR errMessage = packageBatchDFR:WMDisplayErrMessage
	
	Variable dataOrResultsWaveExist = 3 /// bit-wise argument, bit 0 (0 or 1) set if results can be displayed, bit 1 (0 or 2) if original data can be displayed
		
	SVAR /Z currFitFunc = batchDFR:WMfitFunc										    
	if (!SVAR_exists(currFitFunc) || !strLen(currFitFunc))
		errMessage += "Warning: No fit function specified\r"
		dataOrResultsWaveExist = dataOrResultsWaveExist & 2 // results cannot be displayed
	endif
	
	NVAR /Z nCoefs = batchDFR:WMnInCoefs
	if (!NVAR_exists(nCoefs))
		WAVE inArgs = packageDFR:nInputArgsHash
		
		if(SVAR_exists(currFitFunc))
			Variable nCoefsTmp = inArgs[%$currFitFunc]
		
			if (numtype(nCoefsTmp)!=2)
				Variable /G batchDFR:WMnInCoefs
				NVAR nCoefs = batchDFR:WMInCoefs
				nCoefs = nCoefsTmp
			else	
				errMessage += "Warning: the number of input coefficients not specified.  Data results may not be displayed.\r"	
				dataOrResultsWaveExist = dataOrResultsWaveExist & 2 // results cannot be displayed	
			endif
		endif
	endif
	
	NVAR /Z xoffset = batchDFR:WMXOffset
	if (!NVAR_exists(xoffset))
		Variable /G batchDFR:WMXOffset = NaN
		NVAR xoffset = batchDFR:WMXOffset
	endif
	
	Variable /G packageBatchDFR:WMshowFitEquation = 1
	NVAR showFitEquation = packageBatchDFR:WMshowFitEquation
	Wave /T inArgsTxt = packageDFR:inputArgsTextDescription
		
	Wave /Z resultsResiduals = batchDFR:WMBatchResultsResiduals
	if (!waveExists(resultsResiduals))
		errMessage += "Warning: the results residual wave is missing\r"
	endif
		
	Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
	if (!waveExists(resultsMatrix))
		errMessage += "Warning: the results matrix is missing.  Unable to display fit results\r"
		dataOrResultsWaveExist = dataOrResultsWaveExist & 2 // results cannot be displayed
	endif	
	
	Make /FREE/WAVE /N=0 batchWaves
	Make /FREE/WAVE /N=0 batchXWaves
	getYandXBatchData(batchDataDir, batchName, batchWaves, batchXWaves)
	
	Variable batchWavesSize = DimSize(batchWaves, 0)
	if (numType(batchWavesSize)==2 || batchWavesSize<=0)
		errMessage += "Warning: no original data specified.  Unable to display original data\r"
		dataOrResultsWaveExist = dataOrResultsWaveExist & 1 // original data cannot be displayed	
	endif
	
	if (strlen(errMessage))
		Variable rL=285, rT=111, rW=400, rH=82
		if (strlen(WinList("batchFitPanel", ";", "WIN:64")))
			GetWindow batchFitPanel wsize
			rT=V_top+(V_bottom-V_top-rT)/2
			rL=V_left+(V_right-V_left-rW)/2
		endif
		NewPanel /FLT /K=1 /N=ViewBatchFitResultsErrorPanel /W=(50,50,600,300)
		TitleBox errorPanel, win=ViewBatchFitResultsErrorPanel, fsize=12, pos={20, 20}, size={360, 13}, Variable=errMessage
		
		ControlUpdate /W=ViewBatchFitResultsErrorPanel errorPanel
		ControlInfo /W=ViewBatchFitResultsErrorPanel errorPanel
		GetWindow ViewBatchFitResultsErrorPanel, wsize	
		MoveWindow /W=ViewBatchFitResultsErrorPanel V_left, V_top, V_right, V_top+rH+V_Height 
		Button closeButton, win=ViewBatchFitResultsErrorPanel, pos={(V_right-V_left-80)/2,V_Height+50}, size={80,20}, title="OK", proc=WMcloseAlert
	endif
	
	/////////////// Make the Full Panel //////////////
	if (dataOrResultsWaveExist)    
		String currentPanel
		String currentPanelTitle

		Struct batchDataStruct batchInfo
		initBatchDataStruct(batchInfo)
			
		getBatchData(batchDataDir, batchName, batchInfo)
		
		String runTime=""
		String dataFolderStr = ReplaceString("::", batchDataDir+":"+constBatchRunsDirName+":"+PossiblyQuoteName(batchName), ":")
		String utilityWaveName = dataFolderStr+":WMBatchResultsMatrix"
		if (waveExists($utilityWaveName))
			Variable wDate = ModDate($utilityWaveName)
			runTime = Secs2Date(wDate, 0)+" "+Secs2Time(wDate,2)
		endif
		
		DoWindow/F resultsWin0
		if (V_flag != 0)		// Panel already exists - rename it
			String existingWinNames
			Variable i
			do
				i=i+1 //yes, its intended to start at 1
				existingWinNames = WinList("resultsWin"+num2str(i), ";", "")
			while (strlen(existingWinNames))

			currentPanel = "resultsWin"+num2str(i)
			currentPanelTitle = batchName+" Results, "+runTime
		else 
			currentPanel = "resultsWin0"
			currentPanelTitle = batchName+" Results, "+runTime 
		endif
	
		NewPanel /K=1/W=(resultsPanelX,resultsPanelY,resultsPanelX+resultsPanelWidth,resultsPanelY+resultsPanelHeight) /N=$(currentPanel)
		DoWindow /T $currentPanel, currentPanelTitle
		SetWindow $(currentPanel), hook(resultsHook)=ResultsPanelHook
		DefaultGUIFont /W=$(currentPanel) /Mac popup={"Geneva", 12, 0}
		
		DefineGuide /W=$(currentPanel) TabAreaLeft={FL,10}			
		DefineGuide /W=$(currentPanel) TabAreaRight={FR,-10}
		DefineGuide /W=$(currentPanel) TabAreaTop={FT,31}
		DefineGuide /W=$(currentPanel) TabAreaBottom={FB,-10}

		TabControl WMResultsTabControl,win=$(currentPanel),pos={10,7},size={resultsPanelWidth-20,resultsPanelHeight-20},proc=BatchResultsTabControlProc
		TabControl WMResultsTabControl,win=$(currentPanel),userdata=batchDataDir+";"+batchName, fsize=WMBCFBaseFontSize
		///// Resize Code from Resize Control Panel	
			
		TabControl WMResultsTabControl,win=$(currentPanel),tabLabel(0)="Basic Results"
		TabControl WMResultsTabControl,win=$(currentPanel),tabLabel(1)="Summary Results"
		
		NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom) /N=Tab0 /Host=$(currentPanel)
		ModifyPanel /W=$(currentPanel)#Tab0 frameStyle=0,frameInset=0
		
		DefaultGUIFont /W=$(currentPanel)#Tab0 /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
		NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom)  /N=Tab1ContentPanel /Host=$(currentPanel)
		ModifyPanel /W=$(currentPanel)#Tab1ContentPanel frameStyle=0,frameInset=0
		DefaultGUIFont /W=$(currentPanel)#Tab1ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
		
		TabControl WMResultsTabControl,win=$(currentPanel),userdata(ResizeControlsInfo)= A"!!,A.!!#:B!!#D!!!#D$^]4?7!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TabControl WMResultsTabControl,win=$(currentPanel),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TabControl WMResultsTabControl,win=$(currentPanel),userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"		
		SetWindow $currentPanel,hook(ResizeControls)=ResizeControls#ResizeControlsHook	
		SetWindow $currentPanel,userdata(ResizeControlsInfo)= A"!!*'\"z!!#D&!!#D)^]4?7zzzzzzzzzzzzzzzzzzzz"
		SetWindow $currentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow $currentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
		SetWindow $currentPanel,userdata(ResizeControlsGuides)=  "TabAreaLeft;TabAreaRight;TabAreaTop;TabAreaBottom;"
		SetWindow $currentPanel,userdata(ResizeControlsInfoTabAreaLeft)= A":-hTC3`KNs6#pOF9P%gX4',!K3c\\eQF_l/@=(uP+4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3\\`<M7o`,K756hm9KPaE8OQ!&3]g5.9MeM`8Q88W:-(*`3r"
		SetWindow $currentPanel,userdata(ResizeControlsInfoTabAreaRight)= A":-hTC3`KNs6#pOF;JBcWF?<Pq:-*E,F*2;@F'!'n0KW6::dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(6m0KVd)8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MSq@"
		SetWindow $currentPanel,userdata(ResizeControlsInfoTabAreaTop)= A":-hTC3`KNs6#pOF<,Z_;=%Q.JEb0<7Cij`\"Bl5Ud<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B1GLs]<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\rKP"
		SetWindow $currentPanel,userdata(ResizeControlsInfoTabAreaBottom)= A":-hTC3`KNs6#pOF6>psfDf%R;8PV<eATN!1FE:MtDD4.O=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr/0Jtp^<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<'?3r"		
			
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////	Tab 0: Basics	///////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		TitleBox displayedBatch, win=$(currentPanel)#Tab0, pos={0, 2}, size={resultsPanelWidth-20, 30}, frame=0, fsize=20, fstyle=1, fixedSize=1, anchor=MC, title=batchName
		TitleBox displayedWave, win=$(currentPanel)#Tab0, pos={0, 25}, size={resultsPanelWidth-20, 30}, frame=0, fsize=16, fstyle=1, fixedSize=1, anchor=MC
		TitleBox displayedIndexOf, win=$(currentPanel)#Tab0, pos={0, 52}, size={resultsPanelWidth-20, 20}, frame=0, fsize=14, fstyle=1, fixedSize=1, anchor=MC
		String /G packageBatchDFR:WMResultsPanelErrString
		TitleBox displayedError, win=$(currentPanel)#Tab0, pos={10, resultsPanelHeight-285}, size={resultsPanelWidth-20, 40}, frame=0, fsize=14, fstyle=1; DelayUpdate
		TitleBox displayedError, win=$(currentPanel)#Tab0, fixedSize=1, variable=packageBatchDFR:WMResultsPanelErrString
		
		///// Help! /////
		Button helpPanelButton win=$(currentPanel)#Tab0, appearance={os9}, pos={20, 10}, size={80, 25}, title="Help"
		Button helpPanelButton win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName+";"+currentPanel, proc=WMShowHelp
		
		///// Export Results /////
		Button exportPanelButton win=$(currentPanel)#Tab0, appearance={os9}, pos={resultsPanelWidth-120, 10}, size={80, 25}, title="Export"
		Button exportPanelButton win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName+";"+currentPanel, proc=WMShowIndivExportPanel
		
		Button backButton, win=$(currentPanel)#Tab0, appearance={os9}, pos={10,resultsPanelHeight-80},size={70,30},title="Previous"
		Button backButton, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=WMShowNextFit
		Button forwardButton, win=$(currentPanel)#Tab0, appearance={os9}, pos={90,resultsPanelHeight-80},size={70,30},title="Next"
		Button forwardButton, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=WMShowNextFit
		
		GroupBox axisControlGB, win=$(currentPanel)#Tab0, title="                        Axis Control", pos={175, resultsPanelHeight-100}; DelayUpdate
		GroupBox axisControlGB, win=$(currentPanel)#Tab0, size={230, 58}, fsize=12
		SetDrawEnv /W=$(currentPanel)#Tab0 dash=1
		DrawLine /W=$(currentPanel)#Tab0 240, resultsPanelHeight-82, 240, resultsPanelHeight-44
		
		NVAR doLogY = packageBatchDFR:WMdoLogYaxis		
		NVAR doLogX = packageBatchDFR:WMdoLogXaxis
		Checkbox logYAxis, win=$(currentPanel)#Tab0, pos={182,resultsPanelHeight-81}, size={80,23},title="Log Y",fsize=12; DelayUpdate
		Checkbox logYAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setLogAxisProc, variable=doLogY
		Checkbox logXAxis, win=$(currentPanel)#Tab0, pos={182,resultsPanelHeight-63}, size={80,23},title="Log X",fsize=12; DelayUpdate
		Checkbox logXAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setLogAxisProc, variable=doLogX
		
		NVAR doConstantYaxis = packageBatchDFR:WMconstantYaxis
		NVAR doConstantXaxis = packageBatchDFR:WMconstantXaxis		
		Checkbox autoConstantYAxis, win=$(currentPanel)#Tab0, pos={250,resultsPanelHeight-81}, size={80,23},title="Auto Y",fsize=12; DelayUpdate
		Checkbox autoConstantYAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setAxesProc, value = doConstantYaxis==WMautoConstantAxis
		Checkbox manConstantYAxis, win=$(currentPanel)#Tab0, pos={325,resultsPanelHeight-81}, size={80,23},title="Manual Y",fsize=12; DelayUpdate
		Checkbox manConstantYAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setAxesProc, value = doConstantYaxis==WMmanualConstantAxis
		Checkbox autoConstantXAxis, win=$(currentPanel)#Tab0, pos={250,resultsPanelHeight-63}, size={80,23},title="Auto X",fsize=12; DelayUpdate
		Checkbox autoConstantXAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setAxesProc, value = doConstantXaxis==WMautoConstantAxis
		Checkbox manConstantXAxis, win=$(currentPanel)#Tab0, pos={325,resultsPanelHeight-63}, size={80,23},title="Manual X",fsize=12; DelayUpdate
		Checkbox manConstantXAxis, win=$(currentPanel)#Tab0, userdata=batchDataDir+";"+batchName, proc=setAxesProc, value = doConstantXaxis==WMmanualConstantAxis
		
		NVAR manYMin = packageBatchDFR:WMmanYMin
		NVAR manYMax = packageBatchDFR:WMmanYMax
		NVAR manXMin = packageBatchDFR:WMmanXMin
		NVAR manXMax = packageBatchDFR:WMmanXMax
			
		Checkbox showEquation, win=$(currentPanel)#Tab0, pos={resultsPanelWidth-175,resultsPanelHeight-76},size={140,30}, title="Show Fit Equation"; DelayUpdate
		Checkbox showEquation, win=$(currentPanel)#Tab0, proc=WMShowFitEquationProc, fsize=14, win=$(currentPanel), userdata=batchDataDir+";"+batchName, value=1

		DefineGuide /W=$(currentPanel)#Tab0 tableLeft={FL, 10}	
		DefineGuide /W=$(currentPanel)#Tab0 tableRight={FR, -10}
		DefineGuide /W=$(currentPanel)#Tab0 tableTop={FB, -200}
		DefineGuide /W=$(currentPanel)#Tab0 tableBottom={FB, -60}
	
		DefineGuide /W=$(currentPanel)#Tab0 graphLeft={FL, 10}
		DefineGuide /W=$(currentPanel)#Tab0 graphRight={FR, -10}
		DefineGuide /W=$(currentPanel)#Tab0 graphTop={FT, 80}
		DefineGuide /W=$(currentPanel)#Tab0 graphBottom={FB, -250}

		DefineGuide /W=$(currentPanel)#Tab1ContentPanel tableLeft1={FL, 10}	
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel tableRight1={FR, -10}
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel tableTop1={FB, -190}
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel tableBottom1={FB, -10}

		DefineGuide /W=$(currentPanel)#Tab1ContentPanel graphLeft1={FL, 10}
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel graphRight1={FR, -10}
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel graphTop1={FT, 45}
		DefineGuide /W=$(currentPanel)#Tab1ContentPanel graphBottom1={FB, -245}

		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#7a!!#D!!!#=Sz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#=+!!#D!!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#>^!!#D!!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,A.!!#B_!!#D!!!#>.z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl!rzzzzzzzz"
		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Sezzzzzzzzzzzz!!!"
		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,IV!!#;-!!#?Y!!#=+z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGlB6%F\"BL6WZFDl!rzzzzzzzz"
		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGlFCAWpAQ3Sezzzzzzzzzzzz!!!"
		
		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,A.!!#Cj^]6][!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,En!!#Cj^]6][!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,G?!!#Ce^]6`6!!#?!z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,GF!!#CjJ,ho0!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,GF!!#Co!!#>Z!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H5!!#CjJ,hoL!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H]J,ht@J,hon!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H5!!#Co!!#?!!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H]J,htE!!#?C!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,I:J,htA^]6_0!!#<Pz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#D!!!#CtJ,fQLzzzzzzzzzzzzzzzzzzzz"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsGuides)=  "tableLeft;tableRight;tableTop;tableBottom;graphLeft;graphRight;graphTop;graphBottom;"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableLeft)= A":-hTC3cne>Ch6:OAop+98PV<eATN!1FE:MtDD3;7@:CoP<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B1,(d[<CoSI0fhct4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\`<M"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableRight)= A":-hTC3cne>Ch6LYB4uBK=%Q.JEb0<7Cij`\"Bl5UL<+05i4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]/lN4%E:B6q&gk7T)<<<CoSI1-.Kp78-NR;b9q[:JNr&0ebZ"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableTop)= A":-hTC3cne>Ch6RaE'%,m:-*E,F*2;@F'!'n0I'P*@PBlC=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr-0Jtp^<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<*@0KT"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableBottom)= A":-hTC3cne>Ch5qOFEDG<4',!K3c\\eQF_l/@=(uP+,?/)\\0KW6::dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(6h2*4<.8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B/N,:E"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographLeft)= A":-hTC3bNJAE+hpVAop+98PV<eATN!1FE:MtDD3;7@:CoP<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B1,(d[<CoSI0fhct4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\`<M"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographRight)= A":-hTC3bNJAE+i-`B4uBK=%Q.JEb0<7Cij`\"Bl5UL<+05i4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]/lN4%E:B6q&gk7T)<<<CoSI1-.Kp78-NR;b9q[:JNr&0ebZ"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographTop)= A":-hTC3bNJAE+i3hE'%,m:-*E,F*2;@F'!'n0I'P*@PBlC=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr*0eka[<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]JfT"
		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographBottom)= A":-hTC3bNJAE+hRVFEDG<4',!K3c\\eQF_l/@=(uP+,?/)\\0KW6::dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(0g2*4<.8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B/M]1;3r"

//		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#7a!!#D:!!#=Sz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
//		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
//		TitleBox displayedBatch,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
//		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#=+!!#D:!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
//		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
//		TitleBox displayedWave,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"		
//		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!*'\"!!#>^!!#D:!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
//		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
//		TitleBox displayedIndexOf,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"		
//		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,J\"!!#;-!!#?Y!!#=+z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGlB6%F\"BL6WZFDl!rzzzzzzzz"
//		Button exportPanelButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGlFCAWpAQ3Sezzzzzzzzzzzz!!!"				
//		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,A.!!#CHJ,hte!!#>.z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
//		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl!rzzzzzzzz"
//		TitleBox displayedError,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Sezzzzzzzzzzzz!!!"
//		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,BY!!#D5!!#?Y!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
//		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		Button backButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,FK!!#D5!!#?Y!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
//		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		Button forwardButton,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,Gl!!#D0!!#BF!!#?!z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		GroupBox axisControlGB,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H(!!#D4^]6\\p!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox logYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,H(!!#D95QF,E!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox logXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,Ha!!#D4^]6]7!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox autoConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,I5!!#D4^]6]Y!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox manConstantYAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"
//		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,Ha!!#D95QF,a!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox autoConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"		
//		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,I5!!#D95QF-.!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
//		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox manConstantXAxis,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"		
//		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,If^]6bL!!#@o!!#<Pz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<!-2LeBL6WZFDl!rzzzzzzzz"
//		CheckBox showEquation,win=$(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<!+B>QAQ3Sezzzzzzzzzzzz!!!"			
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#D:!!#D>^]4?7zzzzzzzzzzzzzzzzzzzz"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"		
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsGuides)=  "tableLeft;tableRight;tableTop;tableBottom;graphLeft;graphRight;graphTop;graphBottom;"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableLeft)= A":-hTC3cne>Ch6:OAop+98PV<eATN!1FE:MtDD3;7@:CoP<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B1,(d[<CoSI0fhct4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\`<M"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableRight)= A":-hTC3cne>Ch6LYB4uBK=%Q.JEb0<7Cij`\"Bl5UL<+05i4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]8rO4%E:B6q&gk7T)<<<CoSI1-.Kp78-NR;b9q[:JNr&0ebZ"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableTop)= A":-hTC3cne>Ch6RaE'%,m:-*E,F*2;@F'!'n0I'P*@PBlC=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr.1GCm\\<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<*@0KT"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfotableBottom)= A":-hTC3cne>Ch5qOFEDG<4',!K3c\\eQF_l/@=(uP+,?/)\\0KW6::dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(9l0KVd)8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B/N,:E"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographLeft)= A":-hTC3bNJAE+hpVAop+98PV<eATN!1FE:MtDD3;7@:CoP<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B1,(d[<CoSI0fhct4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\`<M"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographRight)= A":-hTC3bNJAE+i-`B4uBK=%Q.JEb0<7Cij`\"Bl5UL<+05i4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]8rO4%E:B6q&gk7T)<<<CoSI1-.Kp78-NR;b9q[:JNr&0ebZ"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographTop)= A":-hTC3bNJAE+i3hE'%,m:-*E,F*2;@F'!'n0I'P*@PBlC=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr*0eka[<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]JfT"
//		SetWindow $(currentPanel)#Tab0,userdata(ResizeControlsInfographBottom)= A":-hTC3bNJAE+hRVFEDG<4',!K3c\\eQF_l/@=(uP+,?/)\\0KW6::dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(3k0KVd)8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B/M]1;3r"

		if (waveExists(resultsMatrix))
			Edit /HOST=$(currentPanel)#Tab0 /N=FitResultsTable /FG=(tableLeft, tableTop, tableRight, tableBottom) resultsMatrix 
			ModifyTable /W=$(currentPanel)#Tab0#FitResultsTable horizontalIndex=2, showParts=124
		endif
		Display /HOST=$(currentPanel)#Tab0 /N=results /FG=(graphLeft, graphTop, graphRight, graphBottom)  
	
		Variable /G  packageBatchDFR:WMindexToResultsPanelImage = 0
		NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
	
		indxTRPI = 0
		WMdisplayFitResultInPanel(indxTRPI, currentPanel+"#Tab0", batchDataDir, batchName)
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////	Tab 1: Summary Views	///////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		TitleBox summaryTitle, win=$(currentPanel)#Tab1ContentPanel, pos={0, 2}, size={resultsPanelWidth-20, 30}, frame=0, fsize=18, fstyle=1, fixedSize=1, anchor=MC
		TitleBox summaryTitle, win=$(currentPanel)#Tab1ContentPanel, title=batchName+" Batch Summary"

		///// Help! /////		
		Button helpPanelButton win=$(currentPanel)#Tab1ContentPanel, appearance={os9}, pos={20, 10}, size={80, 25}, title="Help"
		Button helpPanelButton win=$(currentPanel)#Tab1ContentPanel, userdata=batchDataDir+";"+batchName+";"+currentPanel, proc=WMShowHelp
		
		///// Export Results /////
		Button exportPanelButton win=$(currentPanel)#Tab1ContentPanel, appearance={os9}, pos={resultsPanelWidth-120, 10}, size={80, 25}, title="Export"
		Button exportPanelButton win=$(currentPanel)#Tab1ContentPanel, userdata=batchDataDir+";"+batchName+";"+currentPanel, proc=WMShowSummaryExportPanel		
		
		Display /HOST=$(currentPanel)#Tab1ContentPanel /N=summaryGraph /FG=(graphLeft1, graphTop1, graphRight1, graphBottom1)
		
		Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
		String dimLabels = "\""
		Variable nResultsCols
		if (waveExists(resultsMatrix))
			nResultsCols = DimSize(resultsMatrix, 1)
			for (i=0; i<nResultsCols; i+=1)  
				dimLabels += GetDimLabel(resultsMatrix, 1, i)+";"
			endfor 
		endif
		dimLabels += "\""	
			
		PopupMenu yDataMain, win=$(currentPanel)#Tab1ContentPanel, pos={resultsPanelWidth/2-200,resultsPanelHeight-279},size={150,30}, value=#dimLabels
		PopupMenu yDataMain, win=$(currentPanel)#Tab1ContentPanel, title="Y Axis Data", proc=SetDisplaySummary, userdata=batchDataDir+";"+batchName, fsize=WMBCFBaseFontSize
		String errLabels = "\"_none_;"+dimLabels[1,strlen(dimLabels)-1]
		PopupMenu yDataErr, win=$(currentPanel)#Tab1ContentPanel, pos={resultsPanelWidth/2-200,resultsPanelHeight-254},size={150,30}, value=#errLabels
		PopupMenu yDataErr, win=$(currentPanel)#Tab1ContentPanel, title="Y Axis Error", proc=SetDisplaySummary, userdata=batchDataDir+";"+batchName, fsize=WMBCFBaseFontSize
		dimlabels = "\"_dataset index_;"+dimLabels[1,strlen(dimLabels)-1]
		PopupMenu xDataMain, win=$(currentPanel)#Tab1ContentPanel, pos={resultsPanelWidth/2+50,resultsPanelHeight-279},size={150,30}, value=#dimLabels
		PopupMenu xDataMain, win=$(currentPanel)#Tab1ContentPanel, title="X Axis Data", proc=SetDisplaySummary, userdata=batchDataDir+";"+batchName, fsize=WMBCFBaseFontSize
		PopupMenu xDataErr, win=$(currentPanel)#Tab1ContentPanel, pos={resultsPanelWidth/2+50,resultsPanelHeight-254},size={150,30}, value=#errLabels
		PopupMenu xDataErr, win=$(currentPanel)#Tab1ContentPanel, title="X Axis Error", proc=SetDisplaySummary, userdata=batchDataDir+";"+batchName, fsize=WMBCFBaseFontSize
		TitleBox summaryTitle, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!*'\"!!#7a!!#D!!!#=Sz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox summaryTitle, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox summaryTitle, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"		
		PopupMenu yDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,F-!!#Bb!!#A%!!#=Sz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		PopupMenu yDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl\"Nzzzzzzzz"
		PopupMenu yDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Se0`V1Rzzzzzzzzzzz!!!"
		PopupMenu yDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,F-!!#BnJ,hqP!!#=Sz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		PopupMenu yDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl\"Nzzzzzzzz"
		PopupMenu yDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Se0`V1Rzzzzzzzzzzz!!!"		
		PopupMenu xDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,Hj!!#Bb!!#A%!!#=Sz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		PopupMenu xDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl\"Nzzzzzzzz"
		PopupMenu xDataMain, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Se0`V1Rzzzzzzzzzzz!!!"	
		PopupMenu xDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,Hj!!#BnJ,hqP!!#=Sz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		PopupMenu xDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ctB6%F\"BL6WZFDl\"Nzzzzzzzz"
		PopupMenu xDataErr, win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ctFCAWpAQ3Se0`V1Rzzzzzzzzzzz!!!"		
		
		Button exportPanelButton,win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,IV!!#;-!!#?Y!!#=+z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button exportPanelButton,win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGlB6%F\"BL6WZFDl!rzzzzzzzz"
		Button exportPanelButton,win=$(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGlFCAWpAQ3Sezzzzzzzzzzzz!!!"		
		
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#D!!!#CtJ,fQLzzzzzzzzzzzzzzzzzzzz"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsGuides)=  "tableLeft1;tableRight1;tableTop1;tableBottom1;graphLeft1;graphRight1;graphTop1;graphBottom1;"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfotableLeft1)= A":-hTC3cne>Ch6:OAooah=%Q.JEb0<7Cij`\"Bl5UL<+05j6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3\\iBN7o`,K756hm9KPaE8OQ!&3]g5.9MeM`8Q88W:-(*`3r"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfotableRight1)= A":-hTC3cne>Ch6LYB4uBA4',!K3c\\eQF_l/@=(uP+,?/)\\0gfksFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(6l0KVd)8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MSq@"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfotableTop1)= A":-hTC3cne>Ch6RaE%sFU8PV<eATN!1FE:MtDD3;7@:CrYDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B1bgjL7o`,K756hm69@\\;8OQ!&3]g5.9MeM`8Q88W:-'s]3A<M"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfotableBottom1)= A":-hTC3cne>Ch5qOFEDG<0frH.:-*E,F*2;@F'!'n0I'P*@PL5gDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr.3Ailg<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<'?3r"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfographLeft1)= A":-hTC3bNJAE+hpVAooah=%Q.JEb0<7Cij`\"Bl5UL<+05j6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3\\iBN7o`,K756hm9KPaE8OQ!&3]g5.9MeM`8Q88W:-(*`3r"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfographRight1)= A":-hTC3bNJAE+i-`B4uBA4',!K3c\\eQF_l/@=(uP+,?/)\\0gfksFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(6l0KVd)8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MSq@"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfographTop1)= A":-hTC3bNJAE+i3hE%sFU8PV<eATN!1FE:MtDD3;7@:CrYDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B2`<`f<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]&]U"
		SetWindow $(currentPanel)#Tab1ContentPanel,userdata(ResizeControlsInfographBottom1)= A":-hTC3bNJAE+hRVFEDG<0frH.:-*E,F*2;@F'!'n0I'P*@PL5gDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr,2D@3_<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<*D2*1"		
		
		DisplaySummary(currentPanel, 0, -1, -1, -1)
				
		SetWindow $(currentPanel)#Tab0, hide=0
		SetWindow $(currentPanel)#Tab1ContentPanel, hide=1
		
		if (waveExists(resultsMatrix))
			Make /D/O/N=(9, DimSize(resultsMatrix, 1)) packageBatchDFR:WMBFResultsSummary
			Make /T/O/N=(9) packageBatchDFR:WMBFSummaryCatagories
			Wave summaryWave = packageBatchDFR:WMBFResultsSummary
			Wave /T summaryCats = packageBatchDFR:WMBFSummaryCatagories
			nResultsCols = DimSize(resultsMatrix, 1)					
			for (i=0; i<nResultsCols; i+=1)											
				Duplicate /O/FREE/R=[][i, i] resultsMatrix waveForWaveStats
				WaveStats /Q/Z waveForWaveStats
				summaryWave[0][i] = V_npnts
				summaryWave[1][i] = V_avg
				summaryWave[2][i] = V_sdev
				summaryWave[3][i] = V_min
				summaryWave[4][i] = V_max
				summaryWave[5][i] = V_sem
				summaryWave[6][i] = V_adev
				summaryWave[7][i] = V_skew
				summaryWave[8][i] = V_kurt
				
				String colName = GetDimLabel(resultsMatrix, 1, i)
				SetDimLabel 1, i, $colName, summaryWave
			endfor

			SetDimLabel 0, 0, 'n points', summaryWave
			summaryCats[0] = "n points"
			SetDimLabel 0, 1, avg, summaryWave
			summaryCats[1] = "average"
			SetDimLabel 0, 2, 'std dev', summaryWave
			summaryCats[2] = "std dev"
			SetDimLabel 0, 3, min, summaryWave
			summaryCats[3] = "min"
			SetDimLabel 0, 4, max, summaryWave
			summaryCats[4] = "max"
			SetDimLabel 0, 5, 'std err mean', summaryWave
			summaryCats[5] = "std err mean"
			SetDimLabel 0, 6, 'avg dev', summaryWave
			summaryCats[6] = "avg dev"
			SetDimLabel 0, 7, 'skew', summaryWave
			summaryCats[7] = "skew"
			SetDimLabel 0, 8, 'kurtosis', summaryWave
			summaryCats[8] = "kurtosis"
	
			Edit /HOST=$(currentPanel)#Tab1ContentPanel /N=FitResultsSummaryTable /FG=(tableLeft1, tableTop1, tableRight1, tableBottom1) summaryCats
			AppendToTable /W=$(currentPanel)#Tab1ContentPanel#FitResultsSummaryTable summaryWave
			ModifyTable /W=$(currentPanel)#Tab1ContentPanel#FitResultsSummaryTable horizontalIndex=2,  style(summaryCats)=1, showParts=116
		else
			TitleBox noResultsTitle, win=$(currentPanel)#Tab1ContentPanel, pos={resultsPanelWidth+10,resultsPanelHeight-130}, size={resultsPanelWidth-20, 30}; DelayUpdate
			TitleBox noResultsTitle, win=$(currentPanel)#Tab1ContentPanel, frame=0, fsize=16, fstyle=1, fixedSize=1, anchor=MC, title="No Results yet for this batch."
		endif
		SetActiveSubwindow $(currentPanel)
	endif
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// Axes Range Functions //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

// One of the variables toggling log X or Y axes has been changed (<batch run folder>:WMdoLogYaxis or WMdoLogXaxis)
// Update the displayed data
Function setLogAxisProc(CB_Struct):CheckBoxControl
	Struct WMCheckboxAction & CB_Struct

	if (CB_Struct.eventCode==2)
		Print "debug 1 ", CB_Struct.win;
	
		String dirInfo = GetUserData(CB_Struct.win, CB_Struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)

		NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
		WMdisplayFitResultInPanel(indxTRPI, CB_Struct.win, batchDir, batchName)
	endif
End

/// One of the set manual universal axis variables has changed.  Update the displayed data. ///
Function setManAxes(SV_Struct) :SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	if (SV_Struct.eventCode==3 || SV_Struct.eventCode==2)
		Print "debug 2 ", SV_Struct.win;
	
		String dirInfo = GetUserData(SV_Struct.win, SV_Struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)

		NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
		WMdisplayFitResultInPanel(indxTRPI, SV_Struct.win, batchDir, batchName)
	endif
End

////// Universal axis settings have been changed.  Update controls and graph //////
Function setAxesProc(CB_Struct) : CheckBoxControl
	Struct WMCheckboxAction & CB_Struct

	if (CB_Struct.eventCode==2)
		Print "debug 3 ", CB_Struct.win;
	
		String dirInfo = GetUserData(CB_Struct.win, CB_Struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		
		DFREF batchDataDFR = $(batchDir)
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
	
		NVAR doConstantYaxis = packageBatchDFR:WMconstantYaxis
		NVAR doConstantXaxis = packageBatchDFR:WMconstantXaxis
	
		strswitch (CB_Struct.ctrlName)
			case "autoConstantYAxis":
				Checkbox manConstantYAxis, win=$(CB_Struct.win), value=0		
				
				if (CB_Struct.checked)
					doConstantYaxis = WMautoConstantAxis
					setAutoAxes(batchDir, batchName)
				else
					doConstantYaxis = WMnotConstantAxis
				endif
				break
			case "manConstantYAxis":
				Checkbox autoConstantYAxis, win=$(CB_Struct.win), value=0
							
				///////// To Do: make update happen when the button is clicked.  Method in WMdisplayFitResultInPanel is to use graph's current setting as manual.  Here I want to remember the last
				///////// manual setting.  Have to think this through...
				NVAR manYMin = packageBatchDFR:WMmanYMin
				NVAR manYMax = packageBatchDFR:WMmanYMax
				
				If (!CB_Struct.checked || (numtype(manYMin)==2 || numtype(manYMax)==2))
					GetAxis /Q/W=$(CB_Struct.win)#results left
					manYmin = V_min
					manYmax = V_max
				endif

				if (CB_Struct.checked)
					SetAxis /W=$(CB_Struct.win)#results left, manYMin, manYMax
					doConstantYaxis = WMmanualConstantAxis
				else
					doConstantYaxis = WMnotConstantAxis
				endif
				break
			case "autoConstantXAxis":
				Checkbox manConstantXAxis, win=$(CB_Struct.win), value=0
				
				if (CB_Struct.checked)
					doConstantXaxis = WMautoConstantAxis
					setAutoAxes(batchDir, batchName)
				else
					doConstantXaxis = WMnotConstantAxis
				endif
				break
			case "manConstantXAxis":
				Checkbox autoConstantXAxis, win=$(CB_Struct.win), value=0
				
				NVAR manXMin = packageBatchDFR:WMmanXMin
				NVAR manXMax = packageBatchDFR:WMmanXMax
				
				If (!CB_Struct.checked || (numtype(manXMin)==2 || numtype(manXMax)==2))
					GetAxis /Q/W=$(CB_Struct.win)#results bottom
					manXmin = V_min
					manXmax = V_max
				endif
				
				if (CB_Struct.checked)
					SetAxis /W=$(CB_Struct.win)#results bottom, manXMin, manXMax					
					doConstantXaxis = WMmanualConstantAxis
				else
					doConstantXaxis = WMnotConstantAxis
				endif
				break
			default:
				break
		endswitch

		NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
		WMdisplayFitResultInPanel(indxTRPI, CB_Struct.win, batchDir, batchName)
	endif
End

//// calculates automatic axes and sets the min & max values in variables in the batch folder (WMautoMinY, WMautoMaxY, etc)
Function setAutoAxes(batchDataDir, batchName)
	String batchDataDir, batchName
	
	Make /FREE/WAVE /N=0 batchWaves
	Make /FREE/WAVE /N=0 batchXWaves
	getYandXBatchData(batchDataDir, batchName, batchWaves, batchXWaves)
	
	Struct batchDataStruct batchInfo
	initBatchDataStruct(batchInfo)
			
	getBatchData(batchDataDir, batchName, batchInfo)
	
	DFREF batchDirDFR = getBatchFolderDFR(batchDataDir, batchName)
	DFREF packageBatchDirDFR = getPackageBatchFolderDFR(batchDataDir, batchName)
	
	Variable batchWavesSize = DimSize(batchWaves, 0)
	if (numType(batchWavesSize)!=2 || batchWavesSize>0)
		Variable /G packageBatchDirDFR:WMautoMinY
		NVAR autoMinY = packageBatchDirDFR:WMautoMinY
		Variable /G packageBatchDirDFR:WMautoMaxY
		NVAR autoMaxY = packageBatchDirDFR:WMautoMaxY
		
		Variable /G packageBatchDirDFR:WMautoMinX
		NVAR autoMinX = packageBatchDirDFR:WMautoMinX
		Variable /G packageBatchDirDFR:WMautoMaxX
		NVAR autoMaxX = packageBatchDirDFR:WMautoMaxX
		
		Variable i, nPtsInWave

		if (batchInfo.yValsSourceType & WMconstSingle2DInput)
			WAVE the2DWave = batchWaves[0]
						
			switch (batchInfo.xValsSourceType)
				case WMconstWaveScalingInput:
					autoMinX = DimOffset(the2DWave, 0)
					autoMaxX = autoMinX + DimDelta(the2DWave, 0)*(DimSize(the2DWave,0)-1)
					autoMinY = waveMin(the2DWave)
					autoMaxY = waveMax(the2DWave)				
					break
				case WMconstXyPairsInput:
					autoMinX = waveMin(the2DWave, 0, DimSize(the2DWave,1)-1)
					autoMaxX = waveMax(the2DWave, 0, DimSize(the2DWave,1)-1)
					autoMinY = waveMin(the2DWave, DimSize(the2DWave,1), DimSize(the2DWave,1)*2-1)
					autoMaxY = waveMax(the2DWave, DimSize(the2DWave,1), DimSize(the2DWave,1)*2-1)
					
					nPtsInWave = DimSize(the2DWave, 1)			
					for (i=1; i<floor(nPtsInWave/2); i+=1)
						autoMinX = min(autoMinX, waveMin(the2DWave, i*2*DimSize(the2DWave,1), (i*2+1)*DimSize(the2DWave,1)-1))
						autoMaxX = max(autoMaxX, waveMax(the2DWave, i*2*DimSize(the2DWave,1), (i*2+1)*DimSize(the2DWave,1)-1))
						autoMinY = min(autoMinY, waveMin(the2DWave, (i*2+1)*DimSize(the2DWave,1), (i+1)*2*DimSize(the2DWave,1)-1))
						autoMaxY = max(autoMaxY, waveMax(the2DWave, (i*2+1)*DimSize(the2DWave,1), (i+1)*2*DimSize(the2DWave,1)-1))
					endfor
					break
				case WMconstSingle2DInput:
				case WMconstCommonWaveInput:
					WAVE theXWave = batchXWaves[0]
					autoMinX = waveMin(theXWave)
					autoMaxX = waveMax(theXWave)
					autoMinY = waveMin(the2DWave)
					autoMaxY = waveMax(the2DWave)		
					break
				case WMconstCollection1DInput:
					WAVE theXWave = batchXWaves[0]
					autoMinX = waveMin(theXWave)
					autoMaxX = waveMax(theXWave)
					nPtsInWave = DimSize(batchXWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)			
						WAVE theXWave = batchXWaves[i]
						autoMinX = min(waveMin(theXWave), autoMinX)
						autoMaxX = max(waveMax(theXWave), autoMaxX)
					endfor						
					autoMinY = waveMin(the2DWave)
					autoMaxY = waveMax(the2DWave)
					break
				default:
					break
			endswitch	
		else
			switch (batchInfo.xValsSourceType)
				case WMconstWaveScalingInput:
					WAVE theYWave = batchWaves[0]
					autoMinY = waveMin(theYWave)
					autoMaxY = waveMax(theYWave)
					autoMinX = leftx(theYWave)
					autoMaxX = rightx(theYWave)
					nPtsInWave = DimSize(batchWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)			
						WAVE theYWave = batchWaves[i]
						autoMinY = min(autoMinY, waveMin(theYWave))
						autoMaxY = max(autoMaxY, waveMax(theYWave))
						autoMinX = min(autoMinX, leftx(theYWave))
						autoMaxX = max(autoMaxX, rightx(theYWave))
					endfor
					break
				case WMconstCommonWaveInput:
					WAVE theXWave = batchXWaves[0]
					autoMinX = waveMin(theXWave)
					autoMaxX = waveMax(theXWave)
					
					WAVE theYWave = batchWaves[0]
					autoMinY = waveMin(theYWave)
					autoMaxY = waveMax(theYWave)
					nPtsInWave = DimSize(batchWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)		
						WAVE theYWave = batchWaves[i]
						autoMinY = min(autoMinY, waveMin(theYWave))
						autoMaxY = max(autoMaxY, waveMax(theYWave))
					endfor
					break
				case WMconstXyPairsInput:
					WAVE theYWave = batchWaves[0]
					autoMinY = waveMin(theYWave, DimSize(theYWave, 0), DimSize(theYWave, 0)*2-1)
					autoMaxY = waveMax(theYWave, DimSize(theYWave, 0), DimSize(theYWave, 0)*2-1)
					autoMinX = waveMin(theYWave, 0, DimSize(theYWave, 0)-1)
					autoMaxX = waveMax(theYWave, 0, DimSize(theYWave, 0)-1)
					nPtsInWave = DimSize(batchWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)			
						WAVE theYWave = batchWaves[i]
						autoMinY = min(autoMinY, waveMin(theYWave, DimSize(theYWave, 0), DimSize(theYWave, 0)*2-1))
						autoMaxY = max(autoMaxY, waveMax(theYWave, DimSize(theYWave, 0), DimSize(theYWave, 0)*2-1))
						autoMinX = min(autoMinX, waveMin(theYWave, 0, DimSize(theYWave, 0)-1))
						autoMaxX = max(autoMaxX, waveMax(theYWave, 0, DimSize(theYWave, 0)-1))
					endfor
					break
				case WMconstSingle2DInput:
					WAVE theYWave = batchWaves[0]
					autoMinY = waveMin(theYWave)
					autoMaxY = waveMax(theYWave)
					nPtsInWave = DimSize(batchWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)		
						WAVE theYWave = batchWaves[i]
						autoMinY = min(autoMinY, waveMin(theYWave))
						autoMaxY = max(autoMaxY, waveMax(theYWave))
					endfor
					WAVE theXWave = batchXWaves[0]
					autoMinX = waveMin(theXWave)
					autoMaxX = waveMax(theXWave)
					break
				case WMconstCollection1DInput:
					WAVE theYWave = batchWaves[0]
					autoMinY = waveMin(theYWave)
					autoMaxY = waveMax(theYWave)
					nPtsInWave = DimSize(batchWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)
						WAVE theYWave = batchWaves[i]
						autoMinY = min(autoMinY, waveMin(theYWave))
						autoMaxY = max(autoMaxY, waveMax(theYWave))
					endfor
					WAVE theXWave = batchXWaves[0]
					autoMinX = waveMin(theXWave)
					autoMaxX = waveMax(theXWave)
					nPtsInWave = DimSize(batchXWaves, 0)
					for (i=1; i<nPtsInWave; i+=1)		
						WAVE theXWave = batchXWaves[i]
						autoMinX = min(autoMinX, waveMin(theXWave))
						autoMaxX = max(autoMaxX, waveMax(theXWave))
					endfor
					break
				default:
					break		
			endswitch	
		endif		
	endif
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Results Panel Hook Function ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/////// The Results panel hook records changes in size and position, and responds to arrow (keyboard) and mouse events when the
///////  event occurs on the main results table
Function ResultsPanelHook(s)
	STRUCT WMWinHookStruct &s
	
	String dirInfo, batchDir, batchName
	DFREF batchDataDFR, packageBatchDFR
	strswitch (s.eventName)
		case "kill":
			dirInfo = GetUserData(StringFromList(0,s.winName,"#"), "WMResultsTabControl", "")	
			batchDir = StringFromList(0, dirInfo)
			batchName = StringFromList(1, dirInfo)
		
			String panelNameBase = CleanupName(batchName+"_export", 0)
			String exportWinNames = WinList(panelNameBase+"*", ";", "WIN:64")
			Variable nPanels = ItemsInList(exportWinNames)
			Variable i
			for (i=0; i<nPanels; i+=1)
				DoWindow /K $(StringFromList(i, exportWinNames))
			endfor
			
			break
		case "moved":		
		case "resize":
			dirInfo = GetUserData(StringFromList(0,s.winName,"#"), "WMResultsTabControl", "")	
						
			batchDir = StringFromList(0, dirInfo)
			batchName = StringFromList(1, dirInfo)
		
			batchDataDFR = $(batchDir)
			packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
				
			NVAR resultsPanelY = packageBatchDFR:WMresultsPanelY 
			NVAR resultsPanelX = packageBatchDFR:WMresultsPanelX 
			NVAR resultsPanelWidth = packageBatchDFR:WMresultsPanelWidth
			NVAR resultsPanelHeight = packageBatchDFR:WMresultsPanelHeight
			
			GetWindow $(s.winName) wsize
			resultsPanelY=V_top
			resultsPanelX=V_left
			resultsPanelWidth = V_right-V_left
			resultsPanelHeight= V_bottom-V_top
			break
		
		case "keyboard":
		case "mouseup":
			if (stringmatch(s.winName, "*#FitResultsTable"))
				String currWinName = s.winName
				String ParentPanelName = currWinName[0,strlen(s.winName)-strlen("#FitResultsTable")-1]
				
				dirInfo = GetUserData(ParentPanelName, "BackButton", "")
				batchDir = StringFromList(0, dirInfo)
				batchName = StringFromList(1, dirInfo)
				batchDataDFR = $(batchDir)
				packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		
				String tInfo = tableInfo("", -2)
				String location = StringByKey("TARGETCELL", tInfo)
				Variable currentRow = str2num(StringFromList(0, location, ","))
				Variable nRows = str2num( StringFromList(0, StringByKey("ROWS", tInfo) ) )
				
				String selection = StringByKey("SELECTION", tInfo)
				Variable startRow = str2num(StringFromList(0, selection, ","))
				Variable startCol = str2num(StringFromList(1, selection, ","))
				Variable endRow = str2num(StringFromList(2, selection, ","))
				Variable endCol = str2num(StringFromList(3, selection, ","))
				Variable targetRow = str2num(StringFromList(4, selection, ","))
				Variable targetCol = str2num(StringFromList(5, selection, ","))		
				Variable vInterval = endRow - startRow + 1
				Variable hInterval = endCol - startCol + 1
				
				Variable shiftKey = s.eventMod & 2
				Variable ctrlCmdKey = s.eventMod & 8
		
				if (!cmpStr(s.eventName, "keyboard"))   // keyboard events do not update the target cell until after the hook, so the new location needs to be anticipated
					if (s.keycode==28) /// left arrow
						if (shiftKey)
							currentRow = targetRow
						elseif ((vInterval > 1 || hInterval > 1) && !ctrlCmdKey && targetCol==startCol)
							currentRow = startRow + mod(vInterval+targetRow-startRow+1, vInterval)
						endif													
					elseif (s.keycode==29) /// right arrow
						if (shiftKey)
							currentRow = targetRow
						elseif ((vInterval > 1 || hInterval > 1) && !ctrlCmdKey && targetCol==endCol)
							currentRow = startRow + mod(vInterval+targetRow-startRow+1, vInterval)
						endif
					elseif  (s.keycode==30)  /// up arrow
						if (shiftKey)
							currentRow = targetRow
						elseif (ctrlCmdKey)
							currentRow = 0
						elseif (hInterval > 1 || vInterval > 1)
							currentRow = startRow + mod(vInterval+targetRow-startRow-1, vInterval)
						else 
							currentRow = targetRow==0 ? targetRow : targetRow-1
						endif
					elseif (s.keycode==31)  /// down arrow
						if (shiftKey)
							currentRow = targetRow
						elseif (ctrlCmdKey)
							currentRow = nRows-1
						elseif (hInterval > 1 || vInterval > 1)
							currentRow = startRow + mod(vInterval+targetRow-startRow+1, vInterval)
						else
							currentRow = targetRow==nRows-1? targetRow : targetRow+1
						endif
					else
						break
					endif
				endif
								
				NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
				if (!NVAR_exists(indxTRPI))
					Variable /G packageBatchDFR:WMindexToResultsPanelImage = currentRow
					WMDisplayFitResultInPanel(currentRow, ParentPanelName, batchDir, batchName)
				else
					if (numtype(currentRow)!=2 && indxTRPI != currentRow)
						WMDisplayFitResultInPanel(currentRow, ParentPanelName, batchDir, batchName)
						indxTRPI = currentRow
					endif
				endif
				
			endif
			break
		case "mousedown": 
			if (stringmatch(s.winName, "*#Tab1ContentPanel#summaryGraph"))				
				dirInfo = GetUserData(StringFromList(0,s.winName,"#"), "WMResultsTabControl", "")	
				batchDir = StringFromList(0, dirInfo)
				batchName = StringFromList(1, dirInfo)

				DFREF batchDirDFR = getBatchFolderDFR(batchDir, batchName)
				DFREF packageBatchDirDFR = getPackageBatchFolderDFR(batchDir, batchName)
				
				Variable leftLoc = AxisValFromPixel(s.winName, "left", s.mouseLoc.v)
				Variable bottLoc = AxisValFromPixel(s.winName, "bottom", s.mouseLoc.h)
				
				NVAR /Z iXRow = packageBatchDirDFR:summaryXIndex
				NVAR /Z iYRow = packageBatchDirDFR:summaryYIndex
				Wave sortedXRow = packageBatchDirDFR:sortedXRow
				Wave YVals = packageBatchDirDFR:YVals
				Wave sortedXVal = packageBatchDirDFR:sortedXVal
				
				GetAxis /Q/W=$(s.winName) left
				Variable yTolerance = (V_max-V_min)/50
				GetAxis /Q/W=$(s.winName) bottom
				Variable xTolerance = (V_max-V_min)/50
				
				Variable nearestPtYIndx = FindNearestPtYIndx(YVals, sortedXVal, sortedXRow, bottLoc, leftLoc, yTolerance, xTolerance)
				
				if (numtype(nearestPtYIndx)!=2 && nearestPtYIndx>=0)
					Wave /Z resultsMatrix = batchDirDFR:WMBatchResultsMatrix

					Wave /Z/T batchWaveNames = batchDirDFR:WMbatchWaveNames
					String tagTitle 
					if (waveExists(batchWaveNames))
						if (DimSize(batchWaveNames, 0)==1)
							tagTitle = batchWaveNames[0]+"["+num2str(nearestPtYIndx)+"]"
						elseif (DimSize(batchWaveNames, 0)>1)
							tagTitle = batchWaveNames[nearestPtYIndx]
						endif
					endif
					Tag /W=$(s.winName) /C/N=summaryTag/B=0 WMBatchResultsMatrix, nearestPtYIndx, tagTitle
				else 
					Tag /W=$(s.winName) /K/N=summaryTag
				endif
			endif
			break
		default:
			break
	endswitch
End

////// Find the index holding the nearest point.  yTolerance and xTolerance are the distance around the main point to check
////// Assumes yTolerance and xTolerance are reflect relative scale of the two axes
Function FindNearestPtYIndx(yVals, sortedXVals, sortedXRow, ptX, ptY, yTolerance, xTolerance)
	Wave yVals, sortedXVals, sortedXRow
	Variable ptX, ptY
	Variable yTolerance, xTolerance
	
	Variable xLvl0=-1, xLvl1=-1
	Variable ret=NaN
	
	xLvl0 = BinarySearch(sortedXVals, ptX-xTolerance)
	if (xLvl0==-1)
		xLvl0=0
	elseif (xLvl0==-2)
		xLvl0=DimSize(sortedXVals,0)-1
	endif
	xLvl1 = BinarySearch(sortedXVals, ptX+xTolerance)
	if (xLvl1==-1)
		xLvl1=0
	elseif (xLvl1==-2)
		xLvl1=DimSize(sortedXVals,0)-1
	endif
		
	Variable iy, ix
	Variable minDistance = NaN
	
	for (ix=xLvl0; ix<=xLvl1; ix+=1)
		if (abs(ptY - yVals[sortedXRow[ix]]) < yTolerance)
			Variable currDist = sqrt(((yVals[sortedXRow[ix]]-ptY)/yTolerance)^2 + sqrt(((sortedXVals[ix]-ptX)/xTolerance)^2))
			if (numtype(minDistance)==2 || currDist < minDistance)
				ret = sortedXRow[ix]
				minDistance = currDist
			endif
		endif
	endfor
	
	return ret
End

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Tab Control Functions //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

// Tab Control Functions
Function BatchResultsTabControlProc(TC_Struct) : TabControl
	STRUCT WMTabControlAction &TC_Struct

	if (TC_Struct.eventCode == 2)	
		switch(TC_Struct.tab)
		case 0:
			SetWindow $(TC_struct.win)#Tab0 hide=0
			SetWindow $(TC_struct.win)#Tab1ContentPanel hide=1	
			break
		case 1:
			SetWindow $(TC_struct.win)#Tab0 hide=1
			SetWindow $(TC_struct.win)#Tab1ContentPanel hide=0				
			break
		endswitch
		SetActiveSubwindow $(TC_struct.win)
	endif
End

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Various Control Functions /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function WMCloseAlert(B_Struct):ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2)
		KillWindow $(B_Struct.win)
	endif
End

Function WMHelpPanel(B_Struct):ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2)
		DisplayHelpTopic "Batch Fit Results Panel"
	endif
End	

// One of the summary controls has been changed.  Update the Summary graph
Function SetDisplaySummary(PU_Struct):PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode==2)
		//// get parameter values
		Variable yIndex, xIndex, yErrIndex, xErrIndex
		ControlInfo /W=$(PU_Struct.win) yDataMain	
		yIndex = V_Value-1
		ControlInfo /W=$(PU_Struct.win) yDataErr
		yErrIndex = V_Value-2
		ControlInfo /W=$(PU_Struct.win) xDataMain
		xIndex = V_Value-2
		ControlInfo /W=$(PU_Struct.win) xDataErr
		xErrIndex = V_Value-2
		
		DisplaySummary(StringFromList(0, PU_Struct.win, "#"), yIndex, xIndex, yErrIndex, xErrIndex)
	endif
End

// Display the summary graph according th the current settings
Function DisplaySummary(win, iYCol, iXCol, iYErrCol, iXErrCol, [outputGraphName, resultsWaveName])
	String win
	Variable  iYCol, iXCol, iYErrCol, iXErrCol
	String outputGraphName
	String resultsWaveName
	
	if (ParamIsDefault(outputGraphName))
		outputGraphName=win+"#Tab1ContentPanel#summaryGraph"
	endif
	
	String dirInfo = GetUserData(win, "WMResultsTabControl", "")
	String batchDir = StringFromList(0, dirInfo)
	String batchName = StringFromList(1, dirInfo)
		
	DFREF batchDFR = getBatchFolderDFR(batchDir, batchName) /// data from this particular batch run

	if (ParamIsDefault(resultsWaveName))
		Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
	else
		Wave /Z resultsMatrix = $resultsWaveName
	endif
	
	DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
	
	RemoveFromGraph /Z/W=$outputGraphName $"#0"
		
	if (waveExists(resultsMatrix))	
		Variable /G packageBatchDFR:summaryXIndex = iXCol
		Variable /G packageBatchDFR:summaryYIndex = iYCol
			
		Make /D/O/N=(DimSize(resultsMatrix,0)) packageBatchDFR:sortedXRow, packageBatchDFR:sortedXVal, packageBatchDFR:yVals
		Wave sortedXRow = packageBatchDFR:sortedXRow
		Wave yVals = packageBatchDFR:yVals
		Wave sortedXVal = packageBatchDFR:sortedXVal
		
		yVals = resultsMatrix[p][iYCol]
		sortedXRow = p
		
		if (iXCol<0)   // no X wave specified
			AppendToGraph /W=$outputGraphName resultsMatrix[][iYCol]	
			sortedXVal = p
		else	
			AppendToGraph /W=$outputGraphName resultsMatrix[][iYCol] vs resultsMatrix[][iXCol]
			String xLabel = GetDimLabel(resultsMatrix, 1, iXCol)
			Label /W=$outputGraphName bottom, xLabel
			
			sortedXVal = resultsMatrix[p][iXCol]
			sort sortedXVal, sortedXRow, sortedXVal
		endif
		String yLabel = GetDimLabel(resultsMatrix, 1, iYCol)
		Label /W=$outputGraphName left, yLabel

		if (iYErrCol>=0 && iXerrCol < 0)
			ErrorBars /W=$outputGraphName $(NameOfWave(resultsMatrix)), Y wave=(resultsMatrix[][iYErrCol],resultsMatrix[][iYErrCol])
		elseif (iXerrCol>=0 && iYErrCol < 0)
			ErrorBars /W=$outputGraphName $(NameOfWave(resultsMatrix)), X wave=(resultsMatrix[][iXErrCol],resultsMatrix[][iXErrCol])//[][iXCol]
		elseif (iXerrCol>=0 && iYErrCol >= 0)
			ErrorBars /W=$outputGraphName $(NameOfWave(resultsMatrix)), XY, wave=(resultsMatrix[][iXErrCol],resultsMatrix[][iXErrCol]), wave=(resultsMatrix[][iYErrCol],resultsMatrix[][iYErrCol])
		else
			ErrorBars /W=$outputGraphName $(NameOfWave(resultsMatrix)), OFF
		endif
		
		ModifyGraph /W=$outputGraphName mode=3	
	else
		Variable /G packageBatchDFR:summaryXIndex = NaN
		Variable /G packageBatchDFR:summaryYIndex = NaN
		
		KillWaves /Z packageBatchDFR:sortedYCol, packageBatchDFR:sortedXCol	
	endif
End

Function WMShowIndivExportPanel(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)		
		String dirInfo = GetUserData(B_struct.win, B_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		String currentPanel = StringFromList(2, dirInfo)

		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		String packageDFRString = GetDataFolder(1, packageBatchDFR)

		NVAR resultsPanelX = packageBatchDFR:WMresultsPanelX
		NVAR resultsPanelY = packageBatchDFR:WMresultsPanelY

		String panelName = CleanupName(batchName+"_export1", 0)

		DoWindow /K $panelName

		NewPanel /K=1/W=(resultsPanelX+20,resultsPanelY+20,resultsPanelX+WMBatchFitExportPanelWidth,resultsPanelY+WMBatchFitExportPanelHeight) /N=$panelName 
		
		DoWindow /T $panelName, "Export "+batchName+" results"
		DefaultGUIFont /W=$panelName /Mac popup={"Geneva", 12, 0}
	
		///// Title
		TitleBox exportPanelTitle, win=$panelName, pos={20, 5}, size={WMBatchFitExportPanelWidth-20, 30}, frame=0, fsize=16, fstyle=1, fixedSize=1; DelayUpdate
		TitleBox exportPanelTitle, win=$panelName, anchor=MC, title=batchName+" Export Report"
	
		///// Individual results waves
		/////// Export Waves
		Checkbox exportWavesCheck, win=$panelName, pos={30,70}, size={100,30},title="Export to Waves",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesCheck, win=$panelName, proc=WMExportWaveCB, userdata=batchDir+";"+batchName+";"+currentPanel
		
		String /G packageBatchDFR:WMexportDataFolder = "root"
		TitleBox exportToFolderTitle win=$panelName, title="Export Folder:", frame=0, pos={60, 95}, size={100, 22}, fsize=12, fixedSize=1, disable=2
		SetVariable setVariableFolder win=$panelName, pos={165, 95}, size={255, 24}, fsize=WMBCFBaseFontSize, fixedSize=1, variable=packageBatchDFR:WMexportDataFolder, title=" "; DelayUpdate
		SetVariable setVariableFolder win=$panelName, help={"Set the folder to which exported waves will be copied."}, userdata=batchDir+";"+batchName+";"+currentPanel, disable=2
		MakeSetVarIntoWSPopupButton(panelName, "setVariableFolder", "ExportFolderWaveSelectorNotify", packageDFRString+"WMexportDataFolder", initialSelection="root",content=WMWS_DataFolders)
		PopupWS_SetPopupFont(panelName, "setVariableFolder", fontSize=12)
		
		Checkbox exportWavesGraphCheck, win=$panelName, pos={60,120}, size={100,30},title="Export as Graph",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesGraphCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2
		Checkbox exportWavesTableCheck, win=$panelName, pos={60,145}, size={100,30},title="Export as Text",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesTableCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2

		Checkbox exportAllCheck, win=$panelName, pos={60,180}, size={100,30},title="Export All",fsize=12, proc=WMExportWaveCB; DelayUpdate
		Checkbox exportAllCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, mode=1, value=1, disable=2
		Checkbox exportSomeCheck, win=$panelName, pos={60,205}, size={100,30},title="Export Select",fsize=12, proc=WMExportWaveCB; DelayUpdate
		Checkbox exportSomeCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, mode=1, value=0, disable=2

		SetVariable exportSelectWaves, win=$panelName, pos={170,204}, size={400,30},title=" ",fsize=12, value=_STR:"", disable=2
		TitleBox exportSelectExample, win=$panelName, pos={230, 230}, size={WMBatchFitExportPanelWidth-20, 30}, frame=0, fsize=12, fstyle=1, fixedSize=1; DelayUpdate
		TitleBox exportSelectExample, win=$panelName, title="example: 0-10,14,16-20, 24", disable=2	
	
		//////// Export Text
		Checkbox exportNoteCheck, win=$panelName, pos={30,270}, size={100,30},title="Export to Notebook",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteCheck, win=$panelName, proc=WMExportWaveCB, userdata=batchDir+";"+batchName+";"+currentPanel
		
		SVAR /Z noteName = packageBatchDFR:WMexportNotebookName
		if (!SVAR_exists(noteName) || strlen(noteName)==0)			
			String /G packageBatchDFR:WMexportNotebookName = getUniqueStrLimNameAndTag(batchName, "Results", 31, 10)
		endif
		SetVariable exportNoteName, win=$panelName, title="Export as ", pos={60,300}, size={300,30}, variable=packageBatchDFR:WMexportNotebookName, fsize=12, disable=2
		
		Checkbox exportNoteGraphCheck, win=$panelName, pos={60,335}, size={100,30},title="Export as Graph",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteGraphCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2
		Checkbox exportNoteTableCheck, win=$panelName, pos={60,360}, size={100,30},title="Export as Text",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteTableCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2

		Checkbox exportNoteAllCheck, win=$panelName, pos={60,395}, size={100,30},title="Export All",fsize=12, proc=WMExportWaveCB; DelayUpdate
		Checkbox exportNoteAllCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, mode=1, value=1, disable=2
		Checkbox exportNoteSomeCheck, win=$panelName, pos={60,420}, size={100,30},title="Export Select",fsize=12, proc=WMExportWaveCB; DelayUpdate
		Checkbox exportNoteSomeCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, mode=1, value=0, disable=2

		SetVariable exportNoteSelectWaves, win=$panelName, pos={170,419}, size={400,30},title=" ",fsize=12, value=_STR:"", disable=2
		TitleBox exportNoteSelectExample, win=$panelName, pos={230, 445}, size={WMBatchFitExportPanelWidth-20, 30}, frame=0, fsize=12, fstyle=1, fixedSize=1; DelayUpdate
		TitleBox exportNoteSelectExample, win=$panelName, title="example: 0-10,14,16-20, 24", disable=2		
	
		Button cancelButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2-200, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Cancel"
		Button cancelButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMCancelExport
	
		Button exportButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2-40, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Do Export"
		Button exportButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMIndResultsExport
		
		Button helpButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2+120, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Help"
		Button helpButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMExportHelp
	endif
End

Function WMCancelExport(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)
		DoWindow /K $(B_Struct.win)
	endif
End

Function WMExportHelp(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)
		DisplayHelpTopic "Batch Fit Export Results"
	endif
End

Function WMShowSummaryExportPanel(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)
		String dirInfo = GetUserData(B_struct.win, B_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		String currentPanel = StringFromList(2, dirInfo)

		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		String packageDFRString = GetDataFolder(1, packageBatchDFR)

		NVAR resultsPanelX = packageBatchDFR:WMresultsPanelX
		NVAR resultsPanelY = packageBatchDFR:WMresultsPanelY

		String panelName = CleanupName(batchName+"_export2", 0)

		DoWindow /K $panelName

		NewPanel /K=1/W=(resultsPanelX+20,resultsPanelY+20,resultsPanelX+WMBatchFitExportPanelWidth,resultsPanelY+WMBatchFitExportPanelHeight) /N=$panelName
		
		DoWindow /T $panelName, "Export "+batchName+" summary"
		DefaultGUIFont /W=$panelName /Mac popup={"Geneva", 12, 0}
	
		///// Title
		TitleBox exportPanelTitle, win=$panelName, pos={20, 5}, size={WMBatchFitExportPanelWidth-20, 30}, frame=0, fsize=16, fstyle=1, fixedSize=1; DelayUpdate
		TitleBox exportPanelTitle, win=$panelName, anchor=MC, title=batchName+" Export Report"
	

		/////// Export Waves        
		Checkbox exportWavesCheck, win=$panelName, pos={30,70}, size={100,30},title="Export to Waves",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesCheck, win=$panelName, proc=WMExportWaveCB, userdata=batchDir+";"+batchName+";"+currentPanel
		
		String /G packageBatchDFR:WMexportDataFolder = "root"
		TitleBox exportToFolderTitle win=$panelName, title="Export Folder:", frame=0, pos={60, 95}, size={100, 22}, fsize=12, fixedSize=1, disable=2
		SetVariable setVariableFolder win=$panelName, pos={165, 95}, size={255, 24}, fsize=WMBCFBaseFontSize, fixedSize=1, variable=packageBatchDFR:WMexportDataFolder, title=" "; DelayUpdate
		SetVariable setVariableFolder win=$panelName, help={"Set the folder to which exported waves will be copied."}, userdata=batchDir+";"+batchName+";"+currentPanel, disable=2
		MakeSetVarIntoWSPopupButton(panelName, "setVariableFolder", "ExportFolderWaveSelectorNotify", packageDFRString+"WMexportDataFolder", initialSelection="root",content=WMWS_DataFolders)
		PopupWS_SetPopupFont(panelName, "setVariableFolder", fontSize=12)
		
		Checkbox exportWavesGraphCheck, win=$panelName, pos={60,120}, size={100,30},title="Export Summary Graph",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesGraphCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2
		Checkbox exportWavesTableCheck, win=$panelName, pos={60,145}, size={100,30},title="Export Summary Wave",fsize=12, value=0; DelayUpdate
		Checkbox exportWavesTableCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2
		
		//////// Export Text
		Checkbox exportNoteCheck, win=$panelName, pos={30,270}, size={100,30},title="Export to Notebook",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteCheck, win=$panelName, proc=WMExportWaveCB, userdata=batchDir+";"+batchName+";"+currentPanel
		
		SVAR /Z noteName = packageBatchDFR:WMexportNotebookName
		if (!SVAR_exists(noteName) || strlen(noteName)==0)			
			String /G packageBatchDFR:WMexportNotebookName = getUniqueStrLimNameAndTag(batchName, "Results", 31, 10)
		endif	
		SetVariable exportNoteName, win=$panelName, title="Export as ", pos={60,300}, size={300,30}, variable=packageBatchDFR:WMexportNotebookName, fsize=12, disable=2
		
		Checkbox exportNoteGraphCheck, win=$panelName, pos={60,335}, size={100,30},title="Export Summary Graph",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteGraphCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2
		Checkbox exportNoteTableCheck, win=$panelName, pos={60,360}, size={100,30},title="Export Summary Text",fsize=12, value=0; DelayUpdate
		Checkbox exportNoteTableCheck, win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, value=1, disable=2

		Button cancelButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2-200, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Cancel"
		Button cancelButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMCancelExport
	
		Button exportButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2-40, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Do Export"
		Button exportButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMSumResultsExport
		
		Button helpButton win=$panelName, appearance={os9}, pos={WMBatchFitExportPanelWidth/2+120, WMBatchFitExportPanelHeight-80}, size={80, 25}, title="Help"
		Button helpButton win=$panelName, userdata=batchDir+";"+batchName+";"+currentPanel, proc=WMExportHelp
	endif
End

Function ExportFolderWaveSelectorNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	String dirInfo = GetUserData(windowName, "setVariableFolder", "")
	String batchDir = StringFromList(0, dirInfo)
	String batchName = StringFromList(1, dirInfo)

	DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
	
	SVAR exportFolder =  packageBatchDFR:WMexportDataFolder 
	
	exportFolder=wavepath+":"
end


////////////// Export summary results
Function WMSumResultsExport(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)
		String dirInfo = GetUserData(B_struct.win, B_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		String currentPanel = StringFromList(2, dirInfo)
		
		Variable i, j, nPtsInWave
		
		DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		
		Variable yIndex, xIndex, yErrIndex, xErrIndex
		String graphTitle 

		String panelName = CleanupName(batchName+"_export2", 0)
		
		ControlInfo /W=$panelName exportWavesCheck    //// If the export to waves checkbox is checked, export to a graph or to a wave + table
		if (V_Value)
			SVAR exportFolder = packageBatchDFR:WMexportDataFolder
			String duplicateDataLocation = ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_ResultsCopy"), ":")
			Duplicate /O batchDFR:WMBatchResultsMatrix $(duplicateDataLocation)

			////// Export Graphs - Create waves in the selected export folder
			ControlInfo /W=$panelName exportWavesGraphCheck
			if (V_Value)		
				//// get parameter values
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") yDataMain	
				yIndex = V_Value-1
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") yDataErr
				yErrIndex = V_Value-2
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") xDataMain
				xIndex = V_Value-2
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") xDataErr
				xErrIndex = V_Value-2
		
				graphTitle = getUniqueStrLimNameAndTag(batchName, "Results", 31, 6)
									
				Display /N=$(graphTitle) /W=(10, 50, 560, 500)
				
				DisplaySummary(StringFromList(0, currentPanel, "#"), yIndex, xIndex, yErrIndex, xErrIndex, outputGraphName=graphTitle, resultsWaveName=duplicateDataLocation)
			endif
			
			ControlInfo /W=$panelName exportWavesTableCheck    //// If the export to waves checkbox is checked, export to a graph or to the text
			if (V_Value)
				Duplicate /O packageBatchDFR:WMBFSummaryCatagories $(ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_cats"), ":"))
				Wave /T summaryCats = $(ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_cats"), ":"))
				Duplicate /O packageBatchDFR:WMBFResultsSummary $(ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_summary"), ":"))
				Edit $(ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_cats"), ":")), $(ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"_summary"), ":"))
				ModifyTable horizontalIndex=2, style(summaryCats)=1, showParts=116
			endif
		endif
		
		///// Export to a notebook
		ControlInfo /W=$panelName exportNoteCheck
		if (V_Value)
			//// Get all the graphs to export      
			SVAR /Z noteName = packageBatchDFR:WMexportNotebookName

			Wave summaryWave = packageBatchDFR:WMBFResultsSummary
			Wave /T summaryCats = packageBatchDFR:WMBFSummaryCatagories

			if (!strlen(WinList(noteName, ";", "WIN:16")))
				NewNotebook /F=1 /N=$noteName as noteName		
			endif
		
			Notebook $noteName selection={endOfFile, endOfFile}
			Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=1, fSize=18, fStyle=1, margins={0, 0, 468}
			Notebook $noteName text=batchName+" Summary Report\r"
		
			///////// Export individual results table /////////
			ControlInfo /W=$panelName exportNoteTableCheck
			if (V_Value)
				Notebook $notename newRuler=batchFitTableRuler, justification=0, margins={0,0,1368}, spacing={0,0,0}, tabs={144,216,288,360,432,504,576,648,720,792,864,936,1008,1080,1152,1224,1296}, rulerDefaults={"Geneva",10,0,(0,0,0)}
				
				Notebook $noteName selection={startOfParagraph, endOfParagraph}, fSize=16, fStyle=1
				Notebook $noteName text=batchName+" Individual Run Results\r"

				Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=0, fsize=10, fStyle=1
				Notebook $noteName ruler=batchFitTableRuler 

				Variable nCols = DimSize(summaryWave,1)
				String colNames = "", dataRow

				for (i=0; i<nCols; i+=1)
					colNames += "\t"+GetDimLabel(summaryWave, 1, i)
				endfor
				Notebook $noteName text=colNames+"\r"
				Notebook $noteName fsize=9, fStyle=0
		
				nPtsInWave = DimSize(summaryWave,0)
				for (i=0; i<nPtsInWave; i+=1)      
					dataRow = summaryCats[i]+"\t"
					for (j=0; j<nCols; j+=1)
						sprintf dataRow, "%s%.5E", dataRow, summaryWave[i][j]
						if (j<nCols-1)
							dataRow += "\t"
						endif
					endfor
					Notebook $noteName ruler=batchFitTableRuler 
					Notebook $noteName text=dataRow+"\r", fsize=9, fStyle=0
				endfor				
				Notebook $noteName text="\r"			
			endif
		
			//////// Export select individual graphs /////////
			ControlInfo /W=$panelName exportNoteGraphCheck
			if (V_Value)
			
				//// get parameter values  
				String titleStr
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") yDataMain	
				yIndex = V_Value-1
				titleStr = S_Value
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") yDataErr
				yErrIndex = V_Value-2
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") xDataMain
				xIndex = V_Value-2
				if (xIndex >= 0)
					titleStr = titleStr+" vs. "+S_Value
				endif
				
				ControlInfo /W=$(currentPanel+"#Tab1ContentPanel") xDataErr
				xErrIndex = V_Value-2
		
				graphTitle = "BatchFitSummaryForExport"
				Display /N=$(graphTitle) /W=(50, 50, 560, 500)
				
				DisplaySummary(StringFromList(0, currentPanel, "#"), yIndex, xIndex, yErrIndex, xErrIndex, outputGraphName=graphTitle)

				DoUpdate
							
				Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=1, fSize=16, fStyle=1, margins={0,0,560}
				Notebook $noteName text=titleStr+"\r\t"
				Notebook $noteName picture={$graphTitle, -5, 1}
				Notebook $noteName text="\r"
				
				DoWindow /K $graphTitle
			endif
		endif	
	endif
End


Function WMIndResultsExport(B_STruct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	if (B_Struct.eventCode==2)
		String dirInfo = GetUserData(B_struct.win, B_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		String currentPanel = StringFromList(2, dirInfo)
		
		Variable i, j, nPtsInWave
		
		DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)

		Wave resultsMatrix = batchDFR:WMBatchResultsMatrix    /// main results matricx
		Wave /Z/T batchWaveNames = batchDFR:WMbatchWaveNames

		///// Utility variables
		Variable errVars, whatToPlot
		String titleStr, utilStr
		Variable nResults = DimSize(resultsMatrix,0)
		Variable nCols = DimSize(resultsMatrix,1), nRows = DimSize(resultsMatrix,0)
		String colNames, currCol, dataRow, waveTitle
		Variable nleftover, exportAll=1		

		String panelName = CleanupName(batchName+"_export1", 0)

		ControlInfo /W=$panelName exportWavesCheck    //// If the export to waves checkbox is checked, export to a graph or to the text
		if (V_Value)
			SVAR exportFolder = packageBatchDFR:WMexportDataFolder
			
			Make /N=(DimSize(resultsMatrix,0))/FREE resultsIndices   /// wave of indices to be used in graph and select text options
			ControlInfo /W=$panelName exportAllCheck
			exportAll = V_Value
			if (exportAll)
				resultsIndices = p
			else
				ControlInfo /W=$panelName exportSelectWaves
				parseSelectString(S_Value, DimSize(resultsMatrix,0), resultsIndices)
			endif
			
			////// Export Graphs - Create waves in the selected export folder
			ControlInfo /W=$panelName exportWavesGraphCheck
			if (V_Value)
				GetAxis /W=$(currentPanel)#tab0#results /Q left
				Make /Free /N=2 leftAxis = {V_min, V_max}
				GetAxis /W=$(currentPanel)#tab0#results /Q bottom
				Make /Free /N=2 bottomAxis = {V_min, V_max}
			
				nPtsInWave = DimSize(resultsIndices,0)
				for (i=0; i<nPtsInWave; i+=1)    
					if (waveExists(batchWaveNames))
						if (DimSize(batchWaveNames, 0)==1)
							waveTitle = batchWaveNames[0]+"["+num2str(resultsIndices[i])+"]"
						elseif (DimSize(batchWaveNames, 0)>1)
							waveTitle = batchWaveNames[resultsIndices[i]]
						endif
					else	
						waveTitle = batchName+"_"+num2str(resultsIndices[i])
					endif
				
					String graphTitle = ReplaceString("[", ReplaceString("]", waveTitle, "_"), "_")
					Display /N=$(graphTitle) /W=(10+i*5, 50+i*5, 560+i*5, 500+i*5)   
					errVars = 0
					whatToPlot=3
					titleStr = plotResultsInsideGraph(whatToPlot, resultsIndices[i], graphTitle, batchDir, batchName, errVars, leftAxis, bottomAxis, outputDir=exportFolder)
				endfor
			endif

			////// Export raw wave data - simple copy of the results wave in the case of "all"
			ControlInfo /W=$panelName exportWavesTableCheck
			if (V_Value)
				String batchCopyName, batchRunNamesName
				if (exportAll)
					batchCopyName = ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"Results"), ":")
					batchRunNamesName = ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"Names"), ":")
					if (waveExists(batchWaveNames))
						if (DimSize(batchWaveNames, 0)==1)
							Make /T/O /N=(DimSize(resultsMatrix, 0)) $batchRunNamesName
							Wave /T runNames = $batchRunNamesName
							nPtsInWave = DimSize(resultsMatrix, 0)      			
							for (i=0; i<nPtsInWave; i+=1)  
								runNames[i] = batchWaveNames[0]+"["+num2str(i)+"]"
							endfor
						elseif (DimSize(batchWaveNames, 0)>1)
							Duplicate /O batchDFR:WMbatchWaveNames $batchRunNamesName
						endif					
					else	
						Make /T /O /N=(DimSize(resultsMatrix, 0)) $batchRunNamesName
						Wave /T runNames = $batchRunNamesName
						nPtsInWave = DimSize(resultsMatrix, 0)					
						for (i=0; i<nPtsInWave; i+=1)						
							runNames[i] = batchName+" fit "+num2str(i)
						endfor
					endif
				
					Duplicate /O batchDFR:WMBatchResultsMatrix $batchCopyName
					Edit $batchRunNamesName
					AppendToTable $batchCopyName
					ModifyTable horizontalIndex=2, showParts=124
					ModifyTable style($batchRunNamesName)=1
				else
					batchCopyName = ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"Results"), ":")
					batchRunNamesName = ReplaceString("::", exportFolder +":"+PossiblyQuoteName(batchName+"Names"), ":")

					Make /T /O /N=(DimSize(resultsIndices, 0)) $batchRunNamesName
					Wave /T runNames = $batchRunNamesName
					if (waveExists(batchWaveNames))
						if (DimSize(batchWaveNames, 0)==1)
							nPtsInWave = DimSize(resultsIndices, 0)
							for (i=0; i<nPtsInWave; i+=1)				
								runNames[i] = batchWaveNames[0]+"["+num2str(resultsIndices[i])+"]"
							endfor
						elseif (DimSize(batchWaveNames, 0)>1)
							nPtsInWave = DimSize(resultsIndices, 0)
							for (i=0; i<nPtsInWave; i+=1)				
								runNames[i] = batchWaveNames[resultsIndices[i]]
							endfor
						endif					
					else	
						nPtsInWave = DimSize(resultsIndices, 0)
						for (i=0; i<nPtsInWave; i+=1)			
							runNames[i] = batchName+" fit "+num2str(resultsIndices[i])
						endfor
					endif				
					
					Make /D/O/N=(DimSize(resultsIndices,0), DimSize(resultsMatrix, 1)) $batchCopyName
					Wave resultSubSet = $batchCopyName
					nPtsInWave = DimSize(resultsIndices,0)
					for (i=0; i<nPtsInWave; i+=1)			
						resultSubSet[i][] = resultsMatrix[resultsIndices[i]][q]
					endfor
					nPtsInWave = DimSize(resultsMatrix,1)
					for (i=0; i<nPtsInWave;i+=1)				
						utilStr = GetDimLabel(resultsMatrix, 1, i)
						SetDimLabel 1, i, $utilStr, resultSubSet
					endfor
					
					Edit $batchRunNamesName
					AppendToTable $batchCopyName
					ModifyTable horizontalIndex=2, showParts=124
					ModifyTable style($batchRunNamesName)=1
				endif
			endif
		endif
		
		///// Export to a notebook
		ControlInfo /W=$panelName exportNoteCheck
		if (V_Value)
			//// Get all the graphs to export
			ControlInfo /W=$panelName exportNoteAllCheck
			exportAll = V_Value
			Make /O/N=(nResults) /FREE graphsToExport
			if (exportAll==1)		
				graphsToExport = p
			else
				ControlInfo /W=$(B_Struct.win) exportNoteSelectWaves
				parseSelectString(S_Value, nResults, graphsToExport)
			endif
				
			SVAR /Z noteName = packageBatchDFR:WMexportNotebookName
			
			if (strlen(noteName) > 31)
				DoAlert /T="Notebook Name Too Long" 0, "Notebook names are limited to 31 chars.  The  name "+noteName+" has "+num2str(strlen(noteName))+" chars."
				return 0
			endif
			
			if (!strlen(WinList(noteName, ";", "WIN:16")))
				NewNotebook /F=1 /N=$noteName as noteName		
			endif
		
			ControlInfo /W=$panelName exportSumGraphCheck
			Variable exportSumGraphCheck=V_Value
		
			Notebook $noteName selection={endOfFile, endOfFile}
			Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=1, fSize=18, fStyle=1, margins={0, 0, 468}
			Notebook $noteName text=batchName+" Report\r"
		
			///////// Export individual results table /////////
			ControlInfo /W=$panelName exportNoteTableCheck
			if (V_Value)	
				Notebook $noteName selection={startOfParagraph, endOfParagraph}, fSize=16, fStyle=1
				Notebook $noteName text=batchName+" Individual Run Results\r"

				if (waveExists(resultsMatrix))
					//////////// First create a custom ruler ////////////
					Make /Free/N=(nCols) tabVals     //17 tabVals={144,216,288,360,432,504,576,648,720,792,864,936,1008,1080,1152,1224,1296}
					String tabsAsString="{"		
					
					//// Get the maximum width of the row labels
					Variable maxFontStringWidth=0, currFontStringWidth, currTabPos
					String currRowLabel
					for (i=0; i<numpnts(graphsToExport); i+=1)
						if (waveExists(batchWaveNames))
							if (DimSize(batchWaveNames, 0)==1)
								maxFontStringWidth = max(maxFontStringWidth, FontSizeStringWidth("Geneva", 9, 1, num2str(graphsToExport[i])+") "+batchWaveNames[0]+"["+num2str(graphsToExport[i])+"]"))
							else
								maxFontStringWidth = max(maxFontStringWidth, FontSizeStringWidth("Geneva", 9, 1, num2str(graphsToExport[i])+") "+batchWaveNames[graphsToExport[i]]))
							endif
						else
							maxFontStringWidth = max(maxFontStringWidth, FontSizeStringWidth("Geneva", 9, 1, batchName+" fit "+num2str(graphsToExport[i])))
						endif
					endfor				
				
					//// place the column tabs according to column header width
					tabVals[0] = maxFontStringWidth
					
					colNames = ""
					for (i=0; i<nCols-1; i+=1)
						currCol = GetDimLabel(resultsMatrix, 1, i)
						tabVals[i+1] = tabVals[i]+max(72, FontSizeStringWidth("Geneva", 9, 1,currCol))
						colNames += "\t"+currCol
					endfor
					colNames += "\t"+GetDimLabel(resultsMatrix, 1, nCols-1)

					for (i=0; i<numpnts(tabVals)-1; i+=1)
						tabsAsString += num2str(tabVals[i])+","
					endfor
					tabsAsString += num2Str(tabVals[numpnts(tabVals)-1])+"}"
	
					String cmd = "Notebook "+notename+" newRuler=batchFitTableRuler, justification=0, margins={0,0,1368}, spacing={0,0,0}, tabs="+tabsAsString+", rulerDefaults={\"Geneva\",10,0,(0,0,0)}"
					Execute cmd
				
					Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=0, fsize=10, fStyle=1
					Notebook $noteName ruler=batchFitTableRuler 		
					Notebook $noteName text=colNames+"\r"
					Notebook $noteName fsize=9, fStyle=0
			
					for (i=0; i<numpnts(graphsToExport); i+=1)
						if (waveExists(batchWaveNames))
							if (DimSize(batchWaveNames, 0)==1)
								currRowLabel = num2str(graphsToExport[i])+") "+batchWaveNames[0]+"["+num2str(graphsToExport[i])+"]"	
								currFontStringWidth = FontSizeStringWidth("Geneva", 9, 1, currRowLabel)
							else
								currRowLabel = num2str(graphsToExport[i])+") "+batchWaveNames[graphsToExport[i]]
								currFontStringWidth = FontSizeStringWidth("Geneva", 9, 1, currRowLabel)								
							endif
						else
							currRowLabel = batchName+" fit "+num2str(graphsToExport[i])
							currFontStringWidth = FontSizeStringWidth("Geneva", 9, 1, currRowLabel)
						endif
						Notebook $noteName fStyle=1, text=currRowLabel
						
						dataRow = ""
						currTabPos = 0
						j=0
						do
							currTabPos = tabVals[j]
							dataRow += "\t"		
							j+=1				
						while (currTabPos < maxFontStringWidth)
						
						for (j=0; j<nCols; j+=1)
							sprintf dataRow, "%s%.5E", dataRow, resultsMatrix[graphsToExport[i]][j]
							if (j<nCols-1)
								dataRow += "\t"
							endif
						endfor
						Notebook $noteName fstyle=0, ruler=batchFitTableRuler 
						Notebook $noteName text=dataRow+"\r", fsize=9, fStyle=0
					endfor				
					Notebook $noteName text="\r"			
				endif
			endif
		
			//////// Export select individual graphs /////////
			ControlInfo /W=$panelName exportNoteGraphCheck
			if (V_Value)
				GetAxis /W=$(currentPanel)#tab0#results /Q left
				Make /Free /N=2 leftAxis = {V_min, V_max}
				GetAxis /W=$(currentPanel)#tab0#results /Q bottom
				Make /Free /N=2 bottomAxis = {V_min, V_max}
		
				DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
			
				Notebook $noteName newRuler=BatchFitGraphRuler, justification=0, margins={0,0,560}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
				Notebook $noteName ruler=BatchFitGraphRuler
			
				for (i=0; i<numpnts(graphsToExport); i+=1)
				
					if (WinType("exportGraph")==1)
						DoWindow /K exportGraph
					endif
		
					Display /N=exportGraph /W=(0, 0, 550, 450)  
					errVars = 0
					whatToPlot=3
					Variable index=0
					String graphName = "exportGraph"
					titleStr = plotResultsInsideGraph(whatToPlot, graphsToExport[i], graphName, batchDir, batchName, errVars, leftAxis, bottomAxis)
		
					DoUpdate
				
					Notebook $noteName selection={startOfParagraph, endOfParagraph}, justification=1, fSize=16, fStyle=1
					Notebook $noteName text=titleStr+"\r\t"
					Notebook $noteName picture={exportGraph, -5, 1}
					Notebook $noteName text="\r"
				
					DoWindow /K exportGraph
				endfor
				
				////// make sure the original graph is restored
				NVAR indxTRPI =  packageBatchDFR:WMindexToResultsPanelImage
				WMdisplayFitResultInPanel(indxTRPI, currentPanel+"#Tab0", batchDir, batchName)
			endif
		endif	
	endif
End


////// a select string like "0-10,15,18,20-22".  maxSize is the size of whatever is being selected. outWave is a wave that will be filled with indices 
Function parseSelectString(selectStr, maxSize, outWave)
	String selectStr
	Variable maxSize
	Wave outWave

	Variable nItems = ItemsInList(selectStr, ",")
	Variable curri = 0, i, j
	
	String utilStr
	
	for (i=0; i<nItems; i+=1)
		utilStr = StringFromList(i, selectStr, ",")
		if (ItemsInList(utilStr, "-") > 1)   /// its a range
			Variable lowEnd = str2num(StringFromList(0, utilStr, "-"))
			Variable highEnd = str2num(StringFromList(1, utilStr, "-"))
			if (numType(lowEnd)!=2 && numType(highEnd)!=2 && lowEnd>=0 && highEnd >=lowEnd && highEnd < maxSize)
				for (j=lowEnd; j<=highEnd; j+=1)
					outwave[curri] = j
					curri+=1
				endfor
			else
				DoAlert /T="Selection Text Error" 0, "Error on selection range: "+utilStr+" not a valid range"
			endif
		else			///// its a single graph
			Variable graphi = str2Num(utilStr)
			if (numType(graphi)!=2 && graphi>0 && graphi<maxSize)
				outwave[curri] = graphi
				curri += 1
			else
				DoAlert /T="Selection Text Error" 0, "Error on selection range: "+utilStr+" not a valid index"
			endif
		endif
	endfor
	Redimension /N=(curri) outWave
End

// Next / Previous button control
Function WMShowNextFit(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2)
		String dirInfo = GetUserData(B_struct.win, B_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		
		DFREF batchDataDFR = $(batchDir)
		DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		
		NVAR index = packageBatchDFR:WMindexToResultsPanelImage
	
		NVAR /Z nWaves = batchDFR:WMnWaves  
		
		if (!NVAR_exists(nWaves))
			Variable /G batchDFR:WMnWaves=0
			NVAR /Z nWaves = batchDFR:WMnWaves
		endif
		if (!nWaves)
			nWaves = WMGetNWaves(batchDir, batchName)
		endif
		
		if (nWaves)
			if (!cmpStr(B_Struct.ctrlName, "ForwardButton"))
				index = mod(index+1,nWaves)
			else
				index = mod(index-1+nWaves,nWaves)
			endif
		endif
	
		WMdisplayFitResultInPanel(index, B_Struct.win, batchDir, batchName)
	endif
End

Function WMExportWaveCB(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2)
		String dirInfo = GetUserData(CB_struct.win, CB_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
		
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
	
		String controls = ControlNameList(CB_Struct.win)   //// this function is used by 2 panels and not all the controls occur on one of them
	
		strswitch (CB_Struct.ctrlName)
			case "exportWavesCheck":
				Checkbox exportWavesGraphCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				Checkbox exportWavesTableCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				TitleBox exportToFolderTitle win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				SetVariable setVariableFolder win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2				

				if (strlen(ListMatch(controls, "exportAllCheck")))
					Checkbox exportAllCheck, win=$(CB_Struct.win),  disable=(!CB_Struct.checked)*2
					Checkbox exportSomeCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2			
								
					ControlInfo exportSomeCheck
					if (V_Value)
						SetVariable exportSelectWaves, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
						TitleBox exportSelectExample, win=$(CB_Struct.win),  disable=(!CB_Struct.checked)*2
					else
						SetVariable exportSelectWaves, win=$(CB_Struct.win), disable=2
						TitleBox exportSelectExample, win=$(CB_Struct.win),  disable=2
					endif
				endif
				break
			case "exportAllCheck": 
				Checkbox exportAllCheck, win=$(CB_Struct.win),  value=1
				Checkbox exportSomeCheck, win=$(CB_Struct.win),  value=0
				SetVariable exportSelectWaves, win=$(CB_Struct.win), disable=2
				TitleBox exportSelectExample, win=$(CB_Struct.win), disable=2
				break
			case "exportSomeCheck":
				Checkbox exportAllCheck, win=$(CB_Struct.win), value=0
				Checkbox exportSomeCheck, win=$(CB_Struct.win),  value=1
				SetVariable exportSelectWaves, win=$(CB_Struct.win), disable=0
				TitleBox exportSelectExample, win=$(CB_Struct.win), disable=0
				break
				
			case "exportNoteCheck":
				Checkbox exportNoteGraphCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				Checkbox exportNoteTableCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				SetVariable exportNoteName, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
				if (strlen(ListMatch(controls, "exportNoteAllCheck")))
					Checkbox exportNoteAllCheck, win=$(CB_Struct.win),  disable=(!CB_Struct.checked)*2
					Checkbox exportNoteSomeCheck, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
	
					ControlInfo exportNoteSomeCheck
					if (V_Value)
						SetVariable exportNoteSelectWaves, win=$(CB_Struct.win), disable=(!CB_Struct.checked)*2
						TitleBox exportNoteSelectExample, win=$(CB_Struct.win),  disable=(!CB_Struct.checked)*2
					else
						SetVariable exportNoteSelectWaves, win=$(CB_Struct.win), disable=2
						TitleBox exportNoteSelectExample, win=$(CB_Struct.win),  disable=2
					endif
				endif
				break
			case "exportNoteAllCheck":
				Checkbox exportNoteAllCheck, win=$(CB_Struct.win),  value=1
				Checkbox exportNoteSomeCheck, win=$(CB_Struct.win),  value=0
				SetVariable exportNoteSelectWaves, win=$(CB_Struct.win), disable=2
				TitleBox exportNoteSelectExample, win=$(CB_Struct.win), disable=2
				break
			case "exportNoteSomeCheck":
				Checkbox exportNoteAllCheck, win=$(CB_Struct.win), value=0
				Checkbox exportNoteSomeCheck, win=$(CB_Struct.win),  value=1
				SetVariable exportNoteSelectWaves, win=$(CB_Struct.win), disable=0
				TitleBox exportNoteSelectExample, win=$(CB_Struct.win), disable=0
				break		
					
			default:
				break
		endswitch
	
	endif
End

// Add (or remove) the fit equation from the results graph.  Just plop it in without changing the graph.  The function WMDisplayFitResultInPanel() will keep it current
Function WMShowFitEquationProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2)
		String dirInfo = GetUserData(CB_struct.win, CB_struct.ctrlName, "")
		String batchDir = StringFromList(0, dirInfo)
		String batchName = StringFromList(1, dirInfo)
			
		DFREF batchDataDFR = $(batchDir)
		DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
		DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
		DFREF packageDFR = GetBatchCurveFitPackageDFR()
		
		SVAR /Z currFitFunc = batchDFR:WMfitFunc
		Wave /T inArgsTxt = packageDFR:inputArgsTextDescription
		
		NVAR /Z nInCoefs =  batchDFR:WMnInCoefs
		Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
		
		if (SVAR_exists(currFitFunc) && NVAR_exists(nInCoefs) && waveExists(resultsMatrix))
			Wave /Z/T coefNames = GetCoefNames(currFitFunc, nInCoefs)
		
			Variable iType = FindDimLabel(inArgsTxt, 0, currFitFunc) 
			Variable i
			NVAR index = packageBatchDFR:WMindexToResultsPanelImage
		
			Make /D/Free/N=(dimSize(resultsMatrix,1)) results
			results = resultsMatrix[index][p]		
			GetWindow $(CB_Struct.win) wsize
			String currFormula = equStrFillCoefficients(coefNames, results, currFitFunc, nInCoefs, approxCutOff=(V_right-V_left-40)/20 )
	
			NVAR showFit = packageBatchDFR:WMshowFitEquation
	
			if (CB_Struct.checked && showFit)
				TextBox /W=$(CB_Struct.win)#results /C/N=currFormulaText/Z10/F=0/A=MT currFormula
			else
				TextBox /W=$(CB_Struct.win)#results /C/N=currFormulaText/Z10/F=0/A=MT ""
			endif
		else
			TextBox /W=$(CB_Struct.win)#results /C/N=currFormulaText/Z10/F=0/A=MT ""
		endif
	endif
End

Function WMDisplayFitResultInPanel(index, win, batchDir, batchName)
	Variable index
	String win, batchDir, batchName

	DFREF batchDataDFR = $(batchDir)
	DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
	DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)

	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	String errMessage=""
	Variable dataOrResultsWaveExist = 3 /// bit-wise argument, bit 0 (0 or 1) set if results can be displayed, bit 1 (0 or 2) if original data can be displayed	

	Make /FREE/WAVE /N=0 batchWaves
	Make /FREE/WAVE /N=0 batchXWaves
	getYandXBatchData(batchDir, batchName, batchWaves, batchXWaves)
	
	Variable batchWavesSize = DimSize(batchWaves, 0)
	if (numType(batchWavesSize)==2 || batchWavesSize<=0)
		errMessage += "Warning: no original data specified.  Unable to display original data\r"
		dataOrResultsWaveExist = dataOrResultsWaveExist & 1 // original data cannot be displayed	
	endif
	
	SVAR /Z currFitFunc = batchDFR:WMfitFunc
	if (!SVAR_exists(currFitFunc) || !strLen(currFitFunc))
		dataOrResultsWaveExist = dataOrResultsWaveExist & 2
		errMessage += "Warning: No fit function specified.  Cannot reproduce results\r"
	endif
	NVAR /Z nCoefs = batchDFR:WMnInCoefs
	if (!NVAR_exists(nCoefs))
		WAVE inArgs = packageDFR:nInputArgsHash
		Variable nCoefsTmp = inArgs[%$currFitFunc]
		
		if (numtype(nCoefsTmp)!=2)
			Variable /G batchDFR:WMnInCoefs
			NVAR nCoefs = batchDFR:WMInCoefs
			nCoefs = nCoefsTmp
		else	
			errMessage += "Warning: the number of input coefficients not specified.  Data results may not be displayed.\r"	
			dataOrResultsWaveExist = dataOrResultsWaveExist & 2 // results cannot be displayed	
		endif
	endif
	
	String batchDataDir = WMSCSGetInputSourceFolder("YWaves")
	Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
	if (!waveExists(resultsMatrix))
		errMessage += "Warning: the results matrix is missing.  Unable to display fit results\r"
		dataOrResultsWaveExist = dataOrResultsWaveExist & 2 // results cannot be displayed
	endif	

	Variable waveIndex = min(index, numpnts(batchWaves)-1)
	SVAR GOFFunctions = packageDFR:WMGOFFunctions
	
	// Remove the old traces and also save the graph axes
	GetAxis /W=$(win)#results /Q left
	Make /Free /N=2 leftAxis = {V_min, V_max}
	GetAxis /W=$(win)#results /Q bottom
	Make /Free /N=2 bottomAxis = {V_min, V_max}
	RemoveFromGraph /Z/W=$(win)#results $"#0", $"#1"

	NVAR /Z nCoefs = batchDFR:WMnInCoefs
	Wave /T coefNames = GetCoefNames(currFitFunc, nCoefs)
	if (numpnts(coefNames)>=nCoefs)
		CheckBox showEquation,win=$(win), disable=0
	else
		CheckBox showEquation,win=$(win), disable=2
	endif
	
	////// Plot the results /////// 
	Variable errVars = 0
	String titleStr = plotResultsInsideGraph(dataOrResultsWaveExist, index, win+"#results", batchDir, batchName, errVars, leftAxis, bottomAxis)
	
	TitleBox displayedWave, win=$(win), title=titleStr
	TitleBox displayedIndexOf, win=$(win), title="Data Set: "+num2str(index)

	Wave /Z/T errorMatrix = batchDFR:WMBatchResultsErrorWave
	if (waveExists(errorMatrix))
		SVAR errStr = packageBatchDFR:WMResultsPanelErrString
		errStr = errorMatrix[index]
	else
		errMessage += "Warning: the error message wave for individual fits is missing.\r"
	endif

	if (strlen(errMessage))
		TextBox/C/N=displayFitErrTB /W=$(win)#results /F=0 /A=LT "\\Z11"+errMessage;   ///X=2.83/Y=-1.22
	endif
End

// Returns a title for the plot
///// results to plot is a 2 bit flag
Function /S plotResultsInsideGraph(resultsToPlot, index, graph, batchDir, batchName, errVars, leftAxis, bottomAxis, [outputDir])
	Variable resultsToPlot, index
	String graph, batchDir, batchName
	Variable & errVars
	Wave leftAxis, bottomAxis
	String outputDir

	DFREF batchDataDFR = $(batchDir)
	DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
	DFREF packageBatchDFR = getPackageBatchFolderDFR(batchDir, batchName)
	DFREF outDFR = packageBatchDFR
	if (!paramIsDefault(outputDir))
		outDFR = $outputDir
	endif
	String batchDFRStr = GetDataFolder(1, batchDFR)
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()

	NVAR /Z inputSource = batchDFR:WMyValsSourceType
	NVAR /Z xValsSourceType = batchDFR:WMxValsSourceType

	Make /FREE/WAVE /N=0 batchWaves
	Make /FREE/WAVE /N=0 batchXWaves
	getYandXBatchData(batchDir, batchName, batchWaves, batchXWaves)

	String titleStr = "", newWaveName="defaultName"
	
	SVAR /Z currFitFunc = batchDFR:WMfitFunc
	Wave /Z resultsMatrix = batchDFR:WMBatchResultsMatrix
	NVAR /Z nCoefs = batchDFR:WMnInCoefs	
	
	Variable isXOffset=0, xoffset=NaN
	if (SVAR_exists(currFitFunc) && stringmatch(currFitFunc, "*xoffset*"))
		isXOffset = 1
	endif
	
	Wave /T inArgsTxt = packageDFR:inputArgsTextDescription

	if (resultsToPlot & 2)
		if (inputSource & WMconstSingle2DInput)
			WAVE the2DWave = batchWaves[0]
			
			if (paramIsDefault(outputDir))
				Make /D/O/N=0 packageBatchDFR:WMxvals
				Wave xvals = packageBatchDFR:WMXvals
			else 
				newWaveName = NameOfWave(the2DWave)+"_"+num2str(index)
				Make /D/O/N=0 outDFR:$(newWaveName+"_xvals")
				Wave xvals = outDFR:$(newWaveName+"_xvals")
			endif
			Redimension /N=(DimSize(the2DWave, 0)) xvals
					
			switch (xValsSourceType)
				case WMconstWaveScalingInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][index] the2DWave, packageBatchDFR:WMyvals
						Wave yvals = packageBatchDFR:WMyvals
						Duplicate /O packageBatchDFR:WMyvals, packageBatchDFR:WMXvals
						xvals = x 		
						AppendToGraph /W=$(graph) the2DWave[][index]
					else
						Duplicate /O/R=[][index] the2DWave, outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						Duplicate /O packageBatchDFR:WMyvals, outDFR:$(newWaveName+"_xvals")
						xvals = x 		
						AppendToGraph /W=$(graph) yvals					
					endif
					titleStr ="Column "+num2str(index)+" of "+NameOfWave(the2DWave)
					break
				case WMconstCommonWaveInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][index] the2DWave, packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) the2DWave[][index] vs theXWave
					else
						Duplicate /O/R=[][index] the2DWave, outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")						
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) yvals vs xvals
					endif
					titleStr="Column "+num2str(index)+" of "+NameOfWave(the2DWave)+" vs "+NameOfWave(theXWave)
					break
				case WMconstXyPairsInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][index*2+1] the2DWave, packageBatchDFR:WMyvals
						xvals = the2DWave[p][index*2]
						AppendToGraph /W=$(graph) the2DWave[][index*2+1] vs the2DWave[][index*2]
					else
						Duplicate /O/R=[][index*2+1] the2DWave, outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						xvals = the2DWave[p][index*2]
						AppendToGraph /W=$(graph) yvals vs xvals					
					endif
					titleStr="XY Pair "+num2str(index)+" of "+NameOfWave(the2DWave)
					break
				case WMconstSingle2DInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][index] the2DWave, packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p][index]
						AppendToGraph /W=$(graph) the2DWave[][index] vs theXWave[][index]
					else
						Duplicate /O/R=[][index] the2DWave, outDFR:$(newWaveName+"_yvals")
						Wave yVals = outDFR:$(newWaveName+"_yvals")
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p][index]
						AppendToGraph /W=$(graph) yvals vs xvals
					endif				
					titleStr="Column "+num2str(index)+" of "+NameOfWave(the2DWave)+" vs Column "+num2str(index)+" of "+NameOfWave(theXWave)
					break
				case WMconstCollection1DInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][index] the2DWave, packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[index]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) the2DWave[][index] vs theXWave
					else
						Duplicate /O/R=[][index] the2DWave, outDFR:$(newWaveName+"_yvals")
						Wave yVals = outDFR:$(newWaveName+"_yvals")
						WAVE theXWave = batchXWaves[index]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) yVals vs xVals
					endif
					titleStr="Column "+num2str(index)+" of "+NameOfWave(the2DWave)+" vs "+NameOfWave(theXWave)
					break
				default:
					break
			endswitch	
		else
			newWaveName = NameOfWave(batchWaves[index])
			if (paramIsDefault(outputDir))
				Make /D/O/N=0 packageBatchDFR:WMxvals
				Wave xvals = packageBatchDFR:WMXvals
			else 
				Make /D/O/N=0 outDFR:$(newWaveName+"_xvals")
				Wave xvals = outDFR:$(newWaveName+"_xvals")
			endif
		
			Redimension /N=(DimSize(batchWaves[index], 0)) xvals
			
			switch (xValsSourceType)
				case WMconstWaveScalingInput:
					if (paramIsDefault(outputDir))
						Duplicate /O batchWaves[index], packageBatchDFR:WMyvals
						Duplicate /O packageBatchDFR:WMyvals, packageBatchDFR:WMXvals
						xvals = x
						AppendToGraph /W=$(graph) batchWaves[index]
					else
						Duplicate /O batchWaves[index], outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						Duplicate /O packageBatchDFR:WMyvals, outDFR:$(newWaveName+"_xvals")
						xvals = x 		
						AppendToGraph /W=$(graph) yvals
					endif
					titleStr=NameOfWave(batchWaves[index])
					break
				case WMconstCommonWaveInput:
					if (paramIsDefault(outputDir))
						Duplicate /O batchWaves[index], packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) batchWaves[index] vs batchXWaves[0]
					else
						Duplicate /O batchWaves[index], outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) yvals vs xvals
					endif
					titleStr=NameOfWave(batchWaves[index])+" vs "+NameOfWave(batchXWaves[0])
					break
				case WMconstXyPairsInput:
					if (paramIsDefault(outputDir))
						Duplicate /O/R=[][1] batchWaves[index], packageBatchDFR:WMyvals
						WAVE theWave = batchWaves[index]
						xvals = theWave[p][0]
						AppendToGraph /W=$(graph) theWave[][1] vs theWave[][0]
					else
						Duplicate /O/R=[][1] batchWaves[index], outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						WAVE theWave = batchWaves[index]
						xvals = theWave[p][0]
						AppendToGraph /W=$(graph) yvals vs xvals
					endif
					titleStr="XY Pair from "+NameOfWave(batchWaves[index])
					break
				case WMconstSingle2DInput:
					if (paramIsDefault(outputDir))
						Duplicate /O batchWaves[index], packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p][index]
						AppendToGraph /W=$(graph) batchWaves[index] vs theXWave[][index]
					else
						Duplicate /O batchWaves[index], outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						WAVE theXWave = batchXWaves[0]
						xvals = theXWave[p][index]
						AppendToGraph /W=$(graph) yvals vs xvals
					endif
					titleStr=NameOfWave(batchWaves[index])+" vs Column "+num2str(index)+" of "+NameOfWave(batchXWaves[0])
					break
				case WMconstCollection1DInput:
					if (paramIsDefault(outputDir))
						Duplicate /O batchWaves[index], packageBatchDFR:WMyvals
						WAVE theXWave = batchXWaves[index]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) batchWaves[index] vs batchXWaves[index]
					else
						Duplicate /O batchWaves[index], outDFR:$(newWaveName+"_yvals")
						Wave yvals = outDFR:$(newWaveName+"_yvals")
						WAVE theXWave = batchXWaves[index]
						xvals = theXWave[p]
						AppendToGraph /W=$(graph) yvals vs xvals					
					endif
					titleStr=NameOfWave(batchWaves[index])+" vs "+NameOfWave(batchXWaves[index])
					break
				default:
					break		
			endswitch	
		endif
		if (paramIsDefault(outputDir))
			Wave yvals = packageBatchDFR:WMyvals
		endif
		ModifyGraph/Z /W=$(graph) mode=3, rgb=(0, 0, 65535), fsize=15
	endif
	
	 //////////// results to display? //////////////
	if (resultsToPlot & 1)  
		Make /D/O/N=(nCoefs) packageBatchDFR:WMresultsRow//DimSize(resultsMatrix,1)) packageBatchDFR:WMresultsRow
		Wave resultsRow =  packageBatchDFR:WMresultsRow
		  
		resultsRow = resultsMatrix[index][p]	
		
		Variable doRange = NumVarOrDefault(batchDFRStr+"WMdoRange", 0);
		Variable minRange = NumVarOrDefault(batchDFRStr+"WMminRange", 0);
		Variable maxRange = NumVarOrDefault(batchDFRStr+"WMmaxRange", DimSize(yvals, 0)-1);
		if (numtype(maxRange))
			maxRange = inf
		endif
		
		if (paramIsDefault(outputDir))
			Make /D/O/N=(DimSize(yvals, 0)) packageBatchDFR:WMmodelYvals 
			Wave modelYvals = packageBatchDFR:WMmodelYvals
		else
			Make /D/O/N=(DimSize(yvals, 0)) outDFR:$(newWaveName+"_modelYvals")
			Wave modelYvals = outDFR:$(newWaveName+"_modelYvals")		
		endif
		if (isXOffset)
			xoffset = resultsMatrix[index][dimsize(resultsMatrix,1)-1]//resultsRow[numpnts(resultsRow)-1]
		endif
		
		doFitFunc(xvals, resultsRow, currFitFunc, modelYvals, ncoefs, xoffset)
		
		// NH 9/2015: 	These sorts are to handle data in which the xVals are not monotonic.  Unfortunately when used on 
		// 				monotonically decreasing xVals data that covers only a range it results in a display error.
		//				I moved the sort to the case when there is no range.  Range is always by point (otherwise a mask is used), 
		//				so doing a point range on non-monotonic x values strikes me as nuts - or at least very improbable.  
//		Sort xvals, modelYvals
//		Sort xvals, yvals
//		Sort xvals, xvals					
		if (doRange)
			AppendToGraph /W=$(graph) modelYvals[minRange, maxRange] vs xvals[minRange, maxRange]
		else
			Sort xvals, modelYvals
			Sort xvals, yvals
			Sort xvals, xvals							
			AppendToGraph /W=$(graph) modelYvals vs xvals
		endif
		ModifyGraph /Z /W=$(graph) rgb(modelYvals)=(65535, 0, 0)
	
		Wave nInArgsHash = packageDFR:nInputArgsHash
		Variable iType = FindDimLabel(nInArgsHash, 0, currFitFunc)
		Variable nInCoefs = nCoefs

		///////////// Display the resulting formula //////////////
		String currFormula = inArgsTxt[%$currFitFunc] 
		
		///// 2 built-in formulas that have variable # of coefficients can be displayed in full
		Wave /T coefNames = GetCoefNames(currFitFunc, nInCoefs)
		GetWindow $(graph) wsize
		currFormula = equStrFillCoefficients(coefNames, resultsRow, currFitFunc, nInCoefs, approxCutOff=(V_right-V_left-40)/20 )
				
		Variable /G packageBatchDFR:WMshowFit = 1
		NVAR showFitGlobal = packageBatchDFR:WMshowFit
		Variable showFit = showFitGlobal, i
		for (i=0; i<nInCoefs; i+=1)
			if (numtype(resultsRow[i])==2)
				showFit = 0
			endif
		endfor
		
		if (!showFit)  /// some coefficeints are NaN, assume the fit function didn't work
			Wave/T errorMatrix = batchDFR:WMBatchResultsErrorWave
			TextBox /W=$(graph) /C/N=FitStatsText/F=0/A=LT errorMatrix[index]
			errVars = errVars | 1
			TextBox /W=$(graph) /C/N=currFormulaText/Z10 ""
		else
			TextBox /W=$(graph) /C/N=FitStatsText ""
			NVAR showFitEquation = packageBatchDFR:WMshowFitEquation
			
			if (showFitEquation)
				TextBox /W=$(graph) /C/N=currFormulaText/F=0/A=MT currFormula 
			endif
		endif
		
		////////////// Axis controls: log and/or constant (accross fits) axes /////////////
		NVAR /Z doLogY = packageBatchDFR:WMdoLogYaxis
		if (!NVAR_exists(doLogY))
			Variable /G packageBatchDFR:WMdoLogYaxis = 0
			NVAR /Z doLogY = packageBatchDFR:WMdoLogYaxis
		endif
		NVAR /Z doLogX = packageBatchDFR:WMdoLogXaxis
		if (!NVAR_exists(doLogX))
			Variable /G packageBatchDFR:WMdoLogXaxis = 0
			NVAR /Z doLogX = packageBatchDFR:WMdoLogXaxis
		endif
		if (doLogY)
			ModifyGraph /W=$(graph) log(left)=1
		else
			ModifyGraph /W=$(graph) log(left)=0
		endif
		if (doLogX)
			ModifyGraph /W=$(graph) log(bottom)=1
		else
			ModifyGraph /W=$(graph) log(bottom)=0
		endif
		
		NVAR /Z doConstantYaxis = packageBatchDFR:WMconstantYaxis
		if (NVAR_exists(doConstantYaxis))
			if (doConstantYaxis==WMautoConstantAxis)
				NVAR autoMinY = packageBatchDFR:WMautoMinY
				NVAR autoMaxY = packageBatchDFR:WMautoMaxY
				SetAxis /W=$(graph) left, autoMinY, autoMaxY
			elseif (doConstantYaxis==WMmanualConstantAxis) 
				NVAR manYMin = packageBatchDFR:WMmanYMin
				NVAR manYMax = packageBatchDFR:WMmanYMax
				
				If (numtype(leftAxis[0])==2 || numtype(leftAxis[1])==2)
					SetAxis /A/W=$(graph) left
					GetAxis /Q/W=$(graph) left
					manYMin=V_min
					manYMax=V_max
				else
					manYMin=leftAxis[0]
					manYMax=leftAxis[1]
					SetAxis /W=$(graph) left, leftAxis[0], leftAxis[1]
				endif
			endif
		else    //make sure there's not some residual axis setting - shouldn't be...
			SetAxis /W=$(graph) /A left
		endif
		NVAR /Z doConstantXaxis = packageBatchDFR:WMconstantXaxis
		if (NVAR_exists(doConstantXaxis))
			if (doConstantXaxis==WMautoConstantAxis)
				NVAR autoMinX = packageBatchDFR:WMautoMinX
				NVAR autoMaxX = packageBatchDFR:WMautoMaxX	
				SetAxis /W=$(graph) bottom, autoMinX, autoMaxX
			elseif (doConstantXaxis==WMmanualConstantAxis)
				NVAR manXMin = packageBatchDFR:WMmanXMin
				NVAR manXMax = packageBatchDFR:WMmanXMax
				If (numtype(leftAxis[0])==2 || numtype(leftAxis[1])==2)
					SetAxis /A/W=$(graph) bottom
					GetAxis /Q/W=$(graph) bottom
					manXMin=V_min
					manxMax=V_max
				else
					manXMin=bottomAxis[0]
					manXMax=bottomAxis[1]
					SetAxis /W=$(graph) bottom, bottomAxis[0], bottomAxis[1]
				endif
			endif
		else    //make sure there's not some residual axis setting - shouldn't be...
			SetAxis /W=$(graph) /A bottom
		endif
		//////////////// End Axis ///////////////////
	endif

	return titleStr
End

//////// Get the results of the fit using the fit equation and independent data ////////
Function doFitFunc(xvals, coefWave, curveType, yvals, ncoefs, xoffset)
	WAVE xvals
	WAVE coefWave
	String curveType
	WAVE yvals
	Variable ncoefs	
	Variable xoffset
	
	Variable i

	Redimension /N=(numpnts(xvals)) yvals
	
	strswitch (curveType)
		case "gauss":   
			yvals = coefWave[0] + coefWave[1]*exp(-((xvals[p]-coefWave[2])/coefWave[3])^2)
			break
		case "lor":
			yvals = coefWave[0] + coefWave[1]/((xvals[p]-coefWave[2])^2+coefWave[3])  
			break
		case "exp":
			yvals = coefWave[0] + coefWave[1]*exp(-coefWave[2]*xvals[p])
			break
		case "dblexp":
			yvals = coefWave[0] + coefWave[1]*exp(-coefWave[2]*xvals[p]) + coefWave[3]*exp(-coefWave[4]*xvals[p])
			break
		case "sin":
			yvals = coefWave[0] + coefWave[1]*sin(xvals[p]*coefWave[2]+coefWave[3])
			break
		case "line":
			yvals = coefWave[0] + coefWave[1]	*xvals[p]
			break
		case "poly":
			yvals = coefWave[0]
			for (i=1; i<ncoefs; i+=1)
				yvals += coefWave[i]*xvals[p]^i
			endfor
			break
		case "poly_XOffset":      
			yvals = coefWave[0]
			xoffset = numtype(xoffset)==2 ? 0 : xoffset
			for (i=1; i<ncoefs; i+=1)
				yvals += coefWave[i]*(xvals[p]- xoffset)^i
			endfor
			break
		case "hillequation":
			yvals = coefWave[0] + (coefWave[1]-coefWave[0])/(1 + (coefWave[3]/xvals[p])^coefWave[2])
			break
		case "sigmoid":
			yvals = coefWave[0] + coefWave[1]/(1+exp(-(xvals[p]-coefWave[2])/coefWave[3]))
			break
		case "power":
			yvals = coefWave[0] + coefWave[1]*xvals[p]*coefWave[2]
			break
		case "lognormal":
			yvals = coefWave[0] + coefWave[1]*exp(-(ln(xvals[p]/coefWave[2])/coefWave[3])^2)
			break
		case "exp_XOffset":   
			xoffset = numtype(xoffset)==2 ? 0 : xoffset
			yvals = coefWave[0] + coefWave[1]*exp(-(xvals[p]-xoffset)/coefWave[2])
			break
		case "dblexp_XOffset":   
			xoffset = numtype(xoffset)==2 ? 0 : xoffset
			yvals = coefWave[0] + coefWave[1]*exp(-(xvals[p]-xoffset)/coefWave[2]) + coefWave[3]*exp(-(xvals[p]-xoffset)/coefWave[4])
			break
		case "dblexp_peak":   
			yvals = coefWave[0] + coefWave[1]*(-exp(-(xvals[p]-coefwave[4])/coefWave[2]) + exp(-(xvals[p]-coefwave[4])/coefWave[3]))
			break
		case "Voigt":
			yvals = VoigtPeak(coefWave, xvals[p])
			break
		default: // its a user fit function
			xoffset = numtype(xoffset)==2 ? 0 : xoffset
			
			String pathToYVals = GetWavesDataFolder(yvals, 2)
			String pathToCoefWave = GetWavesDataFolder(coefWave, 2)
			String pathToXVals = GetWavesDataFolder(xvals, 2)
			String pathOnly = GetWavesDataFolder(xvals,1)
			Variable /G $(pathOnly+"xoffset") = xoffset
			
			String cmd = pathToYVals +"=ProcGlobal#"+curveType+"("+pathToCoefWave+", "+pathToXVals+"[p]+"+pathOnly+"xoffset)"	
			Execute /Z cmd

			if (V_Flag!=0)	// perhaps it is an all-at-once fit?
				cmd = "ProcGlobal#"+curveType+"("+pathToCoefWave+", "+pathToYVals+","+pathToXVals+")"	
				Execute cmd
			endif
						
			break
	endswitch
End

//////// fill coefficient variables with values in equations
Function /S equStrFillCoefficients(coefNamesOriginal, resultsOriginal, currFitFunc, nInCoefs, [approxCutOff])
	Wave /T coefNamesOriginal
	Wave resultsOriginal
	String currFitFunc
	Variable nInCoefs
	Variable approxCutOff
	
	Variable i
	String retFormula = WMBCFGetCurrFormula(currFitFunc, nInCoefs)
	
	Duplicate /T/Free coefNamesOriginal coefNames
	Duplicate /Free resultsOriginal results

	/// Sort coeficients by length, longest to shortest, to ensure coef names that are substrings of longer strings don't
	/// get their values substituted into longer coef names
	Make /D/Free/N=(numpnts(coefNames)) coefNameLengths, tmpResults
	tmpResults = results[p]
	for (i=0; i<numpnts(coefNames); i+=1)
		coefNameLengths[i]=strlen(coefNames[i])
	endfor
	Sort /R coefNameLengths coefNames
	Sort /R coefNameLengths tmpResults
	results[0, numpnts(coefNames)-1] = tmpResults[p]
	
	for (i=0; i<nInCoefs; i+=1)
		if (numpnts(coefNames)>i)
			retFormula = ReplaceString(coefNames[i], retFormula, num2Str(results[i]), 1)
		endif
	endfor
	retFormula = ReplaceString("+-", retFormula, "-")
	String formulaNoPlusE = ReplaceString("e+", retFormula, "ee")  // so that the line break doesn't hit the + in scientific notation
	formulaNoPlusE = ReplaceString("e-", formulaNoPlusE, "ee")  

	if (!ParamIsDefault(approxCutOff))
		String tmpStr
		Variable nChars = strlen(retFormula)
		for (i=approxCutOff; i<nChars; i+=approxCutOff)
			Variable indx = min(strsearch(formulaNoPlusE, "+", i), strsearch(formulaNoPlusE, "-", i))
			if (indx>=0)
				i=indx+1
				tmpStr = retFormula[i,i+7]
				retFormula[i,i+7]="\r      "
				retFormula[i+8,strlen(retFormula)-1]=tmpStr+retFormula[i+8,strlen(retFormula)-1]
				tmpStr = formulaNoPlusE[i,i+7]
				formulaNoPlusE[i,i+7]="\r      "
				formulaNoPlusE[i+8,strlen(formulaNoPlusE)-1]=tmpStr+formulaNoPlusE[i+8,strlen(formulaNoPlusE)-1]
			else
				break
			endif
		endfor
	endif

	return retFormula
End

//////// user fit function prototype ///////
Function userFFuncTemplate(w, x) : FitFunc
	WAVE w; Variable x

	DoAlert 0, "You just called template function userFFuncTemplate in WMBatchCurveFitResults. Something is not right..."
	
	Return NaN
End

//////// Allow reporting of Goodness of Fit metrics /////////
Function goodnessOfFitProto(observed, modeled)   // this is the prototype function
	Wave observed, modeled
	
	return 0
End

///// Index of Agreement is from Willmott, 1981
Function indexOfAgreement(obs, model)
	Wave, obs, model
	
	Make /D/Free/N=(numpnts(obs)) yvalsModelYvals2 = (obs-model)^2
	Make /D/Free/N=(numpnts(obs)) IOADenominator = (abs(model-mean(obs)) + abs(obs-mean(obs)))^2
	Variable ioa = 1-sum(yvalsModelYvals2)/sum(IOADenominator)
	
	return ioa
End