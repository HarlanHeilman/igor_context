#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.0	// hideable and PopupMenu value=#str require Igor 6.0
#pragma version=6.381		// released with Igor 6.38

// Append Calibrator.ipf

//
// Choose Calibrator... from Graph menu to open a panel that appends calibrator bars to active graph in the top window. 
//
// The procedure uses the drawing tools to create the calibrator as one grouped object. 
// To make changes to the calibrator  you will usually first ungroup it with the drawing
// tools "bulldozer" menu.

//
// LH000705: Modernized with Igor 4 syntax.
// JP010315: Works when axes are reversed, opens the drawing tools.
// JP010402: Uses panel, has color and digits parameters.
// JP070703: version=6.02, Fixed bug introduced by change to HVAxisList no longer accepting "" to mean top graph.
//                      Adjusted spacing of controls to suit DefaultGuiControls native on Macintosh.
// JP080910: version=6.05, "Calibrator..." item is hidden by HideIgorMenus.
// JP090519: version=6.1, made compatible with being included into an independent module,
//					and behaves better if no graph is present.
// JP150903: version=6.38, operates on the active subwindow (or window).
// JP150908: version=6.38, added controls to position the calibrator.
// JP150910: version=6.38, added controls to rotate vertical text.
// JP160209: version=6.381, Fixed inset SetVariable bugs.

#include <Axis Utilities>

Menu "Graph", hideable
	"Calibrator...",Calibrator()
End

