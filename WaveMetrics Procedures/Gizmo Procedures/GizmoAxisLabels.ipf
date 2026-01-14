#pragma rtGlobals=3		// Require modern global access method.
#pragma modulename=GizmoAxisLabelsModule
#pragma IgorVersion=6.2	// for rtGlobals=3
#pragma version=6.2		// Shipped with Igor 6.2

#include <GizmoUtils>

// GizmoAxisLabels.ipf
// JP080912: 6.05, Initial version
// JP10MAY11, 6.2 - #pragma rtGlobals=3

StrConstant ksPanelName="GizmoAxisLabelsPanel"

// These procedures replace GizmoLabels.ipf (which used string objects to label only some axes)
// These procedures label all axes using modern Gizmo attributes:
//		ModifyGizmo ModifyObject=axes0,property={0,axisLabel,1}
//		ModifyGizmo ModifyObject=axes0,property={0,axisLabelText,"x0 Axis Label"}
//		ModifyGizmo ModifyObject=axes0,property={0,axisLabelCenter,-0.4}
//		ModifyGizmo ModifyObject=axes0,property={0,axisLabelDistance,1}
//		ModifyGizmo ModifyObject=axes0,property={0,axisLabelRGBA,0,0,0,1}
//		 etc
//

// Public routine
Function WMMakeAxisLabelsPanel(boxAxesName)	// use "" for the top gizmo's first box axes object
	String boxAxesName

	if( strlen(boxAxesName) )
		String/G $PanelDFVar("axesObjectName") = boxAxesName
	endif
	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		NewPanel/N=$ksPanelName/K=1 /W=(47,53,687,502) as "Gizmo Axis Labels"
		DoWindow/C $ksPanelName	// in case a window macro somehow got saved
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorSmall",9,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorSmall",0,0}
		ModifyPanel/W=$ksPanelName fixedSize=1, noEdit=1

		String gizmoName= TopGizmo()
		if( strlen(gizmoName) )
			AutoPositionWindow/E/R=$gizmoName $ksPanelName
		endif
	
		String oldDF= SetPanelDF()

		// Label 0 (top-left group)
		Variable/G label0ShowCheck
		CheckBox appendLabel0,pos={19,11},size={16,14},proc=GizmoAxisLabelsModule#ShowAxisLabelCheckProc,title=""
		CheckBox appendLabel0,fSize=11
		CheckBox appendLabel0,variable= root:Packages:GizmoAxisLabels:label0ShowCheck
	
		String axesListFunction= GetIndependentModuleName()+"#GizmoAxisLabelsModule#AxesListChecked()"
	
		String axesList="X0;Y0;Z0;X1;Y1;Z1;X2;Y2;Z2;X3;Y3;Z3;"
		String axisName= StrVarOrDefault(PanelDFVar("label0AxisName"), "Z1")
		String/G label0AxisName=axisName
		Variable mode= 1+WhichListItem(axisName, axesList, ";" , 0, 0)	// case insensitive
		
		PopupMenu axisLabel0Pop,pos={39,7},size={176,20},proc=GizmoAxisLabelsModule#AxisLabelPopMenuProc,title="Show Axis Label for Axis"
		PopupMenu axisLabel0Pop,fSize=11
		PopupMenu axisLabel0Pop,mode=mode,popvalue=axisName,value= #axesListFunction
	
		String/G label0AxisLabel
		SetVariable label0AxisLabel,pos={42,32},size={261,17},proc=GizmoAxisLabelsModule#AxisLabelSetVarProc,title="Axis Label:"
		SetVariable label0AxisLabel,fSize=11
		SetVariable label0AxisLabel,value= root:Packages:GizmoAxisLabels:label0AxisLabel
	
		Variable/G label0AxisDist
		SetVariable label0AxisDist,pos={40,55},size={120,17},proc=GizmoAxisLabelsModule#AxisDistSetVarProc,title="Axis Dist:"
		SetVariable label0AxisDist,fSize=11
		SetVariable label0AxisDist,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label0AxisDist
	
		Variable/G label0AxisCenter
		SetVariable label0AxisCenter,pos={40,78},size={120,17},proc=GizmoAxisLabelsModule#AxisCenterSetVarProc,title="Center:"
		SetVariable label0AxisCenter,fSize=11
		SetVariable label0AxisCenter,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label0AxisCenter
	
		Variable/G label0AxisTilt
		SetVariable label0AxisTilt,pos={40,102},size={120,17},proc=GizmoAxisLabelsModule#AxisTiltSetVarProc,title="Tilt:"
		SetVariable label0AxisTilt,fSize=11
		SetVariable label0AxisTilt,limits={-180,180,5},value= root:Packages:GizmoAxisLabels:label0AxisTilt
	
		Button label0Reset,pos={212,66},size={50,20},proc=GizmoAxisLabelsModule#ResetButtonProc,title="Reset"
		Button label0Reset,fSize=11
	
		Variable/G label0Flip
		CheckBox label0Flip,pos={219,102},size={36,14},proc=GizmoAxisLabelsModule#FlipCheckProc,title="Flip"
		CheckBox label0Flip,fSize=11,variable= root:Packages:GizmoAxisLabels:label0Flip
	
		// Label 1 (top-right group)
		Variable/G label1ShowCheck
		CheckBox appendLabel1,pos={341,11},size={16,14},proc=GizmoAxisLabelsModule#ShowAxisLabelCheckProc,title=""
		CheckBox appendLabel1,fSize=11
		CheckBox appendLabel1,variable= root:Packages:GizmoAxisLabels:label1ShowCheck
	
		axisName= StrVarOrDefault(PanelDFVar("label1AxisName"), "Z3")
		String/G label1AxisName= axisName
		mode= 1+WhichListItem(axisName, axesList, ";" , 0, 0)	// case insensitive
		
		PopupMenu axisLabel1Pop,pos={361,8},size={176,20},proc=GizmoAxisLabelsModule#AxisLabelPopMenuProc,title="Show Axis Label for Axis"
		PopupMenu axisLabel1Pop,fSize=11
		PopupMenu axisLabel1Pop,mode=mode,popvalue=axisName,value= #axesListFunction
	
		String/G label1AxisLabel
		SetVariable label1AxisLabel,pos={364,32},size={261,17},proc=GizmoAxisLabelsModule#AxisLabelSetVarProc,title="Axis Label:"
		SetVariable label1AxisLabel,fSize=11
		SetVariable label1AxisLabel,value= root:Packages:GizmoAxisLabels:label1AxisLabel
	
		Variable/G label1AxisDist
		SetVariable label1AxisDist,pos={362,55},size={120,17},proc=GizmoAxisLabelsModule#AxisDistSetVarProc,title="Axis Dist:"
		SetVariable label1AxisDist,fSize=11
		SetVariable label1AxisDist,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label1AxisDist
	
		Variable/G label1AxisCenter
		SetVariable label1AxisCenter,pos={362,78},size={120,17},proc=GizmoAxisLabelsModule#AxisCenterSetVarProc,title="Center:"
		SetVariable label1AxisCenter,fSize=11
		SetVariable label1AxisCenter,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label1AxisCenter
	
		Variable/G label1AxisTilt
		SetVariable label1AxisTilt,pos={362,102},size={120,17},proc=GizmoAxisLabelsModule#AxisTiltSetVarProc,title="Tilt:"
		SetVariable label1AxisTilt,fSize=11
		SetVariable label1AxisTilt,limits={-180,180,5},value= root:Packages:GizmoAxisLabels:label1AxisTilt
	
		Button label1Reset,pos={531,66},size={50,20},proc=GizmoAxisLabelsModule#ResetButtonProc,title="Reset"
		Button label1Reset,fSize=11
	
		Variable/G label1Flip
		CheckBox label1Flip,pos={538,102},size={36,14},proc=GizmoAxisLabelsModule#FlipCheckProc,title="Flip"
		CheckBox label1Flip,fSize=11,variable= root:Packages:GizmoAxisLabels:label1Flip
	
		// Label 2 (bottom-left group)
		Variable/G label2ShowCheck
		CheckBox appendLabel2,pos={20,153},size={16,14},proc=GizmoAxisLabelsModule#ShowAxisLabelCheckProc,title=""
		CheckBox appendLabel2,fSize=11
		CheckBox appendLabel2,variable= root:Packages:GizmoAxisLabels:label2ShowCheck
	
		axisName= StrVarOrDefault(PanelDFVar("label2AxisName"), "Y0")
		String/G label2AxisName= axisName
		mode= 1+WhichListItem(axisName, axesList, ";" , 0, 0)	// case insensitive
		
		PopupMenu axisLabel2Pop,pos={40,150},size={176,20},proc=GizmoAxisLabelsModule#AxisLabelPopMenuProc,title="Show Axis Label for Axis"
		PopupMenu axisLabel2Pop,fSize=11
		PopupMenu axisLabel2Pop,mode=mode,popvalue=axisName,value= #axesListFunction

		String/G label2AxisLabel
		SetVariable label2AxisLabel,pos={43,174},size={261,17},proc=GizmoAxisLabelsModule#AxisLabelSetVarProc,title="Axis Label:"
		SetVariable label2AxisLabel,fSize=11
		SetVariable label2AxisLabel,value= root:Packages:GizmoAxisLabels:label2AxisLabel
	
		Variable/G label2AxisDist
		SetVariable label2AxisDist,pos={41,197},size={120,17},proc=GizmoAxisLabelsModule#AxisDistSetVarProc,title="Axis Dist:"
		SetVariable label2AxisDist,fSize=11
		SetVariable label2AxisDist,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label2AxisDist
	
		Variable/G label2AxisCenter
		SetVariable label2AxisCenter,pos={41,220},size={120,17},proc=GizmoAxisLabelsModule#AxisCenterSetVarProc,title="Center:"
		SetVariable label2AxisCenter,fSize=11
		SetVariable label2AxisCenter,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label2AxisCenter
	
		Variable/G label2AxisTilt
		SetVariable label2AxisTilt,pos={41,244},size={120,17},proc=GizmoAxisLabelsModule#AxisTiltSetVarProc,title="Tilt:"
		SetVariable label2AxisTilt,fSize=11
		SetVariable label2AxisTilt,limits={-180,180,5},value= root:Packages:GizmoAxisLabels:label2AxisTilt
	
		Button label2Reset,pos={212,208},size={50,20},proc=GizmoAxisLabelsModule#ResetButtonProc,title="Reset"
		Button label2Reset,fSize=11
	
		Variable/G label2Flip
		CheckBox label2Flip,pos={219,242},size={36,14},proc=GizmoAxisLabelsModule#FlipCheckProc,title="Flip"
		CheckBox label2Flip,fSize=11,variable= root:Packages:GizmoAxisLabels:label2Flip
	
		// Label 3 (bottom-right group)
		Variable/G label3ShowCheck
		CheckBox appendLabel3,pos={341,153},size={16,14},size={16,14},proc=GizmoAxisLabelsModule#ShowAxisLabelCheckProc,title=""
		CheckBox appendLabel3,fSize=11
		CheckBox appendLabel3,variable= root:Packages:GizmoAxisLabels:label3ShowCheck
	
		axisName= StrVarOrDefault(PanelDFVar("label3AxisName"), "X0")
		String/G label3AxisName= axisName
		mode= 1+WhichListItem(axisName, axesList, ";" , 0, 0)	// case insensitive

		PopupMenu axisLabel3Pop,pos={361,150},size={176,20},proc=GizmoAxisLabelsModule#AxisLabelPopMenuProc,title="Show Axis Label for Axis"
		PopupMenu axisLabel3Pop,fSize=11
		PopupMenu axisLabel3Pop,mode=mode,popvalue=axisName,value= #axesListFunction

		String/G label3AxisLabel
		SetVariable label3AxisLabel,pos={364,174},size={261,17},proc=GizmoAxisLabelsModule#AxisLabelSetVarProc,title="Axis Label:"
		SetVariable label3AxisLabel,fSize=11
		SetVariable label3AxisLabel,value= root:Packages:GizmoAxisLabels:label3AxisLabel

		Variable/G label3AxisDist
		SetVariable label3AxisDist,pos={362,197},size={120,17},proc=GizmoAxisLabelsModule#AxisDistSetVarProc,title="Axis Dist:"
		SetVariable label3AxisDist,fSize=11
		SetVariable label3AxisDist,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label3AxisDist
	
		Variable/G label3AxisCenter
		SetVariable label3AxisCenter,pos={362,220},size={120,17},proc=GizmoAxisLabelsModule#AxisCenterSetVarProc,title="Center:"
		SetVariable label3AxisCenter,fSize=11
		SetVariable label3AxisCenter,limits={-2,2,0.05},value= root:Packages:GizmoAxisLabels:label3AxisCenter
	
		Variable/G label3AxisTilt
		SetVariable label3AxisTilt,pos={362,244},size={120,17},proc=GizmoAxisLabelsModule#AxisTiltSetVarProc,title="Tilt:"
		SetVariable label3AxisTilt,fSize=11
		SetVariable label3AxisTilt,limits={-180,180,5},value= root:Packages:GizmoAxisLabels:label3AxisTilt
	
		Button label3Reset,pos={531,208},size={50,20},proc=GizmoAxisLabelsModule#ResetButtonProc,title="Reset"
		Button label3Reset,fSize=11
	
		Variable/G label3Flip
		CheckBox label3Flip,pos={538,243},size={36,14},proc=GizmoAxisLabelsModule#FlipCheckProc,title="Flip"
		CheckBox label3Flip,fSize=11,variable= root:Packages:GizmoAxisLabels:label3Flip
	
		// All group
		GroupBox AllGroupBox,pos={20,291},size={604,60},title="Settings for All axes0 Labels"
		GroupBox AllGroupBox, fsize=11
	
		PopupMenu allLabelColor,pos={41,319},size={109,20},proc=GizmoAxisLabelsModule#AllTextColorPopMenuProc,title="Text Color"
		PopupMenu allLabelColor,fSize=11
		PopupMenu allLabelColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	
		Variable/G labelScale
		SetVariable allLabelScale,pos={175,321},size={120,17},proc=GizmoAxisLabelsModule#AllScaleSetVarProc,title="Scale:"
		SetVariable allLabelScale,fSize=11
		SetVariable allLabelScale,limits={0,2,0.05},value= root:Packages:GizmoAxisLabels:labelScale
	
		PopupMenu allFont,pos={330,319},size={166,20},proc=GizmoAxisLabelsModule#AllLabelsFontPopMenuProc,title="Font:"
		PopupMenu allFont,fSize=11
		PopupMenu allFont,mode=191,value= #"FontList(\";\",1)"
	
		// Misc stuff at the bottom
		String/G topGizmo
		SetVariable topGizmoSV,pos={47,370},size={239,17},disable=2,title="Gizmo Window Name:"
		SetVariable topGizmoSV,fSize=11,frame=0
		SetVariable topGizmoSV,value= root:Packages:GizmoAxisLabels:topGizmo
	
		Variable/G echoCommands
		CheckBox echoCommands,pos={329,372},size={163,14},title="Echo Commands to History"
		CheckBox echoCommands,fSize=11,variable= root:Packages:GizmoAxisLabels:echoCommands
	
		Button axesInfo,pos={45,415},size={124,20},proc=GizmoAxisLabelsModule#AxesInfoButtonProc,title="axes0 Info..."
		Button axesInfo,fSize=13
		
		Button showGizmoBoxAxesPanel,pos={322,413},size={125,20},proc=GizmoAxisLabelsModule#ShowGizmoBoxAxesPanelButtonProc,title="Gizmo Box Axes"
		Button showGizmoBoxAxesPanel,fSize=13

		Button help,pos={532,413},size={87,20},proc=GizmoAxisLabelsModule#HelpButtonProc,title="Help",fSize=13
		
		SetDataFolder oldDF
		
		SetWindow kwTopWin,hook(GizmoAxisLabelsPanelHook)=GizmoAxisLabelsModule#PanelWindowHook
	endif
	
	UpdateGizmoAxisLabelsPanel()
