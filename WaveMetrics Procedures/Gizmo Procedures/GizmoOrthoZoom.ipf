#pragma rtGlobals=3		// Use modern global access method.
#pragma moduleName=GizmoOrthoZoom
#pragma IgorVersion=6.2	// requires Igor 6.2
#pragma version=8.03	// shipped with Igor 8.03
#include <GizmoUtils>

// 5/25/2010, Version 6.2, initial release
//
// The Zoom slider makes the objects in the Gizmo window apear larger or smaller,
// and the Pan sliders shift them up/down/left/right.
//

// 06MAY15 make sure this does not show up on IP7 menu bar 
//#if IgorVersion()<7
// 19JUN15 replaced #if test here by #if test in All Gizmo Procedures.ipf

static StrConstant ksPanelName="GizmoOrthoZoomPanel"

static Constant ksSmallHeightPixels= 350	//	400-50	NewPanel /K=1 /W=(772,50,1070,400) as "Zoom"
static Constant ksTallHeightPixels= 412		//	462-50	NewPanel /K=1 /W=(772,50,1071,462) as "Zoom"


// Public Routines
Menu "Gizmo Zoom", dynamic
	"Zoom And Pan Panel", /Q, ShowGizmoOrthoZoomPanel(0) 
//	"Zoom And Pan Floater", /Q, ShowGizmoOrthoZoomPanel(1) 
	"-"
	// It sure would be nice if these could be in the Gizmo menu.
	// These routines are actually in GizmoUtils.ipf
	PreserveGizmoAspectRatioMenu(""),/Q, TogglePreserveGizmoAspectRatio("")
	CentralBoxKeptSquareMenu(""),/Q, ToggleKeepGizmoCentralBoxSquare("")
//	PreserveGizmoUserWidthMenu(""),/Q, TogglePreserveGizmoUserWidth("")
	MakeGizmoAspectRatioMenu("",1,1),/Q, MakeGizmoAspectRatio("",1)
	MakeGizmoAspectRatioMenu("",4,3),/Q, MakeGizmoAspectRatio("",4/3)
	MakeGizmoAspectRatioMenu("",16,9),/Q, MakeGizmoAspectRatio("",16/9)
End