Function Calibrator()
	DoWindow/K CalibratorPanel
	NewPanel/K=1 /W=(465,48,705,607) as "Append Calibrator"
	DoWindow/C CalibratorPanel
	ModifyPanel/W=CalibratorPanel fixedSize=1,noEdit=1
	DefaultGuiFont/W=CalibratorPanel/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	DefaultGuiFont/W=CalibratorPanel/Mac button={"_IgorLarge",13,0}
	DefaultGuiFont/W=CalibratorPanel/Mac tabcontrol={"_IgorMedium",12,0}
	DefaultGuiFont/W=CalibratorPanel/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

	String graphName= WMCalibratorTopGraph()
	if( strlen(graphName) )
		String host= StringFromList(0,graphName,"#")
		AutoPositionWindow/E/M=0/R=$host
	endif

	SetDrawLayer UserBack
	SetDrawEnv gstart
	SetDrawEnv linethick= 2
	DrawLine 64,258,64,243
	SetDrawEnv linethick= 2
	DrawLine 85,243,65,243
	DrawText 69,240,"1"
	DrawText 54,258,"1"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv linethick= 2
	DrawLine 172,260,172,245
	SetDrawEnv linethick= 2
	DrawLine 172,245,152,245
	DrawText 174,260,"1"
	DrawText 157,244,"1"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv linethick= 2
	DrawLine 64,290,64,275
	SetDrawEnv linethick= 2
	DrawLine 85,290,65,290
	DrawText 69,306,"1"
	DrawText 54,289,"1"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv linethick= 2
	DrawLine 172,290,172,275
	SetDrawEnv linethick= 2
	DrawLine 172,290,152,290
	DrawText 157,307,"1"
	DrawText 174,289,"1"
	SetDrawEnv gstop

	// Subwindow
	SetVariable subwindow,pos={14,10},size={223,19},bodyWidth=182,title="Graph:"
	SetVariable subwindow,fSize=12,frame=0,valueColor=(0,0,65535)
	SetVariable subwindow,value= _STR:"Panel0#G0"

	// Axes
	//		x
	PopupMenu xAxis,win=CalibratorPanel,pos={29,40},size={187,20},proc=WMCalibratorPopMenuProc,title="X (Horizontal) Axis:"
	//		y
	PopupMenu yAxis,win=CalibratorPanel,pos={38,65},size={150,20},proc=WMCalibratorPopMenuProc,title="Y (Vertical) Axis:"

	// bar lengths
	//		x
	CheckBox xBar,win=CalibratorPanel,pos={16,93},size={74,16},title="X Length:",proc=WMCalibratorCheckProc
	SetVariable xLength,win=CalibratorPanel,pos={94,93},size={70,19},title=" ",limits={-Inf,Inf,0}
	Button xNice,win=CalibratorPanel,pos={166,93},size={58,16},proc=WMCalibratorPresetButtonProc,title="Preset"
	//		y
	CheckBox yBar,win=CalibratorPanel,pos={16,115},size={74,16},title="Y Length:",proc=WMCalibratorCheckProc
	SetVariable yLength,win=CalibratorPanel,pos={94,115},size={70,19},title=" ",limits={-Inf,Inf,0}
	Button yNice,win=CalibratorPanel,pos={166,115},size={58,16},proc=WMCalibratorPresetButtonProc,title="Preset"

	// Position
	//		corner
	PopupMenu corner,pos={23,164},size={158,20},title="Relative to", proc=WMCalibratorPopMenuProc
	PopupMenu corner,mode=2,popvalue="upper right",value= #"\"upper left;upper right;lower left;lower right;\""

	GroupBox positionGroup,pos={6,141},size={226,79},title="Position",frame=0

	SetVariable vertInset,pos={112,195},size={100,19},bodyWidth=55,title="V Inset"
	SetVariable vertInset,format="%g %%"
	SetVariable vertInset,limits={0,100,1},value=_NUM:15

	SetVariable horizInset,pos={12,195},size={100,19},bodyWidth=55,title="H Inset"
	SetVariable horizInset,format="%g %%"
	SetVariable horizInset,limits={0,100,1},value=_NUM:15

	// bars orientation
	CheckBox upperLeft		win=CalibratorPanel,pos={35,240},size={22,16},proc=WMCalibratorPositionRadio,title=" ",mode=1
	CheckBox upperRight	win=CalibratorPanel,pos={123,240},size={22,16},proc=WMCalibratorPositionRadio,title=" ",mode=1
	CheckBox lowerLeft		win=CalibratorPanel,pos={35,283},size={22,16},proc=WMCalibratorPositionRadio,title=" ",mode=1
	CheckBox lowerRight	win=CalibratorPanel,pos={123,283},size={22,16},proc=WMCalibratorPositionRadio,title=" ",mode=1

	// vertical text orientation
	PopupMenu verticalTextRotation,pos={15,319},size={168,20},proc=WMCalibratorPopMenuProc,title="Vertical Text Rotation"
	PopupMenu verticalTextRotation,mode=2,popvalue="0",value= #"\"-90;0;+90;\""
	TitleBox vertTextDegreesTitle,pos={187,321},size={46,16},title="degrees",frame=0

	// numbers
	PopupMenu numbers,win=CalibratorPanel,pos={12,347},size={175,20},title="Numbers:", value="",proc=WMCalibratorNumPopMenuProc
	// digits
	PopupMenu digits,win=CalibratorPanel,pos={27,376},size={76,20},proc=WMCalibratorStr2NumPopMenuProc,title="Digits:"
	// color
	PopupMenu color,win=CalibratorPanel,pos={30,405},size={86,20},title="Color:",proc=WMCalibratorColorPop
	PopupMenu color,win=CalibratorPanel,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	// lines
	PopupMenu lineSize,win=CalibratorPanel,pos={130,405},size={95,20},title="Line Size:",proc=WMCalibratorStr2NumPopMenuProc
	// layer
	GroupBox layerGroup,win=CalibratorPanel,pos={6,434},size={226,111},title="Drawing Layer", frame=0
	PopupMenu layer,win=CalibratorPanel,pos={77,459},size={93,20},title=" ",proc=WMCalibratorPopMenuProc
	Button eraseAll,pos={78,487},size={99,20},title="Erase Layer",proc=WMCalibratorEraseButtonProc
	Button create,pos={39,516},size={179,20},title="Add Calibrator to Layer",proc=WMCalibratorCreateButtonProc

	WMCalibratorUpdateForGraph("")
	
	SetWindow CalibratorPanel hook=WMCalibratorPanelHook
End

Function WMCalibratorPanelHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "activate":
			WMCalibratorUpdateForGraph("")
			break
	endswitch
	return 0				// 0 if nothing done, else 1 or 2