End

static Function/S AxesListChecked()

	String axesList="X0;Y0;Z0;X1;Y1;Z1;X2;Y2;Z2;X3;Y3;Z3;"

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) == 0 )
		return axesList
	endif

	STRUCT CC_CubeLabels savedCubeLabels
	if( !GetSavedCubeLabels(savedCubeLabels) )
		return axesList
	endif
	
	STRUCT CC_AxisLabel savedLabel
	axesList=""
	Variable j
	for(j=0;j<3;j+=1)
		String whichAxis=StringFromList(j,"X;Y;Z;")
		String checked
		Variable whichNum
		for(whichNum=0;whichNum<4;whichNum+=1)
			GetAxisLabel(savedCubeLabels, whichAxis, whichNum, savedLabel)
			if( savedLabel.drawIt )
				checked="\\M0:!" + num2char(18)+":"
			else
				checked=""
			endif
			axesList += checked+whichAxis+num2istr(whichNum)+";"
		endfor
	endfor

	return axesList
End


Static Function PanelWindowHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable statusCode= 0
	strswitch( hs.eventName )
		case "activate":
			UpdateGizmoAxisLabelsPanel()
			break
	endswitch
	return statusCode		// 0 if nothing done, else 1
End

StrConstant ksLabel0Controls="appendLabel0;axisLabel0Pop;label0AxisCenter;label0AxisDist;label0Flip;label0AxisLabel;label0AxisTilt;label0Reset;"
StrConstant ksLabel1Controls="appendLabel1;axisLabel1Pop;label1AxisCenter;label1AxisDist;label1Flip;label1AxisLabel;label1AxisTilt;label1Reset;"
StrConstant ksLabel2Controls="appendLabel2;axisLabel2Pop;label2AxisCenter;label2AxisDist;label2Flip;label2AxisLabel;label2AxisTilt;label2Reset;"
StrConstant ksLabel3Controls="appendLabel3;axisLabel3Pop;label3AxisCenter;label3AxisDist;label3Flip;label3AxisLabel;label3AxisTilt;label3Reset;"

