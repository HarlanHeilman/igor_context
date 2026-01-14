#pragma rtGlobals=1		// Use modern global access method.
#include <WaveSelectorWidget>
#include <statsPlots>
#pragma ModuleName= ancilla1D

// 19APR07 Factored strings for J version.
// 13OCT06 changed the box plot routine to return the name of the graph window to be killed.
// 15DEC04
// Ancilla Package:
//  Etymology: Latin, female servant: an aid to achieving or mastering something difficult.
//  This package is designed to provide a few statistical analysis tools that can be used with
//  single 1D waves.  

//==========================================================================================
//  Begin String Block
//==========================================================================================
static StrConstant ksUntitled="Untitled"
static StrConstant ksSelect1Wave="Select 1D wave to analyze."	
static StrConstant ksHelp1="The wave selection widget displays only 1D waves. \rChoose the one that you want to analyze"
static StrConstant ksAction2="Enter report notebook name."
static StrConstant ksHelp2="All the results of the analysis will be saved in an IGOR notebook.\rEnter a notebook name in the space below."	
static StrConstant ksAction3="Analyze the wave."	
static StrConstant ksHelp3="When finished, you may want to save the notebook to disk."
static StrConstant ksAction4="Finish"
static StrConstant ksHelp4="Ready to close this panel; You are done!"

static StrConstant ksPanelName="1D Statistics Report"
static StrConstant ksPanelText1="What to do:"
static StrConstant ksPanelText2="What it means:"
static StrConstant ksNextButton="Next >>"
static StrConstant ksBackButton="<< Back"

static StrConstant ksNotebookName="Notebook Name"

static StrConstant ksAlert1Text="You must select at least one valid wave name in order to proceed."
static StrConstant ksAlert2Text="Bad notebook name."
static StrConstant ksAlert3Text="Results will be appended to existing notebook named:"
static StrConstant ksAlert4Text="The dog ate the report notebook.  You will have to restart the analysis."
static StrConstant ksAlert5Text="The cat ate the report notebook.  You will have to restart the analysis."
static StrConstant ksNBName="1D Statistics Report"

static StrConstant ksReportStr1="1D Statistics Report Starting "
static StrConstant ksReportStr2="Analysis for: "

static StrConstant ksLabel1="Spectral Power"
static StrConstant ksSpectralPlot="Spectral plot"
static StrConstant ksWaveStats="WaveStats:"
static StrConstant ksQuantiles="\rQuantiles:"
static StrConstant ksJBTest="\rJarque-Bera Test:"
static StrConstant ksAbortText="statsRunCompleteReport Abort code= "

static StrConstant ksWaveScaling="\rWave Scaling:\r"
static StrConstant ksFrequency="Frequency \\U"				// Note the formatting code!

static StrConstant ksMonaco="Monaco"						// use something else like "Osaka"

//==========================================================================================
// End String Block
//==========================================================================================

constant kNumItemsInList=4
constant kFinishItem=3

Function WM_initAncilla()

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S Ancilla
	Variable/G curStep=0,oldStep=0
	Variable/G fullReport=1
	
	String/G curHelpStr=""
	String/G notebookName=ksUntitled
	String/G srcWaveName=""
	String/G srcSelectionList=""
	
	// Prefs variables
	Variable/G wants4Plot
	make/O/T/N=(kNumItemsInList) twList1d
	make/O/T/N=(kNumItemsInList) twHelp
	Make/O/N=(kNumItemsInList,10) userChoices=0
	
	Variable i=0
	twList1d[i]=ksSelect1Wave		
	twHelp[i]=ksHelp1	
	i+=1
	
	twList1d[i]=ksAction2		
	twHelp[i]=ksHelp2
	i+=1

	twList1d[i]=ksAction3		
	twHelp[i]=ksHelp3	
	i+=1
	
	twList1d[i]=ksAction4						
	twHelp[i]=ksHelp4	
	 i+=1
	
	Make/O/W/U listColors= {{0,0,0},{32000,32000,32000},{0,65535,0},{0,65535,65535},{65535,65535,65535}}
	MatrixTranspose listColors
	Make/O/N=(kNumItemsInList,1,3) listSelectionWave=0
	SetDimLabel 2,1,foreColors,listSelectionWave	
	SetDimLabel 2,2,backColors,listSelectionWave	
	SetDataFolder oldDF
	
	WM_statsAsistantPanel()
End

//==========================================================================================