End

Function/S WMCalibratorAxisList(win, wantHorizAxes)
	String win
	Variable wantHorizAxes
	
	String list= HVAxisList(win,wantHorizAxes)
	if( strlen(list) == 0 )
		list= "\\M1:(:"	// disabled
		if( wantHorizAxes )
			list+="missing X axis"	// these presume that swapXY is off
		else
			list+="missing Y axis"
		endif
	endif
	
	return list	
End

Function/S WMCalibratorTopGraph()

	String graphName= ""
	//String graphName= WinName(0,1)
	// WinName(0,1) is too simple.
	// to support graph in panel we look at the top window behind CalibratorPanel
	// and look for graph window or subwindows.
	Variable i=-1
	do
		i += 1
		String win= WinName(i,1+64,1)	// visible graphs and panels only
		if( strlen(win) == 0 )
			break
		endif
		if( CmpStr(win,"CalibratorPanel") == 0 )
			continue
		endif
		// prefer the active subwindow
		// but if the window is a graph, that's good, too.
		GetWindow $win, activeSW
		Variable type= WinType(S_value)
		if( type == 1 )
			graphName= S_Value
		elseif( winType(win) == 1 )
			graphName= win
		endif
	while(strlen(graphName) == 0)

	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
	endif

	return graphName
End

// gets the graph name from the control panel, if present.
Function/S WMCalibratorGraph()

	String graphName= ""
	ControlInfo/W= CalibratorPanel subwindow
	if( V_Flag == 5 )
		graphName= S_Value
	endif
	
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorTopGraph()
	endif
	return graphName
End

