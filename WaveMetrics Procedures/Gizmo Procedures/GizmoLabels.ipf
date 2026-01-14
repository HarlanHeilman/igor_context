#pragma rtGlobals=3		// Use modern global access method.
#pragma modulename=GizmoAxisLabels
#pragma IgorVersion=6.2// for rtGlobals=3
#pragma version=6.2	// Shipped with Igor 6.2

// NOTE: This procedure file has been obsoleted by GizmoAxisLabels.ipf
#include <GizmoUtils>

// AG23AUG02 - Initial Revision
// JP14MAR05, 5.04 - detects existing labels, made functions static, added color popups and reset buttons, made the settings gizmo-window-specific.
// JP07AUG14, 6.02 - better initial control sizes for the panel checkboxes and color popups, default font is Times New Roman, added Font popup (for all labels)
// JP08SEP16, 6.05 - works when included into an independent module, which required replacing Procs with Functions.
// JP10MAY11, 6.2 - #pragma rtGlobals=3, used GizmoUtils instead of duplicated static routines.

// Public routine
Function WMMakeLabelsPanel()

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		DoWindow/K GizmoAxisLabels
		DoAlert 0, "You must have an open Gizmo Window."
		return 0
	endif

	DoWindow/F GizmoAxisLabels
	if(V_Flag==0)
		NewPanel /K=1/W=(305,50,805,398) as "Axis Labels"
		DoWindow/C GizmoAxisLabels
		ModifyPanel/W=GizmoAxisLabels fixedSize=1//, noEdit=1
		AutoPositionWindow/E/R=$gizmoName GizmoAxisLabels

		// Z1
		Checkbox appendZ1,pos={9,8},size={90,14},proc=GizmoAxisLabels#appendz1ButtonProc,title="Append Z1 Label"
		
		SetVariable z1AxisDistSetVar,pos={16,33},size={120,15},proc=GizmoAxisLabels#z1AxisDistSetVarProc,title="Axis Dist:"
		SetVariable z1AxisDistSetVar,limits={-2,2,0.05}
		
		SetVariable z1CenterSetVar,pos={16,51},size={120,15},proc=GizmoAxisLabels#z1CenterSetVarProc,title="Center:"
		SetVariable z1CenterSetVar,limits={-2,2,0.05}
		
		SetVariable z1ScaleSetvar,pos={16,69},size={120,15},proc=GizmoAxisLabels#z1ScaleSetVarProc,title="Scale:"
		SetVariable z1ScaleSetvar,limits={0,2,0.05}
		
		SetVariable z1AxisLabelsetvar,pos={16,92},size={200,15},proc=GizmoAxisLabels#z1AxisLabelSetVarProc,title="Axis Label:"
		
		PopupMenu z1LabelColor,pos={117,5},size={50,20},proc=GizmoAxisLabels#z1ColorPopMenuProc,value= #"\"*COLORPOP*\""
		
		Button z1Reset,pos={153,48},size={50,20},proc=GizmoAxisLabels#z1Reset,title="Reset"
	
		// Z3
		Checkbox appendZ3,pos={252,10},size={90,14},proc=GizmoAxisLabels#appendZ3ButtonProc,title="Append Z3 Label"
		
		SetVariable z3AxisDistSetVar,pos={253,32},size={120,15},proc=GizmoAxisLabels#z3DistSetVarProc,title="Axis Dist:"
		SetVariable z3AxisDistSetVar,limits={-2,2,0.05}
	
		SetVariable z3ScaleSetVar,pos={254,71},size={120,15},proc=GizmoAxisLabels#z3ScaleSetVarProc,title="Scale:"
		SetVariable z3ScaleSetVar,limits={0,2,0.05}
	
		SetVariable z3CenterSetVar,pos={253,50},size={120,15},proc=GizmoAxisLabels#z3CenterSetVarProc,title="Center:"
		SetVariable z3CenterSetVar,limits={-2,2,0.05}
	
		SetVariable z3StringSetVar,pos={251,92},size={200,15},proc=GizmoAxisLabels#z3StringSetVarProc,title="Axis Label:"

		PopupMenu z3LabelColor,pos={363,5},size={50,20},proc=GizmoAxisLabels#z3ColorPopMenuProc,value= #"\"*COLORPOP*\""
		
		Button z3Reset,pos={390,49},size={50,20},proc=GizmoAxisLabels#z3Reset,title="Reset"

		// Y0
		Checkbox appendY0,pos={10,134},size={91,14},proc=GizmoAxisLabels#y0LabelButtonProc,title="Append Y0 Label"
	
		SetVariable y0DistSetVar,pos={16,162},size={120,15},proc=GizmoAxisLabels#y0AxisDistSetVarProc,title="Axis Dist:"
		SetVariable y0DistSetVar,limits={-2,2,0.05}
		
		SetVariable y0CenterSetVar,pos={16,182},size={120,15},proc=GizmoAxisLabels#y0AxisDistSetVarProc,title="Center:"
		SetVariable y0CenterSetVar,limits={-2,2,0.05}
		
		SetVariable y0HeightSetVar,pos={16,202},size={120,15},proc=GizmoAxisLabels#y0AxisDistSetVarProc,title="Height:"
		SetVariable y0HeightSetVar,limits={-2,2,0.05}
		
		SetVariable y0ScaleSetVar,pos={16,221},size={120,15},proc=GizmoAxisLabels#y0ScaleSetVarProc,title="Scale:"
		SetVariable y0ScaleSetVar,limits={0,2,0.05}
		
		SetVariable y0TiltSetvar,pos={16,241},size={120,15},proc=GizmoAxisLabels#y0TiltSetVarProc,title="Tilt"
		SetVariable y0TiltSetvar,limits={-180,180,5}
		
		SetVariable y0LabelSetVar,pos={13,260},size={200,15},proc=GizmoAxisLabels#y0AxisLabelSetVarProc,title="Axis Label:"

		PopupMenu y0LabelColor,pos={117,131},size={50,20},proc=GizmoAxisLabels#y0ColorPopMenuProc,value= #"\"*COLORPOP*\""
		
		Button y0Reset,pos={153,199},size={50,20},proc=GizmoAxisLabels#y0Reset,title="Reset"

		// X0
		Checkbox appendX0,pos={254,133},size={91,14},proc=GizmoAxisLabels#x0LabelButtonProc,title="Append X0 Label"
	
		SetVariable x0DistSetVar,pos={257,163},size={120,15},proc=GizmoAxisLabels#x0AxisDistSetVarProc,title="Axis Dist:"
		SetVariable x0DistSetVar,limits={-2,2,0.05}
		
		SetVariable x0CenterSetvar,pos={257,183},size={120,15},proc=GizmoAxisLabels#x0AxisDistSetVarProc,title="Center:"
		SetVariable x0CenterSetvar,limits={-2,2,0.05}
		
		SetVariable x0HeightSetVar,pos={257,203},size={120,15},proc=GizmoAxisLabels#x0AxisDistSetVarProc,title="Height:"
		SetVariable x0HeightSetVar,limits={-2,2,0.05}
		
		SetVariable x0LabelSetvar,pos={257,260},size={200,15},proc=GizmoAxisLabels#x0AxisLabelSetVarProc,title="Axis Label:"
	
		SetVariable x0ScaleSetVar,pos={257,223},size={120,15},proc=GizmoAxisLabels#x0ScaleSetVarProc,title="Scale:"
		SetVariable x0ScaleSetVar,limits={0,2,0.05}
		
		SetVariable x0TiltSetVar,pos={257,241},size={120,15},proc=GizmoAxisLabels#x0TiltSetVarProc,title="Tilt:"
		SetVariable x0TiltSetVar,limits={-180,180,5}

		PopupMenu x0LabelColor,pos={363,131},size={50,20},proc=GizmoAxisLabels#x0ColorPopMenuProc,value= #"\"*COLORPOP*\""

		Button x0Reset,pos={390,199},size={50,20},proc=GizmoAxisLabels#x0Reset,title="Reset"

		// Font
		PopupMenu font,pos={88,287},size={308,20},proc=GizmoAxisLabels#FontPopMenuProc,title="Font for Axis Labels:",value= #"FontList(\";\",1)"

		// Info
		Button gizmoInfo,pos={18,316},size={150,20},proc=GizmoAxisLabels#GizmoInfoButtonProc,title="Gizmo Info"

		// update for gop gizmo		
		SetWindow kwTopWin,hook(GizmoLabels)=GizmoAxisLabels#PanelWindowHook

		UpdateGizmoLabelsPanel()
	//else
		// activate event will update the controls for the top gizmo
	endif
	