Static Function WM_statsAsistantPanel() 
	
	DoWindow/F WM_Statcilla
	if(V_Flag==1)
		return 0
	endif
	
	NewPanel/K=1 /W=(439,44,1168,376) as ksPanelName
	DoWindow/C WM_Statcilla
	SetDrawLayer UserBack
	DrawText 15,23,ksPanelText1
	DrawText 224,23,ksPanelText2
	Button WM_Stats_Next,pos={141,287},size={70,20},proc=ancilla1D#forwardBackButtonProc,title=ksNextButton
	Button WM_Stats_Back,pos={15,287},size={70,20},proc=ancilla1D#forwardBackButtonProc,title=ksBackButton
	ListBox WM_StatsStepList,pos={14,29},size={196,222},proc=ancilla1D#WM_ancillaListProc
	ListBox WM_StatsStepList,listWave=root:Packages:Ancilla:twList1d
	ListBox WM_StatsStepList,selWave=root:Packages:Ancilla:listSelectionWave
	ListBox WM_StatsStepList,colorWave=root:Packages:Ancilla:listColors,row= 0
	ListBox WM_StatsStepList,mode= 3
	TitleBox WM_Stats_AncillaHelp,pos={222,29},size={364,56},frame=3,font=$ksMonaco
	TitleBox WM_Stats_AncillaHelp,variable= root:Packages:Ancilla:curHelpStr
	ModifyPanel fixedSize=1
	SetWindow WM_Statcilla hook(cleanupHook)=ancilla1D#statsAncillaWindowHook
	myFakeSelection()
	statsUpdateControlsForSelection()
End 

//==========================================================================================
Static Function statsAncillaWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	switch(s.eventCode)
		case 2:						// this is a kill message
			statsDoCleanup()
		break
	EndSwitch

	return rval
End