Static Function IsZAxis(axisNameOrWhichAxis)
	String axisNameOrWhichAxis	// "z" or "Z0", etc
	
	Variable isZ= 0
	strswitch( axisNameOrWhichAxis[0] )
		case "z":
			isZ= 1
			break
	endswitch
	
	return isZ
End


// Gets the settings from the gizmo box axes object and sets the controls and global variables
static Function UpdateGizmoAxisLabelsPanel()

	DoWindow $ksPanelName
	if( V_Flag == 0 )
		return 0
	endif

	String allControls= ControlNameList(ksPanelName, ";", "*")
	allControls= RemoveFromList("topGizmoSV;help;", allControls)

	String gizmoName= TopGizmo()
	String/G $PanelDFVar("topGizmo")= gizmoName	// for the topGizmoSV SetVariable

	String boxAxesName=""
	if( strlen(gizmoName) )
		String boxAxesList= GizmoBoxAxesList(gizmoName)
		boxAxesName= StrVarOrDefault(PanelDFVar("axesObjectName"), "")
		if( WhichListItem(boxAxesName, boxAxesList) < 0 )
			boxAxesName= StringFromList(0,boxAxesList)
		endif
	endif

	String/G $PanelDFVar("axesObjectName")= boxAxesName
	
	if( strlen(gizmoName) == 0 || strlen(boxAxesName) == 0 )
		ModifyControlList allControls, win=$ksPanelName, disable=2	// disabled
		DoWindow/T $ksPanelName, "Gizmo Axis Labels"
		return 0	// No Gizmo or No Box Axes Object!
	endif

	ModifyControlList allControls, win=$ksPanelName, disable=0	// show enabled
	DoWindow/T $ksPanelName, "Gizmo Axis Labels for "+boxAxesName

	String oldDF= SetPanelDF()

	STRUCT CC_CubeLabels cubeLabels
	GetCubeLabelsFromGizmoBoxAxes(gizmoName, boxAxesName, cubeLabels)

	SaveCubeLabels(cubeLabels)	// preserve label settings for labels with .drawIt == 0 for next time.
	
	STRUCT CC_AxisLabel thisLabel

	// Label 0 (top-left group)

	// NOTE: we don't SET the popup axis name, we READ it and then set the other controls according to that axes values
	//	PopupMenu axisLabel0Pop
	String axisName= GetAxisLabelForPop("axisLabel0Pop", cubeLabels, thisLabel)	// thisLabel is OUTPUT
	
	Variable/G label0ShowCheck= thisLabel.drawIt			// CheckBox appendLabel0

	String controls= RemoveFromList("appendLabel0;axisLabel0Pop;", ksLabel0Controls)
	Variable disable= thisLabel.drawIt ? 0 : 2
	ModifyControlList controls, win=$ksPanelName, disable=disable	// show enabled

	String/G label0AxisLabel= thisLabel.labelText			// SetVariable label0AxisLabel
	Variable/G label0AxisDist= thisLabel.axisLabelDistance	// SetVariable label0AxisDist
	Variable/G label0AxisCenter= thisLabel.axisLabelCenter	// SetVariable label0AxisCenter
	Variable/G label0AxisTilt= thisLabel.axisLabelTilt		// SetVariable label0AxisTilt

	Variable/G label0Flip= thisLabel.axisLabelFlip		// CheckBox label0Flip
	if( disable == 0 )
		disable= IsZAxis(axisName) ? 0 : 2
		CheckBox label0Flip win=$ksPanelName, disable=disable
	endif
	
	// Label 1 (top-right group)

	//	PopupMenu axisLabel1Pop
	axisName= GetAxisLabelForPop("axisLabel1Pop", cubeLabels, thisLabel)	// thisLabel is OUTPUT
	
	Variable/G label1ShowCheck= thisLabel.drawIt			// CheckBox appendLabel1

	controls= RemoveFromList("appendLabel1;axisLabel1Pop;", ksLabel1Controls)
	disable= thisLabel.drawIt ? 0 : 2
	ModifyControlList controls, win=$ksPanelName, disable=disable	// show enabled

	String/G label1AxisLabel= thisLabel.labelText			// SetVariable label1AxisLabel
	Variable/G label1AxisDist= thisLabel.axisLabelDistance	// SetVariable label1AxisDist
	Variable/G label1AxisCenter= thisLabel.axisLabelCenter	// SetVariable label1AxisCenter
	Variable/G label1AxisTilt= thisLabel.axisLabelTilt		// SetVariable label1AxisTilt

	Variable/G label1Flip= thisLabel.axisLabelFlip			// CheckBox label1Flip
	if( disable == 0 )
		disable= IsZAxis(axisName) ? 0 : 2
		CheckBox label1Flip win=$ksPanelName, disable=disable
	endif

	// Label 2 (bottom-left group)

	//	PopupMenu axisLabel2Pop
	axisName= GetAxisLabelForPop("axisLabel2Pop", cubeLabels, thisLabel)	// thisLabel is OUTPUT
	
	Variable/G label2ShowCheck= thisLabel.drawIt			// CheckBox appendLabel2

	controls= RemoveFromList("appendLabel2;axisLabel2Pop;", ksLabel2Controls)
	disable= thisLabel.drawIt ? 0 : 2
	ModifyControlList controls, win=$ksPanelName, disable=disable	// show enabled

	String/G label2AxisLabel= thisLabel.labelText			// SetVariable label2AxisLabel
	Variable/G label2AxisDist= thisLabel.axisLabelDistance	// SetVariable label2AxisDist
	Variable/G label2AxisCenter= thisLabel.axisLabelCenter	// SetVariable label2AxisCenter
	Variable/G label2AxisTilt= thisLabel.axisLabelTilt		// SetVariable label2AxisTilt

	Variable/G label2Flip= thisLabel.axisLabelFlip			// CheckBox label2Flip
	if( disable == 0 )
		disable= IsZAxis(axisName) ? 0 : 2
		CheckBox label2Flip win=$ksPanelName, disable=disable
	endif

	// Label 3 (bottom-right group)

	//	PopupMenu axisLabel3Pop
	axisName= GetAxisLabelForPop("axisLabel3Pop", cubeLabels, thisLabel)	// thisLabel is OUTPUT
	
	Variable/G label3ShowCheck= thisLabel.drawIt			// CheckBox appendLabel3

	controls= RemoveFromList("appendLabel3;axisLabel3Pop;", ksLabel3Controls)
	disable= thisLabel.drawIt ? 0 : 2
	ModifyControlList controls, win=$ksPanelName, disable=disable	// show enabled

	String/G label3AxisLabel= thisLabel.labelText			// SetVariable label3AxisLabel
	Variable/G label3AxisDist= thisLabel.axisLabelDistance	// SetVariable label3AxisDist
	Variable/G label3AxisCenter= thisLabel.axisLabelCenter	// SetVariable label3AxisCenter
	Variable/G label3AxisTilt= thisLabel.axisLabelTilt		// SetVariable label3AxisTilt

	Variable/G label3Flip= thisLabel.axisLabelFlip			// CheckBox label3Flip
	if( disable == 0 )
		disable= IsZAxis(axisName) ? 0 : 2
		CheckBox label3Flip win=$ksPanelName, disable=disable
	endif
	
	// All group
	Variable anyDrawn= AnyAxisLabelsDrawn(gizmoName,boxAxesName,cubeLabels)
	String title
	if( anyDrawn )
		title="Settings for Shown "+boxAxesName+" Labels"
	else
		title =" Settings for Shown axis Labels (none showing)"
	endif
	GroupBox AllGroupBox,win=$ksPanelName,title=title

	disable= anyDrawn ? 0 : 2
	ModifyControlList "allFont;allLabelColor;allLabelScale;", win=$ksPanelName, disable=disable	// show enabled

	Variable red= cubeLabels.textRed*65535	// convert from 0-1 to 0-65535
	Variable green= cubeLabels.textGreen*65535
	Variable blue= cubeLabels.textBlue*65535
	
	PopupMenu allLabelColor,win=$ksPanelName,popColor= (red,green,blue)
	
	Variable/G labelScale=cubeLabels.scale 	// SetVariable allLabelScale

	String font=cubeLabels.labelFont	// someday, one popup per group
	String fonts= FontList(";",1)
	Variable mode= 1+WhichListItem(font, fonts, ";", 0,0)
	PopupMenu allFont,win=$ksPanelName,mode=mode,popvalue= font

	// Misc stuff at the bottom
	
	// topGizmoSV was removed from allControls so it never is disabled, and it is updated above.
	Button axesInfo, win=$ksPanelName,title=boxAxesName+" Info..."

	SetDataFolder oldDF
	return 1