End

Static Function PanelWindowHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable statusCode= 0
	strswitch( hs.eventName )
		case "activate":
			UpdateGizmoLabelsPanel()
			break
	endswitch
	return statusCode		// 0 if nothing done, else 1
End

// Z3 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static Function addZ3Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3pushMatrix, operation=pushMatrix",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3rotateXm90, operation=rotate, data={-90,1,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3RotateY, operation=rotate, data={45,0,1,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3translate, operation=translate, data={1.5,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3RotateZ, operation=rotate, data={90,0,0,1}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3Scale, operation=scale, data={0.25,0.25,0.25}",gizmoName)
	Variable vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMZ3LabelString",gizmoName)
	if( vflg == 0 )
		ExecuteGizmoCmd("AppendToGizmo/N=%s  string=\"z3Label\",strFont=\"Times New Roman\",name=WMZ3LabelString",gizmoName)
	endif
	vflg= ExecuteGizmoCmd("GetGizmo/N=%s attributeItemExists=WMZ3LabelColor",gizmoName)
	if(vflg==0)
		ExecuteGizmoCmd("AppendToGizmo/N=%s attribute color={0,0,0,1},name=WMZ3LabelColor",gizmoName)
		ExecuteGizmoCmd("ModifyGizmo/N=%s setObjectAttribute={WMZ3LabelString,WMZ3LabelColor}",gizmoName)
	endif
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, object=WMZ3LabelString",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ3popMatrix, operation=popMatrix ",gizmoName)
	updateZ3Labels()
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

static Function removeZ3Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3pushMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3RotateZ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s object=WMZ3LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s attribute=WMZ3LabelColor",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

Static Function appendZ3ButtonProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String controls= "z3AxisDistSetVar;z3CenterSetVar;z3LabelColor;z3ScaleSetVar;z3StringSetVar;z3Reset;"
	Variable disable= checked ? 0 : 2
	Variable frame= checked ? 1 : 0
	ModifyControlList controls win=GizmoAxisLabels, disable=disable, frame=frame

	// avoid the hollow increment rectangle when disabled by using a zero increment.
	Variable increment= checked ? 0.05 : 0
	SetVariable z3AxisDistSetVar win= GizmoAxisLabels,limits={-2,2,increment}
	SetVariable z3CenterSetVar win= GizmoAxisLabels, limits={-2,2,increment}
	SetVariable z3ScaleSetVar win= GizmoAxisLabels, limits={0,2,increment}

	if(checked)
		addZ3Labels()
	else
		removeZ3Labels()
	endif
	EnableDisableFontPopup("")
End

Static Function updateZ3Labels()

	z3DistSetVarProc("",0,"","")
	z3ScaleSetVarProc("",0,"","")
	z3StringSetVarProc("",0,"","")	
