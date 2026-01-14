#pragma rtGlobals=1		// Use modern global access method.

// NOTE: The IntDiffXYPanel procedure file is obsolete.
// Use Analysis->Integrate or Analysis->Differentiate instead.
//
// This procedure file creates a control panel that makes it easy to
// Integrate or Differentiate XY data.
//
//	The code here assumes you have your data graphed using the left
//	and bottom axes. If you do not choose to replace the original data, the new
//	data is plotted vs the right an bottom axes.
//
// Wish list:
//  Remember settings through invocations
//  Check for various error conditions
//  Check to see on which axes the data is plotted rather than assuming left and bottom
//  Operate on a sub-range of data
//  Allow for operations on data not shown in the top graph
//
// Larry Hutchinson 950228
// Version 1.1, Larry Hutchinson 950925
//	Changed to be Data Folder and Liberal Names aware.
// LH980206: Fixed problem where switching between "even" and "at same x" gave bad graph
// unless trace manually removed.
// LH000705: Modernized slightly.
//
// HR, 2020-03-08: Replaced Interpolate with Interpolate2.
// Added note to help explaining that this procedure file is obsolete.
//
// JP, 2020-03-09: output prefix isn't "int_" when differentiating.
// Added hook function to keep Y Data popup list valid.

Menu "Macros"
	"Int Diff XY", IntDiffXY()
End