Function WMCalibratorUpdateForGraph(graphName)
	String graphName	// can be "Panel0#G0", for example
	
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorTopGraph()	// can be compound name like "Panel0#Graph0"
	endif
	Variable noGraph= strlen(graphName) == 0
	
	SetVariable subwindow,win=CalibratorPanel,value= _STR:graphName	// VERY IMPORTANT: See 
	
	String oldDF= WMCalibratorSetDF(graphName)
	String df= GetDataFolder(1)	// has trailing ":"

	// set up defaults or load current values
	// NOTE: the control name must match the name of the global var or str in the data folder.
	String str, path, list
	Variable var
	Variable disable=0		// disable everything if no axes.
	// Axes
	//		xAxis
	list=HVAxisList(graphName,1)	// horizontal axes, if any
	if( strlen(list) == 0 )
		if( noGraph )
			list= "no graph"
		else
			list= "missing X axis"
		endif
		disable=2	// shown, but disabled.
	endif
	str= StrVarOrDefault(df+"xAxis",StringFromList(0,list))
	Variable whichOne= WhichListItem(str, list)+1	// note: the axis could have been removed
	if( whichOne == 0 )	// not in list
		str= StringFromList(0,list)
		whichOne= 1
	endif
	String/G xAxis = str
	String cmd= GetIndependentModuleName()+"#WMCalibratorAxisList(\""+graphName+"\",1)"
	PopupMenu xAxis, win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str,value= #cmd

	//		yAxis
	list=HVAxisList(graphName,0)	// vertical axes, if any
	if( strlen(list) == 0 )
		if( noGraph )
			list= "no graph"
		else
			list= "missing Y axis"
		endif
		disable=2	// shown, but disabled.
	endif
	str= StrVarOrDefault(df+"yAxis",StringFromList(0,list))
	whichOne= WhichListItem(str, list)+1
	if( whichOne == 0 )	// not in list
		str= StringFromList(0,list)
		whichOne= 1
	endif
	String/G yAxis = str
	cmd= GetIndependentModuleName()+"#WMCalibratorAxisList(\""+graphName+"\",0)"
	PopupMenu yAxis, win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str,value= #cmd

	// bar lengths
	//		xLength
	path=df+"xBar"
	var=NumVarOrDefault(path,1)
	Variable/G xBar=var
	CheckBox xBar,win=CalibratorPanel,disable=disable,variable=$path
	
	path=df+"xLength"
	if( strlen(graphName) )
		var= WMCalibratorGetPresetLength(graphName,1)	// isX, requres xAxis set up already.
	else
		var=0
	endif
	var=NumVarOrDefault(path,var)
	Variable/G xLength=var
	SetVariable xLength,win=CalibratorPanel,disable=disable,value= $path
	Button xNice win=CalibratorPanel,disable=disable

	//		yLength
	path=df+"yBar"
	var=NumVarOrDefault(path,1)
	Variable/G yBar=var
	CheckBox yBar,win=CalibratorPanel,disable=disable,variable=$path

	path=df+"yLength"
	if( strlen(graphName) )
		var= WMCalibratorGetPresetLength(graphName,0)	// !isX, requres yAxis set up already.
	else
		var=0
	endif
	var=NumVarOrDefault(path,var)
	Variable/G yLength=var
	SetVariable yLength,win=CalibratorPanel,disable=disable, value= $path
	Button yNice win=CalibratorPanel,disable=disable

	// POSITION
	// corner
	list="upper left;upper right;lower left;lower right;"
	str= StrVarOrDefault(df+"corner",StringFromList(1,list))
	String/G corner = str
	whichOne= WhichListItem(str, list)+1
	PopupMenu corner, win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str
	
	// insets
	path=df+"horizInset"
	var=NumVarOrDefault(path,15)
	Variable/G horizInset=var
	SetVariable horizInset,win=CalibratorPanel,disable=disable,value= $path

	path=df+"vertInset"
	var=NumVarOrDefault(path,15)
	Variable/G vertInset=var
	SetVariable vertInset,win=CalibratorPanel,disable=disable,value= $path

	// bars orientation
	path= df+"orientation"
	str= StrVarOrDefault(path,"lowerLeft")
	WMCalibratorPositionRadio(str,1)
	Checkbox upperLeft win=CalibratorPanel, disable=disable
	Checkbox upperRight win=CalibratorPanel, disable=disable
	Checkbox lowerLeft win=CalibratorPanel, disable=disable
	Checkbox lowerRight win=CalibratorPanel, disable=disable

	// vertical text orientation
	list="-90;0;+90;"
	path= df+"verticalTextRotation"
	str= StrVarOrDefault(path,"0")
	String/G verticalTextRotation=str
	whichOne= WhichListItem(str, list)+1
	PopupMenu verticalTextRotation,win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str

	// numbers
	list="don't print;print without units;print with units;print with units, K, m, etc"
	whichOne=NumVarOrDefault(df+"numbers",3)// popup number, 1 is the first item (item 0) in list, default to "print with units"
	Variable/G numbers= whichOne
	str= StringFromList(whichOne-1,list)
	PopupMenu numbers,win=CalibratorPanel,disable=disable, mode=whichOne,popvalue=str,value="don't print;print without units;print with units;print with units, K, m, etc"
	WMCalibratorHideShowDigits(whichOne==1)
	
	// digits
	var=NumVarOrDefault(df+"digits",6)// popup number, 1 is the first item in the list.
	Variable/G digits= var
	whichOne = var+1
	str=num2str(digits)
	PopupMenu digits,win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str,value= #"\"0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;\""

	// color
	Variable/G lineRed, lineGreen, lineBlue // default is conveniently 0,0,0 (black)
	PopupMenu color,win=CalibratorPanel,disable=disable,popColor= (lineRed, lineGreen, lineBlue)
	
	// lines
	//		line size
	list= "0.25;0.5;1;1.5;2;3;4;5;6;7;8;9;10;"
	var= NumVarOrDefault(df+"lineSize",2)
	Variable/G lineSize = var
	str=num2str(var)
	whichOne= WhichListItem(str, list)+1
	PopupMenu lineSize,win=CalibratorPanel,disable=disable, mode=whichOne,popvalue=str,value="0.25;0.5;1;1.5;2;3;4;5;6;7;8;9;10;"
	
	// DRAWING LAYER
	// layer
	list= "window background;ProgBack;UserBack;axes;ProgAxes;UserAxes;traces;ProgFront;UserFront;annotations"
	str= StrVarOrDefault(df+"layer","UserFront")// popup string
	String/G layer = str
	whichOne= WhichListItem(str, list)+1
	PopupMenu layer,win=CalibratorPanel,disable=disable,mode=whichOne,popvalue=str,value= #"\"\\M1:(:window background;ProgBack;UserBack;\\M1:(:axes;ProgAxes;UserAxes;\\M1:(:traces;ProgFront;UserFront;\\M1:(:annotations\""

	// buttons
	Button create win=CalibratorPanel,disable=disable
	Button eraseAll win=CalibratorPanel,disable=disable
	
	SetDataFolder oldDF