End

// returns axis name
static Function/S GetAxisLabelForPop(ctrlName, cubeLabels, thisLabel)
	String ctrlName						// input: "axisLabel0Pop", etc
	STRUCT CC_CubeLabels &cubeLabels	// input
	STRUCT CC_AxisLabel &thisLabel	// OUTPUT
	
	String axisName= AxisNameFromControlName(ctrlName)

	String whichAxis
	Variable whichNum
	WhichAxisAndNumForAxisName(axisName, whichAxis, whichNum)

	GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
	return axisName
End

Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:GizmoAxisLabels	// old procedure used root:Packages:GizmoLabels
	return "root:Packages:GizmoAxisLabels"
End

Static Function/S PanelDFVar(varName)
	String varName
	
	return PanelDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End

Static Function/S GizmoBoxAxesList(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName) )
		return "_none_"
	endif

	String boxAxesNameList=""
	String code= WinRecreation(gizmoName, 0)
	
	// parse:
	// AppendToGizmo Axes=boxAxes,name=axes0
	Variable start=0
	do
		String key="AppendToGizmo Axes=boxAxes,name="
		start= Strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		start += strlen(key)	// point past key to name
		Variable theEnd= strsearch(code, num2char(13), start)
		if( theEnd < 0 )
			break
		endif
		boxAxesNameList += code[start, theEnd-1]+";"
		start= theEnd+1
	while(1)
	if( strlen(boxAxesNameList) == 0 )
		boxAxesNameList= "_none_"
	endif
	return boxAxesNameList
End


static Function/S AxisNameFromControlName(ctrlName)
	String ctrlName
	
	String axisName=""
	if( FindListItem(ctrlName, ksLabel0Controls, ";",0,0) >= 0 )
		ControlInfo/W=$ksPanelName axisLabel0Pop
		axisName= S_value
	elseif( FindListItem(ctrlName, ksLabel1Controls, ";",0,0) >= 0 )
		ControlInfo/W=$ksPanelName axisLabel1Pop
		axisName= S_value
	elseif( FindListItem(ctrlName, ksLabel2Controls, ";",0,0) >= 0 )
		ControlInfo/W=$ksPanelName axisLabel2Pop
		axisName= S_value
	elseif( FindListItem(ctrlName, ksLabel3Controls, ";",0,0) >= 0 )
		ControlInfo/W=$ksPanelName axisLabel3Pop
		axisName= S_value
	endif
	return axisName
End

Structure CC_AxisLabel
	int32 drawIt				// property={0,axisLabel,boolean}
	char labelText[100]		// property={0,axisLabelText,"x0 Axis Label"}
	double axisLabelDistance	// property={0,axisLabelDistance,num}	// -1 to 1
	double axisLabelCenter		// property={0,axisLabelCenter,num}	// -1 to 1
	double axisLabelTilt			// property={0,axisLabelTilt,num}	// -180 to 180 (degrees)
	int32 axisLabelFlip			// property={0,axisLabelFlip,boolean} (for Z0-Z3 only)
EndStructure

Structure CC_CubeLabels
	char gizmoName[32]
	char boxAxesName[32]
	char labelFont[100]				// property={0,labelFont,"Arial"}
	double scale							// property={0,axisLabelScale,scale}
	double textRed, textGreen, textBlue	// property={0,axisLabelRGB,red,green,blue}	values are 0-1
	STRUCT CC_AxisLabel xAxisLabels[4]
	STRUCT CC_AxisLabel yAxisLabels[4]
	STRUCT CC_AxisLabel zAxisLabels[4]
EndStructure