//	z3CenterSetVarProc("",0,"","")	// redundant
	SetLabelFont("", "WMZ3LabelString")
	z3ColorPopMenuProc("z3LabelColor",1,"")	// do last because it tells Gizmo to compile
End

Static Function z3CenterSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	return z3DistSetVarProc(ctrlName,varNum,varStr,varName)
End

Static Function z3DistSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVARs so that updateZ3Labels() can call this function with dummy parameters
	NVAR xTranslation= $GizmoLabelsDFAxisVar("", "z3Label", "xTranslation")
	NVAR yTranslation= $GizmoLabelsDFAxisVar("", "z3Label", "yTranslation")
	
	String cmd
	sprintf cmd,"ModifyGizmo/N= %%s opName=WMZ3translate, operation=translate, data = {%g,%g,0}",xTranslation,yTranslation
	ExecuteGizmoCmd(cmd,"")
End

Static Function z3ScaleSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateZ3Labels() can call this function with dummy parameters
	NVAR uScale= $GizmoLabelsDFAxisVar("", "z3Label", "uScale")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMZ3Scale, operation=scale, data = {%g,%g,%g}",uScale,uScale,uScale
	ExecuteGizmoCmd(cmd,"")
End

Static Function z3StringSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the SVAR so that updateZ3Labels() can call this function with dummy parameters
	SVAR z3String=$GizmoLabelsDFAxisVar("", "z3Label", "z3String")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s ModifyObject=WMZ3LabelString, property = {string,\"%s\"}",z3String
	ExecuteGizmoCmd(cmd,"")
End

Static Function z3ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "z3Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "z3Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "z3Label", "labelBlue")
	
	ControlInfo/W=GizmoAxisLabels $ctrlName
	labelRed= V_Red
	labelGreen= V_Green
	labelBlue= V_Blue

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s modifyAttribute={WMZ3LabelColor,%g,%g,%g,1}",labelRed/65535, labelGreen/65535, labelBlue/65535 //opaque
	ExecuteGizmoCmd(cmd,"")
	ExecuteGizmoCmd("ModifyGizmo/N=%s compile","")
End

// Z1 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static Function addZ1Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1pushMatrix, operation=pushMatrix",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1rotateXm90, operation=rotate, data={-90,1,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1RotateY, operation=rotate, data={45,0,1,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1translate, operation=translate, data={-1.5,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1RotateZ, operation=rotate, data={-90,0,0,1}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1Scale, operation=scale, data={0.25,0.25,0.25}",gizmoName)
	Variable vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMZ1LabelString",gizmoName)
	if( vflg == 0 )
		ExecuteGizmoCmd("AppendToGizmo/N=%s  string=\"z1Label\",strFont=\"Times New Roman\",name=WMZ1LabelString",gizmoName)
	endif
	vflg= ExecuteGizmoCmd("GetGizmo/N=%s attributeItemExists=WMZ1LabelColor",gizmoName)
	if(vflg==0)
		ExecuteGizmoCmd("AppendToGizmo/N=%s attribute color={0,0,0,1},name=WMZ1LabelColor",gizmoName)
		ExecuteGizmoCmd("ModifyGizmo/N=%s setObjectAttribute={WMZ1LabelString,WMZ1LabelColor}",gizmoName)
	endif
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, object=WMZ1LabelString",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMZ1popMatrix, operation=popMatrix ",gizmoName)
	updateZ1Labels()
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

static Function removeZ1Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ3pushMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1RotateZ",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMZ1popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s object=WMZ1LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s attribute=WMZ1LabelColor",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

Static Function appendz1ButtonProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String controls= "z1AxisDistSetVar;z1AxisLabelsetvar;z1CenterSetVar;z1LabelColor;z1ScaleSetvar;z1Reset;"
	Variable disable= checked ? 0 : 2
	Variable frame= checked ? 1 : 0
	ModifyControlList controls win=GizmoAxisLabels, disable=disable, frame=frame
	
	// avoid the hollow increment rectangle when disabled by using a zero increment.
	Variable increment= checked ? 0.05 : 0
	SetVariable z1AxisDistSetVar win= GizmoAxisLabels,limits={-2,2,increment}
	SetVariable z1CenterSetVar win= GizmoAxisLabels, limits={-2,2,increment}
	SetVariable z1ScaleSetvar win= GizmoAxisLabels, limits={0,2,increment}

	if(checked)
		addZ1Labels()
	else
		removeZ1Labels()
	endif
	EnableDisableFontPopup("")
End

Static Function updateZ1Labels()
	z1AxisDistSetVarProc("",0,"","")
	z1ScaleSetVarProc("",0,"","")
	z1AxisLabelSetVarProc("",0,"","")
//	z1CenterSetVarProc("",0,"","")	// redundant with z1AxisDistSetVarProc
	SetLabelFont("", "WMZ1LabelString")
	z1ColorPopMenuProc("z1LabelColor",1,"")	// do last because it tells Gizmo to compile
End

Static Function z1ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "z1Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "z1Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "z1Label", "labelBlue")
	
	ControlInfo/W=GizmoAxisLabels $ctrlName
	labelRed= V_Red
	labelGreen= V_Green
	labelBlue= V_Blue

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s modifyAttribute={WMZ1LabelColor,%g,%g,%g,1}",labelRed/65535, labelGreen/65535, labelBlue/65535 //opaque
	ExecuteGizmoCmd(cmd,"")
	ExecuteGizmoCmd("ModifyGizmo/N=%s compile","")
End


Static Function z1AxisDistSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateZ1Labels() can call this function with dummy parameters
	NVAR xTranslation= $GizmoLabelsDFAxisVar("", "z1Label", "xTranslation")
	NVAR yTranslation= $GizmoLabelsDFAxisVar("", "z1Label", "yTranslation")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMZ1translate, operation=translate, data = {%g,%g,0}",xTranslation,yTranslation
	ExecuteGizmoCmd(cmd,"")