End


Function WMCalibratorNumPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMCalibratorHideShowDigits(popNum==1)
	WMCalibratorSetGlobalFromCtrl(ctrlName,popNum,popStr)
End


Function WMCalibratorHideShowDigits(hideDigits)
	Variable hideDigits
	
	DoWindow CalibratorPanel
	if( V_Flag )
		PopupMenu digits,win=CalibratorPanel, disable=hideDigits	
	endif
End

Function WMCalibratorColorPop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String topGraph= WMCalibratorGraph()
	if( strlen(topGraph) == 0 )
		return 0
	endif
	ControlInfo/W=CalibratorPanel $ctrlName
	if( V_Flag )
		// update the global color variables
		Variable/G $WMCalibratorDF_Var(topGraph,"lineRed")= V_Red
		Variable/G $WMCalibratorDF_Var(topGraph,"lineGreen")= V_Green
		Variable/G $WMCalibratorDF_Var(topGraph,"lineBlue")= V_Blue
	endif
End

// a generic routine.
Function WMCalibratorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMCalibratorSetGlobalFromCtrl(ctrlName,popNum,popStr)
End

// we need the numeric value of the string
Function WMCalibratorStr2NumPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMCalibratorSetGlobalFromCtrl(ctrlName,str2num(popStr),popStr)
End

// update the global string or variable with the same name as ctrlName with either popNum or popStr
Function WMCalibratorSetGlobalFromCtrl(ctrlName,num,str)
	String ctrlName
	Variable num
	String str

	String topGraph= WMCalibratorGraph()
	if( strlen(topGraph) == 0 )
		return 0
	endif
	
	String path= WMCalibratorDF_Var(topGraph,ctrlName)
	SVAR/Z sv= $path
	NVAR/Z vr=$path
	if( SVAR_Exists(sv) )
		sv= str
	elseif( NVAR_Exists(vr) )
		vr= num
	endif
End

Function WMCalibratorCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WMCalibratorSetGlobalFromCtrl(ctrlName,checked,num2str(checked))
End