Static Function InitCubeLabels(gizmoName,boxAxesName,cubeLabels)
	String gizmoName,boxAxesName
	STRUCT CC_CubeLabels &cubeLabels
	
	cubeLabels.gizmoName= gizmoName
	cubeLabels.boxAxesName= boxAxesName
	Variable isMacintosh= strsearch(IgorInfo(2),"Macintosh",0) >= 0
	if( isMacintosh )
		cubeLabels.labelFont="Geneva"
	else
		cubeLabels.labelFont="Arial"
	endif
	cubeLabels.scale=1.0
	cubeLabels.textRed= 0		// black
	cubeLabels.textGreen= 0	// black
	cubeLabels.textBlue= 0		// black

	STRUCT CC_AxisLabel labelDefaults
	labelDefaults.drawIt=0
	labelDefaults.labelText=""
	labelDefaults.axisLabelDistance=0
	labelDefaults.axisLabelCenter=0
	labelDefaults.axisLabelTilt=0
	labelDefaults.axisLabelFlip=0	
	
	Variable i, axisIndex
	for(i=0;i<4;i+=1)
		cubeLabels.xAxisLabels[i]= labelDefaults
		cubeLabels.yAxisLabels[i]= labelDefaults
		cubeLabels.zAxisLabels[i]= labelDefaults
	endfor
	
End

static Function AnyAxisLabelsDrawn(gizmoName,boxAxesName,cubeLabels)
	String gizmoName,boxAxesName
	STRUCT CC_CubeLabels &cubeLabels

	Variable anyDrawn=0
	Variable j
	STRUCT CC_AxisLabel thisLabel
	for(j=0;j<3;j+=1)
		String whichAxis=StringFromList(j,"x;y;z;")
		Variable whichNum
		for(whichNum=0;whichNum<4;whichNum+=1)
			GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
			if( thisLabel.drawIt )
				return 1
			endif
		endfor
	endfor
	return 0
End


// Gizmo completely forgets any axis label settings when ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabel,0} is called.
// We retrieve them here for ONLY ONE box axes whose settings are stored in the panel's userData. See  GetSavedCubeLabels().
Static Function RememberUndrawnAxisLabels(gizmoName,boxAxesName,cubeLabels)
	String gizmoName,boxAxesName
	STRUCT CC_CubeLabels &cubeLabels
	
	STRUCT CC_CubeLabels savedCubeLabels
	if( !GetSavedCubeLabels(savedCubeLabels) )
		return 0
	endif
	if( CmpStr(savedCubeLabels.gizmoName, cubeLabels.gizmoName) != 0 )
		return 0
	endif
	if( CmpStr(savedCubeLabels.boxAxesName, cubeLabels.boxAxesName) != 0 )
		return 0
	endif
	
	STRUCT CC_AxisLabel thisLabel
	STRUCT CC_AxisLabel savedLabel

	Variable anyDrawn=0
	Variable j
	for(j=0;j<3;j+=1)
		String whichAxis=StringFromList(j,"x;y;z;")
		Variable whichNum
		for(whichNum=0;whichNum<4;whichNum+=1)
			GetAxisLabel(savedCubeLabels, whichAxis, whichNum, savedLabel)
			GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
			if( !thisLabel.drawIt )
				// Gizmo has forgotten any previous axis label settings, which we now restore
				thisLabel= savedLabel
				// except that we still want .drawIt=0
				thisLabel.drawIt= 0
				SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
			else
				anyDrawn=1
			endif
		endfor
	endfor
	if( !anyDrawn )
		// restore  the globals
		cubeLabels.labelFont= savedCubeLabels.labelFont	
		cubeLabels.scale= savedCubeLabels.scale
		cubeLabels.textRed= savedCubeLabels.textRed	
		cubeLabels.textGreen= savedCubeLabels.textGreen	
		cubeLabels.textBlue= savedCubeLabels.textBlue	
	endif
	return 1
End


Static Function GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
	STRUCT CC_CubeLabels &cubeLabels	// input
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisLabel &thisLabel	// output

	if( whichNum < 0 || whichNum > 3 )
		return 0
	endif
	if( numtype(whichNum) != 0 )
		return 0
	endif

	strswitch( whichAxis )
		case "x":
			thisLabel= cubeLabels.xAxisLabels[whichNum]
			break
			
		case "y":
			thisLabel= cubeLabels.yAxisLabels[whichNum]
			break
			
		case "z":
			thisLabel= cubeLabels.zAxisLabels[whichNum]
			break
			
		default:
			return 0
	endswitch
	return 1
End

Static Function SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
	STRUCT CC_CubeLabels &cubeLabels	// input
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisLabel &thisLabel	// input
	
	if( whichNum < 0 || whichNum > 3 )
		return 0
	endif
	if( numtype(whichNum) != 0 )
		return 0
	endif

	strswitch( whichAxis )
		case "x":
			cubeLabels.xAxisLabels[whichNum]= thisLabel
			break
			
		case "y":
			cubeLabels.yAxisLabels[whichNum]= thisLabel
			break
			
		case "z":
			cubeLabels.zAxisLabels[whichNum]= thisLabel
			break
			
		default:
			return 0
	endswitch
	return 1
End