End

Static Function z1CenterSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	return z1AxisDistSetVarProc(ctrlName,varNum,varStr,varName)
End

Static Function z1ScaleSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateZ1Labels() can call this function with dummy parameters
	NVAR uScale= $GizmoLabelsDFAxisVar("", "z1Label", "uScale")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMZ1Scale, operation=scale, data = {%g,%g,%g}",uScale,uScale,uScale
	ExecuteGizmoCmd(cmd,"")
End

Static Function z1AxisLabelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the SVAR so that updateZ1Labels() can call this function with dummy parameters
	SVAR z1String= $GizmoLabelsDFAxisVar("", "z1Label", "z1String")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s ModifyObject=WMZ1LabelString, property = {string,\"%s\"}",z1String
	ExecuteGizmoCmd(cmd,"")
End

// X0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Static Function x0LabelButtonProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String controls= "x0CenterSetvar;x0DistSetVar;x0HeightSetVar;x0LabelColor;x0LabelSetvar;x0ScaleSetVar;x0TiltSetVar;x0Reset;"
	Variable disable= checked ? 0 : 2
	Variable frame= checked ? 1 : 0
	ModifyControlList controls win=GizmoAxisLabels, disable=disable, frame=frame

	// avoid the hollow increment rectangle when disabled by using a zero increment.
	Variable increment= checked ? 0.05 : 0
	SetVariable x0DistSetVar win= GizmoAxisLabels,limits={-2,2,increment}
	SetVariable x0CenterSetvar win= GizmoAxisLabels, limits={-2,2,increment}
	SetVariable x0HeightSetVar win= GizmoAxisLabels, limits={0,2,increment}
	SetVariable x0ScaleSetVar win= GizmoAxisLabels, limits={0,2,increment}
	SetVariable x0TiltSetVar win= GizmoAxisLabels,limits={-180,180,checked ? 5 : 0}

	if(checked)
		addX0Labels()
	else
		removeX0Labels()
	endif
	EnableDisableFontPopup("")
End

static Function addX0Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0pushMatrix, operation=pushMatrix",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0rotateXm90, operation=rotate, data={-90,1,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0translate, operation=translate, data={0,1.25,-1}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0Scale, operation=scale, data={0.25,0.25,0.25}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0Tilt, operation=rotate, data={0,1,0,0}",gizmoName)
	Variable vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMX0LabelString",gizmoName)
	if( vflg == 0 )
		ExecuteGizmoCmd("AppendToGizmo/N=%s string=\"x0Label\",strFont=\"Times New Roman\",name=WMX0LabelString",gizmoName)
	endif
	vflg= ExecuteGizmoCmd("GetGizmo/N=%s attributeItemExists=WMX0LabelColor",gizmoName)
	if(vflg==0)
		ExecuteGizmoCmd("AppendToGizmo/N=%s attribute color={0,0,0,1},name=WMX0LabelColor",gizmoName)
		ExecuteGizmoCmd("ModifyGizmo/N=%s setObjectAttribute={WMX0LabelString,WMX0LabelColor}",gizmoName)
	endif
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, object=WMX0LabelString",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMX0popMatrix, operation=popMatrix ",gizmoName)
	updateX0Labels()
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

static Function removeX0Labels()

	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0pushMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0Tilt",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMX0popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s object=WMX0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s attribute=WMX0LabelColor",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

Static Function updateX0Labels()
	x0AxisDistSetVarProc("",0,"","")
	x0ScaleSetVarProc("",0,"","")
	x0AxisLabelSetVarProc("",0,"","")
	x0TiltSetVarProc("",0,"","")
	SetLabelFont("", "WMX0LabelString")
	X0ColorPopMenuProc("x0LabelColor",1,"")	// do last because it tells Gizmo to compile
End

Static Function X0ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "x0Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "x0Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "x0Label", "labelBlue")
	
	ControlInfo/W=GizmoAxisLabels $ctrlName
	labelRed= V_Red
	labelGreen= V_Green
	labelBlue= V_Blue

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s modifyAttribute={WMX0LabelColor,%g,%g,%g,1}",labelRed/65535, labelGreen/65535, labelBlue/65535 //opaque
	ExecuteGizmoCmd(cmd,"")
	ExecuteGizmoCmd("ModifyGizmo/N=%s compile","")
End


Static Function x0AxisDistSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	// use the NVAR so that updateX0Labels() can call this function with dummy parameters
	NVAR xTranslation= $GizmoLabelsDFAxisVar("", "x0Label", "xTranslation")
	NVAR yTranslation= $GizmoLabelsDFAxisVar("", "x0Label", "yTranslation")
	NVAR zTranslation= $GizmoLabelsDFAxisVar("", "x0Label", "zTranslation")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMX0translate, operation=translate, data = {%g,%g,%g}",xTranslation,yTranslation,zTranslation
	ExecuteGizmoCmd(cmd,"")
End

Static Function x0ScaleSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateX0Labels() can call this function with dummy parameters
	NVAR uScale= $GizmoLabelsDFAxisVar("", "x0Label", "uScale")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMX0Scale, operation=scale, data = {%g,%g,%g}",uScale,uScale,uScale
	ExecuteGizmoCmd(cmd,"")
End