Function WMCalibratorPositionRadio(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Checkbox upperLeft win=CalibratorPanel, value=stringmatch(ctrlName,"upperLeft")
	Checkbox upperRight win=CalibratorPanel, value=stringmatch(ctrlName,"upperRight")
	Checkbox lowerLeft win=CalibratorPanel, value=stringmatch(ctrlName,"lowerLeft")
	Checkbox lowerRight win=CalibratorPanel, value=stringmatch(ctrlName,"lowerRight")

	String topGraph= WMCalibratorGraph()
	if( strlen(topGraph) == 0 )
		return 0
	endif
	String/G $WMCalibratorDF_Var(topGraph,"orientation") = ctrlName // store name of control clicked last.
End

Function WMCalibratorPresetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String graphName= WMCalibratorGraph()
	WMCalibratorSetPresetLength(graphName,stringmatch(ctrlName,"xNice"))	// isX
End

Function WMCalibratorSetPresetLength(graphName,isX)
	String graphName
	Variable isX
	
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorGraph()
		if( strlen(graphName) == 0 )
			return 0
		endif
	endif
	Variable length= WMCalibratorGetPresetLength(graphName,isX)
	String lengthVarName
	if( isX )
		lengthVarName= "xLength"
	else
		lengthVarName= "yLength"
	endif
	Variable/G $WMCalibratorDF_Var(graphName,lengthVarName) = length
	return length
End

Function WMCalibratorGetPresetLength(graphName,isX)
	String graphName	// must exist
	Variable isX

	String lengthVarName, axisVarName
	if( isX )
		lengthVarName= "xLength"
		axisVarName= "xAxis"
	else
		lengthVarName= "yLength"
		axisVarName= "yAxis"
	endif

	Variable length= 0
	String axes=WMCalibratorAxisList(graphName,isX)// horizontal axes, if any
	String axis= StrVarOrDefault(WMCalibratorDF_Var(graphName,axisVarName),StringFromList(0,axes))
	if( strlen(AxisInfo(graphName, axis)) )	// axis exists
		GetAxis/W=$graphName/Q $axis
		if( V_Flag == 0 ) // axis exists
			length=WMCalibratorNiceNumber(abs(V_max-V_min)/5)
		endif
	endif
	return length
End

Function WMCalibratorEraseButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=CalibratorPanel layer
	WMCalibratorEraseLayer(WMCalibratorGraph(),S_Value)
End


Function WMCalibratorEraseLayer(win, layerName)
	String win, layerName
	
	if( strlen(win) )
		if( WinType(win) == 1 )
			String oldLayerName= WMCalibratorCurrentDrawLayer(win)
			SetDrawLayer/K/W=$win $layerName
			SetDrawLayer/W=$win $oldLayerName
		endif
	endif
End

Function WMCalibratorCreateButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String topGraph= WMCalibratorGraph()
	if( strlen(topGraph) == 0 )
		return 0
	endif
	
	WMNewCalibratorInGraph(topGraph)
End

Function WMNewCalibratorInGraph(graphName)
	String graphName
	
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorGraph()
		if( strlen(graphName) == 0 )
			return 0
		endif
	endif
	if( WinType(graphName) != 1 )
		return 0
	endif
	
	// gather the parameters from the graph's data folder rather than from the controls
	String oldDF= WMCalibratorSetDF(graphName)
	SVAR xAxis, yAxis
	NVAR xBar, yBar
	NVAR xLength, yLength
	SVAR orientation
	NVAR numbers, digits
	NVAR lineRed, lineGreen, lineBlue
	NVAR lineSize
	SVAR layer
	String corner= StrVarOrDefault("corner","upper right")		// old data folder may not have corner
	Variable horizInset=NumVarOrDefault("horizInset",15)	// old data folder may not have insets, either.
	Variable vertInset=NumVarOrDefault("vertInset",15)	// old data folder may not have insets, either.
	String vtrs=StrVarOrDefault("verticalTextRotation","0")	// old data folder may not have vert text rotation, either.
	Variable vtr = str2num(vtrs)
	SetDataFolder oldDF

	String oldLayerName= WMCalibratorCurrentDrawLayer(graphName)
	SetDrawLayer/W=$graphName $layer

	WMNewCalibrator(graphName, xAxis, yAxis,xBar ? xLength : 0,yBar ? yLength : 0,orientation,numbers,digits, lineSize, lineRed, lineGreen, lineBlue,location=corner,horizInset=horizInset,vertInset=vertInset,vertTextRot=vtr)
	
	String hostName= StringFromList(0, graphName, "#")
	// SetDrawLayer/W=$hostName $oldLayerName
	// We want the user to be able to edit the layer the calibrator is in.
	ShowTools/W=$hostName/A arrow
End

Function/S WMCalibratorCurrentDrawLayer(win)
	String win
	
	String layer="UserFront" // graph default
	if( WinType(win) == 7 )	// panel
		layer= "ProgFront"	// panel default
	endif
	String code= WinRecreation(win,4)	// don't revert to normal mode
	Variable lines= ItemsInList(code,"\r")
	Variable line
	for( line=0; line < lines; line+=1)
		String cmd= StringFromList(line,code,"\r")
		// look for a line like "	SetDrawLayer ProgAxes"
		Variable pos=strsearch(cmd,"SetDrawLayer",0)
		if( pos > 0 )
			pos= strsearch(cmd," ",pos)
			layer=cmd[pos+1,999]		// keep going, we get the last (current layer)
		endif	
	endfor
	return layer
End


// Usage:	NVAR foo= $WMCalibratorDF_Var(graphName,varName)
// 			SVAR foo= $WMCalibratorDF_Var(graphName,varName)
Function/S WMCalibratorDF_Var(graphName,varName)
	String graphName,varName
	
	String path= "root:Packages:WMCalibrator:"
	Variable i, n=ItemsInList(graphName,"#")
	for(i=0; i<n; i+=1)
		String dfName= StringFromList(i,graphName,"#")
		if( strlen(dfName) == 0 )
			continue	// handle "Panel0##G0" by skipping the blank part
		endif
		dfName= CleanupName(dfName,0)
		path += dfName+":"
	endfor
	
	return path+varname
End

// returns the old data folder
Function/S WMCalibratorSetDF(graphName)
	String graphName
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorGraph()
		if( strlen(graphName) == 0 )
			graphName= "_default_"
		endif
	endif
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WMCalibrator
	// handle subwindow syntax
	Variable i, n=ItemsInList(graphName,"#")
	for(i=0; i<n; i+=1)
		String dfName= StringFromList(i,graphName,"#")
		if( strlen(dfName) == 0 )
			continue	// handle "Panel0##G0" by skipping the blank part
		endif
		dfName= CleanupName(dfName,0)
		NewDataFolder/O/S $dfName
	endfor
	return oldDF
End

Function WMNewCalibrator(graphName, xaxis,yaxis,dx,dy,orientation,numbers,digits,penSize,red,green,blue[,location,horizInset,vertInset,vertTextRot])
	String graphName
	String xaxis,yaxis
	Variable dx,dy		// bar lengths in axis units
	String orientation	// "upperLeft", etc.
	Variable numbers	// 	menu popup item:"don't print;print without units;print with units;print with units, K, m, etc"
	Variable digits
	Variable penSize
	Variable red,green,blue
	String location		// optional: "upperLeft", etc - where the calibrator is initially created
	Variable horizInset	// optional: offset in percent from left or right
	Variable vertInset	// optional: offset in percent from bottom or top
	Variable vertTextRot	// optional: rotation of vertical text in degrees
	
	if( strlen(graphName) == 0 )
		graphName= WMCalibratorGraph()
		if( strlen(graphName) == 0 )
			return 0
		endif
	endif
	// default is to put calibrator in upper right corner of graph
	if( ParamIsDefault(location) )
		location="upper right"
	endif
	if( ParamIsDefault(horizInset) )
		horizInset = 15
	endif
	if( ParamIsDefault(vertInset) )
		vertInset = 15
	endif
	if( ParamIsDefault(vertTextRot) )
		vertTextRot = 0
	endif

	Variable xorig,yorig	// corner of calibrator
	Variable px,py		// polygon origin
	Variable hx,hy,vx,vy	// text origins
	Variable tmp
	GetAxis/W=$graphName/Q $xaxis		// V_Min is actually the left value, V_Max the right value
	Variable xReversed = V_Max < V_Min	// that is, right value < left value
	if( xReversed )
		dx= -dx
	endif

	Variable offsetBy= (V_max-V_min)*horizInset/100
	strswitch(location)
		case "upper left":
		case "lower left":
			xorig=V_min + offsetBy + dx	// +dx because drawing code below presumes anchor is right side.
			break
		default:	// upper/lower right
			xorig=V_max - offsetBy
			break
	endswitch
	
	GetAxis/W=$graphName/Q $yaxis		// V_Min is actually the bottom value, V_Max the top value
	Variable yReversed = V_Max < V_Min		// that is, top value < bottom value
	if( yReversed )
		dy= -dy
	endif

	offsetBy= (V_max-V_min)*vertInset/100
	strswitch(location)
		case "lower left":
		case "lower right":
			yorig=V_min + offsetBy	+ dy	// +dy because drawing code below presumes anchor is top.
			break
		default:
			yorig=V_max - offsetBy
			break
	endswitch

	GraphNormal/W=$graphName			// Forces deselection
	SetDrawEnv/W=$graphName gstart		// gstart can't be on next line!
	SetDrawEnv/W=$graphName xcoord= $xaxis,ycoord= $yaxis, fillpat=0,linethick=penSize,linefgc=(red,green,blue)
	strswitch(orientation)
		default:
		case "upperLeft":
			xorig -= dx
			hx= xorig + dx/2
			vy= yorig - dy/2
			px= xorig;py=yorig-dy
			DrawPoly/W=$graphName px,py, 1, 1, {0,0,0,dy,dx,dy}
			break
		case "upperRight":
			hx= xorig - dx/2
			vy= yorig - dy/2
			px= xorig-dx;py=yorig
			DrawPoly/W=$graphName px,py, 1, 1, {0,0,dx,0,dx,-dy}
			break
		case "lowerRight":
			yorig -= dy
			hx= xorig - dx/2
			vy= yorig + dy/2
			px= xorig;py=yorig+dy
			DrawPoly/W=$graphName px,py, 1, 1, {0,0,0,-dy,-dx,-dy}
			break
		case "lowerLeft":
			xorig -= dx
			yorig -= dy
			hx= xorig + dx/2
			vy= yorig + dy/2
			px= xorig+dx;py=yorig
			DrawPoly/W=$graphName px,py, 1, 1, {0,0,-dx,0,-dx,dy}
			break
	endswitch
	
	String labelVal,fmt,units
	Variable xj, yj		// x and y text justification
	// horizontal calibrator value
	if( (dx != 0)%& (numbers>1) )		// label == 1 is don't print
		fmt= WMCalibratorNumberFormat(graphName,xaxis,numbers,digits)
		sprintf labelVal, fmt, abs(dx)
		hy = yorig
		yj=0	// bottom
		if( stringmatch(orientation,"lower*") )	// lower* //"upper-left; upper-right;lower-right;lower left;"
			yj= 2		// top
		endif
		SetDrawEnv/W=$graphName xcoord= $xaxis,ycoord= $yaxis,textxjust= 1,textyjust=yj, textrgb=(red,green,blue)
		DrawText/W=$graphName hx,hy, labelVal
	endif
	// vertical calibrator value
	if( (dy != 0)%& (numbers>1) )
		fmt= WMCalibratorNumberFormat(graphName,yaxis,numbers,digits)
		sprintf labelVal, fmt, abs(dy)
		vx= xorig
		
		yj=1	// middle
		xj=0	// left justification
		if( stringmatch(orientation,"*left") )
			xj= 2								//right justification
		endif
		SetDrawEnv/W=$graphName xcoord= $xaxis,ycoord= $yaxis,textxjust= xj,textyjust=yj,textrot=vertTextRot, textrgb=(red,green,blue)
		DrawText/W=$graphName vx,vy, " "+labelVal+" "	// extra spaces to keep label away from line
	endif
	SetDrawEnv/W=$graphName gstop
End

Function/S WMCalibratorNumberFormat(graphName,axis,numbers,digits)
	String graphName,axis
	Variable numbers	// 	menu popup item:"don't print;print without units;print with units;print with units, K, m, etc"
	Variable digits

	String fmt
	sprintf fmt, "%%.%dg", digits		// "%.6g", usually
	
	String units= WMCalibratorAxisUnits(graphName,axis)
		
	if( (numbers== 3) %& (strlen(units)>0) )	// 3 is print with units
		fmt += " "+units
	endif
	if(numbers == 4)				// 4 is print with units and prefixes
		sprintf fmt, "%%.%gW1P%s", digits,units
	endif
	return fmt
End


Function/S WMCalibratorAxisUnits(graphName,axis)
	String graphName
	String axis
	String inf,units=""
	Variable st,en
	
	inf=AxisInfo(graphName,axis)
	st= strsearch(inf,"UNITS:",0)
	if( st >= 0 )
		en= strsearch(inf,";",st)
		if( en > st )
			units=inf[st+6,en-1]
		endif
	endif
	return units
End


// round to 1, 2, or 5 * 10eN, non-rigorously
Function WMCalibratorNiceNumber(num)
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

Function SubwindowPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

End
