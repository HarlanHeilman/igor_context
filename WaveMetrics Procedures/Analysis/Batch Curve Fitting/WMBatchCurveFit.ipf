#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#pragma IgorVersion=9.00
#pragma version=9.00 // ship with Igor 9
#include <WMBatchCurveFitDefs>
#include <WMBatchCurveFitUI>
#include <WMBatchCurveFitResults>
#include <WMSelectorControlSet>
#include <Resize Controls>
#include <PopupWaveSelector>, version>=1.18
 
////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Gateway Panel and Menu ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Menu "Analysis"
	"Batch Curve Fitting...", /Q, InitBatchFitPanel()
End

Function InitBatchFitPanel()
	DoWindow/F batchFitPanel
	if (V_flag != 0)		// Panel already exists
		return 0
	endif
	
	InitPanelVariables()

	///// Get the global variables /////
	///// Package directory /////
	DFREF packageDFR = GetBatchCurveFitPackageDFR(doInitialization=1)
	String packageDFRString = GetDataFolder(1, packageDFR)	
	
	// locate control sections
	NVAR fileSelectionTop = packageDFR:WMfileSelectionTop
	
	///// Panel Variables /////
	/// controls //
	NVAR left = packageDFR:WMMainPanelLeft
	NVAR top = packageDFR:WMMainPanelTop
	NVAR right = packageDFR:WMMainPanelRight
	NVAR bottom = packageDFR:WMMainPanelBottom
	NVAR listBoxHeight = packageDFR:WMlistBoxHeight 
	NVAR listBoxWidth = packageDFR:WMlistBoxWidth
	NVAR tabRegionBotOffset = packageDFR:WMtabRegionBotOffset
	Variable centerLine = (right-left)/2

	/// state variables ///
	NVAR doMask = packageDFR:WMdoMask
	NVAR doWeight = packageDFR:WMdoWeight
	NVAR doRange = packageDFR:WMdoRange
	
	// Most controls will move up and down based on a sub-panel.  To limit the number of sub-panels some will just be moved individually.
	// These will be set according to base variables of vertical location and height of expanding/contracting object.  
	// Set all vertical positions based on the currWavesTitle vertical position
	NewPanel /N=batchFitPanel /K=1 /W=(left, top, right, bottom) as "Batch Curve Fit"

	///// Set the version so that significant panel changes can be reflected on older panels opened in saved experiments
	SetWindow batchFitPanel userdata(BCF_UPDATEPANELVERSION)=num2str(BCF_UPDATEPANELVERSION)
	
	SetWindow batchFitPanel, hook(mainHook)=MainWindowHook
	
	DefineGuide /W=batchFitPanel TabAreaLeft={FL,10}			// this is changed to FR, 25 when tab 0 is hidden
	DefineGuide /W=batchFitPanel TabAreaRight={FR,-10}
	DefineGuide /W=batchFitPanel TabAreaTop={FT,31}
	DefineGuide /W=batchFitPanel TabAreaBottom={FB,-tabRegionBotOffset}

	TabControl WMBatchFitTabControl,pos={10,7},size={right-left-20,bottom-top-tabRegionBotOffset},proc=BatchFitTabControlProc, fsize=WMBCFBaseFontSize
	
	///// Resize Code from Resize Control Panel	
	TabControl WMBatchFitTabControl,userdata(ResizeControlsInfo)= A"!!,A.!!#:B!!#Dh5QF1X5QCca!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	TabControl WMBatchFitTabControl,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TabControl WMBatchFitTabControl,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	
	TabControl WMBatchFitTabControl,tabLabel(0)="Batch Control"
	TabControl WMBatchFitTabControl,tabLabel(1)="Batch Data Setup"
	TabControl WMBatchFitTabControl,tabLabel(2)="Functions and Coefficients"
	TabControl WMBatchFitTabControl,tabLabel(3)="Weighting",value=0
	TabControl WMBatchFitTabControl,tabLabel(4)="Fit Range and Masking",value=0
	
	NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom) /N=Tab0ContentPanel /Host=batchFitPanel 
	ModifyPanel /W=batchFitPanel#Tab0ContentPanel frameStyle=0,frameInset=0
	DefaultGUIFont /W=batchFitPanel#Tab0ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
	NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom)  /N=Tab1ContentPanel /Host=batchFitPanel
	ModifyPanel /W=batchFitPanel#Tab1ContentPanel frameStyle=0,frameInset=0
	DefaultGUIFont /W=batchFitPanel#Tab1ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
	NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom)  /N=Tab2ContentPanel /Host=batchFitPanel
	ModifyPanel /W=batchFitPanel#Tab2ContentPanel frameStyle=0,frameInset=0
	DefaultGUIFont /W=batchFitPanel#Tab2ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
	NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom)  /N=Tab3ContentPanel /Host=batchFitPanel
	ModifyPanel /W=batchFitPanel#Tab3ContentPanel frameStyle=0,frameInset=0
	DefaultGUIFont /W=batchFitPanel#Tab3ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}
	NewPanel /FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom)  /N=Tab4ContentPanel /Host=batchFitPanel
	ModifyPanel /W=batchFitPanel#Tab4ContentPanel frameStyle=0,frameInset=0
	DefaultGUIFont /W=batchFitPanel#Tab4ContentPanel /Mac popup={"Geneva", WMBCFBaseFontSize, 0}	
	
	///// Resize Code from Resize Control Panel
	SetWindow batchFitPanel,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	SetWindow batchFitPanel,userdata(ResizeControlsInfo)= A"!!*'\"z!!#Dm5QF1i^]4?7zzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow batchFitPanel,userdata(ResizeControlsGuides)=  "TabAreaLeft;TabAreaRight;TabAreaTop;TabAreaBottom;"
	SetWindow batchFitPanel,userdata(ResizeControlsInfoTabAreaLeft)= A":-hTC3`KNs6#pOF9P%gX4',!K3auN>@q\\>GFAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0KW*,;b9q[:JNr*0KVd)8OQ!%3^ue)7o`,K75?nc;FO8U:K'ha8P`)B0ebZ"
	SetWindow batchFitPanel,userdata(ResizeControlsInfoTabAreaRight)= A":-hTC3`KNs6#pOF;JBcWF?<Pq:-)imFCSuRBlm0[DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B3&`]V7o`,K756hm;EIBK8OQ!&3]g5.9MeM`8Q88W:-'s]0KT"
	SetWindow batchFitPanel,userdata(ResizeControlsInfoTabAreaTop)= A":-hTC3`KNs6#pOF<,Z_;=%Q.J@UX@gBLZ]X:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(0c4%E:B6q&gk7T;H><CoSI1-.Kp78-NR;b9q[:JNr,0fo"
	SetWindow batchFitPanel,userdata(ResizeControlsInfoTabAreaBottom)= A":-hTC3`KNs6#pOF6>psfDf%R;8PV<U@<?!m7VQs@@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFmi:et\"]<(Tk\\3]/`O4%E:B6q&gk7RB1,<CoSI1-.Kp78-NR;b9q[:JNr&2_[;"

	////////////////////////////////////////////////////////////////////////////////////////////	
	////////////////////////////////// Tab 0: Batch Control Setup ///////////////////////////////	
	////////////////////////////////////////////////////////////////////////////////////////////

	SVAR currBatchName = packageDFR:WMcurrBatchName
	SVAR currDataFolder = packageDFR:WMbatchDataDir
	if (!DataFolderExists(currDataFolder+":"))
		currDataFolder = "root"
	endif

	/////////// Display and set the Data Folder ///////////
	TitleBox currBatchDirTitle win=batchFitPanel#Tab0ContentPanel, title="Batch Data Folder", fixedSize=1, frame=0, pos={10, fileSelectionTop}; DelayUpdate
	TitleBox currBatchDirTitle win=batchFitPanel#Tab0ContentPanel, size={190, 22}, fsize=WMBCFBaseFontSize+1, fstyle=1, fixedSize=1
	SetVariable setVariableDir win=batchFitPanel#Tab0ContentPanel, pos={10, 20+fileSelectionTop}, size={255, 24}, fsize=WMBCFBaseFontSize, fixedSize=1, value=packageDFR:WMbatchDataDir, title=" "; DelayUpdate
	SetVariable setVariableDir win=batchFitPanel#Tab0ContentPanel, help={"Set the directory from which all batch waves will run.  Available waves will change based batch folder selected."}
	MakeSetVarIntoWSPopupButton("batchFitPanel#Tab0ContentPanel", "setVariableDir", "BatchDirWaveSelectorNotify", packageDFRString+"WMbatchDataDir", initialSelection=currDataFolder,content=WMWS_DataFolders)
	PopupWS_SetPopupFont("batchFitPanel#Tab0ContentPanel", "setVariableDir", fontSize=WMBCFBaseFontSize)

	// collect and display batch run information
	DFREF batchRunsPackageDFR = getPackageBatchFolderDFR(currDataFolder, "")
	Wave /T batchRunsSummary = WMGenBatchRunsSummary()

	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel, pos={10, 70}, size={right-left-40, bottom-top-170-tabRegionBotOffset}, listWave=batchRunsSummary; DelayUpdate
	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel, disable=0, fsize=WMBCFBaseFontSize, mode=1, userColumnResize=1, proc=WMcurrentBatchLBProc

	//// Some control buttons ////
	// Make a new Batch
	Button WMsetBatchNameButton win=batchFitPanel#Tab0ContentPanel, pos={(right-left)/2-340,bottom-top-tabRegionBotOffset-70},size={120,20}, fsize=WMBCFBaseFontSize, title="New Batch", proc=WMNewBatchButtonProc
	// Rename selected batch
	Button WMrenameBatchNameButton win=batchFitPanel#Tab0ContentPanel, pos={(right-left)/2-200,bottom-top-tabRegionBotOffset-70},size={120,20}, fsize=WMBCFBaseFontSize, title="Rename Batch", proc=WMRenameButtonProc
	// copy a batch
	Button WMCopyBatchButton win=batchFitPanel#Tab0ContentPanel, pos={(right-left)/2-60,bottom-top-tabRegionBotOffset-70},size={120,20}, title="Copy Batch", proc=WMCopyBatchButtonProc
	// view batch results
	Button WMViewBatchResultsButton win=batchFitPanel#Tab0ContentPanel, pos={(right-left)/2+80,bottom-top-tabRegionBotOffset-70},size={120,20}, title="View Results", proc=WMViewBatchButtonProc
	// delete a batch		
	Button WMDeleteBatchButton win=batchFitPanel#Tab0ContentPanel, pos={(right-left)/2+220,bottom-top-tabRegionBotOffset-70},size={120,20}, title="Delete Batch", proc=WMDeleteBatchButtonProc

	TitleBox currBatchDirTitle win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) = A"!!,A.!!#9W!!#AM!!#<hz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	TitleBox currBatchDirTitle win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox currBatchDirTitle win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
	SetVariable setVariableDir win=batchFitPanel#Tab0ContentPanel,userdata(popupWSInfo)= A"!!*(/@<?!m7VQs@@;]Xm,?/)\\0LKbrFCf?3:gn6QC]FG8zzzzzzzzzzzzzzzz"
	SetVariable setVariableDir win=batchFitPanel#Tab0ContentPanel,userdata(popupWSInfo) += A"!!!!qDfBi<=&WHmF`__DDD2%jzzz!!!\"?ATUs]EbSrkCh6\"KEW?(>zzz!!!!c@<?!m6tp[C@<Q3\\ASbpfFDl1pDff]*GlRgEz"
	SetVariable setVariableDir win=batchFitPanel#Tab0ContentPanel,userdata(popupWSInfo) += A"zzzzzzzzzzzzzzzz5]Asgz5]-Q%z5Tg%,zzzzz5S*nqz5UZU4zzz"
	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#?E!!#Dc5QF0`J,fQL!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	ListBox currentBatchRunsLB win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button PopupWS_Button0 win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,H?!!#=+!!#=#!!#<pz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button PopupWS_Button0 win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
	Button PopupWS_Button0 win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
	Button WMsetBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,F1!!#CRJ,hq*!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button WMsetBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button WMsetBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button WMrenameBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,H-!!#CRJ,hq*!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button WMrenameBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button WMrenameBatchNameButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button WMCopyBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,I%!!#CRJ,hq*!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button WMCopyBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button WMCopyBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button WMViewBatchResultsButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,IhJ,ht(J,hq*!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button WMViewBatchResultsButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button WMViewBatchResultsButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button WMDeleteBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,J6J,ht(J,hq*!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button WMDeleteBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button WMDeleteBatchButton win=batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"		
	SetWindow batchFitPanel#Tab0ContentPanel,userdata(PopupWS_SetVarList)=  "setVariableDir;"
	SetWindow batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#Dh5QF1PJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab0ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"		
		
	////////////////////////////////////////////////////////////////////////////////////////////	
	////////////////////////////////// Tab 1: Batch Data Setup //////////////////////////////////	
	////////////////////////////////////////////////////////////////////////////////////////////	

	/////////// Display and select Y Waves ///////////
	DefineGuide /W=batchFitPanel#Tab1ContentPanel WaveSelectLeft={FL, 5}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel WaveSelectRight={FL, .48, FR}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel WaveSelectTop={FT,15}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel WaveSelectBottom={FB, 0}
	NewPanel  /FG=(WaveSelectLeft, WaveSelectTop, WaveSelectRight, WaveSelectBottom) /N=YWavesPanel /Host=batchFitPanel#Tab1ContentPanel 
	ModifyPanel /W=batchFitPanel#Tab1ContentPanel#YWavesPanel frameStyle=0,frameInset=0
	
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsGuides)=  "WaveSelectLeft;WaveSelectRight;WaveSelectTop;WaveSelectBottom;XSelectLeft;XSelectRight;XSelectTop;XSelectBottom;"	
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#Dh5QF1PJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsInfosetDataDirLBT)= A":-hTC3cekS6t(1G6tp[86<%lB4',!K3auN>@q\\>GFAQC`AS`Sj@:CoXDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B2`*Td<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]&WS"
	SetWindow batchFitPanel#Tab1ContentPanel,userdata(ResizeControlsInfosetDataDirLBB)= A":-hTC3cekS6t(1G6tp[86:,U4FDl\"X=%Q.J@UX@gBLZ]X:gn6QCa2nf@PC/fDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr02EOE/8OQ!%3_!(17o`,K75?nc;FO8U:K'ha8P`)B1c7>"

	String inputFormatItems = WMSCSInForm1Dset1Dset+";"
	inputFormatItems += WMSCSInForm1DsetScale+";"
	inputFormatItems += WMSCSInForm1Dset1D+";"
	inputFormatItems += WMSCSInForm1Dset2D+";"
	inputFormatItems += WMSCSInForm1Dsetxy+";"
	inputFormatItems += WMSCSInForm2D1Dset+";"
	inputFormatItems += WMSCSInForm2DScale+";"
	inputFormatItems += WMSCSInForm2D1D+";"
	inputFormatItems += WMSCSInForm2D2D+";"
	inputFormatItems += WMSCSInForm2Dxy

	WMSCSInitOptions(inputFormatItems, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel")
	WMSCSSetListBoxHeight("YWaves", listBoxHeight, "batchFitPanel#Tab1ContentPanel#YWavesPanel")
	WMSCSSetListBoxWidth("YWaves", listBoxWidth, "batchFitPanel#Tab1ContentPanel#YWavesPanel")
	WMSCSCreateSelectorControlSet("batchFitPanel", "Tab1ContentPanel#YWavesPanel", "YWaves")
	WMSCSSetFolder(currDataFolder, "YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel")
	WMSCSSetTitleStr("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", "Y")
	WMSCSUpdateControlEnableStatus("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel")

	////////// Display and select X Values/Waves //////////
	DefineGuide /W=batchFitPanel#Tab1ContentPanel XSelectLeft={FL, .52, FR}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel XSelectRight={FR, -10}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel XSelectTop={FT, 15}
	DefineGuide /W=batchFitPanel#Tab1ContentPanel XSelectBottom={FB, 0}
	NewPanel  /FG=(XSelectLeft, XSelectTop, XSelectRight, XSelectBottom) /N=XWavesPanel /Host=batchFitPanel#Tab1ContentPanel 
	ModifyPanel /W=batchFitPanel#Tab1ContentPanel#XWavesPanel frameStyle=0,frameInset=0
	
	WMSCSInitOptions("use wave scaling", "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSSetListBoxHeight("XWaves", listBoxHeight, "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSSetListBoxWidth("XWaves", listBoxWidth, "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSCreateSelectorControlSet("batchFitPanel", "Tab1ContentPanel#XWavesPanel", "XWaves")	
	WMSCSSetFolder(currDataFolder, "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSSetTitleStr("XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel", "X")

	WMSCSSetSlave("YWaves", "batchFitPanel#Tab1ContentPanel#YWavesPanel", "XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")
	WMSCSUpdateControlEnableStatus("XWaves", "batchFitPanel#Tab1ContentPanel#XWavesPanel")

	//////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////// Tab 2: Function and Coefficeint Control /////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////
	////////// Curve Fit Method and Initial Guesses Entry ///////////
	///// Set Curve Fit Method //////
	
	String cmd = GetIndependentModuleName()+"#listFitTypes()"
	PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel, title="Fit Function", value=#cmd; DelayUpdate
	PopupMenu setFitType win=batchFitPanel#Tab2ContentPanel, Proc=setFitTypeProc, pos={10, 10}, size={(right-left)*2/5-10, 25}, fsize=WMBCFBaseFontSize, fstyle=1
		
	///// Set Coefficient Entry Method /////
//	Allow user to specify one set of initial guesses for all fits in a batch.
//	Option to use results from the last successful fit as initial guess for next fit.
//	Option to provide per-fit initial guesses through a 2D wave.

	SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, pos={(right-left)*2/5+20, 10}, size={(right-left)*3/10-40, 25}, fsize=WMBCFBaseFontSize, Proc=WMSetNCoefsProc; DelayUpdate //Proc=WMUpdateCoefControls; DelayUpdate 
	SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, value=packageDFR:WMnCoefs, title="Number of Coefficients", disable=1, limits={1,inf,1};DelayUpdate
	SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, limits={1,inf,1};DelayUpdate
	SetVariable WMSetNCoefs win=batchFitPanel#Tab2ContentPanel, help={"Number of coefficients selection enabled for built in fit funcs with variable coefficients and for user fit funcs without the comments from the curve fitting dialog included"}	
	SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, pos={(right-left)*7/10, 10}, size= {(right-left)*3/10-80, 25}, fsize=WMBCFBaseFontSize; DelayUpdate  
	SetVariable WMSetXOffset win=batchFitPanel#Tab2ContentPanel, value=packageDFR:WMXOffset, title="X Offset", disable=1, help={"X Offset enabled for built in functions with x offset set."}
	WAVE /T inArgsTxt = packageDFR:inputArgsTextDescription
	String currFormula = inArgsTxt[%$StringFromList(0, listFitTypes())]
	TitleBox FitFunctionFormulaTitle win=batchFitPanel#Tab2ContentPanel, title="Equation:", fixedSize=1, frame=0, pos={10, 40}, size={right-left-40,25},fsize=WMBCFBaseFontSize, fstyle=1; DelayUpdate
	TitleBox FitFunctionFormula 	win=batchFitPanel#Tab2ContentPanel, title=currFormula, fixedSize=1, frame=5, pos={10, 65}, size={right-left-40,30},fsize=WMBCFBaseFontSize, fstyle=0
	
	cmd=GetIndependentModuleName()+"#getInitialGuesses()"
	PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, title="Initial Guess Mode", value=#cmd 
	PopupMenu setCoefficientEntry win=batchFitPanel#Tab2ContentPanel, Proc=setCoefficientEntryProc, pos={10, 105}, size={(right-left)/2-50, 30}, fsize=WMBCFBaseFontSize, fstyle=1

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
	
	/////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// Tab 3: Weight Waves /////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////
	Wave /T batchWaveNames = packageDFR:WMbatchWaveNames
	TitleBox WMShowYWavesTitle win=batchFitPanel#Tab3ContentPanel, title="Current Y Waves", fixedSize=1, frame=0, pos={5, 160+listBoxHeight}; DelayUpdate
	TitleBox WMShowYWavesTitle win=batchFitPanel#Tab3ContentPanel, size={listBoxWidth, 20}, fsize=WMBCFBaseFontSize+2, fstyle=1, anchor=MC
	ListBox WMShowYWaves,win=batchFitPanel#Tab3ContentPanel,pos={5,160+listBoxHeight+30},size={listBoxWidth, listBoxHeight}, mode=0; DelayUpdate
	ListBox WMShowYWaves,win=batchFitPanel#Tab3ContentPanel,listWave=batchWaveNames, fsize=WMBCFBaseFontSize
	
	DefineGuide /W=batchFitPanel#Tab3ContentPanel currYSideCenter={FT, .5, FB}	
	DefineGuide /W=batchFitPanel#Tab3ContentPanel currYLBTop={currYSideCenter, 10}
	DefineGuide /W=batchFitPanel#Tab3ContentPanel currYLBBottom={FB, 0}
	
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo)= A"!!,?X!!#BZ!!#BP!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzz"
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzzzzz!!!"
	ListBox WMShowYWaves,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo)= A"!!,?X!!#Bi!!#BP!!#A/z!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	ListBox WMShowYWaves,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzz"
	ListBox WMShowYWaves,win=batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct@s)g4=\\M.KDfg)>D#aP9zzzzzzzzzz!!!"
	
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#Dh5QF1PJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsGuides)=  "currYSideCenter;currYLBTop;currYLBBottom;maskSelectLeft;maskSelectRight;maskSelectTop;maskSelectBott"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsGuides) +=  "om;weightSelectLeft;weightSelectRight;weightSelectTop;weightSelectBottom;"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfocurrYSideCent)= A":-hTC3b*;QE`l=TA7\\,>DKKH14',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B1,q6T7o`,K756hm<'*TM8OQ!&3^uFt;FO8U:K'ha8P`)B0J54E"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfocurrYLBTop)= A":-hTC3b*;QE`l(&<,Z_;=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr+3B0)j<CoSI0fifeEcP;]Bk1dBASuU$E]Zck8OQ!&3]g5.9MeM`8Q88W:-(*`3r"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfocurrYLBBottom)= A":-hTC3b*;QE`l(&6>psfDf%R;8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(6h2*4<.8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B0KT"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfomaskSelectLef)= A":-hTC3c/;HCK\"e\\ARfgUAS-$G=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0KW*,;b9q[:JNr-2D@3_<CoSI0fhct4%E:B6q&jl7T)<G78-NR;b9q[:JNr)/i>CG"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfomaskSelectRig)= A":-hTC3c/;HCK\"e\\ARfg[BkM+$4',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B3&WWU7o`,K756hm;EIBK8OQ!&3]g5.9MeM`8Q88W:-'s]0KT"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfomaskSelectTop)= A":-hTC3c/;HCK\"e\\ARfg]Df@d>8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(?m4%E:B6q&gk7T;H><CoSI1-.Kp78-NR;b9q[:JNr.2*1"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfomaskSelectBot)= A":-hTC3c/;HCK\"e\\ARfgKDfg)>D*(fj:-)imFCSuRBlm0[DImW/<+05k6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFmi:et\"]<(Tk\\3]/`O4%E:B6q&gk7RB1,<CoSI1-.Kp78-NR;b9q[:JNr)3r"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfoweightSelectL)= A":-hTC3d5.LB4uBcASbpfFA-7XF?<Pq:-)imFCSuRBlm0[DImW/<+05k6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]&`K4%E:B6q&gk7SGm6<CoSI1-.m&4&SL@:et\"]<(Tk\\3\\W0D1-5"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfoweightSelectR)= A":-hTC3d5.LB4uBcASbpfFAcgcBQQ=;8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(?m2*4<.8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MSq@"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfoweightSelectT)= A":-hTC3d5.LB4uBcASbpfFB!0t4',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B3&Wig<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]/cV"
	SetWindow batchFitPanel#Tab3ContentPanel,userdata(ResizeControlsInfoweightSelectB)= A":-hTC3d5.LB4uBcASbpfF@'nfFDl\"X=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr.1c7?b<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\WV"
	
	/////////////////////////////////
	//////// weight wave setup ///////
	/////////////////////////////////
	Checkbox WMWeightChck win=batchFitPanel#Tab3ContentPanel, title="Use Weighting", fsize=WMBCFBaseFontSize+1, pos={50, 35}, variable=doWeight, proc=WMsetUseMaskWeightCheckBox																			 

	DefineGuide /W=batchFitPanel#Tab3ContentPanel weightSelectLeft={FL, 0.48, FR}
	DefineGuide /W=batchFitPanel#Tab3ContentPanel weightSelectRight={FR, -10}
	DefineGuide /W=batchFitPanel#Tab3ContentPanel weightSelectTop={FT, 15}
	DefineGuide /W=batchFitPanel#Tab3ContentPanel weightSelectBottom={FB, 0}
	NewPanel  /FG=(weightSelectLeft, weightSelectTop, weightSelectRight, weightSelectBottom) /N=weightWavesPanel /Host=batchFitPanel#Tab3ContentPanel 
	ModifyPanel /W=batchFitPanel#Tab3ContentPanel#weightWavesPanel frameStyle=0,frameInset=0

	WMSCSInitOptions("one wave for all;columns in 2D wave;1D waves collection", "weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	WMSCSSetListBoxHeight("weightWaves", listBoxHeight, "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	WMSCSSetListBoxWidth("weightWaves", listBoxWidth, "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	WMSCSCreateSelectorControlSet("batchFitPanel", "Tab3ContentPanel#weightWavesPanel", "weightWaves")	
	WMSCSSetFolder(currDataFolder, "weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	WMSCSSetDisableControl("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", !doWeight*2)
	WMSCSSetTitleStr("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel", "Weight")	
	if (doWeight)
		WMSCSUpdateControlEnableStatus("weightWaves", "batchFitPanel#Tab3ContentPanel#weightWavesPanel")
	endif
	
	/////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////// Tab 4: Fit Range and Mask Waves //////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////	
	
	Wave /T batchWaveNames = packageDFR:WMbatchWaveNames
	TitleBox WMShowYWavesTitle win=batchFitPanel#Tab4ContentPanel, title="Current Y Waves", fixedSize=1, frame=0, pos={5, 160+listBoxHeight}; DelayUpdate
	TitleBox WMShowYWavesTitle win=batchFitPanel#Tab4ContentPanel, size={listBoxWidth, 20}, fsize=WMBCFBaseFontSize+2, fstyle=1, anchor=MC
	ListBox WMShowYWaves,win=batchFitPanel#Tab4ContentPanel,pos={5,160+listBoxHeight+30},size={listBoxWidth, listBoxHeight}, mode=0; DelayUpdate
	ListBox WMShowYWaves,win=batchFitPanel#Tab4ContentPanel,listWave=batchWaveNames, fsize=WMBCFBaseFontSize
	
	DefineGuide /W=batchFitPanel#Tab4ContentPanel currYSideCenter={FT, .5, FB}	
	DefineGuide /W=batchFitPanel#Tab4ContentPanel currYLBTop={currYSideCenter, 10}
	DefineGuide /W=batchFitPanel#Tab4ContentPanel currYLBBottom={FB, 0}
	
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo)= A"!!,?X!!#BZ!!#BP!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzz"
	TitleBox WMShowYWavesTitle,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzzzzz!!!"
	ListBox WMShowYWaves,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo)= A"!!,?X!!#Bi!!#BP!!#A/z!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	ListBox WMShowYWaves,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct@s)g4=\\M.]Df>[Vzzzzzzzz"
	ListBox WMShowYWaves,win=batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct@s)g4=\\M.KDfg)>D#aP9zzzzzzzzzz!!!"
		
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#=[!!#Dh5QF1PJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsGuides)=  "currYSideCenter;currYLBTop;currYLBBottom;maskSelectLeft;maskSelectRight;maskSelectTop;maskSelectBott"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsGuides) +=  "om;weightSelectLeft;weightSelectRight;weightSelectTop;weightSelectBottom;"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfocurrYSideCent)= A":-hTC3b*;QE`l=TA7\\,>DKKH14',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B1,q6T7o`,K756hm<'*TM8OQ!&3^uFt;FO8U:K'ha8P`)B0J54E"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfocurrYLBTop)= A":-hTC3b*;QE`l(&<,Z_;=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr+3B0)j<CoSI0fifeEcP;]Bk1dBASuU$E]Zck8OQ!&3]g5.9MeM`8Q88W:-(*`3r"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfocurrYLBBottom)= A":-hTC3b*;QE`l(&6>psfDf%R;8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(6h2*4<.8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B0KT"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfomaskSelectLef)= A":-hTC3c/;HCK\"e\\ARfgUAS-$G=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0KW*,;b9q[:JNr-2D@3_<CoSI0fhct4%E:B6q&jl7T)<G78-NR;b9q[:JNr)/i>CG"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfomaskSelectRig)= A":-hTC3c/;HCK\"e\\ARfg[BkM+$4',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\WWl:K'ha8P`)B3&WWU7o`,K756hm;EIBK8OQ!&3]g5.9MeM`8Q88W:-'s]0KT"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfomaskSelectTop)= A":-hTC3c/;HCK\"e\\ARfg]Df@d>8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(?m4%E:B6q&gk7T;H><CoSI1-.Kp78-NR;b9q[:JNr.2*1"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfomaskSelectBot)= A":-hTC3c/;HCK\"e\\ARfgKDfg)>D*(fj:-)imFCSuRBlm0[DImW/<+05k6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFmi:et\"]<(Tk\\3]/`O4%E:B6q&gk7RB1,<CoSI1-.Kp78-NR;b9q[:JNr)3r"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfoweightSelectL)= A":-hTC3d5.LB4uBcASbpfFA-7XF?<Pq:-)imFCSuRBlm0[DImW/<+05k6Z6jaASuTd@;]Xm4&f?Z764FiATBk':Jsbf:JOkT9KFjh:et\"]<(Tk\\3]&`K4%E:B6q&gk7SGm6<CoSI1-.m&4&SL@:et\"]<(Tk\\3\\W0D1-5"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfoweightSelectR)= A":-hTC3d5.LB4uBcASbpfFAcgcBQQ=;8PV<U@<?!m7VQs@@;]Xm,?/)\\1.,ttFCf?3:gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(?m2*4<.8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MSq@"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfoweightSelectT)= A":-hTC3d5.LB4uBcASbpfFB!0t4',!K3auN>@q\\>GFAQC`AS`Sj@:CuZDf0Z.DKJ]`DImWG<*<$d3`U64E]Zff;Ft%f:/jMQ3\\`]m:K'ha8P`)B3&Wig<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3]/cV"
	SetWindow batchFitPanel#Tab4ContentPanel,userdata(ResizeControlsInfoweightSelectB)= A":-hTC3d5.LB4uBcASbpfF@'nfFDl\"X=%Q.J@UX@gBLZ]X:gn6QCa2nf@PU;hDKKH-FAQC`ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr.1c7?b<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\WV"

	/////////////////////////////////
	//////// mask wave setup ////////
	/////////////////////////////////
	Checkbox WMMaskChck win=batchFitPanel#Tab4ContentPanel, title="Use Mask Wave(s)", fsize=WMBCFBaseFontSize+1, pos={20, 35}, variable=doMask, proc=WMsetUseMaskWeightCheckBox

	Checkbox WMRangeChck win=batchFitPanel#Tab4ContentPanel, title="Limit Fit Range by Points", fsize=WMBCFBaseFontSize+1, pos={20, 70}, variable=doRange, proc=WMsetRangeLimitCheckBox	
	SetVariable WMminRange win=batchFitPanel#Tab4ContentPanel, title="Range Min Index", fsize=WMBCFBaseFontSize+1, pos={40, 90}, size={185, 20}, value=_NUM:0, disable=2, limits={0, inf, 1}
	SetVariable WMmaxRange win=batchFitPanel#Tab4ContentPanel, title="Range Max Index", fsize=WMBCFBaseFontSize+1, pos={235, 90}, size={185, 20}, value=_NUM:0, disable=2, limits={0, inf, 1}
	
	////////// Display and select Mask Values/Waves //////////
	DefineGuide /W=batchFitPanel#Tab4ContentPanel maskSelectLeft={FL, 0.5, FR}
	DefineGuide /W=batchFitPanel#Tab4ContentPanel maskSelectRight={FR, -10}
	DefineGuide /W=batchFitPanel#Tab4ContentPanel maskSelectTop={FT, 15}
	DefineGuide /W=batchFitPanel#Tab4ContentPanel maskSelectBottom={FB, 0}
	NewPanel  /FG=(maskSelectLeft, maskSelectTop, maskSelectRight, maskSelectBottom) /N=maskWavesPanel /Host=batchFitPanel#Tab4ContentPanel 
	ModifyPanel /W=batchFitPanel#Tab4ContentPanel#maskWavesPanel frameStyle=0,frameInset=0
	
	WMSCSInitOptions("one wave for all;columns in 2D wave;1D waves collection", "maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	WMSCSSetListBoxHeight("maskWaves", listBoxHeight, "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	WMSCSSetListBoxWidth("maskWaves", listBoxWidth, "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	WMSCSCreateSelectorControlSet("batchFitPanel", "Tab4ContentPanel#maskWavesPanel", "maskWaves")	
	WMSCSSetFolder(currDataFolder, "maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	WMSCSSetDisableControl("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", !doMask*2)
	WMSCSSetTitleStr("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel", "Mask")
	if (doMask)
		WMSCSUpdateControlEnableStatus("maskWaves", "batchFitPanel#Tab4ContentPanel#maskWavesPanel")
	endif

	////////////////////////////////////////////////////////////////////////
	////////////// Launch button, global controls and updates ////////////////
	////////////////////////////////////////////////////////////////////////
	ControlInfo /W=batchFitPanel kwBackgroundColor 
	SetVariable batchNameText win=batchFitPanel, pos={10,bottom-top-45}, size={270, 20}, fsize=WMBCFBaseFontSize+1; DelayUpdate
	SetVariable batchNameText win=batchFitPanel, value=packageDFR:WMcurrBatchName, title="Current Batch:", noedit=1, frame=1, valueBackColor=(V_Red, V_Green, V_Blue)
	NVAR haltOnErr = packageDFR:WMhaltOnErr
	Checkbox continueOnErrorCheckBox win=batchFitPanel, title="Halt on Error",size={100,20}, variable=haltOnErr; DelayUpdate
	Checkbox continueOnErrorCheckBox win=batchFitPanel, pos={295,bottom-top-43},fsize=WMBCFBaseFontSize+1
	NVAR doCovar = packageDFR:WMdoCovar
	Checkbox createCovarMatrixCheckBox win=batchFitPanel, title="Gen Covariance Matrix",size={120,20}, variable=doCovar; DelayUpdate
	Checkbox createCovarMatrixCheckBox win=batchFitPanel, pos={405,bottom-top-43},fsize=WMBCFBaseFontSize+1	
	NVAR maxIterations = packageDFR:WMmaxIterations
	SetVariable maxIterationsSetVar win=batchFitPanel, title="Max Iterations",size={150,20}, variable=maxIterations; DelayUpdate
	SetVariable maxIterationsSetVar win=batchFitPanel, pos={575,bottom-top-45},fsize=WMBCFBaseFontSize+1          	
	Button launchBatchRunButton win=batchFitPanel, title="Run Batch Fitting",size={140,20}, Proc=WMLaunchBatchButtonProc; DelayUpdate
	Button launchBatchRunButton win=batchFitPanel, pos={735,bottom-top-45},fsize=WMBCFBaseFontSize+1
	Button helpButton win=batchFitPanel, title="Help",size={70,20}, Proc=WMHelpButtonProc; DelayUpdate
	Button helpButton win=batchFitPanel, pos={805, 3},fsize=WMBCFBaseFontSize+1
	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,A.!!#CsJ,hrl!!#<Xz!!#](Aon#azzzzzzzzzzzzzz!!#](Aon\"Qzz"
	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,HNJ,htJ!!#@(!!#<@z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	CheckBox createCovarMatrixCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,I0J,htJ!!#A,!!#<@z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	CheckBox createCovarMatrixCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox createCovarMatrixCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,Iu^]6b4J,hqP!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,JH^]6b4J,hqF!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,JZ5QF&7!!#?E!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"			
	
//	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,CT!!#CsJ,hs!!!#<Xz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
//	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
//	SetVariable batchNameText, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"		
//	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,HbJ,htJ!!#@(!!#<@z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
//	CheckBox continueOnErrorCheckBox, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"	
//	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,IIJ,htIJ,hqP!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
//	SetVariable maxIterationsSetVar, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"	
//	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,J,!!#CsJ,hop!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
//	Button helpButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"	
//	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo)= A"!!,JBJ,htIJ,hqK!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
//	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
//	Button launchBatchRunButton, win=batchFitPanel, userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"	
	
	ControlInfo /W=batchFitPanel#Tab0ContentPanel currentBatchRunsLB 
	if (DimSize(batchRunsSummary, 0) && V_Value >=0)
		WMLoadBatch(batchRunsSummary[V_Value][0])
	endif
	
	BatchFitSetTabControlContent(0)
	WMUpdateBatchControlPanel()
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Main Function /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

// Not the simplest function - apologies for not being terribly readible.
// 	Some key variables:
//		- currWave carries the current wave that contains the Y values.  It could also contain the X values if x values are specified via XY pairs
//		- MW[X|Y]ValuesUtilityWave contain copies of current columns of 2D or XY waves used in the batch.  When appropriate each call of curveFit uses these as input
// 		- currWaveName has the name of the wave to be used as Y values for curve fit  May get the name of currWave, or it may have the name of MWYValuesUtilityWave
//		- xWaveStr is the equivalent to currWaveName but it holds the "/X=" portion of the "/X=[wave name]" curveFit flag

Function WMLaunchBatchCurveFit(batchFolder, batchName, fitFunc, batchWaves, yValsSourceType, batchXWaves, xValsSourceType, maskWaves, maskSourceType, weightWaves, weightSourceType,  coefWave, coefHold, coefConstr, coefStyle, nInCoefs, xoffset, epsilonWaveName, [haltOnErr, maxIter, doRange, minRange, maxRange, doCovar])
	String batchFolder
	String batchName
	String fitFunc
	WAVE /Z/WAVE batchWaves
	Variable yValsSourceType
	WAVE /Z/WAVE batchXWaves
	Variable xValsSourceType
	WAVE /Z/WAVE maskWaves
	Variable maskSourceType
	WAVE /Z/WAVE weightWaves
	Variable weightSourceType
	WAVE coefWave, coefHold
	WAVE /Z/T coefConstr			// a wave of constraints in the form described in DisplayHelpTopic "Fitting With Constraints": not error checked here!  
	Variable coefStyle
	Variable nInCoefs
	Variable xoffset
	String epsilonWaveName
	Variable haltOnErr
	Variable maxIter
	// Added post 6.30 release
	Variable doRange	
	Variable minRange
	Variable maxRange
	// Added post 6.34 release
	Variable doCovar
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR(doInitialization=1)
	DFREF batchDataDFR = $batchFolder	
	
	DFREF batchOutDFR = getBatchFolderDFR(batchFolder, batchName)

	String packageDFRString = GetDataFolder(1, packageDFR)
	String batchDataDirDFRString = GetDataFolder(1, batchDataDFR)
	String batchOutDirDFRString = GetDataFolder(1, batchOutDFR)
	
	//// Store batch data - do not store if this has been done already by the UI or if the caller doesn't want it for some other reason 
	STRUCT batchDataStruct batchInfo
//	initBatchDataStruct(batchInfo)
	
	batchInfo.batchDir = batchFolder
	Wave /Z batchInfo.coefWave = coefWave
	Wave /Z batchInfo.coefHold = coefHold
	Wave /T/Z batchInfo.constraintsTextWave = coefConstr		
	batchInfo.yValsSourceType = yValsSourceType
	batchInfo.xValsSourceType = xValsSourceType
	batchInfo.maskSourceType = maskSourceType
	batchInfo.weightSourceType = weightSourceType
	batchInfo.coefStyle = coefStyle
	batchInfo.fitFunc = fitFunc
	batchInfo.nInCoefs = nInCoefs
	batchInfo.xoffset = xoffset
	Wave /Z batchInfo.epsilon = $epsilonWaveName
	batchInfo.haltOnErr = haltOnErr
	batchInfo.maxIter = maxIter
	batchInfo.doRange = doRange
	batchInfo.minRange = minRange
	batchInfo.maxRange = maxRange
	batchInfo.doCovar = doCovar
	WMStoreBatchData(batchInfo, batchName, yWaves=batchWaves, xWaves=batchXWaves, maskWaves=maskWaves, weightWaves=weightWaves)		
	
	Variable nWaves =0
	Variable isXY = (xValsSourceType & WMconstXyPairsInput)/WMconstXyPairsInput
	Variable is2D = (yValsSourceType & WMconstSingle2DInput)/WMconstSingle2DInput
	if (is2D)
		WAVE currWave2D = batchWaves[0]
		nWaves = floor(DimSize(currWave2D, 1)/(1+isXY))
	else
		nWaves = DimSize(batchWaves, 0)
	endif

	//// Get fit function status
	updateFitFunctions()
	Variable isUserFitFuncVar = isUserFitFunc(fitFunc)
	WAVE nInArgsHash = packageDFR:nInputArgsHash	
	Variable iType = FindDimLabel(nInArgsHash, 0, fitFunc)
	String fitFuncBase = fitFunc
	if (numtype(nInArgsHash[iType])==2 && !isUserFitFuncVar)
		fitFunc = fitFunc + " " + num2str(nInCoefs)
	endif
		
	// check mask and weight waves
	Variable nMaskWaves=0, nWeightWaves=0, is2DMask=0, is2Dweight=0
	switch (maskSourceType)
		case WMconstCommonWaveInput:
			nMaskWaves = 1
			break
		case WMconstSingle2DInput:
			nMaskWaves = 1
			is2DMask = 1
			break
		case WMconstCollection1DInput:
			nMaskWaves = nWaves
			break
		default: 
			break
	endswitch
	switch (weightSourceType)
		case WMconstCommonWaveInput:
			nWeightWaves = 1
			break
		case WMconstSingle2DInput:
			nWeightWaves = 1
			is2Dweight = 1
			break
		case WMconstCollection1DInput:
			nWeightWaves = nWaves
			break
		default: 
			break
	endswitch
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////// Pre-launch Error checking ////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	if (!ParamIsDefault(doRange) && doRange && ((!ParamIsDefault(minRange) && numtype(minRange)!=2) || (!ParamIsDefault(maxRange) && numtype(maxRange)!=2)))
		doRange=1
		
		if (ParamIsDefault(minRange) || numtype(minRange)==2)
			minRange = 0
		endif		
		if (ParamIsDefault(maxRange) || numtype(maxRange)==2)
			maxRange = inf
		endif
		
		if (maxRange<=minRange)
			DoAlert /T="Range Index Error" 0, "Batch Curve Fit did not launch because of a range index error.\n\rThe minimum range index is >= to the maximum range index.\n\r"
		
			CleanUpUtilityVars(batchOutDirDFRString)
			return constIndexOutOfRange
		endif
	else 	
		doRange=0
	endif
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////// check the existence of all required waves //////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	String errmsg = ""
	Variable preLaunchErrors = 0	
//	String E

	if (!WaveExists(batchWaves) || !DimSize(batchWaves, 0))
		preLaunchErrors = preLaunchErrors | constNoYWave
		errmsg += "The Y wave(s) do not exist or are size 0\n\r"
	endif
	if ((xValsSourceType != WMconstXyPairsInput && xValsSourceType != WMconstWaveScalingInput &&  xValsSourceType != 0) && (!WaveExists(batchXWaves) || !DimSize(batchXWaves, 0)))
		preLaunchErrors = preLaunchErrors | constNoXWave
		errmsg += "X wave(s) are required but do not exist or are size 0\n\r"
	endif
	if (maskSourceType && (!WaveExists(maskWaves) || !DimSize(maskWaves, 0)))
		preLaunchErrors = preLaunchErrors | constNoMaskWave
		errmsg += "Masking wave(s) are selected but do not exist or are size 0\n\r"
	endif
	if (weightSourceType && (!WaveExists(weightWaves) || !DimSize(weightWaves, 0)))
		preLaunchErrors = preLaunchErrors | constNoWeightWave
		errmsg += "Weighting wave(s) are selected but do not exist or are size 0\n\r"	
	endif
	if (waveExists(coefConstr) && (!CmpStr(fitFunc,"line") || !CmpStr(fitFunc,"poly") || !CmpStr(fitFunc, "poly2D")) && dimsize(coefConstr, 0)>0)		// constraints misapplied to constraint-less fit func
		preLaunchErrors = preLaunchErrors | constConstrLineOrPoly
		errmsg += "Constraints illegally applied to the built-in line or poly fit function. Use User Fit Funcs to apply constraints to these functions.\n\r"
	endif
	
	if (preLaunchErrors)
		DoAlert /T="Non-existing, bad or 0-dimension wave(s)" 0, "Batch Curve Fit did not launch due to errors \n\r"+errmsg
		
		CleanUpUtilityVars(batchOutDirDFRString)
		return preLaunchErrors
	endif	
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	///////////////// check dimensional compatibility of all waves before starting //////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	errmsg = checkDimensionalCompatibility(batchWaves, batchXWaves, yValsSourceType, xValsSourceType)
	if (nMaskWaves)
		errmsg += checkDimensionalCompatibility(batchWaves, maskWaves, yValsSourceType, maskSourceType)
	endif
	if (nWeightWaves)
		errmsg += checkDimensionalCompatibility(batchWaves, weightWaves, yValsSourceType, weightSourceType)	
	endif
	
	if (coefStyle==WMcoefStylePerFitWave)
		if (dimsize(coefWave, 1) != nWaves)
			errmsg += "Number of cols in the coefficient wave ("+num2str(dimsize(coefWave,1))+") does not equal number of fits ("+num2str(nWaves)+")\r"
		endif
	endif
	if (DimSize(coefWave,0) != nInCoefs)
		errmsg += "Number of rows in the coefficient wave ("+num2str(dimsize(coefWave,0))+") does not equal number of coefficients ("+num2str(nInCoefs)+")\r"
	endif
	if (waveExists(coefConstr) && (dimSize(coefConstr, 1)!=0 && dimSize(coefConstr, 1)!=1 && dimSize(coefConstr, 1) != nWaves))
		errmsg += "Number of columns in the constraints text ("+num2str(dimSize(coefConstr, 1))+") wave must be 0 or 1 for same constraints for all fits, or must have columns equal the number of fits ("+num2str(nWaves)+")\r"
	endif
	
	if (strlen(errmsg))
		if (strlen(errmsg)>200)
			errmsg = errmsg[0,197]+"..."
		endif
	
		DoAlert /T="Batch Fit Wave Size Mismatch Error" 0, "Batch Curve Fit did not launch due to errors \n\r"+errmsg
		
		CleanUpUtilityVars(batchOutDirDFRString)
		return constWaveDimMismatch
	endif
	/////////////////////////////// end pre-launch error checking /////////////////////////////////////////
		
	Variable i, j, lastSuccessfuli=-1
	// output the fit coefficients as well as chi2 and sigma
	Variable nOutCoefs = nInCoefs*2+1
	Variable isXOffset = 0, isLine = 0
	if (!cmpStr(fitFuncBase, "line"))
		nOutCoefs += 2
		isLine = 1
	endif
	if (stringmatch(fitFuncBase, "*xoffset*"))
		nOutCoefs += 1
		isXOffset = 1
	endif

	Make /O/D/N=(nWaves, nOutCoefs) batchOutDFR:WMBatchResultsMatrix
	WAVE resultsMatrix = batchOutDFR:WMBatchResultsMatrix
	KillWaves /Z batchOutDFR:WMM_CovarMatrix, batchOutDFR:M_Covar
	if (doCovar)
		Make /O/D/N=(nInCoefs, nInCoefs, nWaves) batchOutDFR:WMM_CovarMatrix
		WAVE covarMatrix = batchOutDFR:WMM_CovarMatrix
	endif

	////// Set output dimension labels
	Wave /T coefNames = GetCoefNames(fitFuncBase, nInCoefs)
	String currCoef
	for (i=0; i<nInCoefs; i+=1)
		if (numpnts(coefNames)>i)
			currCoef = coefNames[i]
		else
			currCoef = "K"+num2str(i)
		endif
		setDimLabel 1, i, $(currCoef), resultsMatrix
	endfor
	SetDimLabel 1, nInCoefs, Chi2, resultsMatrix 
	for (i=1; i<=nInCoefs; i+=1)
		if (numpnts(coefNames)>i-1)
			currCoef = coefNames[i-1]
		else
			currCoef = "K"+num2str(i)
		endif
		setDimLabel 1, nInCoefs+i, $(currCoef+" Sigma"), resultsMatrix
	endfor
	
	if (isLine) 
		SetDimLabel 1, nInCoefs*2+1, R2, resultsMatrix 
		SetDimLabel 1, nInCoefs*2+2, PearsonsR, resultsMatrix 
	endif
	if (isXOffset)
		SetDimLabel 1, nInCoefs*2+1+2*isLine, XOffset, resultsMatrix 
	endif
	
	////// input waves - wipe out old values and set the references here
	Make /O/D/N=(nInCoefs) batchOutDFR:WMcurrCoefs
	WAVE currCoefs = batchOutDFR:WMcurrCoefs
	Make /O/D/N=0 batchOutDFR:WMYValsUtilityWave
	WAVE WMYValsUtilityWave = batchOutDFR:WMYValsUtilityWave
	Make /O/D/N=0 batchOutDFR:WMXValsUtilityWave
	WAVE WMXValsUtilityWave = batchOutDFR:WMXValsUtilityWave
	Make /O/N=0 batchOutDFR:WMMaskValsUtilityWave
	WAVE WMMaskValsUtilityWave = batchOutDFR:WMMaskValsUtilityWave
	Make /O/D/N=0 batchOutDFR:WMWeightValsUtilityWave
	WAVE WMWeightValsUtilityWave = batchOutDFR:WMWeightValsUtilityWave	
	
	///// get the maximum wave size
	Variable maxSize = 0
	if (is2D)
		maxSize = DimSize(batchWaves[0],0)
	else
		for(i=0; i<nWaves; i+=1)
			maxSize = DimSize(batchWaves[i],0) > maxSize ? DimSize(batchWaves[i],0) : maxSize
		endfor
	endif
	
	/////// output waves
	Make /O/D/N=(maxSize, nWaves) batchOutDFR:WMBatchResultsResiduals
	WAVE WMBatchResultsResiduals = batchOutDFR:WMBatchResultsResiduals
	Make /O/N=(nWaves) batchOutDFR:WMBatchResultsNptsInWave
	WAVE WMBatchResultsNptsInWave = batchOutDFR:WMBatchResultsNptsInWave
	Make /O/D/N=0 batchOutDFR:WMResidualsUtilityWave
	WAVE WMResidualsUtilityWave=batchOutDFR:WMResidualsUtilityWave       
	Make /T/O/N=(nWaves) batchOutDFR:WMBatchResultsErrorWave
	WAVE /T WMBatchResultsErrorWave=batchOutDFR:WMBatchResultsErrorWave
	 	 
	/////// utility strings       
	String cmd
	String currWaveName
	String xWaveStr
	String holdStr
	String rowLabel
	
	////////// apply some batch run settings
	if (!ParamIsDefault(maxIter))
		Variable /G batchOutDFR:V_FitMaxIters = maxIter
	else
		KillVariables /Z V_FitMaxIters   // make sure there is no residual V_FitMaxIters set, otherwise it'll get used!
	endif
	if (ParamIsDefault(haltOnErr))
		haltOnErr=1		
	endif
	
	Variable curveFitError = 0
	
	/////// set up progress window ////////
	String /G batchOutDFR:WMBatchRunTotalErrs=""
	SVAR WMBatchRunTotalErrs = batchOutDFR:WMBatchRunTotalErrs
	Variable rL=285, rT=111, rW=553, rH=82
	if (strlen(WinList("batchFitPanel", ";", "WIN:64")))
		GetWindow batchFitPanel wsize
		rT=V_top+(V_bottom-V_top-rT)/2
		rL=V_left+(V_right-V_left-rW)/2
	endif
	NewPanel /K=1 /N=ProgressPanel /W=(rL,rT,rL+rW,rt+rH)
	ValDisplay valdisp0,pos={18,32},size={282,18},limits={0,nWaves,0},barmisc={0,0}, value=_NUM:0, mode=3
	Button bStop, pos={315,32}, size={110,20}, title="Halt Batch Run"
	//////////////////////////////////////
	
	for(i=0; i<nWaves; i+=1) 
		/////// update progress window ///////
		ValDisplay valdisp0, value=_NUM:i+1
		DoUpdate /W=ProgressPanel /E=1
		if (V_Flag==2)
			////// Fill in results matrix and error wave instead of redimensioning
		 	resultsMatrix[i,nWaves][]=NaN
		 	covarMatrix[][][i,nWaves] = NaN
		 	WMBatchResultsErrorWave[i,nWaves]="Batch terminated prior to this fit"
			WMBatchResultsResiduals[][i,nWaves]=NaN
			break		
		endif
		//////////////////////////////////////
		
		/////////// hold info in a string ////////////
		holdStr = "/H=\""
		switch (coefStyle)
			case WMcoefStyleOneForAll:
				if (WaveExists(coefWave))
					currCoefs = coefWave[p]
				else
					currCoefs = NaN
				endif
				for(j=0; j<nInCoefs; j+=1)
					holdStr += num2str(!!coefHold[j])  
				endfor
				break
			case WMcoefStyleLastGood:
				if (lastSuccessfuli<0)
					if (WaveExists(coefWave))
						currCoefs = coefWave[p]
					else
						currCoefs = NaN
					endif
				else
					currCoefs = resultsMatrix[lastSuccessfuli][p]
				endif
				for(j=0; j<nInCoefs; j+=1)
					holdStr += num2str(!!coefHold[j]) 
				endfor
				break
			
			case WMcoefStylePerFitWave:	
				if (WaveExists(coefWave))
					currCoefs = coefWave[p][i]	// if there's a dimension mismatch it will have been caught above: see the errmsg String
				else
					currCoefs = NaN
				endif
				for(j=0; j<nInCoefs; j+=1)
					holdStr += num2str(!!coefHold[j]) 
				endfor				
				break
			default:
				break
		endswitch
		holdstr+="\""
		////////////////////////////////////////////
		
		String savedDataFolder = GetDataFolder(1)
		SetDataFolder batchOutDirDFRString 

		///////////// set up input wave /////////////
		if (is2D)     
			WAVE currWave2D = batchWaves[0]
			Redimension /N=(DimSize(currWave2D,0)) WMResidualsUtilityWave
			Duplicate /O/R=[0, DimSize(currWave2D,0)][i+(i+1)*isXY, i+(i+1)*isXY] currWave2D batchOutDFR:WMYValsUtilityWave
			Redimension /N=(DimSize(currWave2D,0)) WMYValsUtilityWave		
			rowLabel = NameOfWave(currWave2D)+"["+num2str(i+(i+1)*isXY)+"]"
			currWaveName = GetWavesDataFolder(WMYValsUtilityWave, 2)
			WAVE currWave = WMYValsUtilityWave			
		elseif (isXY)   // each wave is a 2 column pair - separate these pairs out.  Do Y wave 
			WAVE currWave = batchWaves[i]
			Redimension /N=(DimSize(currWave,0)) WMYValsUtilityWave, WMResidualsUtilityWave
			rowLabel = nameOfWave(currWave)
			WMYValsUtilityWave = currWave[p][1]
			currWaveName = GetWavesDataFolder(WMYValsUtilityWave, 2)
		else
			WAVE currWave = batchWaves[i]
			Redimension /N=(DimSize(currWave,0)) WMResidualsUtilityWave
			rowLabel = nameOfWave(currWave)
			Duplicate /O currWave batchOutDFR:WMYValsUtilityWave
			currWaveName = GetWavesDataFolder(WMYValsUtilityWave, 2)
		endif
	
		////////////// set up x wave //////////////
		switch (xValsSourceType)
			case WMconstWaveScalingInput:
				xWaveStr = ""
				break
			case WMconstCommonWaveInput:
				sprintf xWaveStr, "/X=%s", GetWavesDataFolder(batchXWaves[0], 2)
				break
			case WMconstXyPairsInput:
				Redimension /N=(DimSize(currWave,0)) WMXValsUtilityWave
				if (is2D)
					WMXValsUtilityWave = currWave2D[p][i*2]
				else
					WMXValsUtilityWave = currWave[p][0]		
				endif
				sprintf xWaveStr, "/X=%s",GetWavesDataFolder(WMXValsUtilityWave, 2)
				break		
			case WMconstSingle2DInput:
				WAVE batchXWave2D = batchXWaves[0]
				Redimension /N=(DimSize(batchXWave2D,0)) WMXValsUtilityWave
				WMXValsUtilityWave = batchXWave2D[p][i]
				sprintf xWaveStr, "/X=%s", GetWavesDataFolder(WMXValsUtilityWave, 2)
				break
			case WMconstCollection1DInput:
				sprintf xWaveStr, "/X=%s", GetWavesDataFolder(batchXWaves[i], 2)
				break
			default:
				break
		endswitch

		String flags=holdstr
		String flagParams=""
		sprintf flagParams "/R=WMResidualsUtilityWave"

		if (numtype(xoffset)!=2 && stringmatch(fitFunc, "*xoffset*"))
			flags += " /K={"+num2str(xoffset)+"}"
		endif
		
		if (doCovar)
			flags += " /M=2"
		endif
		
		if (waveExists(coefConstr) && dimSize(coefConstr,0)>0)		
			if (dimSize(coefConstr, 1)==0 || dimSize(coefConstr, 1)==1)
				flagParams += " /C="+NameOfWave(coefConstr)
			else			// columns vs nWaves dimension mismatch should have been caught in error checking above
				Duplicate /O/T/R=[][i] coefConstr batchOutDFR:WMConstraintUtiltiyWave
				
				// clean out blank constraints
				WAVE /T currConstrWave = batchOutDFR:WMConstraintUtiltiyWave
				Variable iConstr=0
				do 			
					if (iConstr >= dimSize(currConstrWave,0))
						break
					endif
					
					if (strlen(currConstrWave[iConstr])<=0)
						DeletePoints /M=0 iConstr, 1, currConstrWave
					else
						iConstr += 1
					endif
				while(1)
				
				// if there's any left, add /C command to the flagParams string
				if (iConstr>0)
					flagParams += " /C="+batchOutDirDFRString+"WMConstraintUtiltiyWave"
				endif
			endif
		endif
		
	      if (nMaskWaves==1)
			WAVE maskWave2D = maskWaves[0]
			Redimension /N=(DimSize(maskWave2D,0)) WMMaskValsUtilityWave
			WMMaskValsUtilityWave = maskWave2D[p][i*is2DMask]
			sprintf flagParams, "%s /M=%s", flagParams, GetWavesDataFolder(WMMaskValsUtilityWave, 2)	
		elseif (nMaskWaves > 1)
			sprintf flagParams, "%s /M=%s", flagParams, GetWavesDataFolder(maskWaves[i], 2)
		endif
		if (nWeightWaves==1)
			WAVE weightWave2D = weightWaves[0]
			Redimension /N=(DimSize(weightWave2D,0)) WMWeightValsUtilityWave
			WMWeightValsUtilityWave = weightWave2D[p][i*is2DWeight]
			sprintf flagParams, "%s /W=%s /I", flagParams, GetWavesDataFolder(WMWeightValsUtilityWave, 2)
		elseif (nWeightWaves > 1)
			sprintf flagParams, "%s /W=%s /I", flagParams, GetWavesDataFolder(weightWaves[i], 2)
		endif
			
		// set/re-set the V_FitError, V_FitQuitReason variable.  current data folder should be the batch data folder
		Variable /G batchOutDFR:V_FitQuitReason=0
		Variable /G batchOutDFR:V_FitError=0
		NVAR V_FitQuitReason = batchOutDFR:V_FitQuitReason
		NVAR V_FitError = batchOutDFR:V_FitError
		Variable runtimeUserFitError=0
		Variable executeError=0
		
		///////////// range limits string and testing//////////////	
		Wave currWaveNameWR = $currWaveName
		String rangeStr="" 
		
		if (doRange)
			rangeStr = "["+num2str(minRange)+","
			if (!numtype(maxRange))
				rangeStr += num2str(maxRange)+"]"
			else
				rangeStr += "*]"
			endif
			
			Wave currYVals = $currWaveName
			if (minRange >= dimsize(currYVals, 0)) 
				runtimeUserFitError = runtimeUserFitError | constIndexOutOfRange
			endif
		endif
		////////////////////////////////////////////
		
		if (!isUserFitFuncVar && !runtimeUserFitError)
			sprintf cmd, "CurveFit /W=2/Q %s %s, kwCWave=WMcurrCoefs, %s%s %s  %s", flags, fitFunc, currWaveName, rangeStr, xWaveStr, flagParams
			
			Execute /Z cmd
			if (V_Flag)
				executeError = V_Flag
			endif
		elseif (!runtimeUserFitError)
			for (j=0; j<nInCoefs; j+=1)
				if (numtype(currCoefs[j])==2)
					runtimeUserFitError = runtimeUserFitError | constNoInitOnUserFunc
				endif
			endfor 
			
			if (waveExists($epsilonWaveName))
				sprintf flagParams, "%s /E=%s", flagParams,  GetWavesDataFolder($epsilonWaveName, 2)
			endif
						
			sprintf cmd, "FuncFit /W=2/Q %s ProcGlobal#%s, WMcurrCoefs, %s%s %s %s", flags, fitFunc, currWaveName, rangeStr, xWaveStr, flagParams
					
			Execute /Z cmd
			if (V_Flag)
				executeError = V_Flag
			endif
		endif
		
		// capture curve fit errors, pop up a dialog that will ask if the user wants to continue or halt
		// in either case, put the error message in a text in the data directory? in the package directory?  
		curveFitError = 0
		if (V_FitError || V_FitQuitReason || runtimeUserFitError)
			////// don't put a titlebox in the progress panel unless there's been an error.  Here's the check to see if this is the first error //////
			if (!strlen(WMBatchRunTotalErrs))
				TitleBox progressErrors, win=ProgressPanel, fsize=11, pos={18, 57}, size={517, 13}, Variable=WMBatchRunTotalErrs
			endif
		
			WMBatchResultsErrorWave[i] = WMGenFitErrorStr(V_FitError, V_FitQuitReason, runtimeUserFitError, executeError, "batch "+num2str(i))
			WMBatchRunTotalErrs += WMBatchResultsErrorWave[i]
			curveFitError = 1 + haltOnErr
			 
			///// update the progress panel
			ControlUpdate /W=ProgressPanel progressErrors
			ControlInfo /W=ProgressPanel progressErrors
			GetWindow ProgressPanel, wsize	
			MoveWindow /W=ProgressPanel V_left, V_top, V_right, V_top+rH+V_Height 
		else
			WMBatchResultsErrorWave[i] = "Fit converged sucessfully"
		endif

		if (curveFitError>=2)
			DoAlert /T="Batch Curve Fit Error" 0, WMBatchResultsErrorWave[i]
			KillWindow ProgressPanel
			CleanUpUtilityVars(batchOutDirDFRString)
			return 1
		elseif (curveFitError==1 && V_FitQuitReason != 1)
			resultsMatrix[i][0,nInCoefs -1] = NaN	
			resultsMatrix[i][nInCoefs ] = NaN
			resultsMatrix[i][nInCoefs+1, nInCoefs*2] = NaN
			if (doCovar)
				covarMatrix[][][i] = NaN
			endif
			
			if (isLine)
				resultsMatrix[i][nInCoefs*2+1] = NaN
				resultsMatrix[i][nInCoefs*2+2] = NaN
			endif
			if (isXOffset)
				resultsMatrix[i][nInCoefs*2+1+2*isLine] = NaN
			endif
			
			Wave currWave = $currWaveName
			WMBatchResultsNptsInWave[i] = DimSize(currWave, 0)
			WMBatchResultsResiduals[0,WMBatchResultsNptsInWave[i]-1][i] =  NaN
		else
			NVAR /Z V_Pr_local = batchOutDFR:V_Pr, V_r2_local = batchOutDFR:V_r2
			NVAR V_chisq_local = batchOutDFR:V_chisq
			WAVE W_sigma = batchOutDFR:W_sigma
			if (doCovar)
				if (!isUserFitFuncVar && isLine)
					Make /O/N=(2,2) batchOutDFR:M_Covar
					WAVE M_Covar = batchOutDFR:M_Covar
					
					NVAR /Z V_Rab = batchOutDFR:V_Rab
					if (NVAR_Exists(V_Rab))
						M_Covar[1][0] = V_Rab*W_sigma[0]*W_sigma[1]
						M_Covar[0][1] = M_Covar[1][0]
					endif
					M_Covar[0][0] = W_sigma[0]^2
					M_Covar[1][1] = W_sigma[1]^2
				else
					WAVE M_Covar = batchOutDFR:M_Covar
				endif
			endif
			WAVE /Z W_fitConstants = batchOutDFR:W_fitConstants
		
			/// DevNote determine a standard for "successful" to set lastSuccessfuli
			if (V_FitQuitReason != 1)
				lastSuccessfuli = i    
			endif
			
			resultsMatrix[i][0,nInCoefs -1] = currCoefs[q]		
			resultsMatrix[i][nInCoefs] = V_chisq_local
			resultsMatrix[i][nInCoefs+1, nInCoefs*2] = W_sigma[q-nInCoefs-1]
			
			if (doCovar)
				covarMatrix[][][i] = M_Covar[p][q]
			endif
			
			if (isLine)
				resultsMatrix[i][nInCoefs*2+1] = V_r2_local
				resultsMatrix[i][nInCoefs*2+2] = V_Pr_local
			endif
			if (isXOffset)
				resultsMatrix[i][nInCoefs*2+1+2*isLine] = W_fitConstants[0]
			endif
			SetDimLabel 0, i, $(rowLabel), resultsMatrix 
			
			Wave currWave = $currWaveName
			WMBatchResultsNptsInWave[i] = DimSize(currWave, 0)
			WAVE resultsUtility = $(batchOutDirDFRString+"WMResidualsUtilityWave")
			WMBatchResultsResiduals[0,WMBatchResultsNptsInWave[i]-1][i] =  resultsUtility[p]
		endif
		
		SetDataFolder savedDataFolder
	endfor
	
	KillWindow ProgressPanel
	
	//////// clean up some variables /////////
	CleanUpUtilityVars(batchOutDirDFRString)
	return 0
End

Function CleanUpUtilityVars(folderName)
	String folderName
	
	String savedDataFolder = GetDataFolder(1)
	SetDataFolder folderName 
	
	String allWavesStr = WaveList("*Utility*", ";", "")
	
	Variable i
	for(i=0; i<ItemsInList(allWavesStr); i+=1)
		KillWaves /Z $(StringFromList(i, allWavesStr))	
	endfor
	
	SetDataFolder savedDataFolder	
End

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// Error Checking /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

////// will create an alert dialog that will either stop the batch or continue.  In either case the error reason will
////// be stored in the current data directory.  Presumably that is the batch data directory or package data directory
Function /S WMGenFitErrorStr(V_FitError, V_FitQuitReason, V_BatchError, V_ExecuteError, S_RunID)
	Variable V_FitError, V_FitQuitReason, V_BatchError, V_ExecuteError
	String S_RunID
	
	String ErrorStr = "Error on "+S_RunID+": "
	
	if (V_BatchError & constNoInitOnUserFunc)
		ErrorStr += "No initial coefficient values for user defined fit function\n\r"
	endif
	if (V_BatchError & constIndexOutOfRange)
		ErrorStr += "Index out of range\n\r"
	endif	
	
	if (V_FitError & 2)
		ErrorStr += "Singular Matrix Error\n\r"
	endif
	if (V_FitError & 4)
		ErrorStr += "Out of Memory\n\r"
	endif
	if (V_FitError & 8)
		ErrorStr += "Function returned NaN or INF\n\r"
	endif
	if (V_FitError & 16)
		ErrorStr += "Fit function requested stop\n\r"
	endif
	if (V_FitError & 32)
		ErrorStr += "Reentrant curve fitting - more than 1 curve fit executing simultaneously\n\r"
	endif
	
	if (V_FitQuitReason == 1)
		ErrorStr += "The iteration limit was reached\n\r"
	endif
	if (V_FitQuitReason == 2)
		ErrorStr += "User stopped the fit\n\r"
	endif
	if (V_FitQuitReason == 3)
		ErrorStr += "Limit of passes without decreasing chi-square was reached\n\r"
	endif
	
	if (V_ExecuteError)
		ErrorStr += GetErrMessage(V_ExecuteError)+"\n\r"
	endif
	
	return ErrorStr
End

////// return an empty string if no error.  If there's an error return an error string //////
////// If a mask or weight wave is included, do the check for the 
Function /S checkDimensionalCompatibility(yVals, xVals, yValsSourceType, xValsSourceType)
	Wave /WAVE yvals
	Wave /Z /Wave xvals
	Variable yValsSourceType, xValsSourceType
	
	Variable ret = 0
	String ErrMsg = ""
	
	if (xValsSourceType & WMconstWaveScalingInput)
		return ""
	endif
	
	Variable nYVals, nYVals2, nXVals, nXVals2, nMaskVals, nMaskVals2, nWeightVals, nWeightVals2, i	
	
	if (yValsSourceType & WMconstSingle2DInput)
		Wave wave2D = yVals[0]
		nYVals = floor(DimSize(wave2D, 1) / (1 + (WMconstXyPairsInput & xValsSourceType)/WMconstXyPairsInput))
		nYVals2 = DimSize(wave2D, 0)
		switch (xValsSourceType)
			case WMconstCommonWaveInput:
				nXVals = DimSize(xVals[0], 0)
				if (nYVals2 != nXVals)
					ret=0
					ErrMsg += "Error: Number of pts -"+num2str(nXVals)+"- in common X Wave "+NameOfWave(xVals[0])+" does not match "
					ErrMsg += "the number of rows -"+num2str(nYVals)+"-in "+NameOfWave(wave2D)+"\n\r"
				elseif (DimSize(xVals[0], 1) > 0)
					ErrMsg += "Error: curvefit requires 1D waves. "+NameOfWave(xVals[0])+" is 2D or greater."					
				endif
				break
			case WMconstXyPairsInput:
				if (nYVals==0 || nYVals==1)
					ret=0
					ErrMsg += "Error: Wave "+NameOfWave(yVals[0])+" contains 0 or 1 columns: too few for xypairs "
				elseif (!mod(nYVals, 2)==0)
					ErrMsg += "Warning: Wave "+NameOfWave(yVals[0])+" contains an odd number of columns, which is unexpected for xy pairs.  The final column will be ignored"
				endif
				break		
			case WMconstSingle2DInput:
				nXVals = DimSize(xVals[0], 1)
				nXVals2 = DimSize(xVals[0], 0)
				if (nXVals2 != nYVals2)
					ret=0
					ErrMsg += "Error: Number of rows - "+num2Str(nYVals2)+" - in Y wave "+NameOfWave(wave2D)+" does not equal the "
					ErrMsg += "number of rows - "+num2Str(nXVals2)+" - in the X wave "+NameOfWave(xVals[0])+"\n\r"
				endif
				if (nXVals != nYVals)
					ret=0
					ErrMsg += "Error: Number of columns - "+num2Str(nYVals)+" - in Y wave "+NameOfWave(wave2D)+" does not equal the "
					ErrMsg += "number of columns - "+num2Str(nXVals)+" - in the X wave "+NameOfWave(xVals[0])+"\n\r"
				endif
				break
			case WMconstCollection1DInput:
				nXVals = DimSize(xVals,0)
				if (nXVals != nYVals)
					ret=0
					ErrMsg += "Error: Number of columns - "+num2Str(nYVals)+" - in Y wave "+NameOfWave(wave2D)+" does not equal the number - "
					ErrMsg += num2Str(nXVals)+" - of X waves \n\r"
				else
					for (i=0; i<nXVals; i+=1)
						if (DimSize(xVals[i],0) != nYVals2)
							ret=0
							ErrMsg += "Error: Number of rows - "+num2Str(nYVals2)+" - in Y wave "+NameOfWave(wave2D) + " does not equal "
							ErrMsg += "the number of rows - "+num2Str(DimSize(xVals[i],0))+" - in X wave "+NameOfWave(xVals[i])+"\n\r"
						elseif (DimSize(xVals[i], 1) > 0)
							ErrMsg += "Error: curvefit requires 1D waves. "+NameOfWave(xVals[i])+" is 2D or greater."					
						endif
					endfor
				endif
				break
			default:
				break
		endswitch	
	else 
		nYVals = DimSize(yVals,0)
		switch (xValsSourceType)
			case WMconstCommonWaveInput:
				nXVals = DimSize(xVals[0], 0)
				for (i=0; i<nYVals; i+=1)
					if (DimSize(yVals[i],0) != nXVals)
						ret = 0
						ErrMsg += "Error: number of values - "+num2Str(DimSize(yVals[i],0))+" -in Y wave "+NameOfWave(yVals[i])
						ErrMsg += " not equal to the number of values - "+num2str(nXVals)+" - in X wave "+NameOfWave(xVals[0])+"\n\r"
					elseif (DimSize(xVals[0], 1) > 0)
						ErrMsg += "Error: curvefit requires 1D waves. "+NameOfWave(xVals[0])+" is 2D or greater."					
					endif					
				endfor
				break
			case WMconstXyPairsInput:
				for (i=0; i<nYVals; i+=1)
					if (DimSize(yVals[i],1) < 2)
						ret = 0
						ErrMsg += "Error: XY pair wave "+NameOfWave(yVals[i])+" does not have at least 2 columns\n\r"
					endif
				endfor
				break		
			case WMconstSingle2DInput:
				nXVals = DimSize(xVals[0], 1)
				nXVals2 = DimSize(xVals[0], 0)
	
				if (nXVals != nYVals)
					ret=0
					ErrMsg += "Error: The number of Y Waves - "+num2Str(nYVals)+" - does not equal the "
					ErrMsg += "number of columns - "+num2Str(nXVals)+" - in the X wave "+NameOfWave(xVals[0])+"\n\r"
				else						
					for (i=0; i<nYVals; i+=1)
						if (nXVals2 != DimSize(yVals[i], 0))
							ret=0
							ErrMsg += "Error: Number of rows - "+num2Str(DimSize(yVals[i], 0))+" - in Y wave "+NameOfWave(yVals[i])+" does not equal the "
							ErrMsg += "number of rows - "+num2Str(nXVals2)+" - in the X wave "+NameOfWave(xVals[0])+"\n\r"
						endif
					endfor
				endif
				break
			case WMconstCollection1DInput:
				if (nYVals != DimSize(xVals, 0))
					ret=0
					ErrMsg += "Error: The number of Y Waves - "+num2Str(nYVals)+" - does not equal the number of X Waves - "+num2Str(DimSize(xVals,0))+"\n\r"
				else
					for (i=0; i<nYVals; i+=1)
						if (DimSize(yVals[i],0) != DimSize(xVals[i],0))
						 	ret=0
							ErrMsg += "Error: The number values - "+num2Str(DimSize(yVals[i],0))+" - in Y Wave "+NameOfWave(yVals[i])+ " does not equal the number of values - "
							ErrMsg += num2Str(DimSize(xVals[i],0))+" - in X Wave "+NameOfWave(xVals[i])+" \n\r"
						elseif (DimSize(xVals[i], 1) > 0)
							ErrMsg += "Error: curvefit requires 1D waves. "+NameOfWave(xVals[i])+" is 2D or greater."			
						endif
					endfor
				endif
				break
			default:
				break
		endswitch		
	endif
	
	return ErrMsg
End