Function ShowGizmoOrthoZoomPanel(FLT_flag) 
	Variable FLT_flag
	
	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		Variable top=59
		Variable bottom= top+ksSmallHeightPixels
		NewPanel/FLT=(FLT_flag)/W=(265,top,566,bottom)/N=$ksPanelName/K=1 as "Gizmo Zoom"
		ModifyPanel fixedSize=1,noedit=1
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		// Zoom
		TitleBox ZoomTitle,pos={62,4},size={32,16},title="Zoom",frame=0
		GroupBox zoomGroup,pos={11,25},size={150,234},frame=0
		Slider orthoSlider,pos={36,70},size={22,150},proc=GizmoOrthoZoom#OrthoZoomSliderProc
		Slider orthoSlider,limits={3,0.01,0},value= 2,ticks=-20	// no labels
		TitleBox zoomOutTitle,pos={67,202},size={57,16},title="Zoom Out",frame=0
		TitleBox zoomInTitle,pos={70,65},size={46,16},title="Zoom In",frame=0
		if( FLT_flag )
			Button getOrthoForSlider,pos={26,37},size={110,20},proc=GizmoOrthoZoom#GizmoOrthoButtonProc,title="Read from Gizmo"
		else
			SetVariable outLimit,pos={26,37},size={119,16},bodyWidth=40,proc=GizmoOrthoZoom#ZoomOutLimitSetVarProc,title="Zoom Out Limit"
			SetVariable outLimit,fSize=10,limits={2,10,1},value= _NUM:3,live= 1
		endif
		Button defaultOrtho,pos={73,125},size={60,40},proc=GizmoOrthoZoom#GizmoOrthoButtonProc,title="Default\rZoom"
		
		CheckBox keepCentralBoxSquare,pos={26,235},size={119,14},proc=GizmoOrthoZoom#KeepCentralBoxSquareCheckProc,title="Keep Ortho Box Square"
		CheckBox keepCentralBoxSquare,fSize=9,value= 0

		// Pan
		GroupBox panGroup,pos={11,25},size={276,297},frame=0
		TitleBox PanTitle,pos={202,4},size={21,16},title="Pan",frame=0
		Button defaultPan,pos={209,125},size={60,40},proc=GizmoOrthoZoom#GizmoPanButtonProc,title="Default\rPan"

		// Up/Down
		Slider upDownPanSlider,pos={176,70},size={22,150},proc=GizmoOrthoZoom#UpDownSliderProc
		Slider upDownPanSlider,limits={3,-3,0},value= 0,ticks= -3
		TitleBox upTitle,pos={208,70},size={40,16},title="Pan Up",frame=0
		TitleBox DownTitle,pos={208,202},size={57,16},title="Pan Down",frame=0

		// Left/ Right
		Slider leftRightPanSlider,pos={27,290},size={241,22},proc=GizmoOrthoZoom#LeftRightSliderProc
		Slider leftRightPanSlider,limits={3,-3,0},value= 0,side= 2,vert= 0,ticks= -3
		TitleBox RightTitle,pos={214,265},size={54,16},title="Pan Right",frame=0
		TitleBox LeftTitle,pos={27,265},size={49,16},title="Pan Left",frame=0
		
		// Ortho values are placed initially offscreen	
		CheckBox showRanges,pos={13,332},size={101,14},proc=GizmoOrthoZoom#ShowOrthoRangesCheckProc,title="Show Ortho Values"
		CheckBox showRanges,fSize=9,value= 0,mode=2

		SetVariable left,pos={39,352},size={102,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Left"
		SetVariable left,fSize=9,limits={-3,3,0.01},value= _NUM:-2
		SetVariable right,pos={170,352},size={106,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Right"
		SetVariable right,fSize=9,limits={-3,3,0.01},value= _NUM:2
		SetVariable bottom,pos={24,370},size={117,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Bottom"
		SetVariable bottom,fSize=9,limits={-3,3,0.01},value= _NUM:-2
		SetVariable top,pos={175,370},size={101,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Top"
		SetVariable top,fSize=9,limits={-3,3,0.01},value= _NUM:2
		SetVariable back,pos={37,388},size={104,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Back"
		SetVariable back,fSize=9,limits={-3,3,0.01},value= _NUM:-2
		SetVariable front,pos={169,388},size={107,15},bodyWidth=80,proc=GizmoOrthoZoom#OrthoSetVarProc,title="Front"
		SetVariable front,fSize=9,limits={-3,3,0.01},value= _NUM:2

		if( FLT_flag )
			SetActiveSubwindow _endfloat_
		endif
		SetWindow $ksPanelName hook(orthoZoom)=GizmoOrthoZoom#GizmoOrthoWindowHook
	endif
	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		AutoPositionWindow/M=0/E/R=$gizmoName $ksPanelName
		InitOrthoFromTopGizmo()
	endif
End

Static Function InitOrthoFromTopGizmo()

	return InitOrthoFromGizmo(TopGizmo())
End
	
Static Function InitOrthoFromGizmo(gizmoName)
	String gizmoName
	
	if( ValidGizmoName(gizmoName) )
		Variable upDownCenter, leftRightCenter
		Variable ortho= GetGizmoOrthCenters(gizmoName, upDownCenter, leftRightCenter)

		// Zoom
		ControlInfo/W=$ksPanelName outLimit	// optional control limits the maximum ortho for the Slider and window
		if( (V_Flag == 5) && (ortho > V_Value) )
			Variable orthoLimit= ceil(ortho)
			SetVariable outLimit, win=$ksPanelName,value= _NUM:orthoLimit
			Slider orthoSlider, win=$ksPanelName,limits={orthoLimit,0.01,0}	// Note: Slider low > high intentionally.
		endif
		
		// The Zoom slider is either the maximum of the horizontal and vertical ortho ranges
		// or if keepCentralBoxSquare is set, then the preferred range based on keepUsersWidth
		Slider orthoSlider, win=$ksPanelName, value=ortho
		
		Variable mustStaySquare= 0	// output of IsGizmoCentralBoxKeptSquare
		Variable/G $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")= IsGizmoCentralBoxKeptSquare(gizmoName,mustStaySquare=mustStaySquare)
		Variable disable= mustStaySquare ? 2 : 0
		CheckBox keepCentralBoxSquare, win=$ksPanelName, variable=$WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare"),disable=disable
		
		// Pan
		Slider upDownPanSlider, win=$ksPanelName, value=upDownCenter
		Slider leftRightPanSlider, win=$ksPanelName, value=leftRightCenter
	endif
	ShowOrthoRanges(gizmoName)
End

Static Function GizmoOrthoWindowHook(s)
	STRUCT WMWinHookStruct &s
	strswitch(s.eventName)
		case "activate":
			InitOrthoFromTopGizmo()
			break
	endswitch
	return 0
End

// +++++++++++++++++ Private Support Rroutines +++++++++++++

Static Function/S TempDF()
	return "root:Packages:GizmoOrthoZoom"
End

Static Function/S TempDFVar(varName)
	String varName
	
	return TempDF()+":"+PossiblyQuoteName(varName)
End

// set the data folder to a place where Execute can dump all kinds of variables and waves
Static Function/S SetTempDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $TempDF()	// DF is left pointing here
	return oldDF
End


// Returns 1/2 the range of the preferred of the horizontal and vertical ortho:
// 	(rightOrtho-leftOrtho)/2 or (topOrtho-bottomOrtho)/2
// based on keepUsersWidth (whose default is 0).
//
// NOTE: When keepCentralBoxSquare is set and the window isn't square,
// then the horizontalScale (horizontal ortho range) is different than the verticalScale.)
Static Function GetGizmoOrthoScales(gizmoName[,horizontalScale, verticalScale])
	String gizmoName
	Variable &horizontalScale, &verticalScale 	// optional outputs

	Variable left, right, bottom, top, zNear, zFar
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

	Variable hs= abs(right-left)/2		// note: the left/right offset can range from -horizontalScale to +horizontalScale
	if( !ParamIsDefault(horizontalScale) )
		horizontalScale= hs
	endif
	Variable vs= abs(top-bottom)/2		// note: the up/down offset can range from -verticalScale to +verticalScale
	if( !ParamIsDefault(verticalScale) )
		verticalScale= vs
	endif
	
	Variable scale= max(hs,vs)
	if( IsGizmoCentralBoxKeptSquare(gizmoName) )
		Variable keepUsersWidth, windowAspectRatio
		GetGizmoAspectRatio(gizmoName, windowAspectRatio,keepUsersWidth=keepUsersWidth )
		scale= keepUsersWidth ? hs : vs
	endif
	
	return scale
End

// The returned "scale" is the preferred of the horizontal and vertical ortho ranges, based on keepUsersWidth
Static Function GetGizmoOrthCenters(gizmoName, upDownCenter, leftRightCenter)
	String gizmoName
	Variable &upDownCenter, &leftRightCenter

	Variable left, right, bottom, top, zNear, zFar
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

	upDownCenter= (top+bottom)/2
	leftRightCenter= (left+right)/2

	return GetGizmoOrthoScales(gizmoName)
End

Static Function SetTopGizmoOrtho(newOrthoScale)
	Variable newOrthoScale	// 0.01 to 2, usually., the max scale based

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	newOrthoScale= abs(newOrthoScale)

	// Get the current center (that'll stay the same).
	// Get zNear, zFar, displayListIndex and opName for SetGizmoOrtho, too.
	Variable left, right, bottom, top, zNear, zFar,displayListIndex
	String opName
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
	
	Variable upDownCenter= (top+bottom)/2
	Variable leftRightCenter= (left+right)/2

	// compute the new ortho range
	left= leftRightCenter - newOrthoScale
	right= leftRightCenter + newOrthoScale
	
	bottom= upDownCenter - newOrthoScale
	top= upDownCenter + newOrthoScale
	
	// then possibly re-adjust them for the window's aspect ratio and IsGizmoCentralBoxKeptSquare()
	AdjustedGizmoOrtho4AspectRatio(gizmoName, left, right, bottom, top, zNear, zFar)
	
	UpdateGizmoHookForAspectAndBox(gizmoName)

	SetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
End


Static Function OrthoZoomSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable ortho = sa.curval
				SetTopGizmoOrtho(ortho)
				ShowOrthoRanges("")
			endif
			break
	endswitch

	return 0
End

static Function GizmoOrthoButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	strswitch(ctrlName)
		case "getOrthoForSlider":
			InitOrthoFromTopGizmo()
			break
		case "defaultOrtho":
			SetTopGizmoOrtho(2)
			Slider orthoSlider, win=$ksPanelName, value=2
			ControlInfo/W=$ksPanelName outLimit	// optional control limits the maximum ortho for the Slider and window
			if( (V_Flag == 5)  )
				SetVariable outLimit, win=$ksPanelName,value= _NUM:3
			endif
			break
	endswitch
	ShowOrthoRanges("")
End

static Function ZoomOutLimitSetVarProc(ctrlName,orthoLimit,varStr,varName) : SetVariableControl
	String ctrlName
	Variable orthoLimit
	String varStr
	String varName
	
	ControlInfo/W=$ksPanelName orthoSlider
	Slider orthoSlider, win=$ksPanelName,limits={orthoLimit,0.01,0}
	if( V_Value > orthoLimit )
		Slider orthoSlider, win=$ksPanelName,value=orthoLimit
		SetTopGizmoOrtho(orthoLimit)
		ShowOrthoRanges("")
	endif 
End

static Function KeepCentralBoxSquareCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName= TopGizmo()
	if( ValidGizmoName(gizmoName) )
		Variable/G $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")= checked
		ControlInfo/W=$ksPanelName orthoSlider
		Variable ortho= V_Value
		SetTopGizmoOrtho(ortho)
		ShowOrthoRanges("")
	endif
End

// ++++++++ Pan controls. The Sliders are set to -3 to 3 range for now.
// TO DO: Add a [x] Fine Adjust control at the top near the Zoom Out Limit.

Static Function SetTopGizmoPan(newPanCenter, isLeftRight)
	Variable newPanCenter
	Variable isLeftRight	// 1 if left/right center. 0 if up/down center

	String gizmoName= TopGizmo()
	
	// Keep the zNear, zFar the same, too. Also get the displayListIndex and opName for the command.
	Variable left, right, bottom, top, zNear, zFar,displayListIndex
	String opName
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
	
	// keep the scale (ortho range) the same, just alter the center

	Variable range

	if( isLeftRight )
		range= (right-left)/2
		Variable leftRightCenter= newPanCenter
		left= leftRightCenter - range
		right= leftRightCenter + range
	else
		range= (top-bottom)/2
		Variable upDownCenter= newPanCenter
		bottom= upDownCenter - range
		top= upDownCenter + range
	endif
	
	SetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
End

Static Function LeftRightSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set
		String gizmoName= TopGizmo()
		if( strlen(gizmoName) )
			SetTopGizmoPan(sliderValue, 1)
			ShowOrthoRanges(gizmoName)
		endif
	endif

	return 0
End

Static Function UpDownSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set
		String gizmoName= TopGizmo()
		if( strlen(gizmoName) )
			SetTopGizmoPan(sliderValue, 0)
			ShowOrthoRanges(gizmoName)
		endif
	endif

	return 0
End

static Function GizmoPanButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		SetTopGizmoPan(0, 0)
		SetTopGizmoPan(0, 1)
		Slider upDownPanSlider, win=$ksPanelName,value=0
		Slider leftRightPanSlider, win=$ksPanelName,value=0
		ShowOrthoRanges(gizmoName)
	endif
End

static Function ShowOrthoRanges(gizmoName)
	String gizmoName
	
	if( ValidGizmoName(gizmoName) )
		Variable left, right, bottom, top, zNear, zFar
		GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

		Variable orthoLimit= 3	// default
		ControlInfo/W=$ksPanelName outLimit	// optional control
		if( V_Flag == 5 ) 
			orthoLimit= V_Value
		endif
		SetVariable left,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:left
		SetVariable right,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:right
		SetVariable bottom,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:bottom
		SetVariable top,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:top
		SetVariable back,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:zNear
		SetVariable front,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:zFar
	else
		SetVariable left,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
		SetVariable right,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
		SetVariable bottom,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
		SetVariable top,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
		SetVariable back,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
		SetVariable front,win=$ksPanelName,limits={-orthoLimit,orthoLimit,0.01},value= _NUM:NaN
	endif
End

static Function SetOrthoRangesFromSetVariables(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	// Get the displayListIndex and opName for the command.
	Variable left, right, bottom, top, zNear, zFar,displayListIndex
	String opName
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
	
	ControlInfo/W=$ksPanelName left
	left= V_Value
	
	ControlInfo/W=$ksPanelName right
	right= V_Value
	
	ControlInfo/W=$ksPanelName bottom
	bottom= V_Value
	
	ControlInfo/W=$ksPanelName top
	top= V_Value
	
	ControlInfo/W=$ksPanelName back
	zNear= V_Value
	
	ControlInfo/W=$ksPanelName front
	zFar= V_Value
	
	SetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, displayListIndex=displayListIndex, opName=opName)

	// cheap way to set all the other controls.
	InitOrthoFromGizmo(gizmoName)
End


static Function ShowOrthoRangesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Variable heightPixels= checked ? ksTallHeightPixels : ksSmallHeightPixels
	Variable heightPoints = heightPixels * (72/ScreenResolution)	// Convert pixels to points
	GetWindow $ksPanelName wsizeRM
	V_bottom = V_top + heightPoints
	MoveWindow/W=$ksPanelName V_left, V_top, V_right, V_bottom
End

static Function OrthoSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SetOrthoRangesFromSetVariables("")
End
