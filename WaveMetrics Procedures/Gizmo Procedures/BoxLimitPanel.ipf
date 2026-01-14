#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma modulename=GizmoBoxLimit
#pragma IgorVersion=6.2	// for GetGizmo scalingOption, #pragma rtGlobals=3
#pragma version=6.2		// shipped with Igor 6.2

#include <GizmoUtils>, version>=6.2

// JP: Version 6.05:	Removed increment arrows since an increment of 1 is not always appropriate.
//						Autopositioned panel relative to top Gizmo. Made most routines static. Commands echoed to history.
// JP: Version 6.1:	Added noEdit=1
// JP: Version 6.2:	includes GizmoUtils.ipf, adds autoscaling options, #pragma rtGlobals=3

Static StrConstant ksPanelName="GizmoBoxPanel"
Static StrConstant ksFormat="%.8g"

//==============================================================================================
Function WM_initGizmoBoxLimitsPanel()
	
	DoWindow $ksPanelName
	if( V_Flag )
		// panel exists, now see if it has the latest controls in it
		ControlInfo/W=$ksPanelName xAutoscale	// a control added for version=6.2
		if( V_Flag == 0 ) // V_Flag = 0 if the (new) control doesn't exist
			DoWindow/K $ksPanelName	// so we kill the old panel (and create a new one)
		endif
	endif
	
	if(V_Flag)
		DoWindow/F $ksPanelName	// activate will fill in the controls
		return 0
	endif

	String curDF=SetLimitsDF()
	Variable/G xmin,xmax,ymin,ymax,zmin,zmax
	Variable/G showCommands

	NewPanel/N=$ksPanelName/K=1/W=(558,50,812,499) as "Gizmo Axis Ranges"
	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		AutoPositionWindow/E/R=$gizmoName/M=0 $ksPanelName
	endif
	ModifyPanel fixedSize=1, noEdit=1
	DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