Function WM_IDXY_BProcXYDefault(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo popy
	Wave w= TraceNameToWaveRef("", S_Value)
	NVAR np= root:Packages:WMIntDiffXY:gNumIntPnts
	np= numpnts(w)*5
End

Function WM_IDXY_BProcXYDoIt(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo popy
	String yWaveName= S_Value
	
	ControlInfo popinterp
	variable method= V_value

	ControlInfo popXYOp
	variable doIntegrate= V_value==1

	ControlInfo popOpts
	Variable option= V_value

	Wave/Z wy=  TraceNameToWaveRef("", yWaveName)
	Wave/Z wx= XWaveRefFromTrace("", yWaveName)
	if( (WaveExists(wy)==0) || (WaveExists(wx)==0) )
		DoAlert 0,"Can't find waves"
		return 0							// ***** error exit
	endif
	
	yWaveName= NameOfWave(wy)
	String NamexWave= NameOfWave(wx)
	String prefix= "diff_"
	if( doIntegrate )
		prefix= "int_"
	endif
	String wWaveName= prefix+yWaveName
	NVAR gNumIntPnts= root:Packages:WMIntDiffXY:gNumIntPnts

	String savDF= GetDataFolder(1)				// save current data folder
	SetDataFolder GetWavesDataFolder(wy, 1)	// we will ASSUME x is in same DF
												// we do this so Interpolate2 will create output in same DF
	
	// HR, 2020-03-08: Replaced Interpolate with Interpolate2
	Interpolate2/N=(gNumIntPnts)/T=(method)/Y=$wWaveName wx, wy
	
	Wave ww = $wWaveName
	SetDataFolder savDF							// the rest uses wave references so CDF is irrelevant
	
	if(doIntegrate )
		Integrate/T ww
	else
		Differentiate ww
	endif
	
	do
		CheckDisplayed/A $wWaveName
		Variable wwIsDisplayed= V_Flag==1
		Variable isXYAlready= 0
		if( wwIsDisplayed )
			isXYAlready= strlen(XWaveName("", wWaveName)) != 0
		endif
		if( wwIsDisplayed )
			if( (option==1) %& isXYAlready )
				RemoveFromGraph $wWaveName
				wwIsDisplayed= 0
			endif
			if( (option==2) %& (isXYAlready==0) )
				RemoveFromGraph $wWaveName
				wwIsDisplayed= 0
			endif
			if( option==3 )
				RemoveFromGraph $wWaveName
			endif
		endif
		if( option == 1 )
			if( !wwIsDisplayed )
				AppendToGraph/R ww
			endif
			break
		endif
		if( option == 2 )
			Duplicate/O ww, intxyTmp
			Duplicate/O wy,ww
			ww= intxyTmp(wx)
			KillWaves intxyTmp
			if( !wwIsDisplayed )
				AppendToGraph/R ww vs wx
			endif
			break
		endif
		if( option == 3 )
			wy= ww(wx)
			KillWaves ww
		endif
	while(0)
End

Function IntDiffXY()
	NewDataFolder/O root:Packages
	if( !DataFolderExists("root:Packages:WMIntDiffXY") )
		NewDataFolder root:Packages:WMIntDiffXY
		Variable/G root:Packages:WMIntDiffXY:gNumIntPnts= 100
	endif
	DoWindow/K IntDiffXYPanel
	NewPanel/K=1 /W=(334,151,606,343)/N=IntDiffXYPanel
	PopupMenu popy,pos={53,40},size={92,20},title="Y Data:"
	PopupMenu popy,mode=1,value= #"TraceNameList(\"\",\";\",1+4)"
	PopupMenu popinterp,pos={19,73},size={140,20},title="Interpolation:"
	PopupMenu popinterp,mode=1,popvalue="Linear",value= #"\"Linear;Spline\""
	SetVariable setvarnpts,pos={45,103},size={96,15},title="# points"
	SetVariable setvarnpts,limits={20,10000,10},value= root:Packages:WMIntDiffXY:gNumIntPnts
	Button buttonDefault,pos={154,101},size={63,20},proc=WM_IDXY_BProcXYDefault,title="Default"
	PopupMenu popOpts,pos={47,128},size={203,20},title="Options:"
	PopupMenu popOpts,mode=1,popvalue="Evenly spaced result",value= #"\"Evenly spaced result;At same X values;Replace Y Data\""
	Button buttonDoIt,pos={26,164},size={50,20},proc=WM_IDXY_BProcXYDoIt,title="Do It"
	PopupMenu popXYOp,pos={36,10},size={144,20},title="Operation:"
	PopupMenu popXYOp,mode=1,popvalue="Integrate",value= #"\"Integrate;Differentiate\""
	Button helpButton,pos={111,164},size={50,20},proc=WM_IDXY_HelpButtonProc,title="Help"
	Setwindow IntDiffXYPanel, hook(update)=WM_UpdateIntDiffXYPanel
	UpdateTraceList()
End

static Function UpdateTraceList()
	String traces = TraceNameList("",";",1+4)
	ControlInfo/W=IntDiffXYPanel popy
	String currentTraceName= S_Value
	Variable inList = WhichListItem(currentTraceName, traces) >= 0
	if( !inList )
		currentTraceName= StringFromList(0,traces)
		PopupMenu popy,win=IntDiffXYPanel,mode=1,popvalue=currentTraceName
	endif
End

Function WM_UpdateIntDiffXYPanel(s)
	STRUCT WMWinHookStruct &s

	strswitch(s.eventName)
		case "activate":
			UpdateTraceList()
			break
	endswitch

	return 0
End

Function WM_IDXY_HelpButtonProc(ctrlName)
	String ctrlName
	
	DoWindow/F IntegrateXYHelp
	if( V_Flag )
		return 0
	endif

	String nb = "IntegrateXYHelp"
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(82,85,647,323) as "Int/Diff XY Help"
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 777600000}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,0,360}
	Notebook $nb fStyle=1, textRGB=(65535,0,0), text="NOTE", fStyle=-1, textRGB=(0,0,0)
	Notebook $nb text=": The IntDiffXYPanel procedure file is obsolete. Use Analysis->Integrate"
	Notebook $nb text=" or Analysis->Differentiate instead.\r"
	Notebook $nb text="\r"
	Notebook $nb text="This panel makes it easy to Integrate or Differentiate XY data.\r"
	Notebook $nb text="\r"
	Notebook $nb text="The package assumes you have your data graphed using the left and bottom axes."
	Notebook $nb text=" If you do not choose to replace the original data, the new data is plotted vs "
	Notebook $nb text="the right and bottom axes.\r"
End