//==========================================================================================
static Function WM_ancillaListProc(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct

	myFakeSelection()
	return 0							// does not support other return code -- shame.
End
//==========================================================================================

Static Function myFakeSelection()

	NVAR curStep=root:Packages:Ancilla:curStep
	SVAR curHelpStr=root:Packages:Ancilla:curHelpStr
	
	Wave listSelectionWave=root:Packages:Ancilla:listSelectionWave
	Wave/T twHelp=root:Packages:Ancilla:twHelp
	
	listSelectionWave=0
	listSelectionWave[curStep][0][0]=1
	curHelpStr=fakeStringSize(twHelp[curStep])
	
	// now check if we need to scroll to make the selection visible:
	ControlInfo WM_StatsStepList
	Variable topRow=V_startRow
	Variable bottomRow=topRow+V_Height/V_rowHeight				 
	if(curStep<topRow)
		ListBox WM_StatsStepList row=curStep,win=WM_Statcilla
	elseif(curStep>bottomRow)
		ListBox WM_StatsStepList row=topRow+curStep-bottomRow,win=WM_Statcilla
	endif
End
//==========================================================================================
Static Function forwardBackButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR curStep=root:Packages:Ancilla:curStep
	NVAR oldStep=root:Packages:Ancilla:oldStep	
	oldStep=curStep
	if(cmpstr(ctrlName,"WM_Stats_Next")==0)
		curStep+=1
	else
		curStep-=1
		if(curStep<0)
			curStep=0
			Beep
		endif
	endif
	
	// At this point we need to accept the values in the controls and refresh the 
	// controls view for the new step.
	if(statsUpdateControlsForSelection())
		curStep=oldStep
	endif
	myFakeSelection()
End
//==========================================================================================
// creates a string that has fixed number of characters in the top line.  This will make sure that the TitleBox that it goes into
// does not shrink too much.

Static Function/s fakeStringSize(inStr)
	String inStr
	
	String tmp="                                                                           \r"
	tmp+=inStr+"\r"
	return tmp
End

//==========================================================================================
// If the parameter "step" is not the step of the current controls, the controls
// Adds the controls that are relevant for the current step.
// Returns 0 if successful, -1 otherwise.

Static Function statsUpdateControlsForSelection()

	NVAR curStep=root:Packages:Ancilla:curStep
	NVAR oldStep=root:Packages:Ancilla:oldStep	
	Variable result
	// if this is a new step, store the old step data
	if(oldStep!=curStep)
		result=statsReadOldControls(oldStep)
	endif
	
	if(result)
		return result
	endif
		
	switch(curStep)
		case 0:		// select the wave to analyze.
			ListBox statsListWidget,pos={225,96},size={238,154},win=WM_Statcilla
			MakeListIntoWaveSelector("WM_Statcilla", "statsListWidget",content=WMWS_Waves, selectionMode=WMWS_SelectionSingle)
			WS_ClearSelection("WM_Statcilla", "statsListWidget")
		break
		
		case 1:		// Report notebook name.
			SetVariable Stats_NoteBookNameSetVar,pos={226,102},size={342,15},title=ksNotebookName,format="%g"
			SetVariable Stats_NoteBookNameSetVar,value= root:Packages:Ancilla:notebookName,bodyWidth= 271
		break		
	endswitch
	return 0
End

//==========================================================================================
// This function reads and removes the controls associated with oldStep
Static Function statsReadOldControls(oldStep)
	Variable oldStep
	
	Variable result=0
	NVAR curStep=root:Packages:Ancilla:curStep
	
	switch(oldStep)
		case 0:		// pick up the user's selection for the waves they want to analyze:
			String selectedWaveStr= WS_SelectedObjectsList("WM_Statcilla", "statsListWidget")
			SVAR srcSelectionList=root:Packages:Ancilla:srcSelectionList
			srcSelectionList=selectedWaveStr										// in case there is more than one selection
			SVAR srcWaveName=root:Packages:Ancilla:srcWaveName
			srcWaveName=selectedWaveStr[0,strlen(selectedWaveStr)-2]
			Wave/Z ww=$srcWaveName
			if(WaveExists(ww)==0)
				doAlert 0, ksAlert1Text
				return -1
			endif
			// 25APR06 KillControl/W=WM_Statcilla statsListWidget
			ListBox statsListWidget win=WM_Statcilla, disable=1
		break
		
		case 1:
			//  the name of the report is in the string; it must be a valid name. 
			if(curStep>oldStep)
				SVAR notebookName=root:Packages:Ancilla:notebookName
				String tmpStr=CleanupName(notebookName,0)
				if(cmpstr(notebookName,tmpStr)!=0)
					doAlert 0,ksAlert2Text
					return -1
				endif
				Variable needNewNotebook=1
				if(WinType(notebookName)==5)
					String alertStr=ksAlert3Text+notebookName
					doAlert 1,alertStr
					if(V_flag!=1)
						DoWindow/F $notebookName	// bring it to the front so we can kill it.
						return -1
					endif
					needNewNotebook=0
				else
					if(CheckName(notebookName, 10))
						doAlert 0,ksAlert2Text
						return -1
					endif
				endif
				if(needNewNotebook)
					NewNotebook /F=1/K=0/N=$notebookName  as ksNBName
					DoWindow/B $notebookName
				endif
				String startStr=ksReportStr1+date()+"; "+time()
				statsCatNotebookPlain(startStr)
				SVAR srcWaveName=root:Packages:Ancilla:srcWaveName
				SVAR srcSelectionList=root:Packages:Ancilla:srcSelectionList
				Variable numWaves=ItemsInList(srcSelectionList)
				if(numWaves==1)
					startStr=ksReportStr2+srcWaveName+"\r"
				else
					Variable i
					startStr=ksReportStr2
					for(i=0;i<numWaves;i+=1)
						startStr+=StringFromList(i, srcSelectionList )
						if(i<numWaves-1)
							startStr+=", "
						endif
					endfor
					startStr+="\r"
				endif
				statsCatNotebookPlain(startStr)
			endif
			KillControl/W=WM_Statcilla Stats_NoteBookNameSetVar
		break
		
		case 2:
			statsRunCompleteReport(0)		// no preferences
			curStep=kNumItemsInList-1
		break

		case kFinishItem:
			if(curStep>oldStep)
				KillWindow WM_Statcilla
			endif
		break
		
	endswitch
	return result
End

//==========================================================================================
//  
Static Function statsDoPlotsFor1DWave(inWave,plotLag,plotAutoCor,plotHist,plotSpectrum,plotBox,plotProb)
	Wave inWave
	Variable plotLag,plotAutoCor,plotHist,plotSpectrum,plotBox,plotProb
	
	statsCatNotebookPlain("\r\r")
		
	if(plotLag)
		statsPlotLag(inWave)		
		// now paste the graph into the notebook
		statsPasteGraphInNotebook("WM_LAG_PLOT","  ")
		KillWindow WM_LAG_PLOT
	endif
	
	if(plotAutoCor)
		statsAutoCorrPlot(inWave)
		statsPasteGraphInNotebook("WM_AutoCor_PLOT","  ")
		KillWindow WM_AutoCor_PLOT
		KillWaves/Z corWave
	endif
	
	if(plotHist)
		statsPlotHistogram(inWave)
		statsPasteGraphInNotebook("WM_HIST_PLOT","  ")
		KillWindow WM_HIST_PLOT
		KillWaves/Z hResults
	endif
	
	if(plotSpectrum)
		Variable num=numpnts(inWave)
		if(num&1)
			FFT/PAD={(num+1)}/out=4/Dest=W_FFT inWave
		else
			FFT/out=4/Dest=W_FFT inWave
		endif
		Display /W=(5,45,470,405)  W_FFT
		DoWindow/C WM_FFT_PLOT
		Label left ksLabel1
		Label bottom ksFrequency
		TextBox/N=text0/F=0/A=MC/X=-33.06/Y=48.66 ksSpectralPlot
		statsPasteGraphInNotebook("WM_FFT_PLOT","  ")
		KillWindow WM_FFT_PLOT
		KillWaves/Z W_FFT
	endif
	
	String gWindowName										// 13OCT06
	
	if(plotBox)
		gWindowName=statsBoxPlot(inWave)					// 13OCT06
		statsPasteGraphInNotebook(gWindowName,"")			// 13OCT06
		KillWindow $gWindowName								// 13OCT06
	endif
	
	// this would be a probability plot
	if(plotProb)
		gWindowName=statsProbPlot(inWave)
		statsPasteGraphInNotebook(gWindowName,"  ")
		KillWindow $gWindowName
		KillWaves/Z tmpWave,xWave,fit_tmpWave,W_coef,W_sigma
	endif
	
End

//==========================================================================================
//  In the following function we attempt to provide as much as we can of the conventional calculations for a single
// wave. These include WaveStats
Static Function stats1DBasicCalculations(inWave)
	Wave inWave
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:Ancilla
	NewDataFolder/O/S tmp

	WaveStats/Q/W inWave
	Wave/Z M_WaveStats
	if(WaveExists(M_WaveStats))
		statsCatNotebookBold(ksWaveStats)
		statsCatNotebookWaveWDimLabels(M_WaveStats)
	endif

	// Quantiles:
	StatsQuantiles/Q/ALL inWave
	Wave W_StatsQuantiles
	if(WaveExists(W_StatsQuantiles))
		statsCatNotebookBold(ksQuantiles)
		statsCatNotebookWaveWDimLabels(W_StatsQuantiles)
	endif
	
	// Jarque-Bera test for normality:
	StatsJBTest/Q/Z inWave
	statsCatNotebookBold(ksJBTest)
	Wave W_JBResults
	statsCatNotebookWaveWDimLabels(W_JBResults)
	KillDataFolder :
	SetDataFolder oldDF
End
//==========================================================================================
//  
Static Function  statsRunCompleteReport(usePrefs)
	Variable usePrefs
	Variable result
	
	try		
		// do different things here depending on the number of selected waves:
		SVAR srcSelectionList=root:Packages:Ancilla:srcSelectionList
		Variable numWaves=ItemsInList(srcSelectionList)
		if(numWaves==1)
			Wave/Z theWave=$StringFromList(0,srcSelectionList)
			if(WaveExists(theWave))
				result=stats1DBasicCalculations(theWave)
				if(result)
					Abort
				endif
				result=statsDoPlotsFor1DWave(theWave,1,1,1,1,1,1)			 
				if(result)
					Abort
				endif
			endif
		else
			Abort
		endif
	catch
		print ksAbortText, V_AbortCode	
	endtry
End
//==========================================================================================
// The following function adds the provided string to the bottom of the current notebook and appends a CR.
Static Function statsCatNotebookPlain(str)
	String str
	
	SVAR notebookName=root:Packages:Ancilla:notebookName
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlert4Text
		return 0
	endif
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=0
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
// The following function adds the provided string to the bottom of the current notebook and appends a CR.
Static Function statsCatNotebookBold(str)
	String str
	
	SVAR notebookName=root:Packages:Ancilla:notebookName
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlert4Text
		return 0
	endif
	Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
// This function writes a pair of description=value.  Pass str for description -- it will be printed in bold and '=' sign
// appended to it.  The value will be printed in plane.
// QQQ will %g will be sufficient.
Static Function statsCatNotebookPair(str,value)
	String str
	Variable value
	
	String valueStr
	sprintf valueStr,"%g",value
	SVAR notebookName=root:Packages:Ancilla:notebookName
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlert4Text
		return 0
	endif

	str+="="
	Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=0
	Notebook $notebookName selection={endOfFile,endOfFile},text=valueStr
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
Static Function statsCatNotebook1DWave(inWave)
	Wave inWave
	
	SVAR notebookName=root:Packages:Ancilla:notebookName
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlert4Text
		return 0
	endif
	
	Variable i,numRows	=DimSize(inWave,0)
	String dimLabel,valueStr
	Notebook $notebookName newRuler=plainRuler
	Notebook $notebookName newRuler=waveTabRuler,tabs={2.75*72}
	Notebook $notebookName ruler=waveTabRuler
	for(i=0;i<numRows;i+=1)
		if(NumType(inWave[i])==2)
			continue
		endif
		dimLabel=GetDimLabel(inWave, 0, i )+"\t"
		Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
		Notebook $notebookName selection={endOfFile,endOfFile},text=dimLabel,fStyle=0
		sprintf valueStr,"%g\r",inWave[i]
		Notebook $notebookName selection={endOfFile,endOfFile},text=valueStr
	endfor
	Notebook $notebookName ruler=plainRuler
	Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1,text=ksWaveScaling
	statsCatNotebookPair("Start",DimOffset(inWave,0))
	statsCatNotebookPair("Delta",DimDelta(inWave,0))
End
//==========================================================================================
// Bring the notebook window to the front and scroll to the start.
Static Function statsDoCleanup()

	SVAR notebookName=root:Packages:Ancilla:notebookName
	
	if(WinType(notebookName )==5)
		DoWindow/F $notebookName
		// The following code would make it scroll to the top of the notebook:
		Notebook $notebookName selection={startOfFile,startOfFile}
		Notebook $notebookName findText={"",1}
	endif
End
//==========================================================================================

Function WM_WC_DiscardButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String targetName=GetUserData("WM_WindowClosingPanel",ctrlName,"name")
	if(WinType(targetName))
		KillWindow $targetName
	endif
	KillWindow WM_WindowClosingPanel
End
//==========================================================================================
// The following function appends to the notebook a wave with all its dimension labels in bold face.
constant kMinColSize=1.75
Static Function statsCatNotebookWaveWDimLabels(inWave[,showWaveName])
	Wave inWave
	Variable showWaveName
	
	if(ParamIsDefault(showWaveName))
		showWaveName=0
	endif
	
	SVAR notebookName=root:Packages:Ancilla:notebookName
	Variable i,j,numCols=DimSize(inWave,1),numRows=DimSize(inWave,0)
	
	// correction for single column waves.
	if(numCols<=0 && numRows>0)
		numCols=1
	endif
	
	String cmd="Notebook "+notebookName+" newRuler=waveWithDLRuler,tabs={"
	String str,nstr

	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlert5Text
		return 0
	endif
	
	if(showWaveName)
		str="\r"+NameOfWave(inWave)+"\r"
		Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1,text=str
	else
		Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1,text="\r"
	endif
	
	// first figure out how many columns we have
	for(i=1;i<=numCols;i+=1)
		if(i>0)
			cmd+=","
		endif
		str=num2str(i*kMinColSize*72)
		cmd+=str
	endfor
	cmd+="}"+",margins={0,0,"+num2str((numCols+2)*72*kMinColSize)+" }"
	Execute cmd
	
	Notebook $notebookName ruler=waveWithDLRuler, selection={endOfFile,endOfFile},fStyle=1
	// write the column headers
	for(i=0;i<numCols;i+=1)
		str="\t"+GetDimLabel(inWave,1,i)
		Notebook $notebookName text=str 
	endfor
	
	Notebook $notebookName text="\r" 
	
	for(j=0;j<numRows;j+=1)
		str=GetDimLabel(inWave,0,j)
		if(strlen(str)>0)
			Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
			Notebook $notebookName text=str
		endif
		
		str="\t"
		for(i=0;i<numCols;i+=1)
			sprintf nstr,"%g",inWave[j][i]
			if(i<numCols-1)
				nstr+="\t"
			endif
			str+=nstr
		endfor
		str+="\r"
		Notebook $notebookName selection={endOfFile,endOfFile},fStyle=0,text=str
	endfor
	Notebook $notebookName ruler=Normal
End

//==========================================================================================
Function statsPasteGraphInNotebook(nameOfWindow,titleString)
	String nameOfWindow,titleString
	
	SVAR notebookName=root:Packages:Ancilla:notebookName
	if(strlen(titleString)>0)
		statsCatNotebookBold(titleString)
	endif
	Notebook $notebookName picture={$nameOfWindow,-5,1}
End
//==========================================================================================