// X
	GroupBox xGroup,pos={9,9},size={226,112},title="X Limits"

	CheckBox xAutoscale,pos={19,35},size={75,16},proc=GizmoBoxLimit#xManualAutoCheckProc,title="Autoscale"
	CheckBox xAutoscale,value= 1,mode=1
	CheckBox xManualRange,pos={128,35},size={97,16},proc=GizmoBoxLimit#xManualAutoCheckProc,title="Manual Range"
	CheckBox xManualRange,value= 0,mode=1

	SetVariable WMGizmoXminSetVar,pos={36,91},size={187,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="X Min"
	SetVariable WMGizmoXminSetVar,format=ksFormat
	SetVariable WMGizmoXminSetVar,limits={-inf,inf,0.1},value= xmin
	SetVariable WMGizmoXmaxSetVar,pos={33,66},size={190,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="X Max"
	SetVariable WMGizmoXmaxSetVar,format=ksFormat
	SetVariable WMGizmoXmaxSetVar,limits={-inf,inf,0.1},value= xmax

// Y
	GroupBox yGroup,pos={9,130},size={226,112},title="Y Limits"

	CheckBox yAutoscale,pos={19,156},size={75,16},proc=GizmoBoxLimit#yManualAutoCheckProc,title="Autoscale"
	CheckBox yAutoscale,value= 1,mode=1
	CheckBox yManualRange,pos={128,156},size={97,16},proc=GizmoBoxLimit#yManualAutoCheckProc,title="Manual Range"
	CheckBox yManualRange,value= 0,mode=1

	SetVariable WMGizmoYminSetVar,pos={36,210},size={187,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="Y Min"
	SetVariable WMGizmoYminSetVar,format=ksFormat
	SetVariable WMGizmoYminSetVar,limits={-inf,inf,0.1},value= ymin
	SetVariable WMGizmoYmaxSetVar,pos={33,185},size={190,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="Y Max"
	SetVariable WMGizmoYmaxSetVar,format=ksFormat
	SetVariable WMGizmoYmaxSetVar,limits={-inf,inf,0.1},value= ymax

// Z
	GroupBox zGroup,pos={9,260},size={226,112},title="Z Limits"

	CheckBox zAutoscale,pos={19,286},size={75,16},proc=GizmoBoxLimit#zManualAutoCheckProc,title="Autoscale"
	CheckBox zAutoscale,value= 1,mode=1
	CheckBox zManualRange,pos={128,286},size={97,16},proc=GizmoBoxLimit#zManualAutoCheckProc,title="Manual Range"
	CheckBox zManualRange,value= 0,mode=1

	SetVariable WMGizmoZminSetVar,pos={37,343},size={186,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="Z Min"
	SetVariable WMGizmoZminSetVar,format=ksFormat
	SetVariable WMGizmoZminSetVar,limits={-inf,inf,0.1},value= zmin
	SetVariable WMGizmoZmaxSetVar,pos={34,318},size={189,18},bodyWidth=150,proc=GizmoBoxLimit#WM_GizmoBoxSetVarProc,title="Z Max"
	SetVariable WMGizmoZmaxSetVar,format=ksFormat
	SetVariable WMGizmoZmaxSetVar,limits={-inf,inf,0.1},value= zmax

// Other
	Button WMGizmoBoxAutoScaleButton,pos={67,388},size={125,20},proc=GizmoBoxLimit#WMGizmoBoxAutoScaleButtonProc,title="Auto Scale All"
	
	CheckBox showCommands,pos={14,418},size={113,16},title="Echo Commands",variable= showCommands

	CheckBox showAxisCue pos={135,418}, size={103,16},title="Show Axis Cue",value=0
	CheckBox showAxisCue,proc=GizmoBoxLimit#AxisCueCheckProc

	SetWindow kwTopWin,hook(activateHook)=GizmoBoxLimit#WMGizmoBoxPanelHook
	
	SetDataFolder curDF

	// update controls from top gizmo
	WM_UpdateGizmoBoxPanel()
End

//==============================================================================================
static Function WM_GizmoSetOuterBoxFromControls()

	String curDF=SetLimitsDF()
	Variable xmin,xmax,ymin,ymax,zmin,zmax
	
	ControlInfo/W=$ksPanelName WMGizmoXminSetVar 
	xmin=V_value
	ControlInfo/W=$ksPanelName WMGizmoXmaxSetVar 
	xmax=V_value
	ControlInfo/W=$ksPanelName WMGizmoYminSetVar 
	ymin=V_value
	ControlInfo/W=$ksPanelName WMGizmoYmaxSetVar 
	ymax=V_value
	ControlInfo/W=$ksPanelName WMGizmoZminSetVar 
	zmin=V_value
	ControlInfo/W=$ksPanelName WMGizmoZmaxSetVar 
	zmax=V_value
	
	// autoscaling
	Variable scalingOption= 0, numAutoscaled= 0
	String comment=""
	ControlInfo/W=$ksPanelName xAutoscale
	if( V_Value )
		scalingOption = scalingOption | 0x3
		comment += "x, "
		numAutoscaled += 1
	endif
	ControlInfo/W=$ksPanelName yAutoscale
	if( V_Value )
		scalingOption = scalingOption | 0xC
		comment += "y, "
		numAutoscaled += 1
	endif
	ControlInfo/W=$ksPanelName zAutoscale
	if( V_Value )
		scalingOption = scalingOption | 0x30
		comment += "z, "
		numAutoscaled += 1
	endif

	// the simpler default scaling is done when all axes are autoscaled
	String cmd
	if( scalingOption == 0x3F )
		scalingOption= 0
		cmd= "ModifyGizmo autoScale"
	else
		String format
		sprintf format, "ModifyGizmo setOuterBox={%s,%s,%s,%s,%s,%s}", ksFormat, ksFormat, ksFormat, ksFormat, ksFormat, ksFormat
		sprintf cmd,format,xmin,xmax,ymin,ymax,zmin,zmax
	endif
	Variable currentScalingOption,currentAutoscaling
	GetGizmoAutoscalingOptions(TopGizmo(),currentScalingOption,currentAutoscaling)
	
	if( scalingOption != currentScalingOption )
		String cmd2
		if( scalingOption == 0 )
			comment= ""
		else
			comment= " // Autoscale only "+RemoveEnding(comment,", ")
			if( numAutoscaled == 1 )
				comment += " axis"
			else
				comment += " axes"
			endif
		endif
		sprintf cmd2,";ModifyGizmo scalingOption=%d%s",scalingOption,comment
		cmd += cmd2
	endif
	
	ControlInfo/W=$ksPanelName showCommands
	Variable quiet= V_Value == 0
	GizmoEchoExecute(cmd, slashZ=1, slashQ=quiet)
	GizmoEchoExecute("ModifyGizmo compile", slashZ=1, slashQ=1)
	
	SetDataFolder curDF
End


//==============================================================================================
static Function WM_GizmoBoxSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			WM_GizmoSetOuterBoxFromControls()
		break
	endswitch

	return 0
End

//==============================================================================================
static Function WMGizmoBoxAutoScaleButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String curDF=SetLimitsDF()
			ControlInfo/W=$ksPanelName showCommands
			Variable quiet= V_Value == 0
			GizmoEchoExecute("ModifyGizmo autoScale;ModifyGizmo scalingOption=0", slashZ=1, slashQ=quiet)
			GizmoEchoExecute("ModifyGizmo compile", slashZ=1, slashQ=1)
			WM_UpdateGizmoBoxPanel()
			SetDataFolder curDF
		break
	endswitch

	return 0
End
//==============================================================================================
static Function WMGizmoBoxPanelHook(s)
	STRUCT WMWinHookStruct &s
 
 	Variable statusCode=0
 	switch(s.eventCode)
		case 0:					// Activate event -- ask the Gizmo about the current limits
			WM_UpdateGizmoBoxPanel()
		break
		
 	Endswitch
 	return statusCode		// 0 if nothing done, else 1
End
//==============================================================================================
static Function WM_UpdateGizmoBoxPanel()

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) == 0 )
		printf "*** This panel requires an open Gizmo window.***"
		return 0
	endif
	
	Variable xmin,xmax,ymin,ymax,zmin,zmax
	if( !GetGizmoAxisRanges(gizmoName,xmin,xmax,ymin,ymax,zmin,zmax) )
		return 0	// should never happen
	endif

	Variable/G $LimitsDFVar("xmin")= xmin
	Variable/G $LimitsDFVar("xmax")= xmax

	Variable/G $LimitsDFVar("ymin")= ymin
	Variable/G $LimitsDFVar("ymax")= ymax

	Variable/G $LimitsDFVar("zmin")= zmin
	Variable/G $LimitsDFVar("zmax")= zmax

	// 6.2: set increments to 1% of the ranges
	Variable inc, fraction = 0.01

	// 6.2: get auto scaling options
	// By default scalingOption=0. By setting the value to 1-63 it will override any setOuterBox param.
	// but scalingOption=0 does NOT mean complete autoscale.
	Variable scalingOption,autoscaling
	 GetGizmoAutoscalingOptions(gizmoName,scalingOption,autoscaling)
	// X
	Variable isAutoscaled= autoscaling || (scalingOption & 0x3)	// for now, if either X axis end is autoscaled, we say the entire axis is autoscaled.
	CheckBox xAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox xManualRange win=$ksPanelName, value= !isAutoscaled

	inc= NiceNumber((xmax-xmin) * fraction)
	SetVariable WMGizmoXminSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoXmaxSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0
	
	// Y
	isAutoscaled= autoscaling || (scalingOption & 0xC)	// for now, if either Y axis end is autoscaled, we say the entire axis is autoscaled.
	CheckBox yAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox yManualRange win=$ksPanelName, value= !isAutoscaled

	inc= NiceNumber((ymax-ymin) * fraction)
	SetVariable WMGizmoYminSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoYmaxSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0

	// Z
	isAutoscaled= autoscaling || (scalingOption & 0x30)	// for now, if either Z axis end is autoscaled, we say the entire axis is autoscaled.
	CheckBox zAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox zManualRange win=$ksPanelName, value= !isAutoscaled

	inc= NiceNumber((zmax-zmin) * fraction)
	SetVariable WMGizmoZminSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoZmaxSetVar, win=$ksPanelName, limits={-inf,inf,inc}, disable= isAutoscaled ? 2 : 0

	// axis cue
	Variable haveAxisCue= GizmoHasAxisCue(gizmoName)
	CheckBox showAxisCue win=$ksPanelName,value=haveAxisCue

	return 1
End

//==============================================================================================

static Function xManualAutoCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Variable isAutoscaled= CmpStr(ctrlName,"xAutoscale") == 0
	CheckBox xAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox xManualRange win=$ksPanelName, value= !isAutoscaled

	SetVariable WMGizmoXminSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoXmaxSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0

	WM_GizmoSetOuterBoxFromControls()
	WM_UpdateGizmoBoxPanel()
End

static Function yManualAutoCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Variable isAutoscaled= CmpStr(ctrlName,"yAutoscale") == 0
	CheckBox yAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox yManualRange win=$ksPanelName, value= !isAutoscaled

	SetVariable WMGizmoYminSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoYmaxSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0

	WM_GizmoSetOuterBoxFromControls()
	WM_UpdateGizmoBoxPanel()
End

static Function zManualAutoCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Variable isAutoscaled= CmpStr(ctrlName,"zAutoscale") == 0
	CheckBox zAutoscale win=$ksPanelName, value= isAutoscaled
	CheckBox zManualRange win=$ksPanelName, value= !isAutoscaled

	SetVariable WMGizmoZminSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0
	SetVariable WMGizmoZmaxSetVar, win=$ksPanelName, disable= isAutoscaled ? 2 : 0

	WM_GizmoSetOuterBoxFromControls()
	WM_UpdateGizmoBoxPanel()
End

//==============================================================================================
//==============================================================================================

// returns old Data Folder
static Function/S SetLimitsDF()

	String curDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoBoxLimitsPanelFolder
	return curDF
End

Static Function/S LimitsDFVar(varName)
	String varName
	
	return "root:Packages:GizmoBoxLimitsPanelFolder:"+PossiblyQuoteName(varName)
End

//==============================================================================================
// round to 1, 2, or 5 * 10eN, non-rigorously
static Function NiceNumber(num)
	Variable num
	
	if( num == 0 )
		return 0
	endif
	Variable theSign= sign(num)
	num= abs(num)
	Variable lg= log(num)
	Variable decade= floor(lg)
	Variable frac = lg - decade
	Variable mant
	if( frac < log(1.5) )	// above 1.5, choose 2
		mant= 1
	else
		if( frac < log(4) )	// above 4, choose 5
			mant= 2
		else
			if( frac < log(8) )	// above 8, choose 10
				mant= 5
			else
				mant= 10
			endif
		endif
	endif
	num= theSign * mant * 10^decade
	return num
End

static Function AxisCueCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) == 0 )
		return 0
	endif
	
	Variable haveAxisCue= GizmoHasAxisCue(gizmoName)
	ControlInfo/W=$ksPanelName showCommands
	Variable echoCommands= V_Value
	GizmoAddRemoveAxisCue(gizmoName, checked ,echoCommands=echoCommands)
End