// returns true if the values were gotten
Static Function GetCubeLabelsFromGizmoBoxAxes(gizmoName, boxAxesName, cubeLabels)
	String gizmoName, boxAxesName	// boxAxesName can be "_none_"
	STRUCT CC_CubeLabels &cubeLabels	// output

	InitCubeLabels(gizmoName,boxAxesName,cubeLabels)
	
	String code= WinRecreation(gizmoName, 0)
	// find 	AppendToGizmo Axes=boxAxes,name=axes0
	
	String key="AppendToGizmo Axes=boxAxes,name="+boxAxesName
	Variable start= Strsearch(code, key, 0)
	if( start < 0 )
		return 0
	endif
	start += strlen(key)	// point past key to name

	// now parse the axis info:
	//	ModifyGizmo ModifyObject=axes0,property={0,axisLabel,1}
	//	ModifyGizmo ModifyObject=axes0,property={0,axisLabelText,"x0 Axis Label"}
	//	ModifyGizmo ModifyObject=axes0,property={0,axisLabelCenter,-0.4}
	//	ModifyGizmo ModifyObject=axes0,property={0,axisLabelDistance,1}
	//	ModifyGizmo ModifyObject=axes0,property={0,axisLabelRGBA,0,0,0,1}
	//	etc

	key="ModifyGizmo ModifyObject="+boxAxesName+",property={"

	do
		start= Strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		start += strlen(key)	// point past key to index,
		Variable theEnd= strsearch(code, "}", start)
		if( theEnd < 0 )
			break
		endif
		String parameters= code[start, theEnd-1]	// parameters without the { or }
		start= theEnd+1
		
		// interpret the properties:
		// the first param is the axis index
		Variable axisIndex= str2num(StringFromList(0,parameters,","))	// THIS CAN BE -1
		parameters= RemoveListItem(0,parameters,",")
		String whichAxis
		Variable whichNum
		WhichAxisAndNumForAxisIndex(axisIndex, whichAxis, whichNum)

		// remainder of parameters
		String command= StringFromList(0,parameters,",")
		parameters= RemoveListItem(0,parameters,",")

		Variable i
		String str
		STRUCT CC_AxisLabel thisLabel
		
		strswitch( command )
			case "axisLabel":	// property={0,axisLabel,1} (0 is the axis Index)
				str= StringFromList(0,parameters,",")
				Variable drawIt= str2num(str)
				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].drawIt= drawIt
						cubeLabels.yAxisLabels[i].drawIt= drawIt
						cubeLabels.zAxisLabels[i].drawIt= drawIt
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.drawIt= drawIt
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
			case "axisLabelFont":	// the panel makes this a shared parameter (we just keep updating the shared font name)
				str= StringFromList(0,parameters,",")
				str= RemoveQuotes(str)
				cubeLabels.labelFont= str[0,99]	// 100 char limit
				break
			case "axisLabelScale":	// the panel makes this a shared parameter (we just keep updating the shared axisLabelScale)
				str= StringFromList(0,parameters,",")
				Variable axisLabelScale= str2num(str)
				cubeLabels.scale=axisLabelScale
				break
			case "axisLabelRGB":	// the panel makes this a shared parameter (we just keep updating the shared axisLabelRGB)
			case "axisLabelRGBA":
				Variable textRed= str2num(StringFromList(0,parameters,","))	// 0-1
				Variable textGreen= str2num(StringFromList(1,parameters,","))	// 0-1
				Variable textBlue= str2num(StringFromList(2,parameters,","))	// 0-1
				cubeLabels.textRed=textRed
				cubeLabels.textGreen=textGreen
				cubeLabels.textBlue=textBlue
				break
			case "axisLabelText":
				str= parameters	// StringFromList(0,parameters,",")
				str= RemoveQuotes(str)[0,99]	// 100 char limit
				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].labelText= str
						cubeLabels.yAxisLabels[i].labelText= str
						cubeLabels.zAxisLabels[i].labelText= str
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.labelText= str
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
			case "axisLabelDistance":
				str= StringFromList(0,parameters,",")
				Variable axisLabelDistance= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].axisLabelDistance= axisLabelDistance
						cubeLabels.yAxisLabels[i].axisLabelDistance= axisLabelDistance
						cubeLabels.zAxisLabels[i].axisLabelDistance= axisLabelDistance
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.axisLabelDistance= axisLabelDistance
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
			case "axisLabelCenter":
				str= StringFromList(0,parameters,",")
				Variable axisLabelCenter= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].axisLabelCenter= axisLabelCenter
						cubeLabels.yAxisLabels[i].axisLabelCenter= axisLabelCenter
						cubeLabels.zAxisLabels[i].axisLabelCenter= axisLabelCenter
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.axisLabelCenter= axisLabelCenter
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
			case "axisLabelTilt":
				str= StringFromList(0,parameters,",")
				Variable axisLabelTilt= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].axisLabelTilt= axisLabelTilt
						cubeLabels.yAxisLabels[i].axisLabelTilt= axisLabelTilt
						cubeLabels.zAxisLabels[i].axisLabelTilt= axisLabelTilt
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.axisLabelTilt= axisLabelTilt
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
			case "axisLabelFlip":
				str= StringFromList(0,parameters,",")
				Variable axisLabelFlip= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeLabels.xAxisLabels[i].axisLabelFlip= axisLabelFlip
						cubeLabels.yAxisLabels[i].axisLabelFlip= axisLabelFlip
						cubeLabels.zAxisLabels[i].axisLabelFlip= axisLabelFlip	// This property only affects axes z0, z1, z2, z3.
					endfor
				else
					GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
					thisLabel.axisLabelFlip= axisLabelFlip
					SetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
				endif
				break
		endswitch
	
	while(1)

	RememberUndrawnAxisLabels(gizmoName,boxAxesName,cubeLabels)

	return 1
End

Static Function GetSavedCubeLabels(cubeLabels)
	STRUCT CC_CubeLabels &cubeLabels	// output

	String userData=GetUserData(ksPanelName, "", "axisLabels")	// stored in the window, not a control
	Variable haveUserData= strlen(userData)
	if( haveUserData )
		StructGet/S cubeLabels,userData
	endif
	return haveUserData
End

Static Function SaveCubeLabels(cubeLabels)
	STRUCT CC_CubeLabels &cubeLabels	// input

	String userData
	StructPut/S cubeLabels,userData
	
	SetWindow $ksPanelName userdata(axisLabels)=userData
End


// convert from this procedure's notion of axis name and number
// to Gizmo axis index.
static Function AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
	String whichAxis
	Variable whichNum

	Variable axisIndex=0
	strswitch( whichAxis )
		case "x":
			switch( whichNum )
				case 0:
					axisIndex=0
					break
				case 1:
					axisIndex=9
					break
				case 2:
					axisIndex=10
					break
				case 3:
					axisIndex=11
					break
			endswitch
			break

		case "y":
			switch( whichNum )
				case 0:
					axisIndex=1
					break
				case 1:
					axisIndex=6
					break
				case 2:
					axisIndex=7
					break
				case 3:
					axisIndex=8
					break
			endswitch
			break

		case "z":
			axisIndex= whichNum+2
			break

		case "All":
			axisIndex= -1
			break
	endswitch
	return axisIndex
End

// convert from Gizmo axis index
// to this procedure's notion of axis name and number
static Function WhichAxisAndNumForAxisIndex(axisIndex, whichAxis, whichNum)
	Variable axisIndex
	String &whichAxis
	Variable &whichNum

	switch( axisIndex )
		case 9:
		case 10:
		case 11:
			axisIndex -= 8
		case 0:
			whichAxis= "x"
			whichNum= axisIndex
			break
			
		case 6:
		case 7:
		case 8:
			axisIndex -= 4
		case 1:
			whichAxis= "y"
			whichNum= axisIndex-1
			break
			
		case 2:
		case 3:
		case 4:
		case 5:
			whichAxis= "z"
			whichNum= axisIndex-2
			break
			
		case -1:
			whichAxis= "All"
			whichNum= -1
			break
	endswitch
	
End

// seperates "X0" into "X" and 0
static Function WhichAxisAndNumForAxisName(axisName, whichAxis, whichNum)
	String axisName			// Input, "X0", "Y1", "Z3", etc
	String &whichAxis		// Output, "X", "Y", or "Z"
	Variable &whichNum		// Output 0, 1, 2, 3, or 4
	
	whichAxis= axisName[0]
	whichNum= round(str2num(axisName[1]))
	Variable valid = whichNum >= 0 && whichNum <= 3 && numtype(whichNum) == 0
	if( valid )
		strswitch(whichAxis)
			case "x":
			case "y":
			case "z":
				break
			default:
				valid= 0
				break
		endswitch
	endif
	return valid
End

// returns the index

// ModifyGizmo command use axis indices, as in:
//	ModifyGizmo ModifyObject=axes0,property={axisIndex,propertyName, value(s),...}
static Function AxisIndexForAxisName(axisName)
	String axisName
	
	String whichAxis
	Variable whichNum
	WhichAxisAndNumForAxisName(axisName, whichAxis, whichNum)	// outputs are whichAxis and whichNum
	
	Variable index= AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
	return index
End

Static Function AxisConstantForAxisIndex(axisIndex)
	Variable axisIndex
	
	Variable axisConstant
	switch( axisIndex )
		case 0:
			axisConstant= 4194305
			break
		case 1:
			axisConstant= 4194306
			break
		case 2:
			axisConstant= 4194308
			break
		case 3:
			axisConstant= 4194312
			break
		case 4:
			axisConstant= 4194320
			break
		case 5:
			axisConstant= 4194336
			break
		case 6:
			axisConstant= 4194368
			break
		case 7:
			axisConstant= 4194432
			break
		case 8:
			axisConstant= 4194560
			break
		case 9:
			axisConstant= 4194816
			break
		case 10:
			axisConstant= 4195328
			break
		case 11:
			axisConstant= 4196352
			break
		default:
			axisConstant= 0
			break
	endswitch
	return axisConstant
End