Static Function x0AxisLabelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the SVAR so that updateX0Labels() can call this function with dummy parameters
	SVAR x0String= $GizmoLabelsDFAxisVar("", "x0Label", "x0String")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s ModifyObject=WMX0LabelString, property = {string,\"%s\"}",x0String
	ExecuteGizmoCmd(cmd,"")
End

Static Function x0TiltSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateX0Labels() can call this function with dummy parameters
	NVAR x0Tilt= $GizmoLabelsDFAxisVar("", "x0Label", "x0Tilt")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMX0Tilt, operation=rotate, data = {%g,1,0,0}",x0Tilt
	ExecuteGizmoCmd(cmd,"")
End

// Y0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Static Function y0LabelButtonProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String controls= "y0CenterSetVar;y0DistSetVar;y0HeightSetVar;y0LabelColor;y0LabelSetVar;y0ScaleSetVar;y0TiltSetvar;y0Reset;"
	Variable disable= checked ? 0 : 2
	Variable frame= checked ? 1 : 0
	ModifyControlList controls win=GizmoAxisLabels, disable=disable, frame=frame

	// avoid the hollow increment rectangle when disabled by using a zero increment.
	Variable increment= checked ? 0.05 : 0
	SetVariable y0DistSetVar win= GizmoAxisLabels,limits={-2,2,increment}
	SetVariable y0CenterSetVar win= GizmoAxisLabels, limits={-2,2,increment}
	SetVariable y0HeightSetVar win= GizmoAxisLabels, limits={-2,2,increment}
	SetVariable y0ScaleSetVar win= GizmoAxisLabels, limits={0,2,increment}
	SetVariable y0TiltSetvar win= GizmoAxisLabels,limits={-180,180,checked ? 5 : 0}

	if(checked)
		addY0Labels()
	else
		removeY0Labels()
	endif
	EnableDisableFontPopup("")
End

static Function addY0Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0pushMatrix, operation=pushMatrix",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0rotateXm90, operation=rotate, data={-90,1,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0RotateY, operation=rotate, data={90,0,1,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0translate, operation=translate, data={1.25,0,-1}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0Tilt, operation=rotate, data={0,1,0,0}",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0Scale, operation=scale, data={0.25,0.25,0.25}",gizmoName)
	Variable vflg= ExecuteGizmoCmd("GetGizmo/N=%s objectItemExists=WMY0LabelString",gizmoName)
	if( vflg == 0 )
		ExecuteGizmoCmd("AppendToGizmo/N=%s string=\"y0Label\",strFont=\"Times New Roman\",name=WMY0LabelString",gizmoName)
	endif
	vflg= ExecuteGizmoCmd("GetGizmo/N=%s attributeItemExists=WMY0LabelColor",gizmoName)
	if(vflg==0)
		ExecuteGizmoCmd("AppendToGizmo/N=%s attribute color={0,0,0,1},name=WMY0LabelColor",gizmoName)
		ExecuteGizmoCmd("ModifyGizmo/N=%s setObjectAttribute={WMY0LabelString,WMY0LabelColor}",gizmoName)
	endif
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, object=WMY0LabelString",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s setDisplayList=-1, opName=WMY0popMatrix, operation=popMatrix ",gizmoName)
	updateY0Labels()
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

static Function removeY0Labels()
	String oldDF= SetPanelDF()
	String gizmoName= TopGizmo()
	ExecuteGizmoCmd("ModifyGizmo/N=%s startRecMacro",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0pushMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0rotateXm90",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0RotateY",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0translate",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0Tilt",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0Scale",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s displayItem=WMY0popMatrix",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s object=WMY0LabelString",gizmoName)
	ExecuteGizmoCmd("RemoveFromGizmo/Z/N=%s attribute=WMY0LabelColor",gizmoName)
	ExecuteGizmoCmd("ModifyGizmo/N=%s endRecMacro",gizmoName)
	SetDataFolder oldDF
End

Static Function updateY0Labels()
	y0AxisDistSetVarProc("",0,"","")
	y0ScaleSetVarProc("",0,"","")
	y0AxisLabelSetVarProc("",0,"","")
	y0TiltSetVarProc("",0,"","")
	SetLabelFont("", "WMY0LabelString")
	Y0ColorPopMenuProc("y0LabelColor",1,"")	// do last because it tells Gizmo to compile
End

Static Function Y0ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "y0Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "y0Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "y0Label", "labelBlue")
	
	ControlInfo/W=GizmoAxisLabels $ctrlName
	labelRed= V_Red
	labelGreen= V_Green
	labelBlue= V_Blue

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s modifyAttribute={WMY0LabelColor,%g,%g,%g,1}",labelRed/65535, labelGreen/65535, labelBlue/65535 //opaque
	ExecuteGizmoCmd(cmd,"")
	ExecuteGizmoCmd("ModifyGizmo/N=%s compile","")
End

Static Function y0AxisDistSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateY0Labels() can call this function with dummy parameters
	NVAR xTranslation= $GizmoLabelsDFAxisVar("", "y0Label", "xTranslation")
	NVAR yTranslation= $GizmoLabelsDFAxisVar("", "y0Label", "yTranslation")
	NVAR zTranslation= $GizmoLabelsDFAxisVar("", "y0Label", "zTranslation")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMY0translate, operation=translate, data = {%g,%g,%g}",xTranslation,yTranslation,zTranslation
	ExecuteGizmoCmd(cmd,"")
End

Static Function y0ScaleSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateY0Labels() can call this function with dummy parameters
	NVAR uScale= $GizmoLabelsDFAxisVar("", "y0Label", "uScale")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMY0Scale, operation=scale, data = {%g,%g,%g}",uScale,uScale,uScale
	ExecuteGizmoCmd(cmd,"")
End