// primitive: if it starts with a quote it is presumed to end with a quote.
Static Function/S RemoveQuotes(str)
	String str
	
	String firstChar= str[0]
	strswitch(firstChar)
		case "\"":
		case "\'":
			Variable len= strlen(str)
			str= str[1,len-2]
			break
	endswitch
	return str
End


static Function/S CurrentOrDefaultAxisLabel(gizmoName,boxAxesName,axisName)
	String gizmoName,boxAxesName,axisName
	
	String axisLabel= axisName+ " axis label"

	STRUCT CC_CubeLabels cubeLabels
	if( !GetCubeLabelsFromGizmoBoxAxes(gizmoName, boxAxesName, cubeLabels) )
		return axisLabel
	endif
	
	STRUCT CC_AxisLabel thisLabel

	String whichAxis
	Variable whichNum
	WhichAxisAndNumForAxisName(axisName, whichAxis, whichNum)

	GetAxisLabel(cubeLabels, whichAxis, whichNum, thisLabel)
	if( strlen(thisLabel.labelText) )
		axisLabel= thisLabel.labelText
	endif
	
	return axisLabel
End

#if 0
Usage:
	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)
#endif

static Function GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)
	String ctrlName	// input
	String &gizmoName, &boxAxesName, &axisName	// OUTPUTS
	
	gizmoName= TopGizmo()
	boxAxesName=StrVarOrDefault(PanelDFVar("axesObjectName"),"")

	axisName= AxisNameFromControlName(ctrlName)

	Variable axisIndex= AxisIndexForAxisName(axisName)

	return axisIndex
End

// Action procs that don't modify the gizmo (only update other controls)

static Function AxisLabelPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	UpdateGizmoAxisLabelsPanel()
End

// Action procs that change the gizmo

static Function ShowAxisLabelCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)


	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabel,checked}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabel,%d}", gizmoName, boxAxesName, axisIndex, checked
	String axisLabel= CurrentOrDefaultAxisLabel(gizmoName,boxAxesName,axisName)	// doing this before Execute prevents the existing label text from being obliterated
	EchoExecute(cmd, slashZ=1)

	if( checked )
		String oldDF= SetPanelDF()

		sprintf cmd, "ModifyGizmo/N=%s startRecMacro", gizmoName	 // to update faster
		Execute/Q/Z cmd

		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", gizmoName, boxAxesName, axisIndex, axisLabel
		EchoExecute(cmd, slashZ=1)
		// Because text color, scale, and font are actually per-axis label, Gizmo uses the defaults when reestablishing the label.
		// Therefore we must re-assert the values (which we do quietly)
		Execute/Q/Z AllTextColorCommand(gizmoName, boxAxesName)
		Execute/Q/Z AllScalesCommand(gizmoName, boxAxesName)
		Execute/Q/Z AllFontsCommand(gizmoName, boxAxesName)

		sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
		Execute/Q/Z cmd

		sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
		Execute/Q/Z cmd

		SetDataFolder oldDF
	endif
	UpdateGizmoAxisLabelsPanel()
End

static Function AxisDistSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelDistance,varNum}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelDistance,%g}", gizmoName, boxAxesName, axisIndex, varNum
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function AxisCenterSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelCenter,varNum}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelCenter,%g}", gizmoName, boxAxesName, axisIndex, varNum
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function AxisTiltSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelTilt,varNum}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelTilt,%g}", gizmoName, boxAxesName, axisIndex, varNum
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function AxisLabelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelText,varStr}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", gizmoName, boxAxesName, axisIndex, varStr
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function ResetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	String cmd
	sprintf cmd, "ModifyGizmo/N=%s startRecMacro", gizmoName	// to update faster
	EchoExecute(cmd, slashZ=1)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelDistance,varNum}
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelDistance,0}", gizmoName, boxAxesName, axisIndex
	EchoExecute(cmd, slashZ=1)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelCenter,varNum}
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelCenter,0}", gizmoName, boxAxesName, axisIndex
	EchoExecute(cmd, slashZ=1)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelTilt,varNum}
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelTilt,0}", gizmoName, boxAxesName, axisIndex
	EchoExecute(cmd, slashZ=1)

	sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
	EchoExecute(cmd, slashZ=1)

	sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
	EchoExecute(cmd, slashZ=1)
	
	UpdateGizmoAxisLabelsPanel()
End

// should be enabled only if a Z axis
static Function FlipCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName, boxAxesName, axisName
	Variable axisIndex= GetActionDetails(ctrlName, gizmoName, boxAxesName, axisName)

	// ModifyGizmo ModifyObject=axes0,property={axisIndex,axisLabelFlip,checked}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisLabelFlip,%d}", gizmoName, boxAxesName, axisIndex, checked
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()

End


static Function AllTextColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	String boxAxesName=StrVarOrDefault(PanelDFVar("axesObjectName"),"")
	String cmd= AllTextColorCommand(gizmoName, boxAxesName)
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function/S AllTextColorCommand(gizmoName, boxAxesName)
	String gizmoName, boxAxesName

	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelRGB, red, green, blue}	// 0-1
	ControlInfo/W=$ksPanelName allLabelColor
	
	V_Red /= 65535	// 0-1
	V_Green /= 65535
	V_Blue /= 65535

	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={-1,axisLabelRGB, %g,%g,%g}", gizmoName, boxAxesName, V_Red, V_Green, V_Blue
	return cmd
End

static Function AllScaleSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName= TopGizmo()
	String boxAxesName=StrVarOrDefault(PanelDFVar("axesObjectName"),"")

	String cmd= AllScalesCommand(gizmoName, boxAxesName)
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()
End

static Function/S AllScalesCommand(gizmoName, boxAxesName)
	String gizmoName, boxAxesName

	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelRGB, red, green, blue}	// 0-1
	ControlInfo/W=$ksPanelName allLabelScale
	
	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelScale, scale}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={-1,axisLabelScale, %g}", gizmoName, boxAxesName, V_Value
	return cmd
End

static Function AllLabelsFontPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	String boxAxesName=StrVarOrDefault(PanelDFVar("axesObjectName"),"")

	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelFont, \"the font\"}
	String cmd= AllFontsCommand(gizmoName, boxAxesName)
	EchoExecute(cmd, slashZ=1)
	UpdateGizmoAxisLabelsPanel()

End