Static Function y0AxisLabelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the SVAR so that updateY0Labels() can call this function with dummy parameters
	SVAR y0String= $GizmoLabelsDFAxisVar("", "y0Label", "y0String")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s ModifyObject=WMY0LabelString, property = {string,\"%s\"}",y0String
	ExecuteGizmoCmd(cmd,"")
End

Static Function y0TiltSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// use the NVAR so that updateY0Labels() can call this function with dummy parameters
	NVAR y0Tilt= $GizmoLabelsDFAxisVar("", "y0Label", "y0Tilt")

	String cmd
	sprintf cmd,"ModifyGizmo/N=%%s opName=WMY0Tilt, operation=rotate, data = {%g,1,0,0}",y0Tilt
	ExecuteGizmoCmd(cmd,"")
End

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// returns V_Flag
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


Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:GizmoLabels
	return "root:Packages:GizmoLabels"
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End

Static Function/S GizmoLabelsDFAxisVar(gizmoName, axisName,varName)
	String gizmoName
	String axisName	// one of "z3Label", "z1Label", "y0Label", "x0Label"
	String varName
	
	if( !ValidGizmoName(gizmoName) )
		gizmoName= "Default"
	endif

	return PanelDF() +":" + gizmoName + ":" + axisName + ":" + PossiblyQuoteName(varName)
End

Static Function/S GizmoLabelsDFVar(gizmoName,varName)
	String gizmoName
	String varName
	
	if( !ValidGizmoName(gizmoName) )
		gizmoName= "Default"
	endif

	return PanelDF() +":" + gizmoName + ":" + PossiblyQuoteName(varName)
End

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Static Function UpdateGizmoLabelsPanel()

	DoWindow GizmoAxisLabels
	if( V_Flag == 0 )
		return 0
	endif

	String allControls= ControlNameList("GizmoAxisLabels", ";", "*")
	allControls= RemoveFromList("gizmoInfo", allControls)

	String gizmoName= TopGizmo()	// can be ""
	
	Button gizmoInfo win= GizmoAxisLabels, title=gizmoName+" Info", disable=strlen(gizmoName) ? 0 : 2
	
	if( strlen(gizmoName) == 0 )
		ModifyControlList allControls, win=GizmoAxisLabels, disable=1
		return 0	// NO GIZMO!
	endif

	InitGizmoLabelPanelVars(gizmoName)

	// Z1
	Checkbox appendZ1 win= GizmoAxisLabels, variable=$GizmoLabelsDFAxisVar(gizmoName,"z1Label","appendZ1"), disable=0

	NVAR haveLabel=$GizmoLabelsDFAxisVar(gizmoName,"z1Label","appendZ1")	// to force the global to agree with reality
	Variable inDisplay= NameIsInGizmoDisplayList(gizmoName,"WMZ1LabelString")					// actually check the Gizmo contents
	haveLabel= inDisplay
	Variable disable= haveLabel ? 0 : 2
	Variable frame= haveLabel ? 1 : 0
	Variable increment= haveLabel ? 0.05 : 0	// avoid the hollow increment rectangle when disabled by using a zero increment.

	SetVariable z1AxisDistSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z1Label","xTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable z1CenterSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z1Label","yTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable z1ScaleSetvar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z1Label","uScale"), disable=disable, frame=frame,limits={0,2,increment}

	SetVariable z1AxisLabelsetvar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z1Label","z1String"), disable=disable, frame=frame
	
	NVAR labelRed= $GizmoLabelsDFAxisVar("", "z1Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "z1Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "z1Label", "labelBlue")
	
	PopupMenu z1LabelColor,win= GizmoAxisLabels,popColor= (labelRed,labelGreen,labelBlue), disable=disable
	
	Button z1Reset,win= GizmoAxisLabels, disable=disable
	
	// Z3
	Checkbox appendZ3 win= GizmoAxisLabels, variable=$GizmoLabelsDFAxisVar(gizmoName,"z3Label","appendZ3"), disable=0
	
	NVAR haveLabel=$GizmoLabelsDFAxisVar(gizmoName,"z3Label","appendZ3")
	inDisplay= NameIsInGizmoDisplayList(gizmoName,"WMZ3LabelString")	
	haveLabel= inDisplay
	disable= haveLabel ? 0 : 2
	frame= haveLabel ? 1 : 0
	increment= haveLabel ? 0.05 : 0	// avoid the hollow increment rectangle when disabled by using a zero increment.

	SetVariable z3AxisDistSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z3Label","xTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable z3ScaleSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z3Label","uScale"), disable=disable, frame=frame,limits={0,2,increment}

	SetVariable z3StringSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z3Label","z3String"), disable=disable, frame=frame

	SetVariable z3CenterSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"z3Label","yTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "z3Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "z3Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "z3Label", "labelBlue")
	
	PopupMenu z3LabelColor,win= GizmoAxisLabels,popColor= (labelRed,labelGreen,labelBlue), disable=disable

	Button z3Reset,win= GizmoAxisLabels, disable=disable

	// Y0
	Checkbox appendY0 win= GizmoAxisLabels, variable=$GizmoLabelsDFAxisVar(gizmoName,"y0Label","appendY0"), disable=0

	NVAR haveLabel=$GizmoLabelsDFAxisVar(gizmoName,"y0Label","appendY0")
	inDisplay= NameIsInGizmoDisplayList(gizmoName,"WMY0LabelString")	
	haveLabel= inDisplay
	disable= haveLabel ? 0 : 2
	frame= haveLabel ? 1 : 0
	increment= haveLabel ? 0.05 : 0	// avoid the hollow increment rectangle when disabled by using a zero increment.

	SetVariable y0DistSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","zTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable y0CenterSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","xTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable y0HeightSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","yTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable y0ScaleSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","uScale"), disable=disable, frame=frame,limits={0,2,increment}

	SetVariable y0TiltSetvar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","y0Tilt"), disable=disable, frame=frame,limits={-180,180,haveLabel ? 5 : 0}

	SetVariable y0LabelSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"y0Label","y0String"), disable=disable, frame=frame

	NVAR labelRed= $GizmoLabelsDFAxisVar("", "y0Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar("", "y0Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar("", "y0Label", "labelBlue")
	
	PopupMenu y0LabelColor,win= GizmoAxisLabels,popColor= (labelRed,labelGreen,labelBlue), disable=disable

	Button y0Reset,win= GizmoAxisLabels, disable=disable
	
	// X0
	Checkbox appendX0 win= GizmoAxisLabels, variable=$GizmoLabelsDFAxisVar(gizmoName,"x0Label","appendX0"), disable=0

	NVAR haveLabel=$GizmoLabelsDFAxisVar(gizmoName,"x0Label","appendX0")
	inDisplay= NameIsInGizmoDisplayList(gizmoName,"WMX0LabelString")	
	haveLabel= inDisplay
	disable= haveLabel ? 0 : 2
	frame= haveLabel ? 1 : 0
	increment= haveLabel ? 0.05 : 0	// avoid the hollow increment rectangle when disabled by using a zero increment.

	SetVariable x0DistSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","zTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable x0CenterSetvar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","xTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable x0HeightSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","yTranslation"), disable=disable, frame=frame,limits={-2,2,increment}

	SetVariable x0LabelSetvar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","x0String"), disable=disable, frame=frame

	SetVariable x0ScaleSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","uScale"), disable=disable, frame=frame,limits={0,2,increment}

	SetVariable x0TiltSetVar win= GizmoAxisLabels, value= $GizmoLabelsDFAxisVar(gizmoName,"x0Label","x0Tilt"), disable=disable, frame=frame,limits={-180,180,haveLabel ? 5 : 0}

	NVAR labelRed= $GizmoLabelsDFAxisVar(gizmoName, "x0Label", "labelRed")
	NVAR labelGreen= $GizmoLabelsDFAxisVar(gizmoName, "x0Label", "labelGreen")
	NVAR labelBlue= $GizmoLabelsDFAxisVar(gizmoName, "x0Label", "labelBlue")
	
	PopupMenu x0LabelColor,win= GizmoAxisLabels,popColor= (labelRed,labelGreen,labelBlue), disable=disable

	Button x0Reset,win= GizmoAxisLabels, disable=disable

	// Font
	SVAR fontName=$GizmoLabelsDFVar(gizmoName,"fontName")
	String fonts=FontList(";",1)
	Variable mode=1+WhichListItem(fontName,fonts)
	if( mode < 1 )
		mode= 1
	endif
	fontName= StringFromList(mode-1,fonts)
	PopupMenu font,win= GizmoAxisLabels,mode=mode,popvalue=fontName
	EnableDisableFontPopup(gizmoName)

	return 0
End

Static Function EnableDisableFontPopup(gizmoName)
	String gizmoName
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	NVAR haveX0Label=$GizmoLabelsDFAxisVar(gizmoName,"x0Label","appendX0")
	NVAR haveY0Label=$GizmoLabelsDFAxisVar(gizmoName,"y0Label","appendY0")
	NVAR haveZ3Label=$GizmoLabelsDFAxisVar(gizmoName,"z3Label","appendZ3")
	NVAR haveZ1Label=$GizmoLabelsDFAxisVar(gizmoName,"z1Label","appendZ1")
	Variable fontDisable= (haveX0Label || haveY0Label || haveZ3Label || haveZ1Label) ? 0 : 2

	PopupMenu font,win= GizmoAxisLabels, disable=fontDisable
End

// Note that the font isn't a parameter, since it is shared with all labels
Static Function SetLabelFont(gizmoName, stringObjName)
	String gizmoName, stringObjName

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	SVAR fontName=$GizmoLabelsDFVar(gizmoName,"fontName")
	String cmd
	sprintf cmd, "ModifyGizmo/N=%%s ModifyObject=%s, Property={Font,\"%s\"}", stringObjName, fontName
	ExecuteGizmoCmd(cmd,"")
End


Static Function FontPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName
	String/G fontName= popStr
	SetDataFolder oldDF

	NVAR haveZ1Label=$GizmoLabelsDFAxisVar(gizmoName,"z1Label","appendZ1")
	if( haveZ1Label )
		updateZ1Labels()
	endif
	NVAR haveZ3Label=$GizmoLabelsDFAxisVar(gizmoName,"z3Label","appendZ3")
	if( haveZ3Label )
		updateZ3Labels()
	endif
	NVAR haveY0Label=$GizmoLabelsDFAxisVar(gizmoName,"y0Label","appendY0")
	if( haveY0Label )
		updateY0Labels()
	endif
	NVAR haveX0Label=$GizmoLabelsDFAxisVar(gizmoName,"x0Label","appendX0")
	if( haveX0Label )
		updateX0Labels()
	endif
End

Static Function GizmoInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	Execute "ModifyGizmo showInfo"
	SetDataFolder oldDF
End

Static Function z1Reset(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName
	NewDataFolder/O/S z1Label

	Variable/G uScale=0.25
	Variable/G yRotation=45
	Variable/G xTranslation=-1.6
	Variable/G yTranslation=0.5
	Variable/G zRotation=-90

//	Variable/G labelRed=0
//	Variable/G labelGreen=0
//	Variable/G labelBlue=0
//	PopupMenu z1LabelColor win=GizmoAxisLabels, popColor=(labelRed, labelGreen, labelBlue)

	SetDataFolder oldDF
	
	updateZ1Labels()
End

Static Function z3Reset(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName
	NewDataFolder/O/S z3Label

	Variable/G uScale=0.25
	Variable/G yRotation=45
	Variable/G xTranslation=1.6
	Variable/G zRotation=90
	Variable/G yTranslation=-0.4

//	Variable/G labelRed=0
//	Variable/G labelGreen=0
//	Variable/G labelBlue=0
//	PopupMenu z3LabelColor win=GizmoAxisLabels, popColor=(labelRed, labelGreen, labelBlue)

	SetDataFolder oldDF
	
	updateZ3Labels()
End

Static Function y0Reset(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName
	NewDataFolder/O/S y0Label

	Variable/G uScale= 0.25
	Variable/G zTranslation=-1
	Variable/G xTranslation=-0.25
	Variable/G yTranslation=1.4
	Variable/G y0Tilt=0

//	Variable/G labelRed=0
//	Variable/G labelGreen=0
//	Variable/G labelBlue=0
//	PopupMenu y0LabelColor win=GizmoAxisLabels, popColor=(labelRed, labelGreen, labelBlue)

	SetDataFolder oldDF
	
	updateY0Labels()
End

Static Function x0Reset(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName
	NewDataFolder/O/S x0Label

	Variable/G uScale= 0.25

	Variable/G zTranslation=-1
	Variable/G xTranslation=-0.4
	Variable/G yTranslation=1.4
	Variable/G x0Tilt=0

//	Variable/G labelRed=0
//	Variable/G labelGreen=0
//	Variable/G labelBlue=0
//	PopupMenu x0LabelColor win=GizmoAxisLabels, popColor=(labelRed, labelGreen, labelBlue)

	SetDataFolder oldDF
	
	updateX0Labels()
End

Static Function InitGizmoLabelPanelVars(gizmoName)
	String gizmoName

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S GizmoLabels
	NewDataFolder/O/S $gizmoName

	// values common to all labels
	String  str= StrVarOrDefault("fontName","Times New Roman")
	String/G fontName= str
	
	NewDataFolder/O/S z3Label
	
	// added variable for the append, rather than checking for existence.
	Variable val= NumVarOrDefault("appendZ3",0)
	Variable/G appendZ3=val
	
	val= NumVarOrDefault("uScale", 0.25)
	Variable/G uScale=val

	val= NumVarOrDefault("yRotation", 45)
	Variable/G yRotation=val

	val= NumVarOrDefault("xTranslation", 1.6)
	Variable/G xTranslation=val

	val= NumVarOrDefault("zRotation", 90)
	Variable/G zRotation=val

	val= NumVarOrDefault("yTranslation", -0.4)
	Variable/G yTranslation=val

	str= StrVarOrDefault("z3String", "z3 Label")
	String/G z3String=str

	val= NumVarOrDefault("labelRed", 0)
	Variable/G labelRed=val
	
	val= NumVarOrDefault("labelGreen", 0)
	Variable/G labelGreen=val
	
	val= NumVarOrDefault("labelBlue", 0)
	Variable/G labelBlue=val
	
	SetDataFolder ::
	NewDataFolder/O/S z1Label

	val= NumVarOrDefault("appendZ1",0)
	Variable/G appendZ1=val
	
	val= NumVarOrDefault("uScale", 0.25)
	Variable/G uScale=val

	val= NumVarOrDefault("yRotation", 45)
	Variable/G yRotation=val
	
	val= NumVarOrDefault("xTranslation", -1.6)
	Variable/G xTranslation=val

	val= NumVarOrDefault("yTranslation", 0.5)
	Variable/G yTranslation=val

	val= NumVarOrDefault("zRotation", -90)
	Variable/G zRotation=val

	str= StrVarOrDefault("z1String", "z1 Label")
	String/G z1String=str
	
	val= NumVarOrDefault("labelRed", 0)
	Variable/G labelRed=val
	
	val= NumVarOrDefault("labelGreen", 0)
	Variable/G labelGreen=val
	
	val= NumVarOrDefault("labelBlue", 0)
	Variable/G labelBlue=val

	SetDataFolder ::
	NewDataFolder/O/S x0Label

	val= NumVarOrDefault("appendX0",0)
	Variable/G appendX0=val
	
	val= NumVarOrDefault("uScale", 0.25)
	Variable/G uScale=val

	val= NumVarOrDefault("zTranslation", -1)
	Variable/G zTranslation=val
	
	val= NumVarOrDefault("xTranslation", -0.4)
	Variable/G xTranslation=val
	
	val= NumVarOrDefault("yTranslation", 1.4)
	Variable/G yTranslation=val
	
	val= NumVarOrDefault("x0Tilt", 0)
	Variable/G x0Tilt=val

	str= StrVarOrDefault("x0String", "x0 Label")
	String/G x0String=str
	
	val= NumVarOrDefault("labelRed", 0)
	Variable/G labelRed=val
	
	val= NumVarOrDefault("labelGreen", 0)
	Variable/G labelGreen=val
	
	val= NumVarOrDefault("labelBlue", 0)
	Variable/G labelBlue=val

	SetDataFolder ::
	NewDataFolder/O/S y0Label
	
	val= NumVarOrDefault("appendY0",0)
	Variable/G appendY0=val
	
	val= NumVarOrDefault("uScale", 0.25)
	Variable/G uScale=val

	val= NumVarOrDefault("zTranslation", -1)
	Variable/G zTranslation=val
	
	val= NumVarOrDefault("xTranslation", -0.25)
	Variable/G xTranslation=val
	
	val= NumVarOrDefault("yTranslation", 1.4)
	Variable/G yTranslation=val

	val= NumVarOrDefault("y0Tilt", 0)
	Variable/G y0Tilt=val
	
	str= StrVarOrDefault("y0String", "y0 Label")
	String/G y0String=str

	val= NumVarOrDefault("labelRed", 0)
	Variable/G labelRed=val
	
	val= NumVarOrDefault("labelGreen", 0)
	Variable/G labelGreen=val
	
	val= NumVarOrDefault("labelBlue", 0)
	Variable/G labelBlue=val

	SetDataFolder oldDF
End