static Function/S AllFontsCommand(gizmoName, boxAxesName)
	String gizmoName, boxAxesName

	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelRGB, red, green, blue}	// 0-1
	ControlInfo/W=$ksPanelName allFont
	
	// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelScale, scale}
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={-1,axisLabelFont, \"%s\"}", gizmoName, boxAxesName, S_Value
	return cmd
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic/K=1 "Gizmo Axis Labels..."
End

// Utility action procs

Static Function AxesInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String boxAxesName= StrVarOrDefault(PanelDFVar("axesObjectName"), "_none_")
	if( CmpStr(boxAxesName,"_none_") == 0 )
		return 0
	endif

	String oldDF= SetPanelDF()
	String cmd
	// ModifyGizmo edit={objTypeName,objName}
	sprintf cmd, "ModifyGizmo edit={Object,%s}", boxAxesName
	Execute/Z/Q cmd
	SetDataFolder oldDF
End

static Function ShowGizmoBoxAxesPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String func=GetIndependentModuleName()+"#WMGizmoBoxAxesPanel"
	if( exists(func) != 6 )
		Execute/P/Q/Z "INSERTINCLUDE <Gizmo Box Axes>"
		Execute/P/Q/Z "COMPILEPROCEDURES "
	endif
	Execute/P/Q/Z func+"()"
End

// code to deal with old labels created by GizmoLabels.ipf

// Public so that Gizmo Box Axes can check and call either the new or old labels code.
// returns:
// 0 - no old axis labels existed
// 1 - old axis labels have been converted
// 2 - old axis labels remain: use the old panel code instead.
Function CheckForOldGizmoAxisLabels(gizmoName,boxAxesName)
	String gizmoName
	String boxAxesName	// apply any found axis labels to this boxAxes

	if( !HaveOldAxisLabels(gizmoName) )
		return 0
	endif

	// don't keep asking
	Variable useWantOldLabelsAlready= 0 == NumVarOrDefault(PanelDFVar("oldAxisLabelApproval"), 999)
	if( useWantOldLabelsAlready )
		return 2	// use old panel code (again)
	endif

	DoAlert 1, "Convert old, tired axis labels to new, improved axis labels?"
	Variable approval= V_Flag == 1	// yes
	Variable/G $PanelDFVar("oldAxisLabelApproval")= approval

	if( approval )
		// copy axis labels from old-style seperate string objects to the box axes
		String WMX0LabelString, WMY0LabelString, WMZ1LabelString, WMZ3LabelString, strFont
		GetOldAxisLabels(gizmoName, WMX0LabelString, WMY0LabelString, WMZ1LabelString, WMZ3LabelString, strFont)

		RemoveOldAxisLabels(gizmoName)

		String cmd

		ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro", gizmoName)	// to update faster

		// X0
		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabel,1}", boxAxesName, 0
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", boxAxesName, 0, WMX0LabelString
		ExecuteGizmoCmd(cmd,gizmoName)

		// Y0
		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabel,1}", boxAxesName, 1
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", boxAxesName, 1, WMY0LabelString
		ExecuteGizmoCmd(cmd,gizmoName)

		// Z1
		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabel,1}", boxAxesName, 3
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", boxAxesName, 3, WMZ1LabelString
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelFlip,1}", boxAxesName, 3
		ExecuteGizmoCmd(cmd,gizmoName)

		// Z3
		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabel,1}", boxAxesName, 5
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelText,\"%s\"}", boxAxesName, 5, WMZ3LabelString
		ExecuteGizmoCmd(cmd,gizmoName)

		sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={%d,axisLabelFlip,1}", boxAxesName, 5
		ExecuteGizmoCmd(cmd,gizmoName)

		if( strlen(strFont) )
			// ModifyGizmo ModifyObject=axes0,property={-1,axisLabelScale, scale}
			sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, property={-1,axisLabelFont, \"%s\"}", boxAxesName, strFont
			ExecuteGizmoCmd(cmd,gizmoName)
		endif

		ExecuteGizmoCmd("ModifyGizmo/N=%s compile", gizmoName)
		ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro", gizmoName)
	endif
	return approval ? 1 : 2
End

static Function HaveOldAxisLabels(gizmoName)
	String gizmoName
	
	// GetGizmo objectItemExists=name
	// determines if the named item is in the Object List.
	// Sets V_Flag=1 if the named item exists in the Object List or V_Flag=0 if it does not exist
	Variable vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMX0LabelString",gizmoName)
	if(vflg==0)
		vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMY0LabelString",gizmoName)
		if(vflg==0)
			vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMZ1LabelString",gizmoName)
			if(vflg==0)
				vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMZ3LabelString",gizmoName)
			endif
		endif
	endif

	return vflg
End

// returns truth  that any of the labels are in the named gizmo
static Function GetOldAxisLabels(gizmoName, WMX0LabelString, WMY0LabelString, WMZ1LabelString, WMZ3LabelString, strFont)
	String gizmoName
	String &WMX0LabelString, &WMY0LabelString, &WMZ1LabelString, &WMZ3LabelString, &strFont	// outputs
	
	WMX0LabelString=""
	WMY0LabelString=""
	WMZ1LabelString=""
	WMZ3LabelString=""
	strFont=""

	Variable foundAnAxisLabel=0
	String code= WinRecreation(gizmoName, 0)
	
	// parse:
	// 	AppendToGizmo string="x0 Label"[,strFont="Verdana"],name=WMX0LabelString

	Variable start=0
	do
		String key="AppendToGizmo string=\""
		start= strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		Variable theEnd= strsearch(code, num2char(13), start)	// point to the end of the line
		if( theEnd < 0 )
			break
		endif
		String line= code[start, theEnd-1]	

		Variable stringStart= strlen(key)	// point past key to string value in line[]
		
		key= "\","	// find end of string value
		
		Variable stringEnd = strsearch(line, key, stringStart)
		if( stringEnd >= 0 )
			String value= line[stringStart,stringEnd]
			
			// optionally find ,strFont="fontName",
			key= ",strFont=\""
			Variable fontStart=strsearch(line, key, stringEnd+1)
			if( fontStart >= 0 )
				fontStart += strlen(key)
				Variable fontEnd= strsearch(line,  "\",", fontStart)
				if( fontEnd > 0 )
					strFont= line[fontStart,fontEnd]
				endif
			endif
			
			// find ,name=
			key= ",name="
			Variable nameStart=strsearch(line, key, stringEnd+1)
			if( nameStart >= 0 )
				nameStart += strlen(key)
				String name=line[nameStart,999]
				strswitch(name)
					case "WMX0LabelString":
						WMX0LabelString=value
						foundAnAxisLabel= 1
						break
					case "WMY0LabelString":
						WMY0LabelString=value
						foundAnAxisLabel= 1
						break
					case "WMZ3LabelString":
						WMZ3LabelString=value
						foundAnAxisLabel= 1
						break
					case "WMZ1LabelString":
						WMZ1LabelString=value
						foundAnAxisLabel= 1
						break
				endswitch
			endif
		endif
		start= theEnd+1
	while(1)
	
	return foundAnAxisLabel
End


static Function RemoveOldAxisLabels(gizmoName)
	String gizmoName
	
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)

	// X0
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0pushMatrix ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0Tilt",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMX0popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z object=WMX0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z attribute=WMX0LabelColor",gizmoName)

	// Y0
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0pushMatrix ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0Tilt",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMY0popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z object=WMY0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z attribute=WMY0LabelColor",gizmoName)
	
	// Z1
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1pushMatrix ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1RotateZ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ1popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z object=WMZ1LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z attribute=WMZ1LabelColor",gizmoName)

	// Z3
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3pushMatrix ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3RotateZ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z displayItem=WMZ3popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z object=WMZ3LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/N=%s/Z attribute=WMZ3LabelColor",gizmoName)

	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
End

// Users have noticed that the Gizmo command are never echoed to the history, so we do that now.
// Users can set root:Packages:GizmoBoxAxes:echoCommands to zero to suppress this printing
// (CheckBox echoCommands does that)

static Function EchoExecute(command, [slashP, slashZ])
	String command
	Variable slashP, slashZ
	
	if( ParamIsDefault(slashP) )
		slashP= 0
	endif
	if( ParamIsDefault(slashZ) )
		slashZ= 0
	endif
	Variable slashQ= NumVarOrDefault(PanelDFVAR("echoCommands"),1) ? 0 : 1

	GizmoEchoExecute(command, slashQ=slashQ, slashP=slashP, slashZ=slashZ)
End


// quiet, non /P version
static Function ExecuteGizmoCmd(commandFormat,gizmoName)
	String gizmoName
	String commandFormat	// something like "ModifyGizmo/N=%s startRecMacro"
	
	if( !ValidGizmoName(gizmoName) )
		return NaN
	endif

	String oldDF= SetPanelDF()
	String cmd
	sprintf cmd, commandFormat, gizmoName
	
	Execute/Q/Z cmd
	Variable vflg= NumVarOrDefault("V_Flag",Nan)
	SetDataFolder oldDF

	return vflg
End

